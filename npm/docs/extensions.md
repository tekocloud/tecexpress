# Erweiterungen · 0.5.0

Alle Exporte sind eigenständige Implementierungen. Die [DevExtreme-Komponenten](https://js.devexpress.com/Vue/Documentation/ApiReference/UI_Components/) dienen als funktionale Orientierung. Es besteht keine austauschbare DevExpress-API und keine vollständige Abdeckung aller herstellerspezifischen Optionen.

[DataSource-Konfiguration und Datenverträge](data-source.md) · [Gemeinsame Funktionsmatrix für Vue und Flutter](../../flutter/EXTENSIONS.md).

## Öffentliche Komponenten

| Export | Zentrale Props und Ereignisse |
| --- | --- |
| `TxRadioGroup` | `items/dataSource`, `v-model`, `layout`, `disabled`, `label`; `selectionChanged`, `itemClick`, Slot `item`. |
| `TxButtonGroup` | Zusätzlich `selectionMode: none/single/multiple`; Mehrfachwerte sind Arrays. |
| `TxLookup` | `v-model`, Suche, `placeholder`, `showClearButton`, `applyValueMode: instantly/useButtons`, Slot `item`. Remote-Schlüsselauflösung über `byKey`. |
| `TxTagBox` | Wie Lookup, aber Arraywerte; `showSelectionControls`, `maxDisplayedTags`, `acceptCustomValue`, `customItemCreating`. „Alle“ bezieht sich auf die geladenen Suchergebnisse. |
| `TxRangeSlider` | `v-model="[start,end]"`, `min/max`, `step`, `minRange/maxRange`, `disabled/readOnly`, `format`, `showLabels`; `valueChanged`. |
| `TxRangeSelector` | Zusätzlich `dataSource`, `argumentExpr`, `valueExpr`, `seriesType: area/line/bar`, `tickCount`. Mit Date-Grenzen liefert die Auswahl Dates; Schritte/Abstände sind dann Millisekunden. |
| `TxTabPanel` | API von `TxTabs`; Default-Slot `{ selectedIndex, item }` enthält den aktiven Inhalt. Tabs zusätzlich `orientation`, `scrollByContent`, `swipeEnabled`, Item-Icons. |
| `TxList` | `items/dataSource`, `v-model` als Schlüsselarray, `selectionMode`, `searchEnabled`, `allowDeleting`, `allowReordering`, `virtual`, `height`, `itemHeight`; `itemClick/itemDeleted/itemReordered`, Slot `item`. |
| `TxGallery` | `items/dataSource`, `v-model:selectedIndex`, `loop`, `slideshowDelay` (ms, 0 aus), `showIndicator`, `height`, Slot `item`. Autoplay pausiert bei Hover/Fokus und reduzierter Bewegung. |
| `TxFloatingActionButton` | Datengetriebene Einzelaktion oder Speed-Dial; `icon`, `position`, `disabled`, `itemClick`. Positionen: top/bottom-left/right. |
| `TxContextMenu` | Default-Slot als Ziel; Rechtsklick/Langdruck; verschachtelte `items`, `disabled`, `v-model:visible`, `itemClick`. |
| `TxActionSheet` | `v-model:visible`, `items/dataSource`, `title`, `cancelText`, `itemClick`, Slot `item`; unterer Bildschirmrand. |
| `TxLoadPanel` | `visible` oder `dataSource`, `delay`, `message`, `shading`, `fullScreen`; für lokale Overlays einen positionierten Container verwenden. |
| `TxFileManager` | `provider`, optional `dataSource`, `view: details/tiles`, `disabled`; `selectionChanged`, `fileOpened`, `error`. |
| `TxFileUploader` | `adapter`, optional `dataSource<File>`, `multiple`, `accept`, `minFileSize/maxFileSize`, `uploadMode: instantly/useButtons`; `valueChanged/uploaded/uploadError/progress`. Exponierte Methoden `upload()`/`cancel()`. |
| `TxMap` | `center`, `zoom/minZoom/maxZoom`, `tileUrl`, `attribution`, `markers/dataSource`, `routes/routeDataSource`, `width/height`, `disabled`; `update:center/update:zoom`, `markerClick`, `tileError`. |

Popup erhält `height`, `fullScreen`, `dragEnabled`, `resizeEnabled`, `position: center/top/bottom`, synchrone abbrechbare `showing/hiding`-Ereignisse `{ cancel }`. Die Hiding-Prüfung betrifft komponenteninitiierte Schließwünsche; eine von außen auf false gesetzte Sichtbarkeit schließt direkt. Tooltip unterstützt `visible`, `showDelay/hideDelay`, `showOn: hover/click`, `position: top/bottom`, `shown/hidden`, Slot `content`. Toast unterstützt `warning`, Position und Slot `actions`.

## Dateien und Upload

```ts
import { TxMemoryFileProvider, txHttpUpload } from '@tekocloud.de/tecexpress'
const provider = new TxMemoryFileProvider()
const adapter = txHttpUpload({ url: '/api/upload', fieldName: 'file' })
```

Der Datei-Provider bietet `list` sowie optionale `createDirectory`, `rename`, `copy`, `move`, `remove`, `upload`, `download`. Nicht angebotene Operationen werden ausgeblendet. Einträge haben `id`, `parentId`, `name`, `isDirectory`, optionale `size/modified/content`. Namen werden im Speicher-Provider auf Leerwerte/Pfadtrenner geprüft; Zyklusverschiebungen und Namenskollisionen werden abgelehnt. Inhalte bleiben im Arbeitsspeicher; es gibt keine Persistenz.

Ein Uploadadapter ist `(file, { signal, onProgress }) => Promise<result>`. `txHttpUpload` verwendet Multipart/XHR, Fortschrittsereignisse, konfigurierbare Header/Felder und optional `chunkSize/chunkFields`. Der Server muss das gewählte Chunk-Protokoll selbst zusammensetzen. Wiederholung beginnt die Datei von vorn. `accept`/Größenprüfung im Client ersetzen keine Serverprüfung. Die Bibliothek liefert keinen Dateiserver.

## Karte und Benachrichtigungen

`tileUrl` verwendet `{z}/{x}/{y}`. Ohne Quelle werden Marker/Routen auf einer neutralen Fläche dargestellt. Eine Quelle wird nicht automatisch kontaktiert; Attribution und Zugangsbedingungen konfiguriert die Anwendung. `TxGeoAdapter` beschreibt austauschbare `geocode`-/`route`-Funktionen; ihre Ergebnisse werden als Koordinaten beziehungsweise Routenpunkte an die Karte gebunden. Es gibt keine automatisch berechneten Routen. `txProject/txUnproject` liefern Web-Mercator-Umrechnung.

```ts
import { notify } from '@tekocloud.de/tecexpress'
const message = notify({ message: 'Upload läuft', displayTime: 0 })
message.update({ message: 'Upload abgeschlossen', type: 'success', displayTime: 3000 })
// message.close()
```

Meldungen werden je Position gestapelt. Optionen: `message`, `type: info/success/warning/error`, `displayTime`, `position`, `action: { text, onClick }`. SSR-Aufrufe erzeugen keine DOM-Seiteneffekte. Die Anwendung schließt dauerhaft angelegte Meldungen über das Handle.
