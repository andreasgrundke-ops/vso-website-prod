# ============================================================================
# setup.ps1 – Onboarding auf neuem PC für VSO-Website-Arbeit
#
# Version: 1.0.0  (2026-05-02)
# Autor:   Andreas Grundke – Grundke IT-Service
#
# Funktion:
#   - Prüft Voraussetzungen (git, gh, chrome)
#   - Klont das Repo (oder pullt, falls schon da)
#   - Zeigt nächste Schritte (Editor öffnen, deploy.ps1 nutzen)
#
# Aufruf auf neuem PC:
#   PS> iwr https://raw.githubusercontent.com/andreasgrundke-ops/vso-website-prod/main/setup.ps1 -OutFile setup.ps1
#   PS> .\setup.ps1
#
# Oder: Repo schon geklont? Dann reicht .\setup.ps1 zur Voraussetzungs-Prüfung.
# ============================================================================

$ErrorActionPreference = 'Continue'
$repo  = 'andreasgrundke-ops/vso-website-prod'
$dir   = 'vso-website-prod'

Write-Host "=== VSO Website Setup ===" -ForegroundColor Cyan
Write-Host ""

# 1) Tools prüfen
function Test-Tool([string]$cmd, [string]$installHint) {
  $found = Get-Command $cmd -ErrorAction SilentlyContinue
  if ($found) {
    $ver = & $cmd --version 2>&1 | Select-Object -First 1
    Write-Host "✓ $cmd : $ver" -ForegroundColor Green
    return $true
  } else {
    Write-Host "✗ $cmd fehlt — $installHint" -ForegroundColor Red
    return $false
  }
}

$ok = $true
$ok = (Test-Tool 'git'  'https://git-scm.com/download/win') -and $ok
$ok = (Test-Tool 'gh'   'https://cli.github.com')           -and $ok
# Chrome ist Pflicht für build-pdf / build-og-image / build-favicons
$chromePaths = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$chromeFound = $chromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($chromeFound) {
  Write-Host "✓ Chrome: $chromeFound" -ForegroundColor Green
} else {
  Write-Host "✗ Chrome fehlt — https://www.google.com/chrome/" -ForegroundColor Red
  $ok = $false
}

if (-not $ok) {
  Write-Host ""
  Write-Host "Bitte fehlende Tools installieren, dann setup.ps1 erneut ausführen." -ForegroundColor Yellow
  exit 1
}

# 2) gh-Auth prüfen
Write-Host ""
Write-Host "→ GitHub-Auth prüfen..." -ForegroundColor Cyan
$auth = gh auth status 2>&1 | Select-String 'Logged in'
if (-not $auth) {
  Write-Host "  Nicht eingeloggt. Starte Login..." -ForegroundColor Yellow
  gh auth login
} else {
  Write-Host "  ✓ Eingeloggt" -ForegroundColor Green
}

# 3) Repo holen oder updaten
Write-Host ""
if (Test-Path $dir) {
  Write-Host "→ Repo '$dir' existiert lokal — pulle..." -ForegroundColor Cyan
  Set-Location $dir
  git pull
} else {
  Write-Host "→ Klone Repo '$repo'..." -ForegroundColor Cyan
  gh repo clone $repo $dir
  Set-Location $dir
}

# 4) Sub-Sprach-Subdirs vorhanden?
$subdirsOk = (Test-Path 'en/index.html') -and (Test-Path 'pl/index.html') -and (Test-Path 'hr/index.html')
if (-not $subdirsOk) {
  Write-Host ""
  Write-Host "→ Sprach-Subdirs fehlen — baue sie..." -ForegroundColor Cyan
  & .\build-i18n.ps1
}

# 5) Status-Übersicht
Write-Host ""
Write-Host "=== Repo bereit ===" -ForegroundColor Green
Write-Host ""
Write-Host "Verzeichnis: $(Get-Location)"
$tag = git describe --tags --abbrev=0 2>$null
if ($tag) { Write-Host "Letzter Tag: $tag" }
$last = git log -1 --pretty=format:'%h %s (%ar)' 2>$null
if ($last) { Write-Host "Letzter Commit: $last" }

Write-Host ""
Write-Host "Nächste Schritte:" -ForegroundColor Cyan
Write-Host "  1. Editor öffnen: code . (VS Code)"
Write-Host "  2. index.html oder andere Files bearbeiten"
Write-Host "  3. Deploy: .\deploy.ps1 ""Commit-Message"""
Write-Host "     (erkennt index.html-Diff, baut Sub-Sprachen, committet, pusht)"
Write-Host ""
Write-Host "Wichtige Skripte:"
Write-Host "  .\deploy.ps1            – Ein-Klick-Deploy (build + commit + push)"
Write-Host "  .\build-i18n.ps1        – Nur Sub-Sprachen regenerieren"
Write-Host "  .\build-og-image.ps1    – og-image.png aus Template rendern"
Write-Host "  .\build-favicons.ps1    – Bitmap-Favicons rendern"
Write-Host "  ..\visitenkarte\build-pdf.ps1  – Druck-PDFs für Vistaprint"
Write-Host ""
Write-Host "Live-URLs:" -ForegroundColor Green
Write-Host "  https://andreasgrundke-ops.github.io/vso-website-prod/"
Write-Host "  https://andreasgrundke-ops.github.io/vso-website-prod/en/ pl/ hr/"
Write-Host "  https://andreasgrundke-ops.github.io/vso-website-prod/visitenkarte.html"
Write-Host "  https://andreasgrundke-ops.github.io/vso-website-prod/projekt.html (intern)"
