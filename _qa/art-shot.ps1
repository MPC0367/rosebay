# Screenshots the built artifact (routes live behind the hash).
param([string]$Hash='', [int]$Y=0, [int]$W=1470, [int]$H=1000, [string]$Name='art')
$edge='C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { $edge='C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
$out = Join-Path $PSScriptRoot 'shots'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Force $out | Out-Null }
$png = Join-Path $out "$Name.png"
$qs = 'shot=1'
if ($Y -gt 0) { $qs += "&y=$Y" }
$url = "http://localhost:8335/_qa/rosebay-artifact.html?$qs"
if ($Hash) { $url += "#$Hash" }
& $edge --headless=new --disable-gpu --no-first-run --user-data-dir="$env:TEMP\rosebay-edge" `
  --hide-scrollbars --force-device-scale-factor=1 --window-size="$W,$H" `
  --virtual-time-budget=9000 --screenshot="$png" $url 2>$null | Out-Null
if (Test-Path $png) { Write-Host "$png ($([math]::Round((Get-Item $png).Length/1KB)) KB) <- $url" } else { Write-Host "FAILED $url" }
