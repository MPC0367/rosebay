# Downloads images listed in a manifest JSON ({name,u}) into _src\
# Usage: powershell -File fetch-manifest.ps1 -Manifest _qa\ig-manifest.json
param(
  [string]$Manifest = "$PSScriptRoot\ig-manifest.json",
  [string]$Out      = "$PSScriptRoot\..\_src"
)
$ErrorActionPreference = 'Continue'
if (-not (Test-Path $Out)) { New-Item -ItemType Directory -Force $Out | Out-Null }

$json  = Get-Content -Raw -Encoding UTF8 $Manifest
$items = $json | ConvertFrom-Json

$hdr = @{
  'User-Agent'      = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0 Safari/537.36'
  'Accept'          = 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8'
  'Accept-Language' = 'en-US,en;q=0.9'
}

foreach ($it in $items) {
  # Extension comes from the CDN path, not the query string
  $path = ([Uri]$it.u).AbsolutePath
  $ext  = [IO.Path]::GetExtension($path)
  if ([string]::IsNullOrWhiteSpace($ext)) { $ext = '.jpg' }
  $dest = Join-Path $Out ($it.name + $ext)
  if (Test-Path $dest) { Write-Host "skip  $($it.name)$ext"; continue }
  try {
    Invoke-WebRequest -Uri $it.u -Headers $hdr -OutFile $dest -TimeoutSec 60 -UseBasicParsing
    $kb = [math]::Round((Get-Item $dest).Length / 1KB)
    Write-Host ("ok    {0}{1}  {2} KB" -f $it.name, $ext, $kb)
  } catch {
    Write-Host ("FAIL  {0}  {1}" -f $it.name, $_.Exception.Message)
    if (Test-Path $dest) { Remove-Item $dest -Force }
  }
}
Write-Host "--- done. files in $Out :"
Get-ChildItem $Out | Select-Object Name, @{n='KB';e={[math]::Round($_.Length/1KB)}} | Format-Table -AutoSize
