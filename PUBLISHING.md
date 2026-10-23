# tecexpress auf npm und pub.dev veröffentlichen

Diese Anleitung liegt bewusst im **Projektstamm**. Sie beschreibt manuelle Releases der zwei eigenständigen Pakete. Die CI prüft und baut; sie veröffentlicht nichts.

## 1. Voraussetzungen und Ordner

| Paket | Verzeichnis für den Upload | Manifest | Aktuelle Version |
| --- | --- | --- | --- |
| Vue / npm | `npm/` | `npm/package.json` | `0.4.0` |
| Flutter / pub.dev | `flutter/` | `flutter/pubspec.yaml` | `0.4.0` |

Du brauchst Node.js 24.15+ innerhalb von 24.x, npm, Flutter mindestens 3.47.7 mit Dart mindestens 3.13.5, einen npm-Account und für pub.dev einen Google-Account. Flutter muss in deinem Terminal verfügbar sein; nach einer PATH-Änderung das Terminal neu öffnen. `flutter doctor -v` zeigt die verfügbaren Build-Ziele. Windows benötigt Visual Studio mit C++-Desktopwerkzeugen, Android ein JDK und Android-SDK, Apple-Builds einen Mac mit Xcode.

Alle folgenden Befehle funktionieren in PowerShell, sofern nicht anders bezeichnet. `cd`-Angaben immer beachten. Vor dem Release Änderungen prüfen und im eigenen Repository sichern. Keine Tokens, Passwörter, Zertifikate oder Auth-Dateien in das Projekt kopieren.

Repository: https://github.com/tekocloud/tecexpress. Prüfe vor der Veröffentlichung, dass diese URL und die Verzeichnislinks in den Manifesten stimmen und öffentlich erreichbar sind.

## 2. Versionen und Namen prüfen

Start im Projektstamm:

```sh
npm view tecexpress versions --json --registry=https://registry.npmjs.org/
```

Ein `E404` bedeutet, dass die Registry unter deinem Zugriff kein solches Paket liefert; es reserviert den Namen nicht. Wenn der Name bereits jemand anderem gehört, einen eigenen npm-Scope verwenden, z. B. `@DEIN-SCOPE/tecexpress`. Dann Paketname, README-Importe, Demo-Importe und Workspace-Verweise konsistent anpassen und alle Prüfungen wiederholen. Einen existierenden Namen nur mit passenden Veröffentlichungsrechten verwenden.

pub.dev: https://pub.dev/packages/tecexpress. Optional per PowerShell:

```powershell
Invoke-RestMethod https://pub.dev/api/packages/tecexpress
```

Ein 404 ist bei einem noch nicht veröffentlichten Paket zu erwarten. pub.dev hat keine npm-Scopes. Bei Namenskonflikten einen verfügbaren Dart-Paketnamen wählen und `pubspec.yaml`, Dart-Importe, Beispiel und Dokumentation gemeinsam umstellen.

Für jedes Update eine **neue** Version verwenden; veröffentlichte Versionen nicht erneut überschreiben. Für ein synchrones Release die Version in Root-`package.json`, `npm/package.json` und `flutter/pubspec.yaml` angleichen, beide Changelogs aktualisieren und im Stamm `npm install --package-lock-only` ausführen. Beispiel-App und Installationsbeispiele ebenfalls aktualisieren. Das private Root-Manifest wird niemals veröffentlicht.

## 3. npm: prüfen und packen

Im Projektstamm:

```sh
npm ci
npm run typecheck
npm test
npm run build:demo
```

Die Demo importiert den fertigen Build über die öffentlichen Exporte. Für Browserprüfungen:

```sh
cd npm
npx playwright install chromium
cd ..
npm run test:browser
npm run test:package
```

`test:package` baut und installiert das gepackte Paket in einem temporären Consumer und prüft Exporte, SSR sowie Theme-Auflösung. Es gibt dessen Pfad aus.

Jetzt in den **npm-Paketordner** wechseln:

```sh
cd npm
npm pack --dry-run
npm pack
```

Bei Version 0.4.0 entsteht hier `tecexpress-0.4.0.tgz`. Die Ausgabe muss nur `dist/`, `themes/`, `docs/`, Paket-README, Manifest und MIT-Lizenz enthalten. Kein Flutter-Ordner, keine Demo-Builds, Zugangsdaten oder lokalen Testberichte. `prepack` führt Typprüfung, Komponententests und Build aus. Browser- und Consumer-Prüfungen sind die separaten Schritte oben.

Optional das Archiv auflisten:

```sh
tar -tf tecexpress-0.4.0.tgz
```

## 4. npm: anmelden und veröffentlichen

Weiterhin in **`npm/`**:

```sh
npm login --registry=https://registry.npmjs.org/
npm whoami --registry=https://registry.npmjs.org/
npm publish --dry-run --access public
```

`npm login` öffnet gegebenenfalls den Browser. Anmelde- oder Zwei-Faktor-Abfragen direkt dort beziehungsweise im Terminal abschließen. Der Dry-run lädt nichts hoch und beweist keine Namens- oder Accountberechtigung.

Erst nach erfolgreicher Prüfung den echten Upload selbst ausführen:

```sh
npm publish --access public
```

Falls npm einen aktuellen Einmalcode verlangt, die Abfrage beantworten. Keine Codes oder Tokens in Skripte oder Git-Dateien schreiben. Das `publishConfig` des Pakets verweist auf die öffentliche npm-Registry.

Danach prüfen:

```sh
npm view tecexpress@0.4.0 version dist.tarball --registry=https://registry.npmjs.org/
```

## 5. pub.dev: prüfen und Upload simulieren

**Vom Projektstamm** nach `flutter/` wechseln. Falls du noch in `npm/` bist, zuerst `cd ..`:

```sh
cd flutter
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
flutter analyze
flutter test
dart run tool/verify_consumer.dart
cd example
flutter pub get
flutter test
flutter build web --release
flutter build windows --release
cd ..
flutter pub publish --dry-run
```

Die Windows-Buildzeile gilt auf Windows. Auf anderen Hosts stattdessen `flutter build macos --release` oder `flutter build linux --release` verwenden. Android/iOS/macOS/Linux werden zusätzlich von den passenden CI-Jobs gebaut. CI-Ergebnisse vor einem Release kontrollieren; lokale Windows-Prüfungen ersetzen keinen Apple-Build.

Beim Flutter-Dry-run die Dateiliste und Hinweise lesen. Erwartet werden Dart-Bibliothek, pubspec, Lizenz, README, Changelog, Zuordnungstabelle und die veröffentlichbaren Beispieldateien. Die `.pubignore` entfernt generierte Builddateien und lokale SDK-Konfiguration. Insbesondere dürfen weder `local.properties`, `Generated.xcconfig`, `ephemeral/`, Cache-Dateien noch Zugangsdaten enthalten sein. **Fehler beheben und Hinweise prüfen; die Validierung nicht überspringen.**

## 6. pub.dev: veröffentlichen

Weiterhin in **`flutter/`**:

```sh
flutter pub publish
```

Dateiliste prüfen und den Upload im Terminal bestätigen. Bei der ersten Veröffentlichung dem angezeigten Browser-Link folgen und mit dem vorgesehenen Google-Account anmelden. Die Freigabe erfolgt interaktiv. Ein bestehendes Paket darf nur ein berechtigter Uploader beziehungsweise Publisher aktualisieren. Die Beispiel-App hat `publish_to: none`; veröffentlicht wird nur das Paket in `flutter/`.

Danach https://pub.dev/packages/tecexpress/versions aufrufen oder in PowerShell:

```powershell
(Invoke-RestMethod https://pub.dev/api/packages/tecexpress).latest.version
```

Die erste Indexierung und Bewertung kann dauern. Falls ein verifizierter Publisher verwendet werden soll, diesen mit dem berechtigten Account auf pub.dev einrichten beziehungsweise das Paket dort zuordnen.

## 7. Frisch aus den Registries installieren

Diese Tests **außerhalb dieses Workspace** ausführen, damit keine lokale Workspace-Auflösung das Ergebnis verfälscht. Die Beispieldateien hier verwenden neue Ordner im übergeordneten Verzeichnis; bei existierenden Testordnern andere Namen verwenden.

Vom Projektstamm:

```sh
mkdir ../tecexpress-npm-smoke
cd ../tecexpress-npm-smoke
npm init -y
npm install tecexpress@0.4.0 vue@^3.5.0
node --input-type=module -e "import('tecexpress').then(m => console.log(Object.keys(m)))"
```

Für Flutter im übergeordneten Verzeichnis:

```sh
cd ..
flutter create tecexpress_flutter_smoke
cd tecexpress_flutter_smoke
flutter pub add tecexpress:^0.4.0
```

In der neuen App `package:tecexpress/tecexpress.dart` importieren, `MaterialApp(theme: TxTheme.light(), darkTheme: TxTheme.dark(), home: Scaffold(body: TxCard(title: 'Registry-Test', child: Text('Installiert'))))` verwenden und `flutter analyze` sowie `flutter run -d chrome` ausführen. Das vollständige Theme-/Lokalisierungsbeispiel steht in der Flutter-README.

## 8. Häufige Fehler und spätere Updates

| Meldung / Situation | Vorgehen |
| --- | --- |
| npm `ENEEDAUTH`, 401 oder 403 | `npm whoami` prüfen, erneut anmelden, Paket-/Scope-Rechte und angeforderte Zwei-Faktor-Bestätigung kontrollieren. |
| Name bereits vergeben | Eigenen npm-Scope beziehungsweise anderen pub.dev-Paketnamen wählen und Import-/Workspace-Verweise anpassen. |
| Version bereits vorhanden | Neue SemVer-Version vergeben und Build, Changelog sowie Prüfungen wiederholen. |
| npm meldet „private“ | Du bist im Projektstamm. Vor dem Upload nach `npm/` wechseln. Root-`private` nicht entfernen. |
| pub meldet `publish_to: none` | Du bist wahrscheinlich in `flutter/example/`. Mit `cd ..` in das Bibliothekspaket wechseln. |
| `flutter` oder `dart` nicht gefunden | SDK-PATH prüfen, Terminal neu öffnen; globalen Pfad nicht in Repositorydateien festschreiben. |
| Android/JDK oder Apple-Toolchain fehlt | Das passende SDK installieren oder den entsprechenden CI-Runner verwenden. |
| Tests, Formatprüfung oder Dry-run scheitern | Ursache beheben und erneut prüfen; kein Upload mit übersprungener Validierung. |
| pub.dev meldet fehlende Dokumentation/Links | README, CHANGELOG, Lizenz und erreichbare Manifest-URLs im richtigen Paketordner prüfen. |

Bei späteren Releases Schritte 2 bis 7 wiederholen. Bereits veröffentlichte Artefakte nicht durch Löschen und Neuupload ersetzen. Bei einem Releaseproblem eine korrigierte neue Version veröffentlichen und die Registry-Funktionen für Deprecation beziehungsweise Retract prüfen.

Offizielle Referenzen: [npm publish](https://docs.npmjs.com/cli/v11/commands/npm-publish/), [Dart/Pub-Veröffentlichung](https://dart.dev/tools/pub/publishing), [Pub-Dry-run](https://dart.dev/tools/pub/cmd/pub-lish).
