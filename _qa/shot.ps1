# Headless Edge screenshots of the Rosebay site.
#
# The in-app Browser pane reports a zero-size viewport whenever it is hidden,
# which makes every JS measurement useless (and svh resolve to 0). This is the
# reliable path for layout QA.
#
#   .\shot.ps1 -Page index -Y 1500 -W 1470 -H 900 -Name hero
#   .\shot.ps1 -Page menu -To '%23cat-kaprao' -Lang th
#   .\shot.ps1 -Page index -Mobile          # wraps the site in a 390x844 iframe
param(
  [string]$Page   = 'index',
  [int]$Y         = 0,
  [string]$To     = '',
  [string]$Lang   = '',
  [int]$W         = 1470,   # window chrome eats ~30px; 1470 gives a 1440 viewport
  [int]$H         = 900,
  [string]$Name   = '',
  [switch]$Mobile,
  [switch]$Sheet,
  [switch]$Probe,
  [string]$Swipe   = '',
  [int]$MobileW   = 390,
  [int]$MobileH   = 844
)

$root  = Split-Path $PSScriptRoot -Parent
$out   = Join-Path $PSScriptRoot 'shots'
$prof  = Join-Path $env:TEMP 'rosebay-edge'
$edge  = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { $edge = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Force $out | Out-Null }

$qs = "shot=1"
if ($Y -gt 0)   { $qs += "&y=$Y" }
if ($To)        { $qs += "&to=$To" }
if ($Lang)      { $qs += "&lang=$Lang" }
if ($Sheet)     { $qs += "&sheet=1" }
if ($Swipe)     { $qs += "&swipe=$Swipe" }
if ($Probe)     { $qs += "&probe=1" }

$url = "http://localhost:8335/$Page.html?$qs"

if (-not $Name) {
  $Name = $Page
  if ($Y)      { $Name += "-y$Y" }
  if ($To)     { $Name += "-" + ($To -replace '[^a-zA-Z0-9]', '') }
  if ($Lang)   { $Name += "-$Lang" }
  if ($Sheet)  { $Name += "-sheet" }
  if ($Mobile) { $Name += "-m" }
}
$png = Join-Path $out "$Name.png"

if ($Mobile) {
  # Headless Edge silently clamps the window to ~492px wide, which crops the
  # PNG and looks exactly like a horizontal-overflow bug. Wrap the real page
  # in an iframe at the true device size instead.
  $wrap = Join-Path $root '_qa\frame.html'
  $html = @"
<!doctype html><meta charset="utf-8"><title>frame</title>
<style>html,body{margin:0;background:#3a3a3a}
iframe{width:${MobileW}px;height:${MobileH}px;border:0;display:block;margin:0 auto;background:#fff}</style>
<iframe src="$url"></iframe>
"@
  Set-Content -Path $wrap -Value $html -Encoding utf8
  $target = "http://localhost:8335/_qa/frame.html"
  $W = $MobileW + 110
  $H = $MobileH + 36
} else {
  $target = $url
}

& $edge --headless=new --disable-gpu --no-first-run --no-default-browser-check `
  --user-data-dir="$prof" --hide-scrollbars --force-device-scale-factor=1 `
  --window-size="$W,$H" --screenshot="$png" --virtual-time-budget=6000 $target 2>$null | Out-Null

if (Test-Path $png) {
  $kb = [math]::Round((Get-Item $png).Length / 1KB)
  Write-Host "$png  ($kb KB)  <- $url"
} else {
  Write-Host "FAILED: no png written for $url"
}
