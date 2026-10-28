# Flutter 0.7.0 migration / Migration auf Flutter 0.7.0

## Deutsch

Ab 0.7.1 unterstützen iOS und macOS sowohl Swift Package Manager als auch
CocoaPods aus denselben Swift-Quellen. Der lokale Swift-Package-Verweis auf
`FlutterFramework` bindet ausschließlich das von Flutter bereitgestellte SDK ein.
Android verwendet Built-in Kotlin; die Beispiel-App aktiviert
`android.builtInKotlin=true` unter AGP 9.1. Die bisherigen Mindestversionen
Flutter 3.47.7 / Dart 3.13.5 bleiben unverändert.
Die Beispiel-App setzt den von AGP verwendeten Kotlin-Compiler auf 2.4.0, da
der mit AGP gelieferte Standard 2.2.10 unter der vom lokalen Flutter-SDK
geforderten Mindestversion 2.2.20 liegt. Dies ist eine Build-Tool-Konfiguration;
das separate Kotlin-Android-Plugin wird weiterhin nicht angewendet.

tecexpress hat keine direkten externen Laufzeit-Abhängigkeiten mehr. Die einzigen
Laufzeitpakete stammen aus dem Flutter-SDK: `flutter`, `flutter_localizations`
und `flutter_web_plugins`. SDK-interne transitive Pakete, etwa `intl`, bleiben
Teil von Flutter. Entwicklungswerkzeuge wie `flutter_lints` sind weiterhin erlaubt.

### Datei-API

- Alle bisherigen `XFile`-Parameter, Datenquellen und Callbacks verwenden `TxFile`.
- `XFile.fromData(bytes, name: 'a.txt')` wird zu
  `TxFile.fromData(bytes, name: 'a.txt')`; `name` ist erforderlich, `path` entfällt.
- `XFile(path)` wird auf nativen Plattformen zu `TxFile.fromPath(path)`.
- Die Fremdmethoden `readAsString`, `lastModified` und `saveTo` entfallen.
  Text kann mit `utf8.decode(await file.readAsBytes())` aus `dart:convert` gelesen
  werden; für interaktives Speichern `TxFileDialogs.saveFile` verwenden.
- Fremde `XFile`-Objekte explizit konvertieren, falls die Anwendung selbst solche
  Pakete verwendet: Bytes lesen und `TxFile.fromData` aufrufen.
- `TxFileDialogs.pickFiles(multiple: true, extensions: ['txt'])` liefert eigene
  Dateien. Abbruch liefert `[]`. `TxFileDialogs.saveFile(file)` liefert bei Abbruch
  `false`. Im Web bestätigt `true` nur das Auslösen des Browserdownloads.
- `openRead(start, end)` liest einen Bytebereich: Start inklusive, Ende exklusiv.
  `readAsBytes()` lädt den gesamten Inhalt. `path` ist im Browser `null`.
- Eigene Dateien und Ergebnisse von `pickFiles` nach Gebrauch mit `await file.dispose()`
  freigeben. Danach sind keine Leseoperationen mehr erlaubt. `fromPath` löscht die
  Originaldatei niemals. Dialog-/Drop-Dateien werden in unabhängigen Speicher kopiert.
- Der Uploader entsorgt nur Dateien aus seinen eigenen Dialogen und Drops, bei
  Ersetzung oder Entfernen des Widgets. Vom Aufrufer gelieferte Dateien bleiben
  dessen Verantwortung. Callback-Empfänger müssen benötigte Inhalte vor der
  Freigabe selbst kopieren. Ordner-Drops werden nicht unterstützt.

`txHttpUpload` behält seinen Multipart-/Chunk-Vertrag und Fortschritt nach erfolgreich
abgeschlossenen Chunks. Native Uploads lesen Dateien als Stream. Browser-XHR und
Blob-Downloads unterliegen den Speicher- und Berechtigungsgrenzen des Browsers.
Browser-CORS, verbotene HTTP-Header sowie mobile HTTPS-Regeln gelten unverändert.

### Plattformkonfiguration

Nach dem Update `flutter pub get` ausführen und die Anwendung vollständig neu
bauen; Hot Reload registriert das neue native Plugin nicht.

- Android: System-Dateidialoge benötigen keine allgemeine Speicherberechtigung.
  Für Netzwerkzugriffe `android.permission.INTERNET` im App-Manifest deklarieren.
- iOS: Dokument-Picker und Exportdialog verwenden die Systemoberfläche. Externe
  Dateidrops benötigen ein Gerät und eine Quelle, die Dateien bereitstellt.
- macOS: Für Sandbox-Apps `com.apple.security.files.user-selected.read-write`
  setzen; für HTTP `com.apple.security.network.client`. Die Beispiel-App enthält
  diese Entitlements. Security-scoped Quelldateien werden während des Kopierens geöffnet.
- Windows: COM/OLE wird eingebaut verwendet. Flutter benötigt wie bei anderen
  nativen Plugins lokale Symlink-Unterstützung beziehungsweise Entwicklermodus.
- Linux: GTK 3 und GIO/GDBus aus der Systeminstallation verwenden; keine Dart-D-Bus-
  oder FFI-Abhängigkeit. File-Transfer-Portal-Drops benötigen ein laufendes Desktop-Portal.
- Web: Moderne Browser mit `dart:js_interop`; keine eigene JavaScript-Datei einbinden.
  Dateidialoge/Downloads durch eine Benutzeraktion auslösen. JavaScript und WASM
  werden gebaut. Browserdownloads bieten keine zuverlässige Abbruchbestätigung.

Datumsausgaben unterstützen Deutsch/Englisch einschließlich regionaler Locale-Tags;
andere Sprachen fallen auf Englisch zurück. Der Datumseditor nutzt die
Material-Lokalisierung der App.

## English

Version 0.7.1 adds Swift Package Manager support for iOS/macOS alongside
CocoaPods, sharing the same sources. The local FlutterFramework package is
provided by Flutter itself. Android uses built-in Kotlin, enabled in the example
under AGP 9.1. The minimum Flutter/Dart versions remain unchanged.

Version 0.7.0 replaces the third-party `XFile` type with `TxFile` and removes all
direct non-SDK runtime dependencies. Flutter's own transitive dependencies remain.
Use `TxFile.fromData(bytes, name: 'a.txt')` for memory files and
`TxFile.fromPath(path)` for native paths. Use `TxFileDialogs.pickFiles` and
`TxFileDialogs.saveFile` for built-in dialogs. Cancellation returns `[]` or `false`;
browser downloads can only confirm initiation. Release owned files with `dispose`.
Disposing a path-backed file never deletes the source file. Files supplied through
uploader data sources remain owned by the caller; files acquired by the uploader
are released when replaced or when its widget is disposed. Copy callback contents
if you need them beyond this lifetime. Directory drops are unsupported.

Run `flutter pub get` and rebuild the app after upgrading. Android network requests
require INTERNET permission. Sandboxed macOS apps require user-selected read/write
file access and network-client entitlements. Linux uses system GTK/GIO and the
desktop file-transfer portal. Web code uses modern JS interop and supports JS/WASM;
no additional JavaScript setup is required. Browser security, CORS and mobile HTTPS
restrictions still apply. Date labels support German/English with English fallback.

## Platform acceptance checklist / Plattformabnahme

Run `flutter run -t lib/file_probe.dart` in `flutter/example` on each platform.
Pick multiple `.txt` files, cancel the picker, save the three-byte sample, cancel
saving, drop ordinary files, reject a folder, scroll the uploader, and repeat with
two uploaders (one disabled). Verify that file contents remain readable after a
drop and that temporary files disappear after disposal. Test Unicode filenames,
large files and a second Flutter view. On Linux additionally drop from a sandboxed
source using `application/vnd.portal.filetransfer`; on Windows test a virtual file
from a mail client; on iOS test provider-backed files and rotation during a dialog.

Build checks and mocked channel tests do not establish device-level acceptance.
Record unperformed platform/device checks in the release handover; do not publish
0.7.0 as fully verified until these checks have been completed.
