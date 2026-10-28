# Änderungen

## 0.7.1 · 2026-10-28

- Swift-Package-Manager-Unterstützung für iOS/macOS mit gemeinsamen Quellen für SPM und CocoaPods ergänzt.
- Android auf Built-in Kotlin umgestellt; Legacy-Kotlin-Plugin-Anwendung und eigener KGP-Classpath entfernt.
- Beispiel-App verwendet Built-in Kotlin; CI prüft Apple-Builds mit SPM und CocoaPods getrennt.
- Adds Swift Package Manager support for iOS/macOS while preserving CocoaPods; migrates Android to built-in Kotlin. Runtime dependencies remain SDK-only.


## 0.7.0 · 2026-10-28

- Breaking: XFile durch den eigenen Typ TxFile mit expliziter Ressourcenfreigabe ersetzt.
- Alle direkten externen Laufzeit-Abhängigkeiten entfernt; SDK-Abhängigkeiten bleiben.
- Eingebaute System-Dateidialoge, Datei-Drops und Speichern für Android, iOS, macOS, Windows, Linux und Web.
- Eigener Multipart-/Chunk-HTTP-Transport und deutsche/englische Datumsformatierung.
- SDK-Abhängigkeitsprüfung, Datei-/Abbruchtests und manuelle Plattformprobe ergänzt.
- Breaking: replace XFile with TxFile; remove direct third-party runtime dependencies;
  add built-in platform file integration and HTTP transport. See MIGRATION-0.7.md
  for ownership, setup, locale fallback and required device acceptance checks.

## 0.6.1 · 2026-10-28

- desktop_drop auf >=0.8.0 <0.8.1 begrenzt, um die unbedingte D-Bus/FFI-Abhängigkeit späterer 0.8.x-Versionen zu vermeiden.
- WASM-Release-Build der Beispielanwendung zur CI hinzugefügt.
- Einschränkung: Linux-Drag-and-drop über das File-Transfer-Portal (etwa in Flatpak) ist vorübergehend nicht verfügbar.
- Restrict desktop_drop to >=0.8.0 <0.8.1 to avoid unconditional D-Bus/FFI imports; add a Wasm release build to CI. Linux file-transfer portal drag-and-drop is temporarily unavailable.

## 0.6.0 · 2026-10-28

- Vollständige deutsche und englische Paketdokumentation aller öffentlichen APIs mit einfachen Beispielen direkt in der README.
- Ergänzte Dart-API-Kommentare für die generierte Referenz auf pub.dev.
- README unterhalb der pub.dev-Grenze von 262144 Bytes; automatisierte Größen-, Abdeckungs- und Beispielprüfungen.
- Complete German and English API documentation, examples and Dart API comments; compact README with automatic pub.dev size checks.

## 0.5.0 · 2026-10-27

- TxDataSource mit konfigurierbaren Array-/Custom-Stores, Filtern, Suche, Sortierung, Gruppen, Paging, CRUD, Abbruch und Änderungsbenachrichtigungen.
- DataSource-Bindung auch für bestehende Komponenten, ohne zweite lokale Seitenverarbeitung in Grid/CardView.
- 16 zusätzliche Widgets und erweiterte Popup-/Tooltip-/Toast-Funktionen; programmatische Benachrichtigungsstapel.
- Datei-Provider, Speicher-Provider, Dateiauswahl/Drop, HTTP-/Chunk-Uploads und konfigurierbare Kachelkarte.
- Erweiterte Showcases, API-/Migrationsdokumentation und Prüfungen. Plattformgrenzen stehen in EXTENSIONS.md.

## 0.4.0 · 2026-10-23

- Erstes eigenständiges natives Flutter-Paket mit 21 Gegenstücken zur Vue-Bibliothek.
- Light-/Dark-Theme über `ThemeData` und anpassbare `TxThemeData`-Tokens.
- Editoren, Navigation, Popup, Tooltip, Toast und Ladeanzeige.
- DataGrid und CardView mit lokalen Daten, Filtern/Suche, Pagination, Auswahl und Buildern.
- Scheduler mit Tag/Woche/Monat, Terminbearbeitung, Ganztags-/mehrtägigen und parallelen Terminen, Cancellation und Konflikterkennung.
- Chat mit lokalen Nachrichtenmodellen, Autoren, Zeitstempeln, IME-/Tastaturbedienung, Schreibanzeige und Auto-Scroll.
- Beispiel-App für Android, iOS, Web, Windows, macOS und Linux sowie Tests und Release-Anleitung.
