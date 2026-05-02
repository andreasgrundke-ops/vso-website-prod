# DEPLOY.md – GitHub Pages + IONOS-DNS-Migration

Schritt-für-Schritt-Anleitung, wie die Website live geht und WordPress bei IONOS abgelöst wird.

---

## Phase 1 – Repo + GitHub Pages aufsetzen (vor Kundenfreigabe)

### 1.1 Git-Repo lokal initialisieren

```powershell
cd "C:\Users\mail\Claude_Cowork\04_Kunden\VSO 2026\website"
git init -b main
git add .
git commit -m "Initial commit: VSO Produktions-Website v1.0.0"
git tag v1.0.0
```

### 1.2 GitHub-Repo anlegen und pushen

```powershell
gh repo create vso-website-prod --public --source=. --remote=origin --push
git push --tags
```

> Public macht Sinn, weil GitHub Pages Free für Public-Repos kostenlos läuft. Quellcode hat keine Geheimnisse drin (keine API-Keys, kein Secret).
> Wenn du es trotzdem privat willst: `--private` – Pages funktioniert dann auch (GitHub hat Pages für private Repos kostenfrei freigeschaltet seit 2024).

### 1.3 GitHub Pages aktivieren

```powershell
gh api repos/andreasgrundke-ops/vso-website-prod/pages -X POST -f source[branch]=main -f source[path]=/
```

oder im Browser: Repo → Settings → Pages → Source: `Deploy from a branch` → Branch `main` `/ (root)` → Save.

Nach 30–60 Sekunden ist die **Vorschau-URL** live:

```
https://andreasgrundke-ops.github.io/vso-website-prod/
```

⚠️ Solange die Custom Domain bei IONOS noch nicht umgestellt ist, zeigt diese URL den Inhalt – die Kundin schauen lassen.

### 1.4 Vorschau-URL der Kundin schicken

```
Hallo Frau Schröer,

hier der erste Entwurf der neuen Website zum Anschauen:
👉 https://andreasgrundke-ops.github.io/vso-website-prod/

Die Sprachversionen können oben rechts umgeschaltet werden.
Bitte prüfen Sie:
  - Texte und Inhalte
  - Layout und Farben
  - Foto und Logo
  - Sprachversionen DE/EN/PL/HR

Anmerkungen gerne als Liste zurück, dann arbeite ich sie ein.
Sobald wir freigegeben sind, schalten wir auf violetta-schroeer.de um.

Viele Grüße,
Andreas
```

---

## Phase 2 – Iterations-Phase (während Kundenabstimmung)

Jede Änderung läuft gleich:

```powershell
# Änderung in index.html / impressum.html / datenschutz.html / assets/
git add -A
git commit -m "Feedback Frau Schröer Runde 1: Texte Hero + Service 3 angepasst"
git push
```

Nach `git push` ist die Änderung in ~30 s live unter der Vorschau-URL.

### Versionierung mit Git-Tags

Vor jeder größeren Iteration ein Tag setzen, damit man später zurückspringen kann:

```powershell
git tag v1.1.0  # nach erster Feedback-Runde
git push --tags
```

Rollback:
```powershell
git checkout v1.0.0       # in den alten Stand schauen
git checkout main         # zurück zur aktuellen Version
git revert <commit-sha>   # einen einzelnen Commit rückgängig machen
```

---

## Phase 3 – Go-Live (nach Kundenfreigabe)

### 3.1 Letzten Stand pushen + Tag setzen

```powershell
git tag v1.0.0-go-live
git push --tags
```

### 3.2 Custom Domain in GitHub Pages aktivieren

Aus der lokalen Konsole (im `website/`-Ordner):

```powershell
# CNAME-Datei mit der Custom Domain anlegen
'violetta-schroeer.de' | Set-Content CNAME

# Pages-API: Custom Domain setzen
gh api -X PUT repos/andreasgrundke-ops/vso-website-prod/pages -F "cname=violetta-schroeer.de"

git add CNAME
git commit -m "Go-Live: CNAME für violetta-schroeer.de aktivieren"
git push
```

> **Warum CNAME erst jetzt?** Während der Preview-Phase würde GitHub Pages sonst von `andreasgrundke-ops.github.io/vso-website-prod` auf `violetta-schroeer.de` redirecten. Solange die DNS dort noch auf das alte WordPress zeigt, wäre die Vorschau nicht erreichbar.

### 3.3 DNS bei IONOS umstellen

Bei IONOS einloggen → Domain `violetta-schroeer.de` → DNS-Verwaltung. Folgende Records setzen:

**A-Records (für `violetta-schroeer.de` ohne www):**
```
@   A   185.199.108.153
@   A   185.199.109.153
@   A   185.199.110.153
@   A   185.199.111.153
```

**CNAME (für `www.violetta-schroeer.de`):**
```
www   CNAME   andreasgrundke-ops.github.io.
```

**Bestehende A/CNAME-Records, die auf das WordPress-Hosting zeigen, LÖSCHEN.**

⚠️ **MX- und TXT-Records für E-Mail UNANGETASTET LASSEN.** Das E-Mail-Postfach `info@violetta-schroeer.de` läuft weiter über IONOS – die MX-Records dafür sind separat.

### 3.4 SSL-Zertifikat warten

Nach DNS-Umstellung:
1. ~10–15 Min warten, bis DNS propagiert ist (Test: `nslookup violetta-schroeer.de` zeigt 185.199.x.x)
2. GitHub-Pages Settings öffnen → "Enforce HTTPS" sollte ankreuzbar sein → ankreuzen
3. Zertifikat wird automatisch via Let's Encrypt ausgestellt (~5 Min)

Test: https://violetta-schroeer.de → muss ohne SSL-Warnung laden, Inhalt der neuen Seite zeigen.

### 3.5 Maps-Embed einbauen (kommt nach Go-Live)

In `index.html` Sektion `#kontakt` den `<div class="map-placeholder">` ersetzen durch:

```html
<iframe
  src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2667.XXXXXXXXX..."
  width="100%" height="480"
  style="border:0;"
  allowfullscreen=""
  loading="lazy"
  referrerpolicy="no-referrer-when-downgrade"
  title="Standort: Bretonischer Ring 18, 85630 Grasbrunn"></iframe>
```

Den `src`-Wert generieren: Google Maps öffnen → Adresse `Bretonischer Ring 18 Grasbrunn` suchen → "Teilen" → "Karte einbetten" → HTML kopieren → nur den `src`-Wert übernehmen.

```powershell
git commit -am "Maps-Embed eingebaut"
git push
```

---

## Phase 4 – WordPress bei IONOS kündigen

Nach erfolgreicher DNS-Umstellung (Phase 3) und 2–3 Tagen Beobachtung:

1. IONOS-Kundenmenü → Verträge
2. "Managed WordPress" suchen → Kündigen
3. **Domain `violetta-schroeer.de` NICHT kündigen** – die bleibt
4. **E-Mail-Postfach NICHT kündigen** – das bleibt
5. Bestätigungsmail abwarten

**Ersparnis:** ~10 €/Monat = 120 €/Jahr für das WordPress-Hosting.
**Bleibt:** ~12 €/Jahr für die Domain + ~2 €/Monat für das Postfach.

---

## Phase 5 – SEO + lokale Sichtbarkeit (siehe `docs/SEO-CHECKLISTE.md`)

- Google Search Console verifizieren
- Bing Webmaster Tools
- Google Business Profile aktualisieren
- Branchenverzeichnisse (grasbrunn.de, Gelbe Seiten, etc.)

---

## Troubleshooting

| Problem | Lösung |
|---|---|
| "Pages wurde nicht aktiviert" | Repo Settings → Pages → Branch auswählen, "Save" klicken |
| 404 nach DNS-Umstellung | DNS noch nicht propagiert – `nslookup violetta-schroeer.de` checken, 15 Min warten |
| "Not Secure" / SSL-Warnung | "Enforce HTTPS" im Pages-Setting aktivieren, 5 Min warten |
| Custom Domain wird nicht akzeptiert | `CNAME`-Datei im Repo prüfen, muss nur `violetta-schroeer.de` enthalten (eine Zeile) |
| Sprachen funktionieren nicht | Browser-Konsole checken – `localStorage`-Block? Inkognito-Tab testen |
| `_archiv`-Folder wird nicht gefunden | `.nojekyll`-Datei muss im Repo-Root sein – Jekyll filtert sonst `_*`-Verzeichnisse raus |
