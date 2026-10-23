# Prüfbericht · tecexpress 0.4.0

Stand: 23.10.2026. Lokal auf Windows mit Node.js 24.22.1, npm 11.19.1, Flutter 3.47.7 und Dart 3.13.5 geprüft. Es wurden keine Registry-Uploads, Anmeldungen, Git-Pushes oder Release-Tags ausgeführt.

## Lokal erfolgreich

| Bereich | Ergebnis |
| --- | --- |
| Root npm-Workspace | `npm ci` erfolgreich, Root-Befehle delegieren an `npm/`. |
| Vue-Typen und Komponenten | Typprüfung ohne Fehler; 69 Tests bestanden. |
| Vue-Browser | 13 Chromium-Tests bestanden, inklusive Themes und Mobilansicht. |
| Vue-Builds | Bibliothek und Vite-Demo gebaut; 21 öffentliche Exporte erhalten. |
| npm-Consumer | Gepacktes Paket in einem separaten temporären Projekt installiert; Exporte, SSR und Themes erfolgreich geprüft. |
| npm-Publishing | `npm publish --dry-run --access public` erfolgreich; Authentifizierung für echten Upload noch erforderlich. |
| Flutter-Format und Analyse | Formatprüfung ohne Änderungen; `flutter analyze` ohne Meldungen. |
| Flutter-Bibliothek | 24 Logik-/Widgettests bestanden: Editoren, Controller, Auswahl/Filter, Kalendergrenzen, Terminbearbeitung, Cancellation/Konflikte, Chat/IME/Timer/Scroll und Overlays. |
| Flutter-Showcase | 7 Tests bestanden: SDK-Schriftauflösung und Dateinamenschreibweise, Start/Themewechsel und alle fünf Bereiche in Light/Dark bei 1200 und 390 Pixeln. |
| Flutter-Consumer | Separates temporäres Projekt importiert alle 21 öffentlichen Gegenstücke und rendert native Widgets; Test bestanden. |
| Flutter Web | Showcase mit `flutter build web --release` gebaut. |
| Flutter Windows | Showcase mit `flutter build windows --release` gebaut. |
| pub.dev-Publishing | `flutter pub publish --dry-run` erfolgreich, **0 Warnungen**. |

Screenshots der Flutter-Layoutprüfungen: `flutter/example/build/qa/`; geprüft mit echten SDK-Schriften. Screenshots und Builddateien sind keine Veröffentlichungsinhalte.

## Paketinhalte

- npm: `dist/`, `themes/`, Dokumentation, README, Manifest und MIT-Lizenz; keine Flutter-Quellen oder Demo-Builds.
- pub.dev: Dart-Quellen, Manifest, Dokumentation, Lizenz und veröffentlichbare Beispieldateien. Cache-/Buildordner, lokale SDK-Konfiguration, signierungsbezogene Dateien und Prüfwerkzeuge werden ausgeschlossen.
- Die Paketarchive enthalten keine Registry-Zugangsdaten. Die Root-Konfiguration und Beispiel-App sind privat beziehungsweise `publish_to: none`.

## Nachprüfung der gemeldeten CI-Fehler

- `npm run typecheck` baut jetzt zuerst die öffentlichen Exporte und Deklarationen. Lokal auch ohne vorhandenes `npm/dist/` erfolgreich geprüft; 69 Vue-Tests bestanden.
- Die visuellen Flutter-Tests ermitteln das SDK über die aktive `package_config.json` und suchen Schriften unabhängig von der Groß-/Kleinschreibung. Alle 7 Showcase-Tests, Formatprüfung und `flutter analyze` lokal erfolgreich. Die genaue Ausnahme des gemeldeten CI-Setups war im bereitgestellten Auszug nicht enthalten; der nächste CI-Lauf muss die Korrektur auf Ubuntu bestätigen.
- Die Flutter-CI verwendet den ausführlichen Testreporter, damit Fehler einschließlich Setup-Ausnahmen im Log sichtbar sind.

## Remote-Prüfung ausstehend

`.github/workflows/validate.yml` enthält Vue-/Flutter-Prüfungen, Consumer- und Dry-run-Prüfungen sowie Flutter-Beispielbuilds für Web, Windows, Linux, macOS, iOS ohne Codesign und Android-APK. Der Nutzer meldete CI-Fehler; für die obigen Korrekturen liegt noch kein Remote-Laufergebnis vor. Android, iOS, macOS und Linux wurden in dieser lokalen Windows-Sitzung nicht gebaut und nicht auf Geräten getestet.

Die erfolgreichen lokalen Windows-/Web-Builds und gemeinsamen Widgettests sind keine Aussage über gerätespezifische Laufzeittests auf allen sechs Plattformen. Die CI stellt weitere Buildnachweise nach einem eigenen Git-Push bereit.

Manuelle Veröffentlichung und Registry-Installation nach dem echten Upload: [PUBLISHING.md](PUBLISHING.md).
