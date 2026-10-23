# tecexpress Flutter Showcase

Alle 21 Komponenten und Konfigurationen mit Light-/Dark-Theme. `flutter pub get` und `flutter run -d chrome` beziehungsweise `flutter run -d windows` starten die lokale Demo. Die App sendet keine Daten an einen Server und wird nicht als eigenes pub.dev-Paket veröffentlicht.

## Bereiche

- Eingaben und Oberfläche: Editoren, Tabs, Menü, Toolbar, Popup, Tooltip, Toast und Ladeanzeige.
- DataGrid: Sortieren, Filtern, Pagination und Auswahl mit typisierten Spalten.
- Scheduler: Tages-/Wochen-/Monatsansicht und lokale Terminbearbeitung.
- Cards: Einzelkarten und durchsuchbares Kartenraster.
- Chat: lokale Nachrichten, Eingaben und simulierte Schreibanzeige.

`flutter test` prüft Start, Themewechsel sowie alle Bereiche auf Desktop und Mobil. Die visuellen Tests erzeugen Screenshots unter `build/qa/`; sie werden nicht veröffentlicht.
