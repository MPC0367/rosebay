# Minimal static file server for the Rosebay site.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1 [-Port 8335]
param([int]$Port = 8335)

$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "rosebay serving $root on http://localhost:$Port/"

$mime = @{
  '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'
  '.js'='application/javascript; charset=utf-8'; '.json'='application/json; charset=utf-8'
  '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.png'='image/png'; '.webp'='image/webp'
  '.avif'='image/avif'; '.svg'='image/svg+xml'; '.ico'='image/x-icon'
  '.woff2'='font/woff2'; '.mp4'='video/mp4'; '.txt'='text/plain; charset=utf-8'
  '.webmanifest'='application/manifest+json'
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ($rel -eq '') { $rel = 'index.html' }
    $path = Join-Path $root $rel
    if ((Test-Path $path -PathType Container)) { $path = Join-Path $path 'index.html' }
    if (-not (Test-Path $path -PathType Leaf) -and -not [IO.Path]::HasExtension($path)) {
      $path = "$path.html"
    }
    if (Test-Path $path -PathType Leaf) {
      $ext = [IO.Path]::GetExtension($path).ToLower()
      $ctx.Response.ContentType = $(if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' })
      $ctx.Response.Headers.Add('Cache-Control', 'no-store')
      $bytes = [IO.File]::ReadAllBytes($path)
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $b = [Text.Encoding]::UTF8.GetBytes('404')
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
    }
    $ctx.Response.OutputStream.Close()
  } catch {
    Write-Host "err: $($_.Exception.Message)"
  }
}
