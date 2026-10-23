# Änderungen

## 0.4.0 · 23.10.2026

- Eigenständig veröffentlichbares Vue-Paket im Ordner npm/; stabile Exporte und Theme-Pfade.
- Native Flutter-Gegenstücke in flutter/, gemeinsame Release-Anleitung im Projektstamm.
- Workspace-Weiterleitungen, Registry-Metadaten, Prepack-Prüfungen und plattformübergreifende CI.

## 0.3.0 · 23.10.2026

- `TxCard` mit Header-, Medien-, Aktions-, Inhalts- und Footer-Slots sowie drei Darstellungsvarianten.
- `TxCardView` mit lokalen Daten, Suche, Pagination, Auswahl und Vorlagen.
- `TxChat` mit Nachrichtenmodell, Autoren, Zeitstempeln, Schreibanzeigen, Enter/Shift+Enter und IME-Unterstützung.
- Abbrechbares Sendeereignis für eigene Backends; lokale Nachrichtenverwaltung, Auto-Scroll und Hinweis auf neue Nachrichten beim Hochscrollen.
- Light-/Dark-Theme, responsive Demo, Dokumentation und Tests für Karten und Chat.
- Switch-Dekoration blockiert keine direkten Klicks auf das native Eingabeelement mehr.

## 0.2.0 · 23.10.2026

- `TxScheduler`: Tages-, Wochen- und Monatsansicht mit Datumsnavigation.
- Lokale Termine anlegen, bearbeiten und nach Bestätigung löschen; kontrollierte Daten über `v-model:data-source`.
- Ganztägige und mehrtägige Termine, überschneidungsfreie Spaltenanordnung paralleler Termine und eigener Termin-Slot.
- Validierung, abbrechbare Änderungsereignisse, Konflikterkennung und granulare Editierrechte.
- Kalenderarithmetik über Sommerzeit- und Monatsgrenzen, Tastaturbedienung, Light-/Dark-Theme und responsive Demo.
- Keine Wiederholungen, Ressourcen oder Drag-and-drop in dieser Version.

## 0.1.0 · 23.10.2026

- Eigenständiges ESM-Paket `tecexpress` für Vue 3 mit TypeScript-Deklarationen und optionalem Plugin.
- 16 UI-Komponenten plus `TxColumn`-Konfiguration.
- DataGrid mit lokalen Daten, Filterzeile, Sortierung, Pagination, Auswahl und Zell-Slots.
- Light- und Dark-Theme, semantische CSS-Tokens und Laufzeitumschaltung.
- Vite-Demo, Unit-/Interaktions- und Chromium-Browsertests sowie isolierter Pakettest.
- Keine DevExtreme-Abhängigkeiten und kein Lizenzkey.
