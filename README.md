# Violetta Schröer – Website (Produktion)

Statischer OnePager mit i18n DE/EN/PL/HR. Vanilla HTML/CSS/JS, kein Build-Tool.
Deployed auf **GitHub Pages**, Custom Domain `violetta-schroeer.de` via IONOS-DNS.

CI 2026.01 · Navy + Gold · Cormorant Garamond + Inter

## Dateien

| Datei | Zweck |
|---|---|
| `index.html` | OnePager – alles inline (CSS, JS, i18n-Translations). |
| `impressum.html` | Pflichtangaben § 5 TMG. |
| `datenschutz.html` | DSGVO-Datenschutzerklärung (GitHub-Pages-Hosting + Google Fonts + Maps berücksichtigt). |
| `404.html` | Fehlerseite im Navy-Hero-Look. |
| `robots.txt` | Erlaubt alle Crawler inkl. AI (GPTBot, Google-Extended, ClaudeBot, PerplexityBot). |
| `sitemap.xml` | URL-Karte für Search Engines, mit hreflang. |
| `CNAME` | GitHub-Pages Custom-Domain-Marker (`violetta-schroeer.de`). |
| `.nojekyll` | Schaltet Jekyll auf GitHub Pages aus (verhindert Probleme mit `_`-Verzeichnissen). |
| `assets/img/` | Logo, Portrait, Hero-Bilder. |
| `DEPLOY.md` | Deploy-Anleitung Schritt-für-Schritt (GitHub Pages + IONOS-DNS). |

## Lokal laufen lassen

```powershell
cd "C:\Users\mail\Claude_Cowork\04_Kunden\VSO 2026\website"
python -m http.server 8000
# → http://localhost:8000/
```

Oder schlichtweg `index.html` per Doppelklick im Browser öffnen (i18n + Lucide funktionieren auch ohne Webserver).

## Sprachversionen testen

```
http://localhost:8000/?lang=de    (Standard)
http://localhost:8000/?lang=en
http://localhost:8000/?lang=pl
http://localhost:8000/?lang=hr
```

## Inhalte ändern

**Texte (alle Sprachen):** im `<script>`-Block am Ende der `index.html`. Suche das `translations`-Objekt. Jede Sprache hat den gleichen Schlüssel-Satz.

**Layout/Farben:** im `<style>`-Block. Custom Properties am Anfang (`:root { --navy:#1d4e6b; --gold:#c49a45; ... }`).

**Bilder:** `assets/img/`. Formate ohne Bedacht ändern – `<img>` hat `width`/`height` für CLS.

## Schema.org / GEO-Optimierung

Drei JSON-LD-Blöcke im `<head>`:
1. **AccountingService + LocalBusiness** – Hauptentität mit Adresse, Geo, Öffnungszeiten, Service-Catalog
2. **Person** – Violetta Schröer mit IHK-Credential
3. **FAQPage** – 7 typische Kundenfragen, parallel zur sichtbaren FAQ-Sektion → wichtig für AI-Suche (ChatGPT, Perplexity, Google AI Mode)

## Deployment

Siehe **DEPLOY.md**.

## Versionierung

Jeder Push auf `main` ist live in ~30 Sekunden. Rollback per:
```bash
git revert HEAD
git push
```
Oder zu einem Tag zurück:
```bash
git checkout v1.0.0
```

Tags werden vor jedem produktiven Push gesetzt (siehe DEPLOY.md).

## Änderungen mit der Kundin

1. Änderungswunsch in HTML/CSS umsetzen
2. Lokal testen (`python -m http.server 8000`)
3. `git commit -m "..."` + `git push` → Live nach ~30 s
4. Kundin checkt unter https://andreasgrundke-ops.github.io/vso-website-prod/ (vor DNS-Umstellung) bzw. https://violetta-schroeer.de/ (nach DNS-Umstellung)
