# Builds the Rosebay web image set from _src\ into img\.
#
# Two things matter here:
#  1. Rosebay's own Wongnai photographs carry a burnt-in dish caption and a
#     ROSEBAY / HOME COOKING CAFE wordmark across the lower part of the frame.
#     Those duplicate the site's own typography and read as artifacts, so the
#     lower band is cropped away. `cb` = fraction of height cropped off the
#     bottom.
#  2. Their captions are also the most reliable label we have for what each
#     dish photograph actually is — see doc/RESEARCH.md.
param(
  [string]$Src = "$PSScriptRoot\..\_src",
  [string]$Out = "$PSScriptRoot\..\img"
)
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $Out)) { New-Item -ItemType Directory -Force $Out | Out-Null }

# n = destination stem; s = source; max = longest edge; cb = crop off bottom
$plan = @(
  # --- the house
  @{ n='house-front';   s='gm-29.jpg';              max=2000 }
  @{ n='house-wide';    s='gm-28.jpg';              max=1800 }
  @{ n='house-porch';   s='wn-17-04c606a2.jpg';     max=1600; cb=0.12 }
  @{ n='house-door';    s='gm-01.jpg';              max=1600 }
  @{ n='door-pet';      s='gm-27.jpg';              max=1600 }
  @{ n='house-side';    s='wn-15-63bf7c28.jpg';     max=1600; cb=0.12 }
  @{ n='sign-wall';     s='gm-07.jpg';              max=1600 }
  # --- the rooms
  @{ n='room';          s='gm-26.jpg';              max=1800 }
  @{ n='room-2';        s='gm-02.jpg';              max=1600 }
  @{ n='room-3';        s='gm-06.jpg';              max=1600 }
  @{ n='room-garden';   s='wn-11-2b930cb6.jpg';     max=1600; cb=0.12 }
  # --- the kitchen
  @{ n='kitchen';       s='wn-09-8e8dd487.jpg';     max=1800; cb=0.12 }
  @{ n='kitchen-pass';  s='wn-10-8c728510.jpg';     max=1800; cb=0.12 }
  @{ n='kitchen-cook';  s='wn-21-2c934613.jpg';     max=1800; cb=0.12 }
  @{ n='counter';       s='wn-19-e0b8e394.jpg';     max=1600; cb=0.12 }
  @{ n='cabinet';       s='gm-31.jpg';              max=1600 }
  # --- food, labelled by Rosebay's own burnt-in captions, then cropped
  @{ n='kaprao-beef';   s='wn-22-4fc866de.jpg';     max=1600; cb=0.245 }  # "KHAO KAPRAO BEEF TENDERLOIN WITH FRIED EGG"
  @{ n='kaprao-crab';   s='wn-23-a3494578.jpg';     max=1600; cb=0.245 }  # "KHAO KAPRAO CRAB WITH FRIED EGG"
  @{ n='kaprao-mince';  s='wn-24-ef3db22b.jpg';     max=1600; cb=0.245 }  # "KAPRAO FRIED RICE MINCED PORK WITH CRACKLING PORK AND FRIED EGG"
  @{ n='beeffat-rice';  s='wn-25-0f48b7a9.jpg';     max=1600; cb=0.245 }  # "BEEF FAT FRIED RICE & BEEF TENDERLOIN GARLIC WITH CREAMY OMELETTE"
  @{ n='kaprao-wn6';    s='wn-06-c0aa437b.jpg';     max=1600; cb=0.245 }
  @{ n='kaprao-wn7';    s='wn-07-1c956742.jpg';     max=1600; cb=0.245 }
  # --- food, clean guest photographs with nothing burnt in
  @{ n='omelette-beef'; s='gm-09.jpg';              max=1600 }
  @{ n='kaprao-table';  s='gm-18.jpg';              max=1600 }
  @{ n='kaprao-over';   s='gm-24.jpg';              max=1600 }
  @{ n='kaprao-rice';   s='gm-23.jpg';              max=1600 }
  @{ n='friedrice-sau'; s='gm-05.jpg';              max=1600 }
  @{ n='friedrice-tbl'; s='gm-22.jpg';              max=1600 }
  @{ n='crispy-pork';   s='gm-25.jpg';              max=1600 }
  @{ n='pork-bites';    s='gm-19.jpg';              max=1600 }
  @{ n='sweet-fries';   s='gm-11.jpg';              max=1600 }
  @{ n='two-plates';    s='gm-03.jpg';              max=1600 }
  @{ n='chilli';        s='gm-21.jpg';              max=1400 }
  @{ n='espresso';      s='gm-10.jpg';              max=1400 }
  @{ n='menu-card';     s='gm-04.jpg';              max=1600 }
  # --- their own Instagram, straight through
  @{ n='latte';         s='ig-0826-latte.webp';     copy=$true }
  @{ n='coffee';        s='ig-0820-coffee.webp';    copy=$true }
  @{ n='tea';           s='ig-0822-tea.webp';       copy=$true }
  @{ n='bench';         s='ig-0827-bench.webp';     copy=$true }
  @{ n='ig-omelette';   s='ig-0825-omelette.webp';  copy=$true }
  @{ n='ig-eggrice';    s='ig-0821-eggrice.webp';   copy=$true }
  @{ n='ig-plate';      s='ig-0819-plate.webp';     copy=$true }
  @{ n='ig-friedrice';  s='ig-0818-friedrice2.webp';copy=$true }
  @{ n='ig-kaprao';     s='ig-0828-kaprao-egg.jpg'; max=1400 }
  @{ n='ig-rice';       s='ig-0824-friedrice.jpg';  max=1400 }
)

$codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$eps = New-Object Drawing.Imaging.EncoderParameters 1
$eps.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality, 82)

$done = 0; $skipped = @()
foreach ($p in $plan) {
  $in = Join-Path $Src $p.s
  if (-not (Test-Path $in)) { $skipped += $p.s; continue }

  if ($p.copy) {
    Copy-Item $in (Join-Path $Out ($p.n + [IO.Path]::GetExtension($p.s))) -Force
    $done++; continue
  }

  $dest = Join-Path $Out ($p.n + '.jpg')
  $img  = [Drawing.Image]::FromFile($in)
  try {
    $cb = 0.0
    if ($p.ContainsKey('cb')) { $cb = [double]$p.cb }
    $srcH = [int][math]::Round($img.Height * (1.0 - $cb))
    $srcW = $img.Width

    $scale = [math]::Min(1.0, $p.max / [math]::Max($srcW, $srcH))
    $w = [int][math]::Round($srcW * $scale)
    $h = [int][math]::Round($srcH * $scale)

    $bmp = New-Object Drawing.Bitmap $w, $h
    $g   = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode     = [Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($img,
      (New-Object Drawing.Rectangle 0, 0, $w, $h),
      0, 0, $srcW, $srcH,
      [Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $bmp.Save($dest, $codec, $eps)
    $bmp.Dispose()
    $done++
  } finally { $img.Dispose() }
}

Write-Host "wrote $done files"
if ($skipped.Count) { Write-Host "MISSING: $($skipped -join ', ')" }
$total = (Get-ChildItem $Out -File | Measure-Object Length -Sum).Sum
Write-Host ("total {0:N1} MB" -f ($total / 1MB))
