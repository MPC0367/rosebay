# Captures the loading veil held open, at a given progress.
param([string]$P = '0.62', [int]$W = 1470, [int]$H = 900, [string]$Name = 'veil')
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { $edge = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
$out = Join-Path $PSScriptRoot 'shots'
$prof = Join-Path $env:TEMP 'rosebay-edge'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Force $out | Out-Null }
$png = Join-Path $out "$Name.png"
$url = "http://localhost:8335/index.html?shot=1&veil=hold&p=$P"
& $edge --headless=new --disable-gpu --no-first-run --user-data-dir="$prof" --hide-scrollbars `
  --force-device-scale-factor=1 --window-size="$W,$H" --virtual-time-budget=6000 `
  --screenshot="$png" $url 2>$null | Out-Null
if (Test-Path $png) { Write-Host "$png ($([math]::Round((Get-Item $png).Length/1KB)) KB)" } else { Write-Host "FAILED" }
