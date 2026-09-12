# Runs the in-page layout probe under headless Edge and prints its report:
# horizontal overflow offenders and WCAG-AA contrast failures.
#   .\probe.ps1 -Page index -W 1470
#   .\probe.ps1 -Page menu -W 400 -H 900
param(
  [string[]]$Pages = @('index', 'menu', 'home', 'visit'),
  [int]$W = 1470,
  [int]$H = 900,
  [string]$Lang = ''
)
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { $edge = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
$prof = Join-Path $env:TEMP 'rosebay-edge-probe'

foreach ($p in $Pages) {
  $qs = "shot=1&probe=1"
  if ($Lang) { $qs += "&lang=$Lang" }
  $url = "http://localhost:8335/$p.html?$qs"
  $dom = & $edge --headless=new --disable-gpu --no-first-run --no-default-browser-check `
    --user-data-dir="$prof" --hide-scrollbars --force-device-scale-factor=1 `
    --window-size="$W,$H" --virtual-time-budget=7000 --dump-dom $url 2>$null

  $joined = ($dom -join "`n")
  $m = [regex]::Match($joined, '<div id="probe-out"[^>]*>(.*?)</div>', 'Singleline')
  if ($m.Success) {
    $json = [System.Web.HttpUtility]::HtmlDecode($m.Groups[1].Value)
    Write-Host "== $p @ ${W}px" -ForegroundColor Cyan
    Write-Host $json
  } else {
    Write-Host "== $p @ ${W}px : no probe output" -ForegroundColor Yellow
  }
}
