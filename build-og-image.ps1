# ============================================================================
# build-og-image.ps1 – Generiert assets/img/og-image.jpg via Headless Chrome
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

$src = (Resolve-Path 'assets\og-image-template.html').Path
$srcUri = "file:///" + ($src -replace '\\', '/')
$out = Join-Path $PSScriptRoot 'assets\img\og-image.png'

Write-Host "→ Generiere og-image..." -ForegroundColor Cyan
& $chrome `
  --headless=new `
  --disable-gpu `
  --hide-scrollbars `
  --window-size=1200,630 `
  "--screenshot=$out" `
  $srcUri 2>&1 | Out-Null

if (Test-Path $out) {
  $size = (Get-Item $out).Length
  Write-Host ("✓ {0} ({1:N0} Bytes)" -f $out, $size) -ForegroundColor Green
  Write-Host "  → Im HTML referenziert als assets/img/og-image.jpg (Pfad in index.html ggf. anpassen wenn .png)"
} else {
  Write-Host "FEHLER beim Erzeugen" -ForegroundColor Red
}
