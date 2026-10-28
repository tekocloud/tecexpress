# Erweiterungen und Funktionsmatrix · 0.5.0

Die [Paket-README](https://github.com/tekocloud/tecexpress/blob/main/flutter/README.md#de-api)
enthält die vollständige öffentliche API mit deutschen und englischen Erklärungen
und einfachen Beispielen. Die folgende Matrix beschreibt ergänzend die Unterschiede
zwischen Vue und Flutter.

Die Bibliotheken bieten 37 Komponenten beziehungsweise Konfigurationen und zusätzlich DataSource-/Store-/Provider-APIs. Die Zuordnung beschreibt die tatsächlich implementierten Fähigkeiten; eine vollständige DevExtreme-Options- oder API-Kompatibilität wird nicht behauptet.

## Gemeinsame DataSource

```dart
final source = TxDataSource<TxItem<int>>(TxDataSourceConfig<TxItem<int>>(
  store: TxArrayStore([const TxItem(value: 1, text: 'Entwicklung')], keyOf: (item) => item.value),
  keyOf: (item) => item.value,
  pageSize: 20,
));
// TxLookup<int>(dataSource: source, value: selected, onChanged: ...)
// Der Eigentümer ruft source.dispose() auf.
```

Alle datenführenden Widgets akzeptieren bei `dataSource` eine `List<T>`, `TxDataSourceConfig<T>` oder `TxDataSource<T>`. Der Parameter ist für diese rückwärtskompatible Union als `Object` deklariert; generische Widget-/Source-Typen ausdrücklich angeben. Der Lifecycle-Adapter prüft den Typ beim Binden. `items` bleibt nutzbar; `dataSource` hat Vorrang. Arraylisten bleiben synchron, konfigurierte Stores laden asynchron. Eigene Instanzen werden vom Widget nicht entsorgt.

`TxDataSourceConfig<T>` enthält `store`, `keyOf`, `sort`, `filter`, `searchExpr/searchValue`, `group`, `pageSize/pageIndex/paginate`, `remoteOperations`, `select/map`. Flutter verwendet typisierte Getter statt JavaScript-Feldpfaden. `select/map` transformieren nach `T`; Projektionen müssen den gewählten Typ weiter erfüllen.

`TxLoadOptions<T>` bietet dieselben Abfrageinformationen sowie `skip/take`, Count-Anforderungen und `TxCancellation`. `TxLoadResult<T>` liefert `data`, `totalCount`, `groups`, `groupCount`. `TxGroup<T>` enthält Schlüssel, direkte Items, Anzahl und Untergruppen. Gruppenpaging betrifft oberste Gruppen; Zeilenverbraucher verwenden die flachen `data`.

`TxCustomStore<T>` nimmt Callbacks für `load`, optional `byKey/insert/update/remove` an und meldet diese Fähigkeiten über `can…`. Remote-Stores verarbeiten Abfragen standardmäßig selbst und liefern die Gesamtanzahl. Bei `remoteOperations: false` müssen sie alle Rohdaten liefern. Das Backend-Protokoll bestimmt die Anwendung. Getterfunktionen sind nicht serialisierbar.

`TxSort<T>` beschreibt Getter und Richtung. `TxFilter<T>` bietet Vergleichs-/Textoperatoren sowie `TxFilter.and/or/not`. `TxDataSource.configure(...)` lädt neu und setzt bei Suche, Filter und Seitengröße die Seite zurück; `clearFilter: true` entfernt den Filter. `items`, `groups`, `totalCount`, `loading`, `loaded`, `error` sind beobachtbar über ChangeNotifier. `TxDataSourceBuilder<T>` verbindet beliebige eigene Oberflächen damit. `cancel()` und Generationsprüfung verhindern veraltete Ergebnisse.

`insert/update/remove` schreiben über den Store und laden neu. Flutter-Updates verwenden `T Function(T)`. `push(List<TxPush<T>>)` führt solche Store-Operationen nacheinander aus; keine Transaktion und keine automatische WebSocket-Anbindung. Kalender und Chat schreiben bei DataSource-Bindung über diesen Vertrag. Für vollständige Verläufe `paginate: false` konfigurieren.

Geteilte Instanzen teilen den Abfragezustand; unabhängige Ansichten brauchen eigene Instanzen. DataGrid/CardView verarbeiten geladene Seiten nicht erneut lokal. Auswahl bleibt über Seiten/Filter erhalten; bekannte Löschungen werden entfernt. Bei externen Remote-Löschungen muss die Anwendung die betroffenen Schlüssel aktualisieren. Eine neue DataSource ersetzt Store/Key-Konfiguration.

## Funktionen und Unterschiede

| Element | Vue und Flutter | Plattform-/Umfangsgrenzen |
| --- | --- | --- |
| RadioGroup | Datenbindung, Einzelwahl, Anordnung, deaktivierte Einträge | Vue String-/Item-Objekte; Flutter `TxItem<T>` und native RadioGroup. |
| ButtonGroup | Keine/einfache/mehrfache Auswahl, Datenbindung | Flutter verwendet FilterChips; Item-Icons und native Darstellung je Framework. |
| TagBox | Mehrfachwerte, Tags, Suche, geladene Auswahl, Bestätigung, eigene Werte | Vue `acceptCustomValue`; Flutter `onCustomItemCreating`; „Alle“ meint geladene Einträge. |
| Lookup | Suchbare Einzelwahl, Remote-Laden, Paging, Schlüsselauflösung | Vue Dialog, Flutter BottomSheet; eigene Datenformen über Mapping/`TxItem<T>`. |
| RangeSlider | Zwei Grenzen, Schritte, Mindest-/Höchstabstand, Beschriftung | Der ausgewählte Bereich kann als Ganzes verschoben werden. |
| RangeSelector | Datenserien, numerische/zeitliche Achse, Linie/Balken/Fläche | Flutter `TxRangeSelector.date` übersetzt DateTimeRange; keine allgemeine Chart-Engine. |
| FloatingActionButton | Einzelaktion/Speed-Dial, Aktionen, Icons | Vue positioniert per Prop; Flutter innerhalb des gewünschten Stack-/Scaffold-Platzes einbauen. |
| FileManager | Ordnerbaum, Pfad, Details/Kacheln, Auswahl, Dateioperationen, Upload/Download | Providerfähigkeiten bestimmen Aktionen; Ziel-ID für Kopieren/Verschieben; kein Server enthalten. |
| FileUploader | Auswahl, Drop, Größen-/Typprüfung, Fortschritt, Abbruch, Wiederholung, Chunk-Adapter | Drop/Picker abhängig von OS/Plugin; Wiederholung startet neu. Flutter-HTTP meldet Fortschritt je abgeschlossenem Chunk. |
| Popup | Fokus, Escape, Außenklick, Größe, Verschieben, Resize, Vollbild, Aktionen | `onShowing/onHiding` beziehungsweise Events können Benutzeraktionen abbrechen; externe Sichtbarkeit bleibt maßgeblich. |
| Toast/notify | Meldungstypen, Laufzeit, programmatische Handles und Meldungsstapel | Vue `notify`, Flutter `txNotify`; deklarative Toasts behalten ihren bisherigen Vertrag. |
| Tooltip | Text, native/DOM-Semantik, Verzögerung, Aktivierung | Steuerbare Sichtbarkeit und eigene Inhalte; Vue Top/Bottom-Kollisionskorrektur, Flutter nativer Tooltip. |
| Tabs/TabPanel | Datengebundene Reiter und aktive Inhalte, Tastatur | Ausrichtung, Icons, Swipe und verzögert erstellter aktiver Inhalt; Flutter mit AnimatedSwitcher. |
| ContextMenu | Rechtsklick/Langdruck, deaktivierte Einträge, verschachtelte Aktionen | Vue HTML-Untermenüs, Flutter aufeinanderfolgende native Popup-Menüs. |
| ActionSheet | Aktionen, Titel, Abbrechen | Flutter `TxActionSheet.show`; Vue `visible` und unterer Bildschirmrand. |
| List | Suche, Auswahl, Paging, Virtualisierung, Löschen/Umordnen | Vue feste Zeilenhöhe bei Virtualisierung; Flutter Builderliste, `groupOf`, Delete-/Reorder-Callbacks. |
| Gallery | Navigation, Indikatoren, Seitenwechsel, Schleife/Autoplay | Flutter PageView; Loop betrifft programmatische Navigation. Kein Medienplayer. |
| LoadPanel | Ladeoverlay, Text, Verzögerung, Shading, Source-Ladezustand | Vue `fullScreen`; Flutter Größe durch Container/Stack, für Vollbild entsprechend einbauen. |
| Map | Kacheln, Pan/Zoom, Marker, Popups und Routenlinien | Konfigurierbare Quellen/Attribution; Geo-Adapter werden von der Anwendung aufgerufen. Keine automatische Routing-/Geocoding-API. |

Die Matrix benennt bewusst Unterschiede der nativen Bedienung. Nicht enthalten sind sämtliche herstellerspezifischen Theme-Pixel, Optionsaliasnamen, OData-/DevExtreme-Serverprotokolle, ein produktiver Dateiserver, integrierte Kartenanbieter-Schlüssel, resumierbare Uploadprotokolle und eine vollständige Chart-/GIS-Engine.

## Datei- und Kartenadapter

`TxFileProvider` liefert `list` und eine `capabilities`-Menge für `createDirectory/rename/copy/move/remove/upload/download`. `TxMemoryFileProvider` implementiert diese Operationen im Speicher, einschließlich Namenskollisionen, rekursivem Kopieren/Löschen und Zyklusschutz. `txFileStore(provider, parentGetter)` macht daraus einen CustomStore. Einträge sind `TxFileEntry` mit stabiler ID, Parent-ID, Name, Typ, Größe und optionalem Inhalt.

`TxFileUploader.dataSource` kann eine Liste, Konfiguration oder Instanz mit `XFile`-Einträgen liefern. `TxUploadAdapter` erhält ein exportiertes `XFile` und `TxUploadContext(cancellation, onProgress)`. `txHttpUpload(TxHttpUploadConfig(...))` verwendet Multipart mit konfigurierbaren Headern/Feldern und optional `chunkSize/chunkFields`. Serverseitige Zusammenführung ist ein Vertrag der Anwendung. Dateiinhalt wird derzeit für den HTTP-Adapter in den Speicher gelesen. Der Speicher-Provider ist ebenfalls nicht für beliebig große Dateien vorgesehen.

`file_selector` übernimmt die native Dateiauswahl, `desktop_drop` Drop-Ereignisse. Die verfügbaren Dialoge unterscheiden sich je Plattform. Flutter-Downloads unterstützen `onDownload(entry, bytes)` für eine eigene Plattformintegration; ohne Callback wird ein Speicherdialog versucht. Browser-/Mobilanwendungen mit anderen Speichermöglichkeiten verwenden den Callback. Windows-Pluginbuilds benötigen Symlink-Unterstützung.

`TxMap` verwendet `TxCoordinate`, `TxMapMarker`, `TxMapRoute`, getrennte Marker-/Routenquellen und konfigurierbare Kachel-URLs `{z}/{x}/{y}`. `TxGeoAdapter` beschreibt Geocoding/Routing; Ergebnisse werden an die Karte gebunden. Zugangsdaten und Attribution konfiguriert die Anwendung. Ohne Quelle bleiben Marker/Routen auf einer neutralen Fläche bedienbar; es gibt keinen impliziten externen Kartenaufruf.

## Migration von 0.4.0

Bestehende Listen-, `items`-, `value`-/Callback- und Vue-`v-model`-Aufrufe bleiben gültig. Die bisherigen 21 Komponenten/Konfigurationen werden weiterhin exportiert. Neue DataSource-Instanzen bewusst teilen oder trennen; sie sind keine reine Datensammlung, sondern besitzen Abfragezustand. Flutter-Verbraucher übernehmen beim Dependency-Update die neuen Datei-/HTTP-Plugins. Es erfolgt keine Veröffentlichung durch die Bibliothek.
