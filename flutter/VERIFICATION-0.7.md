# Flutter 0.7.0 – Prüfstand am 28.10.2026

Lokale Umgebung: Windows, Flutter 3.47.7 / Dart 3.13.5.

## Erfolgreich

- `flutter analyze --no-pub`: keine Befunde.
- `flutter test --no-pub`: 47 Tests erfolgreich; Datei-API, Bereichslesen,
  Ressourcenbesitz, Dialogabbruch, verschachtelte Drop-Ziele, Multipart-Sonderzeichen,
  leere Dateien, Wiederholung und aktiver Upload-Abbruch eingeschlossen.
- `dart run tool/verify_dependencies.dart`: Paket und Beispiel enthalten nur
  direkte SDK-Laufzeitabhängigkeiten; das Beispiel referenziert zusätzlich das
  lokale tecexpress-Paket. Keine Overrides.
- Separater Consumer: öffentliche API kompiliert; 2 Tests erfolgreich.
- Generierte Dokumentation: 105 vollständige Dart-Beispiele analysiert;
  7 Widget-Beispiele erfolgreich getestet. README unter 262144 UTF-8-Bytes.
- Windows-Release-Build der Beispiel-App und der Datei-Testansicht erfolgreich.
- Beispiel-App: 7 Tests einschließlich Light-/Dark-Layouts bei 390/1200 Pixeln erfolgreich.
- JavaScript- und WASM-Release-Builds erfolgreich. Beide Browser-Release-Proben
  in Chrome erfolgreich: Auswahl/Filter, Lesbarkeit nach Auswahl, Bereichslesen,
  DOM-Aufräumen, Abbruch, Ressourcenfreigabe, Multipart mit Browser-Blob-Slices,
  Chunk-Fortschritt, leere Uploads und XHR-Abbruch.
  Beide Release-Proben prüfen außerdem Drop-Zustellung und Freigabe widgeteigener Dateien.
  Auswahl-/Drop-Ereignisse werden dabei programmgesteuert erzeugt; eine manuelle
  Bedienung der Browser-/Betriebssystemdialoge ist damit nicht ersetzt.
- Veröffentlichungsvorschau: ausschließlich Git-Warnung wegen uncommitteter
  Änderungen; keine Abhängigkeits- oder Changelog-Warnung. Nichts veröffentlicht.

## Vor Freigabe noch offen

- Android-, iOS-, macOS- und Linux-Builds wurden auf diesem Windows-Host nicht
  ausgeführt. Die CI-Matrix enthält alle sechs Plattformen und beide Web-Builds;
  ihre Ergebnisse stehen noch aus.
- Native Dialoge, Speichern und reale externe Datei-Drops benötigen die manuelle
  Abnahme aus MIGRATION-0.7.md auf jeder Plattform. Die Windows-UI-Automatisierung
  konnte die Testansicht lesen, aber nachfolgende Eingaben scheiterten mit
  `coordinate input geometry is unavailable` / `failed to activate captured window`.
  Diese Funktionsprüfung ist deshalb nicht als bestanden gewertet.
- Beim Windows-Test wurde ein Zugriff auf einen abgebauten Messenger im
  Plugin-Destruktor gefunden und entfernt. Erneuter Build erfolgreich; normales
  Beenden muss zusätzlich praktisch bestätigt werden.
- Linux-Portal-/Flatpak-Transfer, Windows-Dateien ohne normalen Dateipfad,
  Apple-Dateiprovider/Sandbox, große Dateien und zusätzliche Flutter-Views sind
  ausdrücklich noch praktisch zu prüfen.
- Der lokale Flutter-Browsertestserver lieferte CanvasKit-/Skwasm-Dateien mit 404
  aus (Windows-Pfadbehandlung im SDK). Die Release-Proben verwenden einen eigenen
  lokalen Server und waren erfolgreich. Die separaten SDK-Browsertests sind in
  Linux-CI eingetragen, lokal jedoch nicht als bestanden gewertet.
- Browser-Download und dessen Benutzerabbruch wurden nicht praktisch abgenommen;
  Browser erlauben grundsätzlich nur die Bestätigung des Downloadstarts.

## Browser-Release-Probe wiederholen

Nach Installation der vorhandenen Repository-Entwicklungswerkzeuge (`npm ci`):

```powershell
cd flutter/example
flutter build web --release --no-pub -t test_support/file_web_probe.dart
node ../tool/verify_web_release.mjs
flutter build web --wasm --release --no-pub -t test_support/file_web_probe.dart
node ../tool/verify_web_release.mjs
```

Für die normale Beispiel-App anschließend `flutter build web --wasm --release`
ohne abweichendes Target ausführen. Die Probe ist von der Paketveröffentlichung
ausgeschlossen. Eine bestimmte pub.dev-Punktzahl ist erst nach der tatsächlichen
Neubewertung bestätigt. 0.7.0 bis zur offenen Plattformabnahme nicht veröffentlichen.
