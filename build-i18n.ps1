# ============================================================================
# build-i18n.ps1 – Generiert statische Sprach-Subdirs aus DE-Master
#
# Version: 1.0.0  (2026-05-02)
# Autor:   Andreas Grundke – Grundke IT-Service
#
# Funktionsweise:
#   - Liest website/index.html (DE-Master)
#   - Extrahiert translations-Objekt aus dem JS-Block
#   - Pro non-DE Sprache (en/pl/hr):
#       1. Setzt <html lang>
#       2. Setzt canonical, og:url, og:locale auf Sub-URL
#       3. Ersetzt title + meta description (hardcoded pro Sprache)
#       4. Ersetzt alle data-i18n="key">…</tag> mit übersetztem Inhalt
#       5. Stellt Lang-Switcher .act-Klasse korrekt
#       6. Macht relative Pfade (assets/, impressum.html, etc.) absolut
#   - Schreibt nach website/{en|pl|hr}/index.html
#
# Aufruf (aus website/-Ordner):
#   PS> .\build-i18n.ps1
# ============================================================================

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$src = 'index.html'
if (-not (Test-Path $src)) { Write-Host "FEHLER: $src nicht gefunden" -ForegroundColor Red; exit 1 }

# ---------- Title + Description pro Sprache (hardcoded) ----------
$titleByLang = @{
  en = "Violetta Schröer – Tax Specialist (IHK) Grasbrunn nr Munich · Accounting, Payroll, Construction Wages"
  pl = "Violetta Schröer – Specjalistka podatkowa Grasbrunn k. Monachium · Księgowość, płace, płace budowlane"
  hr = "Violetta Schröer – Porezna stručnjakinja Grasbrunn kraj Münchena · Knjigovodstvo, plaće, građevinske plaće"
}
$descByLang = @{
  en = "Certified tax specialist (IHK) in Grasbrunn near Munich. Personal financial accounting, payroll, construction wages and office services. Over 20 years of experience. Multilingual DE/EN/PL/HR."
  pl = "Certyfikowana specjalistka podatkowa (IHK) w Grasbrunn k. Monachium. Osobista księgowość finansowa, płace, płace budowlane i usługi biurowe. Ponad 20 lat doświadczenia. Wielojęzycznie DE/EN/PL/HR."
  hr = "Ovlaštena porezna stručnjakinja (IHK) u Grasbrunnu kraj Münchena. Osobno financijsko knjigovodstvo, plaće, građevinske plaće i uredske usluge. Više od 20 godina iskustva. Višejezično DE/EN/PL/HR."
}
$ogLocaleByLang = @{ en = 'en_US'; pl = 'pl_PL'; hr = 'hr_HR' }

# ---------- Master einlesen ----------
$master = Get-Content $src -Raw

# ---------- Translations extrahieren aus dem JS-Block ----------
# Strategie: finde "  en: { … }," Block, dann key:"value" pro Zeile
function Extract-LangBlock([string]$content, [string]$lang) {
  # Pattern: "lang: {" ... "  }," oder "  }" am Ende
  $pattern = "(?ms)\b" + $lang + ":\s*\{(.+?)\}\s*[,}]"
  $m = [regex]::Match($content, $pattern)
  if (-not $m.Success) { Write-Host "Kein Block fuer Sprache '$lang' gefunden" -ForegroundColor Yellow; return @{} }
  return $m.Groups[1].Value
}

function Parse-Translations([string]$block) {
  # key:"value" – value kann \" enthalten
  $h = @{}
  $rx = [regex]'(?ms)\b(\w+)\s*:\s*"((?:[^"\\]|\\.)*)"'
  foreach ($m in $rx.Matches($block)) {
    $key = $m.Groups[1].Value
    $val = $m.Groups[2].Value
    # Unescape JS string escapes
    $val = $val -replace '\\"', '"'
    $val = $val -replace "\\\\", '\'
    $val = $val -replace '\\n', "`n"
    $h[$key] = $val
  }
  return $h
}

$translations = @{}
foreach ($lang in 'en','pl','hr') {
  $block = Extract-LangBlock $master $lang
  $translations[$lang] = Parse-Translations $block
  Write-Host "Sprache '$lang': $($translations[$lang].Count) Keys extrahiert"
}

# ---------- Pro Sprache HTML generieren ----------
foreach ($lang in 'en','pl','hr') {
  $c = $master

  # 1) <html lang>
  $c = $c -replace '<html lang="de">', "<html lang=""$lang"">"

  # 2) canonical (nur erste Stelle, sicher mit Backreference)
  $c = $c -replace '<link rel="canonical" href="https://schroeer-office\.de/"\s*/>', "<link rel=""canonical"" href=""https://schroeer-office.de/$lang/""/>"

  # 3) og:url
  $c = $c -replace '<meta property="og:url" content="https://schroeer-office\.de/"\s*/>', "<meta property=""og:url"" content=""https://schroeer-office.de/$lang/""/>"

  # 4) og:locale
  $c = $c -replace '<meta property="og:locale" content="de_DE"\s*/>', "<meta property=""og:locale"" content=""$($ogLocaleByLang[$lang])""/>"

  # 5) Title
  $newTitle = $titleByLang[$lang]
  $c = [regex]::Replace($c, '<title>[^<]+</title>', "<title>$newTitle</title>", 'IgnoreCase')

  # 6) meta description (Haupt-description, nicht og:description)
  $newDesc = $descByLang[$lang]
  $c = [regex]::Replace($c, '(<meta name="description" content=")[^"]+(")', "`$1$newDesc`$2")
  $c = [regex]::Replace($c, '(<meta property="og:title" content=")[^"]+(")', "`$1$newTitle`$2")
  $c = [regex]::Replace($c, '(<meta property="og:description" content=")[^"]+(")', "`$1$newDesc`$2")

  # 7) Lang-Switcher: act umsetzen
  # DE: 'class="act" ' raus
  $c = $c -replace 'href="/" data-lang="de" class="act" ', 'href="/" data-lang="de" '
  # Aktuelle Sprache: act rein
  $c = $c -replace "href=""/$lang/"" data-lang=""$lang"" hreflang=""$lang""", "href=""/$lang/"" data-lang=""$lang"" class=""act"" hreflang=""$lang"""

  # 8) data-i18n Replacements
  # Pattern: data-i18n="key">CONTENT</tag>
  # CONTENT kann auch "« … » enthalten, aber kein < (weil dann kein TextNode)
  foreach ($key in $translations[$lang].Keys) {
    $val = $translations[$lang][$key]
    # HTML-escape minimal (nur &)
    $valEscaped = $val -replace '&(?!\w+;)', '&amp;'
    $pattern = '(data-i18n="' + [regex]::Escape($key) + '">)[^<]*'
    $c = [regex]::Replace($c, $pattern, "`${1}$valEscaped")
  }

  # 9) Relative Pfade absolut machen (wegen Subdir-Verschachtelung)
  $c = $c -replace '(\s)(src|href)="(assets/)', "`$1`$2=""/$3"
  $c = $c -replace '(href)="(impressum\.html|datenschutz\.html|visitenkarte\.html)"', "`$1=""/`$2"""

  # 10) Output schreiben
  $outDir = Join-Path $PSScriptRoot $lang
  if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
  $outFile = Join-Path $outDir 'index.html'
  Set-Content -Path $outFile -Value $c -NoNewline -Encoding UTF8

  $size = (Get-Item $outFile).Length
  Write-Host ("✓ {0}/index.html geschrieben ({1} bytes)" -f $lang, $size)
}

Write-Host ""
Write-Host "Fertig. Sprach-Subdirs:"
Get-ChildItem -Directory $PSScriptRoot | Where-Object { $_.Name -in 'en','pl','hr' } | ForEach-Object {
  Write-Host "  /$($_.Name)/index.html"
}
