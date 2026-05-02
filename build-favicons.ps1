# ============================================================================
# build-favicons.ps1 – Generiert Bitmap-Favicons via Headless Chrome
# Version: 1.0.0  (2026-05-02)
# ============================================================================

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$chromeCandidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$chrome = $chromeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { Write-Host "Chrome nicht gefunden" -ForegroundColor Red; exit 1 }

$src = (Resolve-Path 'assets\favicon-template.html').Path
$srcUri = "file:///" + ($src -replace '\\', '/')

$outputs = @(
  @{ name='apple-touch-icon.png';        size=180 },
  @{ name='android-chrome-192x192.png';  size=192 },
  @{ name='android-chrome-512x512.png';  size=512 },
  @{ name='favicon-32.png';              size=32  },
  @{ name='favicon-16.png';              size=16  }
)

foreach ($o in $outputs) {
  $out = Join-Path $PSScriptRoot ('assets\img\' + $o.name)
  Write-Host ("→ {0} ({1}×{1})" -f $o.name, $o.size) -ForegroundColor Cyan
  & $chrome `
    --headless=new `
    --disable-gpu `
    --hide-scrollbars `
    "--window-size=$($o.size),$($o.size)" `
    "--screenshot=$out" `
    $srcUri 2>&1 | Out-Null
  if (Test-Path $out) {
    Write-Host ("  ✓ {0:N0} Bytes" -f (Get-Item $out).Length) -ForegroundColor Green
  } else {
    Write-Host "  ✗ FEHLER" -ForegroundColor Red
  }
}

Write-Host ""
Write-Host "Fertig. Im <head> bitte folgende Tags setzen:" -ForegroundColor Cyan
Write-Host '  <link rel="icon" type="image/svg+xml" href="/assets/img/favicon.svg"/>'
Write-Host '  <link rel="icon" type="image/png" sizes="32x32" href="/assets/img/favicon-32.png"/>'
Write-Host '  <link rel="icon" type="image/png" sizes="16x16" href="/assets/img/favicon-16.png"/>'
Write-Host '  <link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png"/>'
Write-Host '  <link rel="manifest" href="/assets/img/site.webmanifest"/>'
