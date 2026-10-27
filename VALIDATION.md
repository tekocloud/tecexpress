# Prüfbericht · tecexpress 0.5.0

Stand: 27.10.2026. Lokal auf Windows mit Node.js 24.22.1, Flutter 3.47.7 und Dart 3.13.5. Keine Veröffentlichung, Git-Pushes oder Release-Tags. Die folgenden Ergebnisse betreffen die Arbeitskopie dieser Erweiterung; ältere Ergebnisse der Version 0.4.0 werden nicht als Nachweis für 0.5.0 verwendet.

## Lokal geprüft

| Bereich | Ergebnis |
| --- | --- |
| Vue-Typen | `npm run typecheck`, einschließlich öffentlicher Deklarationen und Demo. |
| Vue-Tests | 95 Tests: bestehende Funktionen, DataSource-Abfragen/CRUD/Abbruch/Fehler, gemeinsam genutzte Instanzen, Grid-/CardView-Paging, neue Controls, Overlays, Datei- und Uploadadapter. |
| Vue-Browser | 16 Chromium-Tests: bestehende Abläufe, gemeinsame Datenbindung, entfernte Suche, Dateioperationen, Benachrichtigungsstapel, Desktop/Mobil und Light/Dark. |
| Vue-Builds | Bibliotheks- und Demo-Build. |
| npm-Consumer | Gepacktes Paket in einem separaten temporären Projekt installiert; 37 Komponenten/Konfigurationen, 4 Store-/Provider-Klassen, globale Registrierung, SSR, DataSource-SSR und Theme-Exporte geprüft. |
| Flutter-Format/Analyse | `dart format --output=none --set-exit-if-changed lib test tool example/lib example/test` und `flutter analyze`. |
| Flutter-Bibliothek | 39 Logik-/Widget-/Adaptertests; einschließlich eines echten lokalen HTTP-Servers für Multipart-/Chunk-Verträge. |
| Flutter-Showcase | 7 Tests; Layout-/Screenshotprüfungen aller sechs Bereiche bei 1200 und 390 Pixeln in Light/Dark. |
| Flutter-Consumer | Separates temporäres Projekt importiert alle 37 Gegenstücke und die DataSource und rendert native Widgets. |
| pub.dev-Dry-run | Paketvalidierung mit einer Warnung wegen der noch nicht committeten Änderungen; keine Veröffentlichung. |
| Flutter Web | `flutter build web --release` erfolgreich. |

Die neuen Vue- und Flutter-Mobilansichten wurden zusätzlich anhand der erzeugten Screenshots visuell geprüft. Artefakte liegen unter `npm/test-results/` beziehungsweise `flutter/example/build/qa/`; sie gehören nicht zum veröffentlichten Paket.

## Lokal nicht erfolgreich beziehungsweise nicht ausgeführt

- **Windows:** `flutter build windows --release` endet vor der Kompilierung mit „Building with plugins requires symlink support“. Die neuen Dateiplugins benötigen Symlink-Unterstützung beziehungsweise Windows-Entwicklermodus. Es wurden keine Systemeinstellungen geändert.
- **Android:** SDK 36 und Java 17 sind vorhanden. `flutter build apk --release` endet beim Gradle-Start mit `java.io.IOException: Unable to establish loopback connection`. Ein erneuter Versuch mit ausschließlich prozesslokaler IPv4-Präferenz scheiterte ebenfalls. Für diese Arbeitskopie liegt deshalb kein erfolgreicher APK-Nachweis vor.
- **Linux, macOS, iOS:** Auf diesem Windows-Host nicht gebaut und nicht auf Geräten getestet.
- **Remote-CI:** `.github/workflows/validate.yml` enthält weiterhin Qualitäts-/Consumer-/Paketprüfungen und sechs Plattformbuilds. Es wurde kein Remote-Lauf für diese Änderungen gestartet; dessen Ergebnisse stehen aus.

## Aussagegrenzen

- Umfang und Unterschiede der DevExtreme-orientierten Implementierungen stehen in [EXTENSIONS.md](flutter/EXTENSIONS.md). Es wird keine vollständige DevExpress-API-/Optionsparität behauptet.
- Dateioperationen wurden mit dem Speicher-Provider geprüft. Produktive Dateiserver, Kartenanbieter, Zugangsdaten und Geocoding-/Routingdienste müssen durch die konsumierende Anwendung konfiguriert und separat geprüft werden.
- HTTP-Tests prüfen Multipart, Chunk-Metadaten, Fehler, Abbruch und Neustart; serverseitige Chunk-Zusammenführung und resumierbare Protokolle sind keine Bibliotheksfunktion.
- Native Auswahl-, Drop- und Speicherdialoge wurden hier nicht auf sämtlichen Zielgeräten interaktiv getestet. Flutter-Downloads bieten `onDownload` für eigene Plattformintegration.
- Paket-/Consumerprüfungen sind keine Registry-Veröffentlichung. Anleitung: [PUBLISHING.md](PUBLISHING.md).
