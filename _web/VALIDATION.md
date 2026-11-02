# Prüfung der Web-Dokumentation

Stand: 2. November 2026.

Lokal erfolgreich geprüft:

- Katalog mit 108 Vue- und 105 Flutter-Seiten in Deutsch und Englisch; interne Referenzen, Codeblöcke, Demo-Zuordnung und öffentliche TypeScript-Exporte.
- PHP-Syntax und HTML-Rendering sämtlicher Seiten mit PHP 8.5.12, inklusive Escaping, generischer Typen und ungültiger Links.
- HTTP 200 und fehlerfreie PHP-Ausgabe für sämtliche Katalogseiten; HTTP 404 bei unbekannter Seite.
- Vue-Produktionsbuild mit Vite; alle 38 generierten Vue-Demos im Chromium-Browser geladen und zurückgesetzt, Textfeld und Checkbox bedient.
- Flutter-Analyzer ohne Befunde; 39 Widgettests erfolgreich, darunter alle 38 generierten Beispiele und zusätzliche Eingabe-/Klickprüfungen.
- Flutter-Web-Releasebuild erfolgreich; echte Flutter-Web-Vorschau im separaten Demo-Server und im PHP-iframe geöffnet.
- Browsersuche, Deep Links, Sprachwechsel, Theme-Wechsel, mobile Navigation und Layout ohne horizontalen Seitenüberlauf.
- Visuelle Kontrolle der Desktop- und Mobilansicht sowie der Komponentenansicht.
- Demo-Server: statische Dateien, Frame-Ancestors-Header, Healthcheck, fehlende Seiten, Multipart-Upload ohne Speicherung, Typ- und Größenfehler.
- GitHub-Workflow mit actionlint 1.7.12 validiert.

Nicht lokal ausgeführt: vollständiger Docker-Image-Build, GHCR-Push, Portainer-Deployment sowie DNS/TLS und Einbettung auf der produktiven Domain. Auf diesem Rechner ist keine Docker-Laufzeit verfügbar. Die neue GitHub Action baut das Linux-amd64-Image einschließlich Flutter-Prüfungen und führt vor der Veröffentlichung einen Container-Smoke-Test aus.

Die Beispiele übernehmen den vorhandenen Bibliotheksumfang. Die Widgettests prüfen das Mounten sämtlicher Flutter-Beispiele; sie sind keine vollständigen Interaktionstests jedes einzelnen Parameters. Paketinterne Flutter-Texte können auch bei englischer Material-Lokalisierung deutsch bleiben.
