# ============================================================================
# deploy.ps1 – Ein-Klick-Deploy für VSO-Website
#
# Version: 1.0.0  (2026-05-02)
# Autor:   Andreas Grundke – Grundke IT-Service
#
# Funktionsweise:
#   1. Prüft, ob index.html geändert ist → wenn ja: build-i18n.ps1 ausführen
#   2. git add -A
#   3. git commit (Message als Parameter oder interaktiv)
#   4. git push (+ tags wenn vorhanden)
#   5. Wartet auf GitHub-Pages-Build, gibt Live-URL aus
#
# Aufruf:
#   PS> .\deploy.ps1 "Hero-Texte gefeintuned"
#   PS> .\deploy.ps1                            # fragt nach Message
#   PS> .\deploy.ps1 "Bug-Fix" -Tag v2.3.1      # mit neuem Git-Tag
# ============================================================================
param(
  [string]$Message = "",
  [string]$Tag = ""
)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

# 1) Status prüfen
$status = git status --porcelain
if (-not $status) {
  Write-Host "Nichts zu committen — Working Tree ist clean." -ForegroundColor Yellow
  exit 0
}

# 2) Build, wenn index.html im Diff ist
$indexChanged = git status --porcelain | Where-Object { $_ -match '\b(M|A|R|MM)\s+index\.html' -or $_ -match '\bindex\.html$' }
if ($indexChanged) {
  Write-Host "→ index.html wurde geändert — baue Sub-Sprachen neu..." -ForegroundColor Cyan
  & .\build-i18n.ps1
  if ($LASTEXITCODE -ne 0) { Write-Host "FEHLER beim Build" -ForegroundColor Red; exit 1 }
} else {
  Write-Host "→ index.html unverändert — kein Build nötig" -ForegroundColor Gray
}

# 3) Message holen
if (-not $Message) {
  $Message = Read-Host "Commit-Message"
  if (-not $Message) { Write-Host "Abgebrochen — keine Message." -ForegroundColor Red; exit 1 }
}

# 4) Stage + Commit + Push
git add -A
git commit -m "$Message"
if ($LASTEXITCODE -ne 0) { Write-Host "FEHLER beim Commit" -ForegroundColor Red; exit 1 }

if ($Tag) {
  git tag $Tag
  Write-Host "→ Tag '$Tag' gesetzt" -ForegroundColor Cyan
}

Write-Host "→ Push..." -ForegroundColor Cyan
git push
if ($Tag) { git push --tags }

# 5) Pages-Build abwarten + URL ausgeben
Write-Host ""
Write-Host "→ Warte auf Pages-Build (max. 60 s)..." -ForegroundColor Cyan
$tries = 0
while ($tries -lt 12) {
  Start-Sleep -Seconds 5
  $tries++
  $st = gh api repos/andreasgrundke-ops/vso-website-prod/pages 2>$null | ConvertFrom-Json
  if ($st.status -eq 'built') {
    Write-Host "✓ Pages built ($($tries * 5)s)" -ForegroundColor Green
    break
  }
}

Write-Host ""
Write-Host "Live-URLs:" -ForegroundColor Green
Write-Host "  DE: https://andreasgrundke-ops.github.io/vso-website-prod/"
Write-Host "  EN: https://andreasgrundke-ops.github.io/vso-website-prod/en/"
Write-Host "  PL: https://andreasgrundke-ops.github.io/vso-website-prod/pl/"
Write-Host "  HR: https://andreasgrundke-ops.github.io/vso-website-prod/hr/"
Write-Host "  VC: https://andreasgrundke-ops.github.io/vso-website-prod/visitenkarte.html"
Write-Host "  Projekt-Doku: https://andreasgrundke-ops.github.io/vso-website-prod/projekt.html"
