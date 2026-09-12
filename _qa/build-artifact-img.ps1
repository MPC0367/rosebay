# Re-encodes every image the artifact actually references into _qa\aimg\ at
# artifact sizes. The published page carries its images as base64, which
# inflates them by a third against a 16 MB ceiling, so the site's own img\
# set is far too heavy to inline as-is.
param(
  [string]$Root = "$PSScriptRoot\..",
  [string]$Out  = "$PSScriptRoot\aimg",
  [string]$List = "$PSScriptRoot\used.txt"
)
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }
New-Item -ItemType Directory -Force $Out | Out-Null

$codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
function Save-Jpg($bmp, $path, $q) {
  $eps = New-Object Drawing.Imaging.EncoderParameters 1
  $eps.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality, $q)
  $bmp.Save($path, $codec, $eps)
}

$refs = Get-Content $List | Where-Object { $_.Trim() }
$done = 0; $skipped = @()

foreach ($rel in $refs) {
  $src = Join-Path $Root $rel
  if (-not (Test-Path $src)) { $skipped += $rel; continue }

  # flatten img/g/name.jpg -> g__name.jpg so one folder holds everything
  $flat = ($rel -replace '^img/', '' -replace '/', '__')
  $dest = Join-Path $Out $flat

  # WebP cannot be re-encoded here, and these are already small
  if ($rel -match '\.webp$') { Copy-Item $src $dest -Force; $done++; continue }

  # the hero carries the first impression, the gallery thumbs are seen at
  # ~300px, everything else sits between
  $max = 1180; $q = 68
  if ($rel -match 'house-front')  { $max = 1500; $q = 70 }
  elseif ($rel -match '^img/g/')  { $max = 470;  $q = 62 }
  elseif ($rel -match 'menu-card'){ $max = 1300; $q = 72 }  # it has to stay readable

  $img = [Drawing.Image]::FromFile($src)
  try {
    $scale = [math]::Min(1.0, $max / [math]::Max($img.Width, $img.Height))
    $w = [int][math]::Round($img.Width * $scale)
    $h = [int][math]::Round($img.Height * $scale)
    $bmp = New-Object Drawing.Bitmap $w, $h
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode     = [Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($img, (New-Object Drawing.Rectangle 0, 0, $w, $h))
    $g.Dispose()
    Save-Jpg $bmp $dest $q
    $bmp.Dispose()
    $done++
  } finally { $img.Dispose() }
}

$raw = (Get-ChildItem $Out -File | Measure-Object Length -Sum).Sum
Write-Host ("$done files, {0:N0} KB raw, ~{1:N0} KB as base64" -f ($raw/1KB), ($raw*4/3/1KB))
if ($skipped.Count) { Write-Host "MISSING: $($skipped -join ', ')" }
