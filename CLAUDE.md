# CLAUDE.md — Website VSO 2026 (schroeer-office.de)

> Teil des Workspace `00_KI_Work` · Strang **02_GIT** · Router + globaler Kontext: Root-Master `00_KI_Work\CLAUDE.md` (§0 Projekt-Router).
> **Dieses Repo ist oeffentlich** — keine Kundeninterna, Preise oder Zugaenge hier ablegen.

## Zweck
Website der Kundin Violetta Schroeer — Office Dienstleistungen, Steuerfachwirtin (IHK) in
Grasbrunn bei Muenchen. Statischer OnePager in vier Sprachen (DE/EN/PL/HR), Ziel ist die
Gewinnung lokaler Buchhaltungs- und Lohnmandate.

## Stack / Technik
Vanilla HTML + CSS + JS, kein Framework. GitHub Pages aus `main`, Domain per CNAME.
Sprachversionen unter `/en/`, `/pl/`, `/hr/` werden aus `index.html` **generiert**
(`build-i18n.ps1`) — dort nie von Hand editieren. Vorschaubild ebenfalls generiert
(`build-og-image.ps1` aus `assets/og-image-template.html`).

**Nach jeder Aenderung an `index.html`:** `.\build-i18n.ps1` → commit → push → live pruefen.
Bei reinen CSS-, JS- oder Bildaenderungen entfaellt der Build.

## Stand / offen / naechster Schritt
- **Stand:** 22.09.2026 — Portraetfoto der Kundin im Bereich "Ueber mich" und in den
  strukturierten Daten, neues Vorschaubild mit Portrait. Zwei Altlasten behoben: About-Fotos
  waren unter 980px Breite unsichtbar, und in den Sprachversionen liefen alle
  Inline-Hintergrundbilder auf 404.
- **Offen:** Off-Site-Sichtbarkeit — Google Unternehmensprofil fehlt, Verzeichniseintraege
  tragen einen falschen Vornamen ("Wioletta"/"Violatta").
- **Naechster Schritt:** Unternehmensprofil anlegen und die Verzeichnisdaten korrigieren.

## Wissen zum Projekt
Fachwissen, Fallstricke und der Sichtbarkeitsstand liegen **ausserhalb dieses Repos** im
Kundenordner: `02_GIT\kunden\VSO 2026\docs\wiki\` (Index: `README.md`), Umsetzungs-Runbooks
in `02_GIT\kunden\VSO 2026\docs\`.

*CI 2026.01 · Grundke IT-Service · www.grundke-it.de*
