# Flutter 0.7.1 – Plattform-Paketierung

## Korrekturen

- SwiftPM-Manifeste unter `ios/tecexpress/Package.swift` und
  `macos/tecexpress/Package.swift` ergänzt.
- Swift-Quellen unverändert nach `tecexpress/Sources/tecexpress/` verschoben;
  CocoaPods verwendet dieselben Dateien über die aktualisierten Podspecs.
- SwiftPM bindet ausschließlich das lokale FlutterFramework-SDK ein.
- Android wendet kein separates Kotlin-Plugin mehr an und enthält keinen
  eigenen KGP-Classpath. Beispiel-App aktiviert Built-in Kotlin unter AGP 9.1.
- Release-Metadaten, Beispiel-App und native Versionsangaben auf 0.7.1 erhöht.

Die Umsetzung folgt den Flutter-Anleitungen für
[Swift Package Manager](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors)
und [Built-in Kotlin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors).

## Lokal bestätigt

Die beiden Prüfungen wurden direkt mit dem tatsächlichen Tagger aus
`pana` **0.23.19** gegen den Paketordner ausgeführt:

```json
{
  "tags": ["is:swiftpm-plugin", "is:built-in-kotlin"],
  "previousLegacyKotlinDetected": true,
  "currentLegacyKotlinDetected": false,
  "explanations": []
}
```

- `flutter analyze --no-pub`: keine Befunde.
- 47 Pakettests und der Showcase-Widgettest erfolgreich.
- SDK-Abhängigkeitsprüfung, Formatprüfung und neue Prüfung der nativen
  Paketstruktur erfolgreich.
- Vorherige und verschobene Swift-Quelldateien auf unveränderten Inhalt geprüft.
- Versionsangaben in Manifesten und npm-Lockdatei konsistent.
- Android-Debug-APK mit aktiviertem Built-in Kotlin erfolgreich gebaut:
  `example/build/app/outputs/flutter-apk/app-debug.apk`. Der Compiler wird über
  eine nicht angewendete (`apply false`) Deklaration in der Beispiel-App auf
  2.4.0 gesetzt. Das Android-Plugin selbst wendet kein separates KGP an.
- Veröffentlichungsvorschau enthält beide Package.swift-Manifeste, beide neuen
  Source-Verzeichnisse und die aktualisierten Podspecs. Noch vorhandene Warnungen
  betreffen den nicht committeten Git-Zustand einschließlich der verschobenen Dateien.

## Noch zu bestätigen

- Apple-Builds können auf diesem Windows-Rechner nicht ausgeführt werden. CI
  enthält für iOS und macOS jeweils separate Builds mit aktiviertem SwiftPM und
  deaktiviertem SwiftPM (CocoaPods). Diese CI-Ergebnisse stehen noch aus.
- Die übrigen Geräteprüfungen aus VERIFICATION-0.7.md bleiben erforderlich.

## Lokale Java-Besonderheit

Der erste Android-Buildversuch scheiterte vor der Projektkompilierung an
`Unable to establish loopback connection`. Für den erfolgreichen Build wurde
ausschließlich im gestarteten Shell-Prozess ein temporäres Socket-Verzeichnis
gesetzt; keine Java- oder Windows-Systemeinstellung wurde geändert:

```powershell
# Aus flutter/example:
New-Item -ItemType Directory -Path build/java-sockets -Force
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:/source/own/tecexpress/flutter/example/build/java-sockets'
flutter build apk --debug --no-pub
```

Dies war für die lokale Java-17-/Windows-Umgebung erforderlich und ist keine
Voraussetzung für die Plugin-Nutzung oder die pub.dev-Tag-Erkennung.

Vor Veröffentlichung alle Änderungen einschließlich der neuen SwiftPM-Ordner
committen und die nativen CI-Builds abwarten. Nichts wurde veröffentlicht.
Die tatsächliche pub.dev-Gesamtpunktzahl kann erst nach der Neubewertung von
0.7.1 bestätigt werden; die zwei beanstandeten Tagger-Prüfungen bestehen lokal.
