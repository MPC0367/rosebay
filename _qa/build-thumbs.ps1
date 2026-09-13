# Gallery thumbnails: the ribbon shows many photographs at once, so it loads
# small ones. The full-size file in img\ is fetched only when a tile is
# expanded. WebP sources are already small enough to use as they are.
param(
  [string]$Src = "$PSScriptRoot\..\img",
  [string]$Out = "$PSScriptRoot\..\img\g",
  [int]$MaxEdge = 760
)
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $Out)) { New-Item -ItemType Directory -Force $Out | Out-Null }

$names = @(
  'ig-kaprao','kaprao-beef','kaprao-crab','kaprao-mince','kaprao-table',
  'friedrice-sau','friedrice-tbl','crispy-pork','sweet-fries','beeffat-rice',
  'omelette-beef','two-plates','espresso','sign-wall','room','house-wide',
  'kitchen-cook','pork-bites','ig-rice'
)

$codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$eps = New-Object Drawing.Imaging.EncoderParameters 1
$eps.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality, 74)

$n = 0
foreach ($name in $names) {
  $in = Join-Path $Src "$name.jpg"
  if (-not (Test-Path $in)) { Write-Host "skip $name (no jpg)"; continue }
  $dest = Join-Path $Out "$name.jpg"
  $img = [Drawing.Image]::FromFile($in)
  try {
    $scale = [math]::Min(1.0, $MaxEdge / [math]::Max($img.Width, $img.Height))
    $w = [int][math]::Round($img.Width * $scale)
    $h = [int][math]::Round($img.Height * $scale)
    $bmp = New-Object Drawing.Bitmap $w, $h
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, (New-Object Drawing.Rectangle 0, 0, $w, $h))
    $g.Dispose()
    $bmp.Save($dest, $codec, $eps)
    $bmp.Dispose()
    $n++
  } finally { $img.Dispose() }
}
$total = (Get-ChildItem $Out -File | Measure-Object Length -Sum).Sum
Write-Host ("wrote {0} thumbnails, {1:N0} KB total" -f $n, ($total / 1KB))
