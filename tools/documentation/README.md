# Paketdokumentation pflegen / Maintaining package documentation

`npm/README.md` und `flutter/README.md` sind die vollständigen, zweisprachigen
Anwenderreferenzen. Sie werden als Teil des jeweiligen Pakets veröffentlicht.
`content.mjs`, `examples.mjs` und `details.mjs` enthalten die redaktionellen Texte
und Beispiele; `generate.mjs` liest Exporte, Typen, Props und Standardwerte aus
der aktuellen Implementierung. Unbekannte Exporte/Optionsnamen führen zu einem
Fehler und müssen redaktionell ergänzt werden.

The package READMEs contain the complete German and English references. The
generator reads current exports, types, props and defaults from implementation;
the adjacent content modules hold manually maintained explanations and examples.
Unknown exports/options fail generation and require editorial content.

## Generieren / Generate

Aus dem Repository-Stammverzeichnis in PowerShell / from the repository root:

```powershell
npm run build
$flutterSdk = Split-Path (Split-Path (Get-Command flutter).Source)
dart --packages="$flutterSdk/packages/flutter_tools/.dart_tool/package_config.json" tools/documentation/extract.dart "$env:TEMP/tecexpress-dart-api.json"
node tools/documentation/generate.mjs --format
```

Für eine reine Flutter-Aktualisierung `--flutter-only` ergänzen. Der Generator
liest die Versionsnummer aus dem jeweiligen Manifest. Die Flutter-README muss
einschließlich UTF-8-Sonderzeichen höchstens **262144 Bytes** umfassen; Generator
und Prüfer brechen bei Überschreitung mit einem Fehler ab. Parameter werden einmal
mit Typ, Standardwert und Erklärung dokumentiert, statt dieselben Felder in einer
zweiten Tabelle zu wiederholen. Der gemeinsame Widget-Parameter `key` steht im Einstieg.

Add `--flutter-only` to update only Flutter. Versions come from package manifests.
The Flutter README must fit within **262144 UTF-8 bytes**; generation and verification
fail above that limit. Parameter tables document types, defaults and meaning once;
duplicate field rows are omitted. The shared widget `key` parameter is documented
in getting started.

Der Extraktor verwendet den mit Flutter ausgelieferten Analyzer, ohne die
Paketabhängigkeiten zu ändern. Bei einer neuen SDK-Installation gegebenenfalls
zuerst `flutter --version` ausführen, damit Flutter seine Werkzeuge initialisiert.
Auf anderen Plattformen denselben SDK-relativen `--packages`-Pfad verwenden und
den Ausgabeparameter des Extraktors bei Bedarf explizit an den Generator geben.

The extractor uses Flutter's bundled analyzer without adding package dependencies.
On a fresh SDK installation, initialize Flutter tools with `flutter --version`.
On other platforms use the equivalent SDK-relative package configuration path;
an explicit JSON path can also be passed to the generator.

Fehlende Dart-Kommentare ergänzen / add missing Dart comments:

```powershell
node tools/documentation/generate.mjs --format --dart-comments
```

`--refresh-comments` erneuert auch bestehende Kommentare der erfassten öffentlichen
Dart-API aus den redaktionellen Texten. Vor jedem solchen Lauf den Extraktor
erneut ausführen: Die AST-Offsets müssen zum aktuellen Quellstand passen.
Kommentare an gemeinsam deklarierten Feldern erklären jedes Feld separat.

`--refresh-comments` also replaces existing public API comments using the editorial
content. Always rerun the extractor first because AST offsets must match the
current sources. Shared field declarations receive descriptions of all fields.

## Prüfen / Verify

```powershell
npm run test:package
# Use the installed consumer directory printed by the preceding command:
dart --packages="$flutterSdk/packages/flutter_tools/.dart_tool/package_config.json" tools/documentation/extract.dart "$env:TEMP/tecexpress-dart-api.json"
node tools/documentation/verify.mjs C:/path/to/printed/tecexpress-consumer-XXXXXX
```

Flutter separat prüfen / verify Flutter separately:

```powershell
node tools/documentation/verify.mjs --flutter-only
```

Der Prüfer kontrolliert Sprachabdeckung, Anker, Codeblöcke und öffentliche
Dart-Kommentare. Alle vollständigen Vue-/TypeScript-Beispiele werden gegen das
installierte Paket typgeprüft. Flutter-Beispiele und sieben Widget-Smoke-Tests
werden in einem temporären Consumer vorbereitet. Dessen ausgegebenen Pfad für
folgende Befehle verwenden / use the printed temporary Flutter consumer path:

```powershell
flutter pub get
flutter analyze
flutter test
```

The verifier checks language coverage, anchors, code fences and public Dart
comments. It typechecks complete Vue/TypeScript examples against the installed
package and prepares a temporary Flutter consumer with complete snippets and
seven widget smoke tests. HTTP examples are analyzed but not sent to a server.

Abschließend in den jeweiligen Paketordnern ausführen / finally run in each package:

- npm: `npm run typecheck`, `npm pack --dry-run`
- Flutter: `flutter analyze`, `flutter test`, `dart doc`, `flutter pub publish --dry-run`

Generierte HTML-Dokumentation unter `flutter/doc/api/` wird nicht hochgeladen;
pub.dev generiert die API-Referenz aus den ausgelieferten Dart-Kommentaren.
Die Veröffentlichung selbst ist kein Bestandteil dieser Werkzeuge.

Generated `flutter/doc/api/` HTML is excluded from uploads; pub.dev generates its
API reference from shipped Dart comments. These tools do not publish packages.
