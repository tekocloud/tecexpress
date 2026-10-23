# tecexpress für Flutter

Native Flutter-UI-Bibliothek unter MIT-Lizenz, Version **0.4.0**, ohne Lizenzkey. Alle 21 vorhandenen tecexpress-Komponenten beziehungsweise Konfigurationen sind enthalten. Keine WebView, keine DevExtreme-Laufzeitabhängigkeit, keine kommerzielle UI-Abhängigkeit.

**Veröffentlichung auf pub.dev und npm: [zentrale Anleitung im Repository](https://github.com/tekocloud/tecexpress/blob/main/PUBLISHING.md).**

## Installation

Nach Veröffentlichung:

```sh
flutter pub add tecexpress
```

Vor Veröffentlichung aus einer lokalen App:

```yaml
dependencies:
  tecexpress:
    path: /pfad/zu/tecexpress/flutter
```

Flutter **3.47.7+**, Dart **3.13.5+**. Zielplattformen: Android, iOS, Web, Windows, macOS und Linux. Die Bibliothek nutzt gemeinsame Flutter-Widgets; die Beispiel-App enthält Hostprojekte für alle Plattformen.

## Einstieg und Themes

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

void main() => runApp(MaterialApp(
  theme: TxTheme.light(),
  darkTheme: TxTheme.dark(),
  themeMode: ThemeMode.system,
  locale: const Locale('de'),
  localizationsDelegates: TxLocalizations.delegates,
  supportedLocales: TxLocalizations.supportedLocales,
  home: Scaffold(body: Padding(
    padding: const EdgeInsets.all(24),
    child: TxCard(title: 'Hallo tecexpress', child: TxButton(
      text: 'Los geht’s', type: TxButtonType.primary, onPressed: () {},
    )),
  )),
));
```

`TxThemeData` ist eine `ThemeExtension`. Eigene Tokens mit `TxTheme.light(tokens: TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12))` übergeben. `txThemeOf(context)` liefert die aktuellen Tokens. Die Musterfarben entsprechen der Vue-Version, die Bedienung folgt Flutter.

## Eingaben und Daten

Texte verwenden `TextEditingController` oder `initialValue`, andere Eingaben `value` und `onChanged`. Externe Controller gehören der Anwendung; intern erzeugte Controller werden von den Widgets entsorgt. `disabled`, `readOnly` und `isValid` werden dort unterstützt, wo in der Zuordnung beschrieben. Fehlerdarstellung ersetzt kein eigenes Validierungssystem.

```dart
TxSelectBox<int>(
  label: 'Kategorie', value: selected,
  items: const [TxItem(value: 1, text: 'Technik'), TxItem(value: 2, text: 'Design')],
  onChanged: (value) => setState(() => selected = value),
);
```

Generische Datenkomponenten benötigen `keyOf` (eindeutige String-/Integer-Schlüssel) und typisierte Getter. Ein `TxColumn<T>` ist Konfiguration, kein Widget.

```dart
TxDataGrid<Map<String, Object>>(
  dataSource: const [{'id': 1, 'name': 'Werkraum Berlin'}],
  keyOf: (row) => row['id']!,
  columns: [TxColumn(caption: 'Name', valueGetter: (row) => row['name'])],
  selection: TxSelectionMode.multiple,
  onSelectedRowKeysChanged: (keys) => setState(() => selectedKeys = keys),
);
```

## Scheduler und Chat

```dart
TxScheduler(
  dataSource: appointments,
  onDataSourceChanged: (next) => setState(() => appointments = next),
  currentDate: DateTime(2026, 10, 23),
  onAppointmentAdding: (change) { if (!mayCreate) change.cancel = true; },
);

TxChat(
  user: TxChatUser(id: 'me', name: 'Stefan'),
  items: messages,
  onItemsChanged: (next) => setState(() => messages = next),
);
```

Bei übergebenen Listen übernimmt die Anwendung Änderungen über die passenden Callbacks. Ohne Liste verwalten Scheduler/Chat ihren Zustand intern. Fest übergebene `currentDate`, `currentView`, Auswahl oder Seitenindizes sind kontrolliert: Zum Navigieren die entsprechenden `on…Changed`-Callbacks mit dem eigenen Zustand verbinden oder die Props weglassen.

Termine verwenden `DateTime`, Ganztagstermine lokale Tagesgrenzen mit exklusivem Ende. Tage werden mit Kalenderarithmetik verschoben, nicht mit festen 24-Stunden-Dauern. UTC-Zeitpunkte werden für die Darstellung in lokale Zeit umgerechnet. Der Scheduler unterstützt keine Serien, Ressourcen oder Drag-and-drop.

Chat zeigt lokale Nachrichten. `onMessageEntered` kann synchron mit `change.cancel = true` abbrechen und eine eigene Backend-Verarbeitung starten. `sent` bedeutet lokale Aufnahme, keine serverseitige Zustellbestätigung. HTML wird als Text angezeigt. Kein Backend oder KI-Dienst enthalten. Enter sendet, Shift+Enter erzeugt eine neue Zeile; laufende IME-Komposition wird berücksichtigt.

## API und Showcase

[Vollständige Zuordnung der 21 Komponenten, Funktionen und Unterschiede](COMPONENTS.md). API-Dokumentation lässt sich mit `dart doc` erzeugen. Ausführbare Beispiele aller Komponenten: `example/lib/showcase.dart`.

```sh
flutter pub get
flutter analyze
flutter test
dart run tool/verify_consumer.dart
cd example
flutter pub get
flutter test
flutter run -d chrome
```

Alternativ `flutter run -d windows`; für andere Plattformen die passenden Hostwerkzeuge verwenden. Deutsche Steuerelemente und Kalender benötigen die oben gezeigten Lokalisierungsdelegates. `locale`-Optionen steuern Datum/Zeit; eigene UI-Bedientexte sind derzeit deutsch.

[Änderungen](CHANGELOG.md) · [MIT-Lizenz](LICENSE) · [Repository](https://github.com/tekocloud/tecexpress)
