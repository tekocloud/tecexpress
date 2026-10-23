# tecexpress

Eigenständige UI-Bibliotheken unter MIT-Lizenz, ohne Lizenzkey: Vue 3 und natives Flutter mit Light-/Dark-Themes.

**Veröffentlichen: [PUBLISHING.md](PUBLISHING.md) erklärt Schritt für Schritt den Upload auf npm und pub.dev.** Es wird nichts automatisch veröffentlicht.

| Ordner | Inhalt | Einstieg |
| --- | --- | --- |
| [`npm/`](npm/) | Vue-Paket `tecexpress` 0.4.0, TypeScript, CSS-Themes, Demo und Tests | [Vue-Anleitung](npm/README.md) |
| [`flutter/`](flutter/) | Flutter-Paket `tecexpress` 0.4.0 für Android, iOS, Web, Windows, macOS und Linux | [Flutter-Anleitung](flutter/README.md) |

Die aktuellen 21 Komponenten und Konfigurationen stehen auf beiden Seiten zur Verfügung. [Funktions- und API-Zuordnung](flutter/COMPONENTS.md). Die APIs folgen den Konventionen des jeweiligen Frameworks.

## Vue entwickeln

Im Projektstamm, mit Node.js 24.15+ innerhalb von 24.x:

```sh
npm ci
npm run build
npm run dev
```

Demo: http://127.0.0.1:5173. `npm test`, `npm run typecheck`, `npm run test:browser`, `npm run build:demo` und `npm run test:package` funktionieren weiterhin aus dem Stamm. Der Workspace-Stamm ist privat; das öffentliche Paket liegt in `npm/`.

## Flutter entwickeln

Mit Flutter 3.47.7 / Dart 3.13.5 oder kompatiblen neueren Versionen:

```sh
cd flutter
flutter pub get
flutter analyze
flutter test
cd example
flutter pub get
flutter run -d chrome
```

Alternativ `flutter run -d windows`. Weitere Plattformen benötigen ihre üblichen SDKs und Build-Werkzeuge. Der Showcase demonstriert alle 21 Gegenstücke.

## Validierung und CI

Die Workflows unter `.github/workflows/` prüfen das npm-Paket sowie Flutter und Beispiel-Builds für alle sechs Zielplattformen. Lokale und noch nicht auf GitHub ausgeführte Prüfungen sind im [Prüfbericht](VALIDATION.md) getrennt dokumentiert.

Backend-/KI-Dienste, Scheduler-Serien und Ressourcenplanung gehören nicht zum aktuellen Umfang. [MIT-Lizenz](LICENSE).
