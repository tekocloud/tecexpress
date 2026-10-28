# @tekocloud.de/tecexpress

[Deutsch](#de) · [English](#en)

<!-- API tables are generated from source. See tools/documentation/README.md in the repository. -->

<a id="de"></a>
## Deutsch

Vollständige öffentliche API von tecexpress 0.5.0 für Vue 3. MIT-Lizenz, ohne Lizenzkey.

[Installation und Einstieg](#de-start) · [Daten und Zustandsverwaltung](#de-data) · [Dateien, Uploads und Karten](#de-adapters) · [API-Verzeichnis](#de-api) · [Entwicklung](#de-development)

<a id="de-start"></a>
### Installation und Einstieg

```sh
npm install @tekocloud.de/tecexpress vue@^3.5.0
```

Alle folgenden Vue-Beispiele sind vollständige Single-File-Components. Als App.vue speichern und in einer Vue-3-Anwendung mit TypeScript ausführen. Für lokale Entwicklung Node.js 24.15+ innerhalb 24.x verwenden.

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTextBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const text = ref('Alex')
</script>

<template>
  <TxTextBox v-model="text" label="Name" />
</template>
```

Einzelimporte sind möglich; alternativ registriert `app.use(Tecexpress)` alle Komponenten. Props in camelCase können in Templates als kebab-case geschrieben werden.

**Themes**

```ts
import '@tekocloud.de/tecexpress/themes/index.css'
document.documentElement.dataset.txTheme = 'dark' // 'light'
// Fixed theme: import only themes/light.css or themes/dark.css instead.
```

Ohne data-tx-theme gilt Light. Das Attribut funktioniert auch auf einem Container und bleibt für Overlays erhalten. Nach dem CSS-Import können Tokens am Container überschrieben werden.

```css
.my-app { --tx-accent: #6636c6; --tx-radius: 10px; --tx-control-height: 44px; }
```

Verfügbare Tokens: `--tx-font`, `--tx-font-size`, `--tx-radius`, `--tx-space`, `--tx-control-height`, `--tx-bg`, `--tx-surface`, `--tx-surface-alt`, `--tx-text`, `--tx-muted`, `--tx-border`, `--tx-accent`, `--tx-accent-text`, `--tx-hover`, `--tx-selection`, `--tx-danger`, `--tx-success`, `--tx-focus`, `--tx-shadow`, `--tx-backdrop`, `--tx-scheduler-slot-height`.

<a id="de-data"></a>
### Daten und Zustandsverwaltung

Eine Datenbindung akzeptiert Arrays, Konfigurationen oder bestehende DataSource-Instanzen. Bei einer Konfiguration besitzt und entsorgt die Komponente ihre Source; eine übergebene Instanz bleibt Aufgabe der Anwendung. dataSource hat Vorrang vor items. Geteilte Instanzen teilen auch Filter, Suche, Sortierung und Seite. Für unabhängige Ansichten eigene Instanzen verwenden.

Kontrollierte Werte mit v-model beziehungsweise update-Ereignissen übernehmen. Ohne Wertbindung verwalten unterstützte Komponenten ihren Zustand intern.

ArrayStores verarbeiten Abfragen lokal; CustomStores standardmäßig auf dem Server. Bei remoteOperations = false müssen CustomStores sämtliche Rohdaten liefern. Der Serververtrag wird von der Anwendung bestimmt; Getter sind nicht serialisierbar. Für serverseitiges Paging totalCount liefern. Kalender und Chat benötigen vollständige Verläufe oder eine bewusst begrenzte Datenmenge; paginate = false lädt alles.

load/reload/configure können fehlschlagen: await mit try/catch verwenden und error anzeigen. Neue Ladevorgänge ersetzen alte; verspätete Antworten überschreiben keinen neueren Zustand. Schlüssel bleiben eindeutig und unveränderlich. Schreiben ohne passende Store-Operation schlägt fehl. push ist keine Transaktion.

Terminenden liegen nach dem Beginn. Ganztagstermine verwenden lokale Tagesgrenzen mit exklusivem Ende. UTC-Zeitpunkte werden lokal dargestellt. Chat zeigt Text, kein HTML; Backend und KI-Dienst richtet die Anwendung ein.

```ts
import { TxDataSource } from '@tekocloud.de/tecexpress'
const source = new TxDataSource({ store: [{ id: 1, text: 'One' }], paginate: false })
try { await source.load() } catch (error) { console.error(error) }
source.dispose()
```

<a id="de-adapters"></a>
### Dateien, Uploads und Karten

Der MemoryFileProvider speichert nur im Arbeitsspeicher. Ungültige Namen, doppelte IDs/Namen, ungültige Eltern und zyklische Verschiebungen werden abgelehnt. Dateioperationen sind asynchron. Optionale Provider-Methoden bestimmen sichtbare Aktionen; txFileStore unterstützt Laden, Löschen und Umbenennen, sofern angeboten.

HTTP-Uploads benötigen einen eigenen Multipart-POST-Endpunkt. fieldName ist standardmäßig file. Bei chunkSize muss der Server das durch chunkFields vereinbarte Protokoll zusammensetzen. Wiederholung beginnt von vorn. XHR meldet Fortschritt während der Übertragung; withCredentials ist standardmäßig false.

Kartenkacheln verwenden {z}/{x}/{y}. Kachelquelle, Zugangsdaten und Attribution müssen selbst konfiguriert werden. GeoAdapter wird von der Anwendung aufgerufen; seine Ergebnisse werden als Marker/Routen gebunden. Ohne Quelle erfolgt kein impliziter externer Kartenaufruf.

<a id="de-api"></a>
### API-Verzeichnis

- [TxRadioGroup](#de-txradiogroup)
- [TxButtonGroup](#de-txbuttongroup)
- [TxLookup](#de-txlookup)
- [TxTagBox](#de-txtagbox)
- [TxList](#de-txlist)
- [TxGallery](#de-txgallery)
- [TxFloatingActionButton](#de-txfloatingactionbutton)
- [TxContextMenu](#de-txcontextmenu)
- [TxActionSheet](#de-txactionsheet)
- [TxRangeSlider](#de-txrangeslider)
- [TxRangeSelector](#de-txrangeselector)
- [TxFileManager](#de-txfilemanager)
- [TxFileUploader](#de-txfileuploader)
- [TxMap](#de-txmap)
- [TxTabPanel](#de-txtabpanel)
- [TxLoadPanel](#de-txloadpanel)
- [useTxSource](#de-usetxsource)
- [notify](#de-notify)
- [TxNotifyOptions](#de-txnotifyoptions)
- [TxNotifyHandle](#de-txnotifyhandle)
- [TxCollectionItem](#de-txcollectionitem)
- [TxEntry](#de-txentry)
- [TxRangeValue](#de-txrangevalue)
- [txProject](#de-txproject)
- [txUnproject](#de-txunproject)
- [TxCoordinate](#de-txcoordinate)
- [TxMapMarker](#de-txmapmarker)
- [TxMapRoute](#de-txmaproute)
- [TxGeoAdapter](#de-txgeoadapter)
- [TxButton](#de-txbutton)
- [TxTextBox](#de-txtextbox)
- [TxTextArea](#de-txtextarea)
- [TxNumberBox](#de-txnumberbox)
- [TxCheckBox](#de-txcheckbox)
- [TxSwitch](#de-txswitch)
- [TxSelectBox](#de-txselectbox)
- [TxDateBox](#de-txdatebox)
- [TxTabs](#de-txtabs)
- [TxToolbar](#de-txtoolbar)
- [TxMenu](#de-txmenu)
- [TxPopup](#de-txpopup)
- [TxTooltip](#de-txtooltip)
- [TxToast](#de-txtoast)
- [TxLoadIndicator](#de-txloadindicator)
- [TxDataGrid](#de-txdatagrid)
- [TxColumn](#de-txcolumn)
- [TxScheduler](#de-txscheduler)
- [TxCard](#de-txcard)
- [TxCardView](#de-txcardview)
- [TxChat](#de-txchat)
- [EditorValue](#de-editorvalue)
- [ValueChangedEvent](#de-valuechangedevent)
- [Item](#de-item)
- [RowKey](#de-rowkey)
- [DataRow](#de-datarow)
- [Column](#de-column)
- [SortDescriptor](#de-sortdescriptor)
- [RowClickEvent](#de-rowclickevent)
- [SelectionChangedEvent](#de-selectionchangedevent)
- [Appointment](#de-appointment)
- [SchedulerView](#de-schedulerview)
- [SchedulerDate](#de-schedulerdate)
- [SchedulerEditing](#de-schedulerediting)
- [AppointmentEvent](#de-appointmentevent)
- [AppointmentChangeEvent](#de-appointmentchangeevent)
- [AppointmentClickEvent](#de-appointmentclickevent)
- [AppointmentUpdatingEvent](#de-appointmentupdatingevent)
- [AppointmentUpdatedEvent](#de-appointmentupdatedevent)
- [SchedulerCellClickEvent](#de-schedulercellclickevent)
- [CardField](#de-cardfield)
- [CardClickEvent](#de-cardclickevent)
- [CardSelectionChangedEvent](#de-cardselectionchangedevent)
- [ChatUser](#de-chatuser)
- [ChatMessage](#de-chatmessage)
- [ChatMessageEvent](#de-chatmessageevent)
- [ChatMessageEnteredEvent](#de-chatmessageenteredevent)
- [ChatTypingEvent](#de-chattypingevent)
- [Tecexpress](#de-tecexpress)
- [txRead](#de-txread)
- [txMatches](#de-txmatches)
- [txQuery](#de-txquery)
- [TxKey](#de-txkey)
- [TxSelector](#de-txselector)
- [TxSort](#de-txsort)
- [TxFilter](#de-txfilter)
- [TxGroup](#de-txgroup)
- [TxLoadOptions](#de-txloadoptions)
- [TxLoadResult](#de-txloadresult)
- [TxStore](#de-txstore)
- [TxDataSourceConfig](#de-txdatasourceconfig)
- [TxSource](#de-txsource)
- [TxPush](#de-txpush)
- [TxArrayStore](#de-txarraystore)
- [TxCustomStore](#de-txcustomstore)
- [TxDataSource](#de-txdatasource)
- [txFileStore](#de-txfilestore)
- [txHttpUpload](#de-txhttpupload)
- [TxFileEntry](#de-txfileentry)
- [TxFileProvider](#de-txfileprovider)
- [TxMemoryFileProvider](#de-txmemoryfileprovider)
- [TxUploadContext](#de-txuploadcontext)
- [TxUploadAdapter](#de-txuploadadapter)
- [TxHttpUploadConfig](#de-txhttpuploadconfig)

`undefined` (Vue) beziehungsweise optionale nullable Parameter (Dart) bedeuten keinen extern vorgegebenen Wert. Boolean-Props ohne expliziten Vue-Standard sind false. Typen und Standardwerte unten stammen aus der aktuellen Implementierung; zusätzliche Fähigkeiten werden dadurch nicht zugesagt.

<a id="de-txradiogroup"></a>
### TxRadioGroup

Sichtbare Optionsfelder für eine Einzelwahl.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `modelValue` | `any` | `undefined` | Kontrollierter Wert für v-model. |
| `selectionMode` | `"none" &#124; "single" &#124; "multiple" &#124; undefined` | `single` | Auswahlmodus. |
| `layout` | `string &#124; undefined` | `horizontal` | Horizontale oder vertikale Anordnung. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| selectionChanged | Neue Auswahl: { value, itemData }. |
| itemClick | { itemData } |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item, selected } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxRadioGroup } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxRadioGroup v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="de-txbuttongroup"></a>
### TxButtonGroup

Gruppe von Aktionen mit keiner, einfacher oder mehrfacher Auswahl.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `modelValue` | `any` | `undefined` | Kontrollierter Wert für v-model. |
| `selectionMode` | `"none" &#124; "single" &#124; "multiple" &#124; undefined` | `single` | Auswahlmodus. |
| `layout` | `string &#124; undefined` | `horizontal` | Horizontale oder vertikale Anordnung. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| selectionChanged | Neue Auswahl: { value, itemData }. |
| itemClick | { itemData } |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item, selected } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxButtonGroup, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxButtonGroup v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="de-txlookup"></a>
### TxLookup

Suchbare Einzelwahl mit nachladbarer Datenquelle.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `modelValue` | `any` | `undefined` | Kontrollierter Wert für v-model. |
| `placeholder` | `string &#124; undefined` | `Auswählen …` | Hinweis bei leerer Eingabe. |
| `searchEnabled` | `boolean &#124; undefined` | `true` | Aktiviert die Suche. |
| `acceptCustomValue` | `boolean &#124; undefined` | `false` | Erlaubt eigene Einträge. |
| `showSelectionControls` | `boolean &#124; undefined` | `false` | Zeigt Mehrfachauswahl-/Alle-Steuerelemente. |
| `showClearButton` | `boolean &#124; undefined` | `true` | Zeigt die Aktion zum Leeren. |
| `maxDisplayedTags` | `number &#124; undefined` | `4` | Maximal sichtbare Tags vor der Zusammenfassung. |
| `applyValueMode` | `string &#124; undefined` | `instantly` | Übernahme sofort oder über Bestätigung. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |
| customItemCreating | Eigener Text in { text }; eigenen Eintrag über die Anwendung ergänzen. |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxLookup } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxLookup v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="de-txtagbox"></a>
### TxTagBox

Suchbare Mehrfachauswahl mit Tags. Alle auswählen betrifft die geladenen Ergebnisse.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `modelValue` | `any` | `undefined` | Kontrollierter Wert für v-model. |
| `placeholder` | `string &#124; undefined` | `Auswählen …` | Hinweis bei leerer Eingabe. |
| `searchEnabled` | `boolean &#124; undefined` | `true` | Aktiviert die Suche. |
| `acceptCustomValue` | `boolean &#124; undefined` | `false` | Erlaubt eigene Einträge. |
| `showSelectionControls` | `boolean &#124; undefined` | `false` | Zeigt Mehrfachauswahl-/Alle-Steuerelemente. |
| `showClearButton` | `boolean &#124; undefined` | `true` | Zeigt die Aktion zum Leeren. |
| `maxDisplayedTags` | `number &#124; undefined` | `4` | Maximal sichtbare Tags vor der Zusammenfassung. |
| `applyValueMode` | `string &#124; undefined` | `instantly` | Übernahme sofort oder über Bestätigung. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |
| customItemCreating | Eigener Text in { text }; eigenen Eintrag über die Anwendung ergänzen. |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTagBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const keys = ref<number[]>([])
</script>

<template>
  <TxTagBox v-model="keys" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="de-txlist"></a>
### TxList

Liste mit Suche, Auswahl und optionalem Löschen oder Umordnen über Ereignisse.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `modelValue` | `unknown[] &#124; undefined` | `[]` | Kontrollierter Wert für v-model. |
| `selectionMode` | `string &#124; undefined` | `none` | Auswahlmodus. |
| `searchEnabled` | `boolean &#124; undefined` | `false` | Aktiviert die Suche. |
| `grouped` | `boolean &#124; undefined` | `false` | Zeigt die geladenen Einträge nach Gruppen. |
| `allowDeleting` | `boolean &#124; undefined` | `false` | Zeigt Aktionen zum Löschen von Listeneinträgen. |
| `allowReordering` | `boolean &#124; undefined` | `false` | Zeigt Aktionen zum Umordnen von Listeneinträgen. |
| `virtual` | `boolean &#124; undefined` | `false` | Rendert nur den sichtbaren Listenbereich. |
| `itemHeight` | `number &#124; undefined` | `44` | Feste Zeilenhöhe für virtuelle Listen. |
| `height` | `number &#124; undefined` | `300` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| itemClick | { itemData, itemIndex } |
| itemDeleted | Gelöschter Listeneintrag in { itemData }. |
| itemReordered | Umordnung in { itemData, fromIndex, toIndex, items }; items enthält die neue Liste. |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item, index, selected } |

```vue
<script setup lang="ts">
import { TxList } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxList :items="[{ id: 1, text: 'One' }]" search-enabled />
</template>
```

<a id="de-txgallery"></a>
### TxGallery

Durchblätterbare Galerie mit optionaler automatischer Wiedergabe; kein Medienplayer.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `selectedIndex` | `number &#124; undefined` | `undefined` | Nullbasierter aktiver Eintrag. |
| `loop` | `boolean &#124; undefined` | `false` | Erlaubt Umlauf vom letzten zum ersten Galerieeintrag. |
| `slideshowDelay` | `number &#124; undefined` | `0` | Intervall der automatischen Navigation; 0 schaltet sie aus. |
| `showIndicator` | `boolean &#124; undefined` | `true` | Zeigt Galerieindikatoren. |
| `height` | `number &#124; undefined` | `240` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:selectedIndex | Neuer Wert von selectedIndex; über v-model:selectedIndex übernehmen (modelValue: v-model). |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item, index } |

```vue
<script setup lang="ts">
import { TxGallery } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxGallery :items="['One', 'Two']"><template #item="{ item }">{{ item }}</template></TxGallery>
</template>
```

<a id="de-txfloatingactionbutton"></a>
### TxFloatingActionButton

Schwebende Hauptaktion oder aufklappbare Aktionsgruppe.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `icon` | `string &#124; undefined` | `+` | Symbol der Aktion. |
| `position` | `string &#124; undefined` | `bottom-right` | Position der Meldung beziehungsweise des Overlays. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| itemClick | { itemData } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxFloatingActionButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxFloatingActionButton :items="[{ text: 'Add' }]" @item-click="saved = true" />
</template>
```

<a id="de-txcontextmenu"></a>
### TxContextMenu

Kontextaktionen über Rechtsklick oder langes Drücken auf den Zielinhalt.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `visible` | `boolean &#124; undefined` | `false` | Steuert die Sichtbarkeit. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:visible | Neuer Wert von visible; über v-model:visible übernehmen (modelValue: v-model). |
| itemClick | { itemData } |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxContextMenu } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxContextMenu :items="[{ text: 'Copy' }]" @item-click="saved = true">Right click here</TxContextMenu>
</template>
```

<a id="de-txactionsheet"></a>
### TxActionSheet

Aktionsauswahl am unteren Bildschirmrand mit Abbrechen-Aktion.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `visible` | `boolean &#124; undefined` | `false` | Steuert die Sichtbarkeit. |
| `title` | `string &#124; undefined` | `undefined` | Titel der Ansicht. |
| `cancelText` | `string &#124; undefined` | `Abbrechen` | Beschriftung der Abbrechen-Aktion. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:visible | Neuer Wert von visible; über v-model:visible übernehmen (modelValue: v-model). |
| itemClick | { itemData } |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { item } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxActionSheet, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const visible = ref(false)
</script>

<template>
  <TxButton text="Actions" @click="visible = true" />
  <TxActionSheet v-model:visible="visible" :items="[{ text: 'Copy' }]" />
</template>
```

<a id="de-txrangeslider"></a>
### TxRangeSlider

Auswahl eines Intervalls mit zwei Grenzen, Schritten und Mindest-/Höchstabstand.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `[TxRangeValue, TxRangeValue] &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `min` | `number &#124; Date &#124; undefined` | `0` | Untere zulässige Grenze. |
| `max` | `number &#124; Date &#124; undefined` | `100` | Obere zulässige Grenze. |
| `step` | `number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `minRange` | `number &#124; undefined` | `0` | Mindestabstand zwischen den Bereichsgrenzen. |
| `maxRange` | `number &#124; undefined` | `undefined` | Höchstabstand zwischen den Bereichsgrenzen. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `label` | `string &#124; undefined` | `Bereich` | Beschriftung beziehungsweise zugänglicher Name. |
| `showLabels` | `boolean &#124; undefined` | `true` | Zeigt die beiden Bereichsgrenzen als Text. |
| `dataSource` | `TxSource<Record<string, unknown>> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `argumentExpr` | `string &#124; undefined` | `argument` | Feld für die X-Achse der Serie. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `seriesType` | `string &#124; undefined` | `area` | Seriendarstellung area/line/bar. |
| `tickCount` | `number &#124; undefined` | `5` | Anzahl der Achsenbeschriftungen. |
| `format` | `((v: TxRangeValue) => string) &#124; undefined` | `undefined` | Formatiert Bereichswerte für die Anzeige. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | { value } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxRangeSlider } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const range = ref<[number, number]>([20, 80])
</script>

<template>
  <TxRangeSlider v-model="range" :min="0" :max="100" />
</template>
```

<a id="de-txrangeselector"></a>
### TxRangeSelector

Intervallauswahl über einer einfachen Flächen-, Linien- oder Balkenserie.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `[TxRangeValue, TxRangeValue] &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `min` | `number &#124; Date &#124; undefined` | `0` | Untere zulässige Grenze. |
| `max` | `number &#124; Date &#124; undefined` | `100` | Obere zulässige Grenze. |
| `step` | `number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `minRange` | `number &#124; undefined` | `0` | Mindestabstand zwischen den Bereichsgrenzen. |
| `maxRange` | `number &#124; undefined` | `undefined` | Höchstabstand zwischen den Bereichsgrenzen. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `label` | `string &#124; undefined` | `Bereich` | Beschriftung beziehungsweise zugänglicher Name. |
| `showLabels` | `boolean &#124; undefined` | `true` | Zeigt die beiden Bereichsgrenzen als Text. |
| `dataSource` | `TxSource<Record<string, unknown>> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `argumentExpr` | `string &#124; undefined` | `argument` | Feld für die X-Achse der Serie. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `seriesType` | `string &#124; undefined` | `area` | Seriendarstellung area/line/bar. |
| `tickCount` | `number &#124; undefined` | `5` | Anzahl der Achsenbeschriftungen. |
| `format` | `((v: TxRangeValue) => string) &#124; undefined` | `undefined` | Formatiert Bereichswerte für die Anzeige. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | { value } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxRangeSelector } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const range = ref<[number, number]>([20, 80])
</script>

<template>
  <TxRangeSelector v-model="range" :data-source="[{ argument: 0, value: 4 }, { argument: 100, value: 8 }]" />
</template>
```

<a id="de-txfilemanager"></a>
### TxFileManager

Ordnernavigation und Dateiaktionen. Der Provider bestimmt die verfügbaren Operationen; kein Dateiserver enthalten.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<TxFileEntry> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `provider` | `TxFileProvider` | `erforderlich` | Datei-Provider mit unterstützten Operationen. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `view` | `string &#124; undefined` | `details` | Darstellungsmodus. |
| `label` | `string &#124; undefined` | `Dateimanager` | Beschriftung beziehungsweise zugänglicher Name. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| selectionChanged | Neue Auswahl: TxFileEntry[]. |
| fileOpened | Aktivierter TxFileEntry. |
| error | Fehlerobjekt einer Dateioperation. |

```vue
<script setup lang="ts">
import { TxFileManager, TxMemoryFileProvider } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const provider = new TxMemoryFileProvider([{ id: '1', parentId: null, name: 'Documents', isDirectory: true }])
</script>

<template>
  <TxFileManager :provider="provider" />
</template>
```

<a id="de-txfileuploader"></a>
### TxFileUploader

Dateiauswahl und Uploadwarteschlange mit Größen-/Typprüfung, Fortschritt und Wiederholung ab Dateianfang.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<File> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `adapter` | `TxUploadAdapter &#124; undefined` | `undefined` | Uploadfunktion für eine Datei. |
| `multiple` | `boolean &#124; undefined` | `false` | Erlaubt mehrere Dateien. |
| `accept` | `string &#124; undefined` | `undefined` | Browser-Dateitypfilter, etwa .pdf oder image/*. |
| `maxFileSize` | `number &#124; undefined` | `undefined` | Maximale Dateigröße in Bytes. |
| `minFileSize` | `number &#124; undefined` | `0` | Minimale Dateigröße in Bytes. |
| `uploadMode` | `string &#124; undefined` | `useButtons` | Sofortiger oder per Schaltfläche gestarteter Upload. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `Dateien hochladen` | Beschriftung beziehungsweise zugänglicher Name. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |
| uploaded | Upload erfolgreich: { file, result }. |
| uploadError | Upload fehlgeschlagen: { file, error }. |
| progress | Uploadfortschritt in Bytes: { file, loaded, total }. |

Über eine Template-Ref erreichbar: `upload(): Promise<void[]>` startet alle bereiten Warteschlangeneinträge parallel; `cancel(): void` bricht alle laufenden Einträge ab. Beispiel: `await uploader.value?.upload()` beziehungsweise `uploader.value?.cancel()`. Die Ref wird mit `const uploader = ref<{ upload(): Promise<void[]>; cancel(): void } | null>(null)` angelegt und mit `ref="uploader"` gebunden.

```vue
<script setup lang="ts">
import { TxFileUploader, txHttpUpload } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
// Replace with your server's multipart endpoint.
const upload = txHttpUpload({ url: '/api/upload' })
</script>

<template>
  <TxFileUploader :adapter="upload" accept=".txt" />
</template>
```

<a id="de-txmap"></a>
### TxMap

Karte mit Pan/Zoom, Markern und Routenlinien. Ohne tileUrl bleibt die Fläche neutral; Quellen und Attribution richtet die Anwendung ein.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `center` | `TxCoordinate &#124; undefined` | `{"lat":52.52,"lng":13.405}` | Geografischer Kartenmittelpunkt. |
| `zoom` | `number &#124; undefined` | `5` | Kartenzoomstufe. |
| `minZoom` | `number &#124; undefined` | `1` | Kleinste Zoomstufe. |
| `maxZoom` | `number &#124; undefined` | `19` | Größte Zoomstufe. |
| `tileUrl` | `string &#124; undefined` | `undefined` | Kachel-URL mit Platzhaltern {z}/{x}/{y}. |
| `attribution` | `string &#124; undefined` | `undefined` | Quellen-/Lizenzhinweis des Kartenanbieters. |
| `width` | `number &#124; undefined` | `640` | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| `height` | `number &#124; undefined` | `360` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| `dataSource` | `TxSource<TxMapMarker> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `markers` | `TxMapMarker[] &#124; undefined` | `[]` | Darzustellende Kartenmarker. |
| `routes` | `TxMapRoute[] &#124; undefined` | `[]` | Darzustellende Routenlinien. |
| `routeDataSource` | `TxSource<TxMapRoute> &#124; undefined` | `undefined` | Separate Datenquelle für Routenlinien. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:center | Neuer Wert von center; über v-model:center übernehmen (modelValue: v-model). |
| update:zoom | Neuer Wert von zoom; über v-model:zoom übernehmen (modelValue: v-model). |
| markerClick | Aktivierter TxMapMarker. |
| tileError | Fehlgeschlagene Kachel in { x, y, zoom }. |

```vue
<script setup lang="ts">
import { TxMap } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxMap :markers="[{ id: 1, lat: 52.52, lng: 13.405, text: 'Berlin' }]" />
</template>
```

<a id="de-txtabpanel"></a>
### TxTabPanel

Reiter und zugehöriger aktiver Inhalt in einer gemeinsamen Ansicht.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `unknown` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `selectedIndex` | `unknown` | `undefined` | Nullbasierter aktiver Eintrag. |
| `modelValue` | `unknown` | `undefined` | Kontrollierter Wert für v-model. |
| `disabled` | `unknown` | `false` | Sperrt die Interaktion. |
| `label` | `unknown` | `Reiter` | Beschriftung beziehungsweise zugänglicher Name. |
| `orientation` | `unknown` | `horizontal` | Ausrichtung der Reiter. |
| `scrollByContent` | `unknown` | `true` | Erlaubt Scrollen über den Reiterinhalt. |
| `swipeEnabled` | `unknown` | `false` | Erlaubt Reiterwechsel durch Wischen. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:selectedIndex | Neuer Wert von selectedIndex; über v-model:selectedIndex übernehmen (modelValue: v-model). |
| selectionChanged | Neue Auswahl: { selectedIndex, itemData }. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | { selectedIndex, item } |

```vue
<script setup lang="ts">
import { TxTabPanel } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxTabPanel :items="[{ text: 'Home' }]">
    <template #default="{ selectedIndex }">Page {{ selectedIndex + 1 }}</template>
  </TxTabPanel>
</template>
```

<a id="de-txloadpanel"></a>
### TxLoadPanel

Ladeoverlay, gesteuert durch Sichtbarkeit oder den Ladezustand einer DataSource.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `undefined` | Steuert die Sichtbarkeit. |
| `dataSource` | `Pick<TxDataSource<unknown>, "loading" &#124; "subscribe"> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `message` | `string &#124; undefined` | `Wird geladen …` | Meldungstext. |
| `delay` | `number &#124; undefined` | `0` | Wartezeit vor Anzeige des Ladeoverlays. |
| `shading` | `boolean &#124; undefined` | `true` | Zeigt eine abgedunkelte Hintergrundfläche. |
| `fullScreen` | `boolean &#124; undefined` | `false` | Füllt den Bildschirm. |

```vue
<script setup lang="ts">
import { TxLoadPanel } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <div style="position: relative; height: 160px"><TxLoadPanel :visible="true" message="Loading" /></div>
</template>
```

<a id="de-usetxsource"></a>
### useTxSource

Vue-Composable für reaktive items/source/loading/error/revision-Refs. In setup aufrufen; fremde Instanzen werden nicht entsorgt.

Parameter: getSource liest die aktuelle Datenbindung, fallback liefert optional eine Ersatzliste (Standard []). Rückgabe: items/source/loading/error/revision als Vue-Refs. Lifecycle-Hooks benötigen setup. Unmount entfernt Listener und entsorgt nur aus Konfigurationen erzeugte Instanzen.

```ts
function useTxSource<T>(getSource: () => TxSource<T> | undefined, fallback?: () => T[]): { items: ComputedRef<T[]>; source: ShallowRef<TxDataSource<T> | undefined, TxDataSource<T> | undefined>; loading: ComputedRef<boolean>; error: ComputedRef<unknown>; revision: ShallowRef<number, number>; }
```

```ts
import { defineComponent, h } from 'vue'
import { useTxSource } from '@tekocloud.de/tecexpress'
export default defineComponent({ setup() {
  const rows = [{ id: 1, text: 'One' }]
  const { items, loading, error, source, revision } = useTxSource(() => rows)
  return () => h('p', error.value ? String(error.value) : `${items.value.length} / ${loading.value} / ${revision.value} / ${!!source.value}`)
} })
```

<a id="de-notify"></a>
### notify

Zeigt eine gestapelte Meldung und liefert close/update. Standard: info, 3500 ms, bottom-right; displayTime 0 bleibt offen. Unter SSR ist das Handle wirkungslos.

Parameter options ist ein Meldungsstring oder TxNotifyOptions. Rückgabe synchron TxNotifyHandle. close(): void schließt idempotent; update(changes): void übernimmt Teiloptionen und startet den Timer neu. Die Stapelposition wird bei Erstellung festgelegt. Aktionen verwenden action.text/onClick. Das aktuelle Theme muss auch am Dokumentkörper verfügbar sein, da Meldungen dort angelegt werden.

```ts
function notify(options: string | TxNotifyOptions): TxNotifyHandle
```

```ts
import { notify } from '@tekocloud.de/tecexpress'
const handle = notify({ message: 'Working', displayTime: 0 })
handle.update({ message: 'Done', type: 'success', displayTime: 3000 })
handle.close()
```

<a id="de-txnotifyoptions"></a>
### TxNotifyOptions

Nachricht, Darstellung, Dauer, Position und optionale Aktion einer Benachrichtigung.

```ts
interface TxNotifyOptions {
  message: string
  type?: 'info' | 'success' | 'warning' | 'error'
  displayTime?: number
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left'
  action?: { text: string; onClick: () => void }
}
```

| Feld | Bedeutung |
| --- | --- |
| message | Meldungstext. |
| type | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |
| displayTime | Anzeigedauer; 0 beziehungsweise Duration.zero bleibt offen. |
| position | Position der Meldung beziehungsweise des Overlays. |
| action | Optionale Aktion mit Text und onClick-Callback. |

```ts
import type { TxNotifyOptions } from '@tekocloud.de/tecexpress'
const example: TxNotifyOptions = { message: 'Saved', type: 'success' }
console.log(example)
```

<a id="de-txnotifyhandle"></a>
### TxNotifyHandle

Handle zum Schließen oder Aktualisieren einer bestehenden Benachrichtigung.

```ts
interface TxNotifyHandle {
  close(): void
  update(changes: Partial<TxNotifyOptions>): void
}
```

| Feld | Bedeutung |
| --- | --- |
| close | Schließt die zugehörige Benachrichtigung. |
| update | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |

```ts
import type { TxNotifyHandle } from '@tekocloud.de/tecexpress'
const example: TxNotifyHandle = { close: () => {}, update: changes => console.log(changes) }
console.log(example)
```

<a id="de-txcollectionitem"></a>
### TxCollectionItem

Auswahleintrag; Wertauflösung über value, dann id, dann text.

```ts
interface TxCollectionItem {
  id?: string | number
  value?: unknown
  text: string
  icon?: string
  disabled?: boolean
  group?: string
  imageUrl?: string
  items?: TxCollectionItem[]
  destructive?: boolean
  separator?: boolean
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| value | Aktueller Eingabe-/Optionswert. |
| text | Anzuzeigender Text. |
| icon | Symbol der Aktion. |
| disabled | Sperrt die Interaktion. |
| group | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| imageUrl | Bildadresse der Karte. |
| items | Einträge; bei Datenbindung durch dataSource ersetzt. |
| destructive | Kennzeichnet eine destruktive Aktion. |
| separator | Kennzeichnet einen Menütrenner. |

```ts
import type { TxCollectionItem } from '@tekocloud.de/tecexpress'
const example: TxCollectionItem = { id: 1, text: 'One', value: 1 }
console.log(example)
```

<a id="de-txentry"></a>
### TxEntry

String oder strukturierter Auswahleintrag.

```ts
type TxEntry = string | TxCollectionItem
```

```ts
import type { TxEntry } from '@tekocloud.de/tecexpress'
const example: TxEntry = 'One'
console.log(example)
```

<a id="de-txrangevalue"></a>
### TxRangeValue

Numerische oder zeitliche Bereichsgrenze; Dates verwenden Millisekunden für Schritt und Abstand.

```ts
type TxRangeValue = number | Date
```

```ts
import type { TxRangeValue } from '@tekocloud.de/tecexpress'
const example: TxRangeValue = 20
console.log(example)
```

<a id="de-txproject"></a>
### txProject

Projiziert geografische Koordinaten in Web-Mercator-Weltpixel bei gegebenem Zoom; begrenzt die Breite auf etwa ±85,05°.

Parameter: point mit lat/lng in Grad und zoom. Rückgabe synchron: { x, y } in Vue, Offset in Dart; Weltpixel, keine Pixel relativ zum sichtbaren Kartenausschnitt.

```ts
function txProject(point: TxCoordinate, zoom: number): { x: number; y: number; }
```

```ts
import { txProject } from '@tekocloud.de/tecexpress'
const pixel = txProject({ lat: 52.52, lng: 13.405 }, 5)
console.log(pixel.x, pixel.y)
```

<a id="de-txunproject"></a>
### txUnproject

Wandelt Web-Mercator-Weltpixel beim gleichen Zoom zurück in geografische Koordinaten.

Parameter: Vue x, y, zoom; Dart Offset point, zoom. Rückgabe synchron TxCoordinate mit lat/lng in Grad; denselben Zoom wie bei txProject verwenden.

```ts
function txUnproject(x: number, y: number, zoom: number): TxCoordinate
```

```ts
import { txProject, txUnproject } from '@tekocloud.de/tecexpress'
const pixel = txProject({ lat: 52.52, lng: 13.405 }, 5)
console.log(txUnproject(pixel.x, pixel.y, 5))
```

<a id="de-txcoordinate"></a>
### TxCoordinate

Geografische Breite und Länge in Grad.

```ts
interface TxCoordinate {
  lat: number
  lng: number
}
```

| Feld | Bedeutung |
| --- | --- |
| lat | Geografische Breite in Grad. |
| lng | Geografische Länge in Grad. |

```ts
import type { TxCoordinate } from '@tekocloud.de/tecexpress'
const example: TxCoordinate = { lat: 52.52, lng: 13.405 }
console.log(example)
```

<a id="de-txmapmarker"></a>
### TxMapMarker

Koordinate mit eindeutiger ID und optionalem Popuptext und Farbe.

```ts
interface TxMapMarker extends TxCoordinate {
  id: string | number
  text?: string
  color?: string
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| text | Anzuzeigender Text. |
| color | Darstellungsfarbe. |
| lat | Geografische Breite in Grad. |
| lng | Geografische Länge in Grad. |

```ts
import type { TxMapMarker } from '@tekocloud.de/tecexpress'
const example: TxMapMarker = { id: 1, lat: 52.52, lng: 13.405, text: 'Berlin' }
console.log(example)
```

<a id="de-txmaproute"></a>
### TxMapRoute

Darzustellende Routenlinie aus Koordinaten; berechnet keine Route.

```ts
interface TxMapRoute {
  id: string | number
  points: TxCoordinate[]
  color?: string
  width?: number
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| points | Koordinaten der Routenlinie in Reihenfolge. |
| color | Darstellungsfarbe. |
| width | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |

```ts
import type { TxMapRoute } from '@tekocloud.de/tecexpress'
const example: TxMapRoute = { id: 1, points: [{ lat: 52.52, lng: 13.405 }, { lat: 52.53, lng: 13.41 }] }
console.log(example)
```

<a id="de-txgeoadapter"></a>
### TxGeoAdapter

Vertrag eigener Geocoding-/Routing-Dienste. Dienste selbst aufrufen und Ergebnisse an die Karte binden.

```ts
interface TxGeoAdapter {
  geocode?(query: string, signal?: AbortSignal): Promise<TxCoordinate[]>
  route?(points: TxCoordinate[], signal?: AbortSignal): Promise<TxCoordinate[]>
}
```

| Feld | Bedeutung |
| --- | --- |
| geocode | Fragt den eigenen Geodienst nach Koordinaten für einen Suchtext. |
| route | Fragt den eigenen Routingdienst nach einer Route durch die Wegpunkte. |

```ts
import type { TxGeoAdapter } from '@tekocloud.de/tecexpress'
const example: TxGeoAdapter = { geocode: async query => query ? [{ lat: 52.52, lng: 13.405 }] : [], route: async points => points }
console.log(example)
```

<a id="de-txbutton"></a>
### TxButton

Schaltfläche mit Text, Symbol und Klickaktion.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `text` | `string &#124; undefined` | `undefined` | Anzuzeigender Text. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `type` | `"default" &#124; "normal" &#124; "danger" &#124; "success" &#124; undefined` | `normal` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |
| `useSubmitBehavior` | `boolean &#124; undefined` | `false` | Verwendet einen nativen Submit-Button. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| click | Klickereignis mit MouseEvent. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxButton text="Save" @click="saved = true" />
</template>
```

<a id="de-txtextbox"></a>
### TxTextBox

Einzeilige Texteingabe; Änderungen über das Modell oder den Callback übernehmen.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTextBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const text = ref('Alex')
</script>

<template>
  <TxTextBox v-model="text" label="Name" />
</template>
```

<a id="de-txtextarea"></a>
### TxTextArea

Mehrzeilige Texteingabe mit konfigurierbarer Zeilenzahl.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTextArea } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const text = ref('Alex')
</script>

<template>
  <TxTextArea v-model="text" label="Notes" :rows="4" />
</template>
```

<a id="de-txnumberbox"></a>
### TxNumberBox

Zahleneingabe mit Grenzen und Schritten. Ein leerer Wert ergibt null.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxNumberBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const amount = ref<number | null>(10)
</script>

<template>
  <TxNumberBox v-model="amount" :min="0" :max="100" />
</template>
```

<a id="de-txcheckbox"></a>
### TxCheckBox

Kontrollkästchen für einen booleschen Wert.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxCheckBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const enabled = ref(true)
</script>

<template>
  <TxCheckBox v-model="enabled" label="Active" />
</template>
```

<a id="de-txswitch"></a>
### TxSwitch

Schalter für einen booleschen Wert.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxSwitch } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const enabled = ref(true)
</script>

<template>
  <TxSwitch v-model="enabled" label="Active" />
</template>
```

<a id="de-txselectbox"></a>
### TxSelectBox

Einfachauswahl aus einer Liste oder Datenquelle.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxSelectBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxSelectBox v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="de-txdatebox"></a>
### TxDateBox

Datumseingabe mit unterer und oberer Grenze.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Aktueller Eingabe-/Optionswert. |
| `label` | `string &#124; undefined` | `undefined` | Beschriftung beziehungsweise zugänglicher Name. |
| `name` | `string &#124; undefined` | `undefined` | Name des Eingabefelds beziehungsweise Dateiname. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hinweis bei leerer Eingabe. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `required` | `boolean &#124; undefined` | `false` | Kennzeichnet die erforderliche Eingabe. |
| `isValid` | `boolean &#124; undefined` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Fehlermeldung bei isValid = false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Untere zulässige Grenze. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Obere zulässige Grenze. |
| `step` | `string &#124; number &#124; undefined` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| `rows` | `number &#124; undefined` | `3` | Sichtbare Textzeilen. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `displayExpr` | `string &#124; undefined` | `text` | Feld für den sichtbaren Auswahltext. |
| `valueExpr` | `string &#124; undefined` | `value` | Feld für den Auswahlwert beziehungsweise Serienwert. |
| `type` | `string &#124; undefined` | `text` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:value | Neuer Wert von value; über v-model:value übernehmen (modelValue: v-model). |
| valueChanged | Neuer Wert in { value }; Editoren liefern zusätzlich previousValue und event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxDateBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const date = ref('2026-10-28')
</script>

<template>
  <TxDateBox v-model="date" label="Date" />
</template>
```

<a id="de-txtabs"></a>
### TxTabs

Reiternavigation mit optionalem Inhalt des aktiven Reiters.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<string &#124; Item> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `(string &#124; Item)[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `selectedIndex` | `number &#124; undefined` | `undefined` | Nullbasierter aktiver Eintrag. |
| `modelValue` | `number &#124; undefined` | `undefined` | Kontrollierter Wert für v-model. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `Reiter` | Beschriftung beziehungsweise zugänglicher Name. |
| `orientation` | `string &#124; undefined` | `horizontal` | Ausrichtung der Reiter. |
| `scrollByContent` | `boolean &#124; undefined` | `true` | Erlaubt Scrollen über den Reiterinhalt. |
| `swipeEnabled` | `boolean &#124; undefined` | `false` | Erlaubt Reiterwechsel durch Wischen. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:modelValue | Neuer Wert von modelValue; über v-model:modelValue übernehmen (modelValue: v-model). |
| update:selectedIndex | Neuer Wert von selectedIndex; über v-model:selectedIndex übernehmen (modelValue: v-model). |
| selectionChanged | Neue Auswahl: { selectedIndex, itemData }. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | { selectedIndex, item } |

```vue
<script setup lang="ts">
import { TxTabs } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxTabs :items="[{ text: 'Home' }, { text: 'Settings' }]">
    <template #default="{ selectedIndex }">Page {{ selectedIndex + 1 }}</template>
  </TxTabs>
</template>
```

<a id="de-txtoolbar"></a>
### TxToolbar

Werkzeugleiste mit Hauptinhalt und nachgestellten Aktionen.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `label` | `string &#124; undefined` | `Werkzeugleiste` | Beschriftung beziehungsweise zugänglicher Name. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |
| after | () |

```vue
<script setup lang="ts">
import { TxToolbar } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxToolbar><button>Save</button><template #after>Ready</template></TxToolbar>
</template>
```

<a id="de-txmenu"></a>
### TxMenu

Flache Liste von Menüaktionen; verschachtelte Aktionen gehören ins ContextMenu.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<string &#124; Item> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `items` | `(string &#124; Item)[] &#124; undefined` | `[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `label` | `string &#124; undefined` | `Menü` | Beschriftung beziehungsweise zugänglicher Name. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| itemClick | { itemData, itemIndex, event } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxMenu } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxMenu :items="[{ text: 'Home' }]" @item-click="saved = true" />
</template>
```

<a id="de-txpopup"></a>
### TxPopup

Dialog mit Titel und Inhalt. Vorereignisse können synchron abgebrochen werden; externe Sichtbarkeit bleibt maßgeblich.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `false` | Steuert die Sichtbarkeit. |
| `title` | `string &#124; undefined` | `Dialog` | Titel der Ansicht. |
| `showCloseButton` | `boolean &#124; undefined` | `true` | Zeigt die Schließen-Aktion. |
| `hideOnOutsideClick` | `boolean &#124; undefined` | `false` | Erlaubt Schließen über den Außenbereich. |
| `width` | `string &#124; number &#124; undefined` | `480` | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| `height` | `string &#124; number &#124; undefined` | `undefined` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| `fullScreen` | `boolean &#124; undefined` | `false` | Füllt den Bildschirm. |
| `dragEnabled` | `boolean &#124; undefined` | `false` | Erlaubt das Verschieben des Dialogs. |
| `resizeEnabled` | `boolean &#124; undefined` | `false` | Erlaubt Größenänderungen des Dialogs. |
| `position` | `string &#124; undefined` | `center` | Position der Meldung beziehungsweise des Overlays. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:visible | Neuer Wert von visible; über v-model:visible übernehmen (modelValue: v-model). |
| showing | Vor Anzeige: { cancel }; synchron auf true setzen, um abzubrechen. |
| hiding | Vor benutzerinitiiertem Schließen: { cancel }; synchron abbrechbar. |
| shown | Nach Anzeige, ohne Payload. |
| hidden | Nach Verbergen, ohne Payload. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |
| footer | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxPopup, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const visible = ref(false)
</script>

<template>
  <TxButton text="Open" @click="visible = true" />
  <TxPopup v-model:visible="visible" title="Details">Hello</TxPopup>
</template>
```

<a id="de-txtooltip"></a>
### TxTooltip

Hinweis zum Zielinhalt mit Verzögerung und optional eigenem Inhalt.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `text` | `string &#124; undefined` | `` | Anzuzeigender Text. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `visible` | `boolean &#124; undefined` | `undefined` | Steuert die Sichtbarkeit. |
| `showDelay` | `number &#124; undefined` | `0` | Verzögerung vor dem Anzeigen in Millisekunden. |
| `hideDelay` | `number &#124; undefined` | `0` | Verzögerung vor dem Verbergen in Millisekunden. |
| `position` | `string &#124; undefined` | `top` | Position der Meldung beziehungsweise des Overlays. |
| `showOn` | `string &#124; undefined` | `hover` | Auslöser des Tooltips. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:visible | Neuer Wert von visible; über v-model:visible übernehmen (modelValue: v-model). |
| shown | Nach Anzeige, ohne Payload. |
| hidden | Nach Verbergen, ohne Payload. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |
| content | () |

```vue
<script setup lang="ts">
import { TxTooltip } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxTooltip text="More information"><button>Help</button></TxTooltip>
</template>
```

<a id="de-txtoast"></a>
### TxToast

Zeitlich begrenzte Statusmeldung; Sichtbarkeitsänderungen in der Anwendung übernehmen.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `false` | Steuert die Sichtbarkeit. |
| `message` | `string &#124; undefined` | `undefined` | Meldungstext. |
| `position` | `string &#124; undefined` | `bottom-right` | Position der Meldung beziehungsweise des Overlays. |
| `type` | `"error" &#124; "success" &#124; "info" &#124; "warning" &#124; undefined` | `info` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |
| `displayTime` | `number &#124; undefined` | `3500` | Anzeigedauer; 0 beziehungsweise Duration.zero bleibt offen. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:visible | Neuer Wert von visible; über v-model:visible übernehmen (modelValue: v-model). |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |
| actions | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxToast, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const visible = ref(false)
</script>

<template>
  <TxButton text="Notify" @click="visible = true" />
  <TxToast v-model:visible="visible" message="Saved" type="success" />
</template>
```

<a id="de-txloadindicator"></a>
### TxLoadIndicator

Zugängliche Ladeanzeige mit Beschriftung.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `true` | Steuert die Sichtbarkeit. |
| `label` | `string &#124; undefined` | `Wird geladen …` | Beschriftung beziehungsweise zugänglicher Name. |

```vue
<script setup lang="ts">
import { TxLoadIndicator } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxLoadIndicator label="Loading" />
</template>
```

<a id="de-txdatagrid"></a>
### TxDataGrid

Datentabelle mit Einspaltensortierung, UND-Textfiltern, Pagination, Auswahl und eigenen Zellen.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<DataRow> &#124; undefined` | `[]` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `keyExpr` | `string &#124; undefined` | `id` | Feld für den stabilen Datensatzschlüssel. |
| `columns` | `Column[] &#124; undefined` | `undefined` | Spalten- beziehungsweise Kartenfeldkonfigurationen. |
| `filterRow` | `boolean &#124; { visible: boolean; } &#124; undefined` | `true` | Zeigt die Textfilterzeile. |
| `pageSize` | `number &#124; undefined` | `10` | Anzahl Datensätze je Seite. |
| `pageIndex` | `number &#124; undefined` | `undefined` | Nullbasierter Seitenindex. |
| `selection` | `"none" &#124; "single" &#124; "multiple" &#124; { mode: "none" &#124; "single" &#124; "multiple"; } &#124; undefined` | `none` | Auswahlmodus. |
| `selectedRowKeys` | `RowKey[] &#124; undefined` | `undefined` | Kontrollierte Menge ausgewählter Zeilenschlüssel. |
| `loading` | `boolean &#124; undefined` | `false` | Zeigt den Ladezustand. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `noDataText` | `string &#124; undefined` | `Keine Daten vorhanden.` | Text bei leerem Datenbestand. |
| `label` | `string &#124; undefined` | `Datentabelle` | Beschriftung beziehungsweise zugänglicher Name. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| rowClick | RowClickEvent: data, key, rowIndex, event. |
| selectionChanged | Neue Auswahl: { selectedRowKeys, selectedRowsData }. |
| update:selectedRowKeys | Neuer Wert von selectedRowKeys; über v-model:selectedRowKeys übernehmen (modelValue: v-model). |
| update:pageIndex | Neuer Wert von pageIndex; über v-model:pageIndex übernehmen (modelValue: v-model). |
| sortChanged | Aktueller SortDescriptor oder null. |
| filterChanged | Aktuelle Textfilter als Record&lt;string, string&gt;. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | TxColumn[] |
| [cellTemplate] | { data, value, column, rowIndex } |

```vue
<script setup lang="ts">
import { TxDataGrid, TxColumn } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const rows = [{ id: 1, name: 'Alex' }]
</script>

<template>
  <TxDataGrid :data-source="rows" key-expr="id">
    <TxColumn data-field="name" caption="Name" />
  </TxDataGrid>
</template>
```

<a id="de-txcolumn"></a>
### TxColumn

Spaltenkonfiguration des DataGrid; keine eigenständige Oberfläche.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataField` | `string` | `erforderlich` | Feldname; muss im Grid eindeutig sein. |
| `caption` | `string &#124; undefined` | `undefined` | Sichtbare Feld-/Spaltenüberschrift. |
| `width` | `string &#124; number &#124; undefined` | `undefined` | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| `allowSorting` | `boolean &#124; undefined` | `true` | Erlaubt Sortierung dieser Spalte. |
| `allowFiltering` | `boolean &#124; undefined` | `true` | Erlaubt Filtern dieser Spalte. |
| `cellTemplate` | `string &#124; undefined` | `undefined` | Name des Vue-Slots für eigene Zellen. |
| `visible` | `boolean &#124; undefined` | `true` | Steuert die Sichtbarkeit. |
| `alignment` | `"center" &#124; "left" &#124; "right" &#124; undefined` | `undefined` | Ausrichtung des Inhalts. |

```vue
<script setup lang="ts">
import { TxColumn, TxDataGrid } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const rows = [{ id: 1, name: 'Alex' }]
</script>

<template>
  <TxDataGrid :data-source="rows" key-expr="id">
    <TxColumn data-field="name" caption="Name" cell-template="nameCell" />
    <template #nameCell="{ value }"><strong>{{ value }}</strong></template>
  </TxDataGrid>
</template>
```

<a id="de-txscheduler"></a>
### TxScheduler

Tag-, Wochen- und Monatskalender mit Terminbearbeitung. Ganztagsenden sind exklusiv; keine Serien, Ressourcen oder Drag-and-drop.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<Appointment> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `currentDate` | `SchedulerDate &#124; undefined` | `undefined` | Aktueller Kalendertag; für Navigation kontrollierten Wert aktualisieren. |
| `currentView` | `SchedulerView &#124; undefined` | `undefined` | Aktuelle Kalenderansicht. |
| `views` | `SchedulerView[] &#124; undefined` | `["day","week","month"]` | Angebotene Kalenderansichten. |
| `firstDayOfWeek` | `number &#124; undefined` | `1` | Erster Wochentag; 1 = Montag. |
| `startDayHour` | `number &#124; undefined` | `8` | Erste sichtbare Tagesstunde. |
| `endDayHour` | `number &#124; undefined` | `18` | Letzte sichtbare Tagesstunde. |
| `cellDuration` | `number &#124; undefined` | `30` | Länge einer Kalenderzelle in Minuten. |
| `editing` | `boolean &#124; SchedulerEditing &#124; undefined` | `true` | Berechtigungen zum Anlegen, Ändern und Löschen. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `loading` | `boolean &#124; undefined` | `false` | Zeigt den Ladezustand. |
| `locale` | `string &#124; undefined` | `de-DE` | Locale für Datums-/Zeitformatierung. |
| `label` | `string &#124; undefined` | `Terminplaner` | Beschriftung beziehungsweise zugänglicher Name. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:dataSource | Neuer Wert von dataSource; über v-model:dataSource übernehmen (modelValue: v-model). |
| update:currentDate | Neuer Wert von currentDate; über v-model:currentDate übernehmen (modelValue: v-model). |
| update:currentView | Neuer Wert von currentView; über v-model:currentView übernehmen (modelValue: v-model). |
| appointmentClick | AppointmentClickEvent: appointmentData, event. |
| cellClick | SchedulerCellClickEvent: startDate, endDate, allDay, event. |
| appointmentAdding | AppointmentChangeEvent mit cancel vor Anlegen. |
| appointmentAdded | AppointmentEvent nach lokalem Anlegen. |
| appointmentUpdating | AppointmentUpdatingEvent mit oldData, newData und cancel. |
| appointmentUpdated | AppointmentUpdatedEvent mit oldData und newData. |
| appointmentDeleting | AppointmentChangeEvent mit cancel vor Löschen. |
| appointmentDeleted | AppointmentEvent nach lokalem Löschen. |

**Slots**

| Slot | Argumente |
| --- | --- |
| appointment | { appointmentData, startDate, endDate, view } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxScheduler, type Appointment } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const appointments = ref<Appointment[]>([{ id: 1, text: 'Meeting', startDate: new Date(2026, 9, 28, 9), endDate: new Date(2026, 9, 28, 10) }])
const calendarDate = ref(new Date(2026, 9, 28))
</script>

<template>
  <TxScheduler v-model:data-source="appointments" v-model:current-date="calendarDate" />
</template>
```

<a id="de-txcard"></a>
### TxCard

Präsentationskarte mit Titel, Medien, Inhalt und Aktionen.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `title` | `string &#124; undefined` | `undefined` | Titel der Ansicht. |
| `subtitle` | `string &#124; undefined` | `undefined` | Zusätzlicher Untertitel. |
| `imageUrl` | `string &#124; undefined` | `undefined` | Bildadresse der Karte. |
| `imageAlt` | `string &#124; undefined` | `` | Alternativtext des Bildes. |
| `variant` | `"outlined" &#124; "elevated" &#124; "filled" &#124; undefined` | `outlined` | Darstellungsvariante der Karte. |
| `loading` | `boolean &#124; undefined` | `false` | Zeigt den Ladezustand. |

**Slots**

| Slot | Argumente |
| --- | --- |
| default | () |
| header | () |
| media | () |
| actions | () |
| footer | () |

```vue
<script setup lang="ts">
import { TxCard } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxCard title="Project" subtitle="Active">Hello<template #footer>Updated today</template></TxCard>
</template>
```

<a id="de-txcardview"></a>
### TxCardView

Kartenliste mit Suche, Pagination, Auswahl und eigenen Karteninhalten.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<DataRow> &#124; undefined` | `[]` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `keyExpr` | `string &#124; undefined` | `id` | Feld für den stabilen Datensatzschlüssel. |
| `titleExpr` | `string &#124; undefined` | `title` | Feld des Kartentitels. |
| `subtitleExpr` | `string &#124; undefined` | `subtitle` | Feld des Kartenuntertitels. |
| `imageExpr` | `string &#124; undefined` | `imageUrl` | Feld der Kartenbildadresse. |
| `imageAltExpr` | `string &#124; undefined` | `imageAlt` | Feld des Bildalternativtexts. |
| `columns` | `CardField[] &#124; undefined` | `[]` | Spalten- beziehungsweise Kartenfeldkonfigurationen. |
| `searchEnabled` | `boolean &#124; undefined` | `true` | Aktiviert die Suche. |
| `searchExpr` | `string &#124; string[] &#124; undefined` | `undefined` | Felder beziehungsweise Getter der Suche. |
| `pageSize` | `number &#124; undefined` | `6` | Anzahl Datensätze je Seite. |
| `pageIndex` | `number &#124; undefined` | `undefined` | Nullbasierter Seitenindex. |
| `selection` | `"none" &#124; "single" &#124; "multiple" &#124; undefined` | `none` | Auswahlmodus. |
| `selectedCardKeys` | `RowKey[] &#124; undefined` | `undefined` | Kontrollierte Menge ausgewählter Kartenschlüssel. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `loading` | `boolean &#124; undefined` | `false` | Zeigt den Ladezustand. |
| `noDataText` | `string &#124; undefined` | `Keine Karten vorhanden.` | Text bei leerem Datenbestand. |
| `label` | `string &#124; undefined` | `Kartenansicht` | Beschriftung beziehungsweise zugänglicher Name. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| cardClick | CardClickEvent: data, key, index, event. |
| selectionChanged | Neue Auswahl: { selectedCardKeys, selectedCardsData }. |
| update:selectedCardKeys | Neuer Wert von selectedCardKeys; über v-model:selectedCardKeys übernehmen (modelValue: v-model). |
| update:pageIndex | Neuer Wert von pageIndex; über v-model:pageIndex übernehmen (modelValue: v-model). |
| searchChanged | Neuer Suchtext als string. |

**Slots**

| Slot | Argumente |
| --- | --- |
| item | { data, key, index, selected } |
| media | { data, key, index, selected } |
| content | { data, key, index, selected } |
| footer | { data, key, index, selected } |
| field | { data, column, value } |

```vue
<script setup lang="ts">
import { TxCardView } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxCardView :data-source="[{ id: 1, title: 'Project' }]" />
</template>
```

<a id="de-txchat"></a>
### TxChat

Lokaler Nachrichtenverlauf mit Autoren, Schreibanzeige und Sendeereignissen. sent bestätigt die lokale Aufnahme, keine Serverzustellung.

| Prop | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<ChatMessage> &#124; undefined` | `undefined` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| `user` | `ChatUser` | `erforderlich` | Aktueller Chatautor. |
| `items` | `ChatMessage[] &#124; undefined` | `undefined` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| `inputFieldText` | `string &#124; undefined` | `undefined` | Kontrollierter Nachrichtenentwurf. |
| `title` | `string &#124; undefined` | `Chat` | Titel der Ansicht. |
| `subtitle` | `string &#124; undefined` | `` | Zusätzlicher Untertitel. |
| `label` | `string &#124; undefined` | `Chat` | Beschriftung beziehungsweise zugänglicher Name. |
| `placeholder` | `string &#124; undefined` | `Nachricht schreiben …` | Hinweis bei leerer Eingabe. |
| `emptyText` | `string &#124; undefined` | `Noch keine Nachrichten. Starte die Unterhaltung.` | Text des Leerzustands. |
| `disabled` | `boolean &#124; undefined` | `false` | Sperrt die Interaktion. |
| `readOnly` | `boolean &#124; undefined` | `false` | Verhindert Änderungen des Werts. |
| `loading` | `boolean &#124; undefined` | `false` | Zeigt den Ladezustand. |
| `sending` | `boolean &#124; undefined` | `false` | Sperrt Senden während einer eigenen laufenden Anfrage. |
| `maxLength` | `number &#124; undefined` | `4000` | Maximale Textlänge. |
| `typingUsers` | `ChatUser[] &#124; undefined` | `[]` | Aktuell schreibende Autoren. |
| `showAvatar` | `boolean &#124; undefined` | `true` | Zeigt Autorenbilder. |
| `showUserName` | `boolean &#124; undefined` | `true` | Zeigt Autorennamen. |
| `showDayHeaders` | `boolean &#124; undefined` | `true` | Gruppiert Nachrichten mit Tagesüberschriften. |
| `showMessageTimestamp` | `boolean &#124; undefined` | `true` | Zeigt Nachrichtenzeiten. |
| `locale` | `string &#124; undefined` | `de-DE` | Locale für Datums-/Zeitformatierung. |

**Ereignisse**

| Event | Payload / Verhalten |
| --- | --- |
| update:items | Neuer Wert von items; über v-model:items übernehmen (modelValue: v-model). |
| update:inputFieldText | Neuer Wert von inputFieldText; über v-model:inputFieldText übernehmen (modelValue: v-model). |
| messageEntered | ChatMessageEnteredEvent; cancel synchron setzen, um eigene Serververarbeitung zu starten. |
| messageSent | ChatMessageEvent nach lokaler Aufnahme. |
| typingStart | ChatTypingEvent beim Beginn des Schreibens. |
| typingEnd | ChatTypingEvent beim Ende des Schreibens. |

**Slots**

| Slot | Argumente |
| --- | --- |
| header | { user } |
| empty | () |
| message | { message, isOwn } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxChat, type ChatMessage } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const messages = ref<ChatMessage[]>([])
</script>

<template>
  <TxChat v-model:items="messages" :user="{ id: 'me', name: 'Alex' }" />
</template>
```

<a id="de-editorvalue"></a>
### EditorValue

Eingabewert eines Editors.

```ts
type EditorValue = string | number | boolean | null
```

```ts
import type { EditorValue } from '@tekocloud.de/tecexpress'
const example: EditorValue = 'Hello'
console.log(example)
```

<a id="de-valuechangedevent"></a>
### ValueChangedEvent

Typisierter Ereignisvertrag für ValueChangedEvent; die Felder unten beschreiben den Payload.

```ts
interface ValueChangedEvent<T = EditorValue> {
  value: T
  previousValue: T
  event: Event
}
```

| Feld | Bedeutung |
| --- | --- |
| value | Aktueller Eingabe-/Optionswert. |
| previousValue | Wert vor der Änderung. |
| event | Ursprüngliches Eingabe-/Mausereignis. |

```ts
import type { ValueChangedEvent } from '@tekocloud.de/tecexpress'
const example: ValueChangedEvent<string> = { value: 'New', previousValue: 'Old', event: new Event('input') }
console.log(example)
```

<a id="de-item"></a>
### Item

Menü-/Reitereintrag.

```ts
interface Item {
  text: string
  icon?: string
  visible?: boolean
  disabled?: boolean
  id?: string | number
}
```

| Feld | Bedeutung |
| --- | --- |
| text | Anzuzeigender Text. |
| icon | Symbol der Aktion. |
| visible | Steuert die Sichtbarkeit. |
| disabled | Sperrt die Interaktion. |
| id | Eindeutige stabile ID. |

```ts
import type { Item } from '@tekocloud.de/tecexpress'
const example: Item = { text: 'Home', id: 1 }
console.log(example)
```

<a id="de-rowkey"></a>
### RowKey

Eindeutiger String- oder Zahlenschlüssel eines Datensatzes.

```ts
type RowKey = string | number
```

```ts
import type { RowKey } from '@tekocloud.de/tecexpress'
const example: RowKey = 1
console.log(example)
```

<a id="de-datarow"></a>
### DataRow

Frei strukturierter Datensatz mit benannten Feldern.

```ts
type DataRow = Record<string, unknown>
```

```ts
import type { DataRow } from '@tekocloud.de/tecexpress'
const example: DataRow = { id: 1, name: 'Alex' }
console.log(example)
```

<a id="de-column"></a>
### Column

Spaltenkonfiguration des DataGrid; keine eigenständige Oberfläche.

```ts
interface Column {
  dataField: string
  caption?: string
  width?: string | number
  allowSorting?: boolean
  allowFiltering?: boolean
  cellTemplate?: string
  visible?: boolean
  alignment?: 'left' | 'center' | 'right'
}
```

| Feld | Bedeutung |
| --- | --- |
| dataField | Feldname; muss im Grid eindeutig sein. |
| caption | Sichtbare Feld-/Spaltenüberschrift. |
| width | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| allowSorting | Erlaubt Sortierung dieser Spalte. |
| allowFiltering | Erlaubt Filtern dieser Spalte. |
| cellTemplate | Name des Vue-Slots für eigene Zellen. |
| visible | Steuert die Sichtbarkeit. |
| alignment | Ausrichtung des Inhalts. |

```ts
import type { Column } from '@tekocloud.de/tecexpress'
const example: Column = { dataField: 'name', caption: 'Name' }
console.log(example)
```

<a id="de-sortdescriptor"></a>
### SortDescriptor

Sortier- oder Gruppierungsbeschreibung mit Selector und absteigender Richtung.

```ts
interface SortDescriptor {
  dataField: string
  desc: boolean
}
```

| Feld | Bedeutung |
| --- | --- |
| dataField | Feldname; muss im Grid eindeutig sein. |
| desc | Absteigende Sortierung. |

```ts
import type { SortDescriptor } from '@tekocloud.de/tecexpress'
const example: SortDescriptor = { dataField: 'name', desc: false }
console.log(example)
```

<a id="de-rowclickevent"></a>
### RowClickEvent

Typisierter Ereignisvertrag für RowClickEvent; die Felder unten beschreiben den Payload.

```ts
interface RowClickEvent {
  data: DataRow
  key: RowKey
  rowIndex: number
  event: MouseEvent
}
```

| Feld | Bedeutung |
| --- | --- |
| data | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| key | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| rowIndex | Nullbasierter Index der sichtbaren Zeile. |
| event | Ursprüngliches Eingabe-/Mausereignis. |

```ts
import type { RowClickEvent } from '@tekocloud.de/tecexpress'
const example: RowClickEvent = { data: { id: 1 }, key: 1, rowIndex: 0, event: new MouseEvent('click') }
console.log(example)
```

<a id="de-selectionchangedevent"></a>
### SelectionChangedEvent

Typisierter Ereignisvertrag für SelectionChangedEvent; die Felder unten beschreiben den Payload.

```ts
interface SelectionChangedEvent {
  selectedRowKeys: RowKey[]
  selectedRowsData: DataRow[]
}
```

| Feld | Bedeutung |
| --- | --- |
| selectedRowKeys | Kontrollierte Menge ausgewählter Zeilenschlüssel. |
| selectedRowsData | Datensätze der ausgewählten Zeilen. |

```ts
import type { SelectionChangedEvent } from '@tekocloud.de/tecexpress'
const example: SelectionChangedEvent = { selectedRowKeys: [1], selectedRowsData: [{ id: 1 }] }
console.log(example)
```

<a id="de-appointment"></a>
### Appointment

Unveränderlicher Termin mit validiertem Schlüssel, Titel und Ende nach Beginn. Ganztagsgrenzen müssen lokale Mitternacht sein.

```ts
interface Appointment {
  id: RowKey
  text: string
  startDate: SchedulerDate
  endDate: SchedulerDate
  allDay?: boolean
  description?: string
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| text | Anzuzeigender Text. |
| startDate | Termin-/Zellenbeginn. |
| endDate | Termin-/Zellenende, bei Ganztag exklusiv. |
| allDay | Ganztagstermin mit lokalen Tagesgrenzen. |
| description | Optionale Terminbeschreibung. |

```ts
import type { Appointment } from '@tekocloud.de/tecexpress'
const example: Appointment = { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }
console.log(example)
```

<a id="de-schedulerview"></a>
### SchedulerView

Tages-, Wochen- oder Monatsansicht.

```ts
type SchedulerView = 'day' | 'week' | 'month'
```

```ts
import type { SchedulerView } from '@tekocloud.de/tecexpress'
const example: SchedulerView = 'week'
console.log(example)
```

<a id="de-schedulerdate"></a>
### SchedulerDate

Datum als Date oder parsebarer String; lokale ISO-Werte ohne Z kennzeichnen lokale Zeit.

```ts
type SchedulerDate = Date | string
```

```ts
import type { SchedulerDate } from '@tekocloud.de/tecexpress'
const example: SchedulerDate = new Date(2026, 9, 28)
console.log(example)
```

<a id="de-schedulerediting"></a>
### SchedulerEditing

Berechtigungen zum Anlegen, Ändern und Löschen von Terminen; none sperrt alle drei Aktionen.

```ts
interface SchedulerEditing {
  allowAdding?: boolean
  allowUpdating?: boolean
  allowDeleting?: boolean
}
```

| Feld | Bedeutung |
| --- | --- |
| allowAdding | Erlaubt neue Termine. |
| allowUpdating | Erlaubt Terminänderungen. |
| allowDeleting | Zeigt Aktionen zum Löschen von Listeneinträgen. |

```ts
import type { SchedulerEditing } from '@tekocloud.de/tecexpress'
const example: SchedulerEditing = { allowAdding: true, allowUpdating: false }
console.log(example)
```

<a id="de-appointmentevent"></a>
### AppointmentEvent

Typisierter Ereignisvertrag für AppointmentEvent; die Felder unten beschreiben den Payload.

```ts
interface AppointmentEvent {
  appointmentData: Appointment
}
```

| Feld | Bedeutung |
| --- | --- |
| appointmentData | Betroffener Termin. |

```ts
import type { AppointmentEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentEvent = { appointmentData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' } }
console.log(example)
```

<a id="de-appointmentchangeevent"></a>
### AppointmentChangeEvent

Typisierter Ereignisvertrag für AppointmentChangeEvent; die Felder unten beschreiben den Payload.

```ts
interface AppointmentChangeEvent extends AppointmentEvent {
  cancel: boolean
}
```

| Feld | Bedeutung |
| --- | --- |
| cancel | Synchron auf true setzen, um die Aktion abzubrechen. |
| appointmentData | Betroffener Termin. |

```ts
import type { AppointmentChangeEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentChangeEvent = { appointmentData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, cancel: false }
console.log(example)
```

<a id="de-appointmentclickevent"></a>
### AppointmentClickEvent

Typisierter Ereignisvertrag für AppointmentClickEvent; die Felder unten beschreiben den Payload.

```ts
interface AppointmentClickEvent extends AppointmentEvent {
  event: MouseEvent
}
```

| Feld | Bedeutung |
| --- | --- |
| event | Ursprüngliches Eingabe-/Mausereignis. |
| appointmentData | Betroffener Termin. |

```ts
import type { AppointmentClickEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentClickEvent = { appointmentData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, event: new MouseEvent('click') }
console.log(example)
```

<a id="de-appointmentupdatingevent"></a>
### AppointmentUpdatingEvent

Typisierter Ereignisvertrag für AppointmentUpdatingEvent; die Felder unten beschreiben den Payload.

```ts
interface AppointmentUpdatingEvent {
  oldData: Appointment
  newData: Appointment
  cancel: boolean
}
```

| Feld | Bedeutung |
| --- | --- |
| oldData | Vorheriger Datensatz. |
| newData | Neuer vorgeschlagener Datensatz. |
| cancel | Synchron auf true setzen, um die Aktion abzubrechen. |

```ts
import type { AppointmentUpdatingEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentUpdatingEvent = { oldData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, newData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, cancel: false }
console.log(example)
```

<a id="de-appointmentupdatedevent"></a>
### AppointmentUpdatedEvent

Typisierter Ereignisvertrag für AppointmentUpdatedEvent; die Felder unten beschreiben den Payload.

```ts
interface AppointmentUpdatedEvent {
  oldData: Appointment
  newData: Appointment
}
```

| Feld | Bedeutung |
| --- | --- |
| oldData | Vorheriger Datensatz. |
| newData | Neuer vorgeschlagener Datensatz. |

```ts
import type { AppointmentUpdatedEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentUpdatedEvent = { oldData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, newData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' } }
console.log(example)
```

<a id="de-schedulercellclickevent"></a>
### SchedulerCellClickEvent

Typisierter Ereignisvertrag für SchedulerCellClickEvent; die Felder unten beschreiben den Payload.

```ts
interface SchedulerCellClickEvent {
  startDate: Date
  endDate: Date
  allDay: boolean
  event: MouseEvent
}
```

| Feld | Bedeutung |
| --- | --- |
| startDate | Termin-/Zellenbeginn. |
| endDate | Termin-/Zellenende, bei Ganztag exklusiv. |
| allDay | Ganztagstermin mit lokalen Tagesgrenzen. |
| event | Ursprüngliches Eingabe-/Mausereignis. |

```ts
import type { SchedulerCellClickEvent } from '@tekocloud.de/tecexpress'
const example: SchedulerCellClickEvent = { startDate: new Date(2026, 9, 28, 9), endDate: new Date(2026, 9, 28, 10), allDay: false, event: new MouseEvent('click') }
console.log(example)
```

<a id="de-cardfield"></a>
### CardField

Feld einer Karte mit Beschriftung, Getter und optionalem Builder.

```ts
interface CardField {
  dataField: string
  caption?: string
}
```

| Feld | Bedeutung |
| --- | --- |
| dataField | Feldname; muss im Grid eindeutig sein. |
| caption | Sichtbare Feld-/Spaltenüberschrift. |

```ts
import type { CardField } from '@tekocloud.de/tecexpress'
const example: CardField = { dataField: 'name', caption: 'Name' }
console.log(example)
```

<a id="de-cardclickevent"></a>
### CardClickEvent

Typisierter Ereignisvertrag für CardClickEvent; die Felder unten beschreiben den Payload.

```ts
interface CardClickEvent {
  data: DataRow
  key: RowKey
  index: number
  event: MouseEvent
}
```

| Feld | Bedeutung |
| --- | --- |
| data | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| key | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| index | Nullbasierter Eintragsindex. |
| event | Ursprüngliches Eingabe-/Mausereignis. |

```ts
import type { CardClickEvent } from '@tekocloud.de/tecexpress'
const example: CardClickEvent = { data: { id: 1 }, key: 1, index: 0, event: new MouseEvent('click') }
console.log(example)
```

<a id="de-cardselectionchangedevent"></a>
### CardSelectionChangedEvent

Typisierter Ereignisvertrag für CardSelectionChangedEvent; die Felder unten beschreiben den Payload.

```ts
interface CardSelectionChangedEvent {
  selectedCardKeys: RowKey[]
  selectedCardsData: DataRow[]
}
```

| Feld | Bedeutung |
| --- | --- |
| selectedCardKeys | Kontrollierte Menge ausgewählter Kartenschlüssel. |
| selectedCardsData | Datensätze der ausgewählten Karten. |

```ts
import type { CardSelectionChangedEvent } from '@tekocloud.de/tecexpress'
const example: CardSelectionChangedEvent = { selectedCardKeys: [1], selectedCardsData: [{ id: 1 }] }
console.log(example)
```

<a id="de-chatuser"></a>
### ChatUser

Autor mit validiertem Schlüssel und nicht leerem Namen.

```ts
interface ChatUser {
  id: RowKey
  name: string
  avatarUrl?: string
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| name | Name des Eingabefelds beziehungsweise Dateiname. |
| avatarUrl | Optionale Avatar-Bildadresse. |

```ts
import type { ChatUser } from '@tekocloud.de/tecexpress'
const example: ChatUser = { id: 'me', name: 'Alex' }
console.log(example)
```

<a id="de-chatmessage"></a>
### ChatMessage

Unveränderliche Nachricht mit Autor, Zeitstempel und nicht leerem Text.

```ts
interface ChatMessage {
  id: RowKey
  text: string
  timestamp: Date | string
  author: ChatUser
  status?: 'pending' | 'sent' | 'error'
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| text | Anzuzeigender Text. |
| timestamp | Zeitpunkt der Nachricht. |
| author | Autor der Nachricht. |
| status | Lokaler Nachrichtenstatus. |

```ts
import type { ChatMessage } from '@tekocloud.de/tecexpress'
const example: ChatMessage = { id: 1, text: 'Hello', timestamp: new Date(), author: { id: 'me', name: 'Alex' } }
console.log(example)
```

<a id="de-chatmessageevent"></a>
### ChatMessageEvent

Typisierter Ereignisvertrag für ChatMessageEvent; die Felder unten beschreiben den Payload.

```ts
interface ChatMessageEvent {
  message: ChatMessage
}
```

| Feld | Bedeutung |
| --- | --- |
| message | Meldungstext. |

```ts
import type { ChatMessageEvent } from '@tekocloud.de/tecexpress'
const example: ChatMessageEvent = { message: { id: 1, text: 'Hello', timestamp: new Date(), author: { id: 'me', name: 'Alex' } } }
console.log(example)
```

<a id="de-chatmessageenteredevent"></a>
### ChatMessageEnteredEvent

Typisierter Ereignisvertrag für ChatMessageEnteredEvent; die Felder unten beschreiben den Payload.

```ts
interface ChatMessageEnteredEvent extends ChatMessageEvent {
  cancel: boolean
  event: Event
}
```

| Feld | Bedeutung |
| --- | --- |
| cancel | Synchron auf true setzen, um die Aktion abzubrechen. |
| event | Ursprüngliches Eingabe-/Mausereignis. |
| message | Meldungstext. |

```ts
import type { ChatMessageEnteredEvent } from '@tekocloud.de/tecexpress'
const example: ChatMessageEnteredEvent = { message: { id: 1, text: 'Hello', timestamp: new Date(), author: { id: 'me', name: 'Alex' } }, cancel: false, event: new Event('submit') }
console.log(example)
```

<a id="de-chattypingevent"></a>
### ChatTypingEvent

Typisierter Ereignisvertrag für ChatTypingEvent; die Felder unten beschreiben den Payload.

```ts
interface ChatTypingEvent {
  user: ChatUser
}
```

| Feld | Bedeutung |
| --- | --- |
| user | Aktueller Chatautor. |

```ts
import type { ChatTypingEvent } from '@tekocloud.de/tecexpress'
const example: ChatTypingEvent = { user: { id: 'me', name: 'Alex' } }
console.log(example)
```

<a id="de-tecexpress"></a>
### Tecexpress

Vue-Plugin: install(app) registriert alle Komponenten global; auch als Default-Export verfügbar.

```ts
import { createApp, h } from 'vue'
import Tecexpress, { TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
createApp({ render: () => h(TxButton, { text: 'Hello' }) }).use(Tecexpress).mount('#app')
```

<a id="de-txread"></a>
### txRead

Liest einen verschachtelten Feldpfad oder ruft einen Getter auf. Fehlende Pfade ergeben undefined.

Parameter: item = Datensatz, selector = Punktpfad oder Getter. Rückgabe unknown; fehlender Pfad undefined. Getterfehler werden weitergegeben.

```ts
function txRead<T>(item: T, selector: TxSelector<T>): unknown
```

```ts
import { txRead } from '@tekocloud.de/tecexpress'
console.log(txRead({ address: { city: 'Berlin' } }, 'address.city')) // Berlin
```

<a id="de-txmatches"></a>
### txMatches

Prüft synchron, ob ein Datensatz einen Filter erfüllt; Textvergleiche ignorieren Groß-/Kleinschreibung.

Parameter: item = zu prüfender Datensatz, f = TxFilter. Rückgabe boolean; verändert den Datensatz nicht. Getterfehler werden weitergegeben.

```ts
function txMatches<T>(item: T, f: TxFilter<T>): boolean
```

```ts
import { txMatches } from '@tekocloud.de/tecexpress'
console.log(txMatches({ age: 20 }, { selector: 'age', operator: '>=', value: 18 })) // true
```

<a id="de-txquery"></a>
### txQuery

Verarbeitet lokale Daten synchron: Filtern/Suchen, Sortieren/Gruppieren, Paging und Projektion. Das Eingangsarray bleibt erhalten.

Parameter: input = Ausgangsliste, o/options = TxLoadOptions. Synchrones Ergebnis: TxLoadResult mit flacher data-Liste, totalCount vor Paging und optionalen groups/groupCount. Gruppierung ändert nicht die Form von data. Getter-/Projektionsfehler werden weitergegeben; Dart skip/take dürfen nicht negativ sein.

```ts
function txQuery<T>(input: readonly T[], o: TxLoadOptions<T>): TxLoadResult<T>
```

```ts
import { txQuery } from '@tekocloud.de/tecexpress'
console.log(txQuery([{ id: 2 }, { id: 1 }], { sort: [{ selector: 'id' }], take: 1 })) // data: [{ id: 1 }], totalCount: 2
```

<a id="de-txkey"></a>
### TxKey

Eindeutiger String- oder Zahlenschlüssel eines Datensatzes.

```ts
type TxKey = string | number
```

```ts
import type { TxKey } from '@tekocloud.de/tecexpress'
const example: TxKey = 1
console.log(example)
```

<a id="de-txselector"></a>
### TxSelector

Feldpfad oder Getter zum Lesen eines Werts aus einem Datensatz.

```ts
type TxSelector<T> = string | ((item: T) => unknown)
```

```ts
import type { TxSelector } from '@tekocloud.de/tecexpress'
const example: TxSelector<{ id: number }> = 'id'
console.log(example)
```

<a id="de-txsort"></a>
### TxSort

Sortier- oder Gruppierungsbeschreibung mit Selector und absteigender Richtung.

```ts
interface TxSort<T> {
  selector: TxSelector<T>
  desc?: boolean
}
```

| Feld | Bedeutung |
| --- | --- |
| selector | Feldpfad oder Getter des Abfragewerts. |
| desc | Absteigende Sortierung. |

```ts
import type { TxSort } from '@tekocloud.de/tecexpress'
const example: TxSort<{ id: number }> = { selector: 'id', desc: false }
console.log(example)
```

<a id="de-txfilter"></a>
### TxFilter

Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.

Standardoperator ist Gleichheit. Textoperatoren ignorieren Groß-/Kleinschreibung. Leeres AND ist wahr, leeres OR ist falsch. Dart matches(item) liefert bool, Vue txMatches(item, filter) boolean. Getterfehler werden weitergegeben.

```ts
type TxFilter<T> =
  | {
      selector: TxSelector<T>
      operator?:
        | '='
        | '<>'
        | '>'
        | '>='
        | '<'
        | '<='
        | 'contains'
        | 'startswith'
        | 'endswith'
      value: unknown
    }
  | { and: TxFilter<T>[] }
  | { or: TxFilter<T>[] }
  | { not: TxFilter<T> }
```

```ts
import type { TxFilter } from '@tekocloud.de/tecexpress'
const example: TxFilter<{ id: number }> = { selector: 'id', operator: '>=', value: 1 }
console.log(example)
```

<a id="de-txgroup"></a>
### TxGroup

Gruppierter Abfragebestand mit Gruppenschlüssel und Anzahl vor dem Paging.

```ts
interface TxGroup<T> {
  key: unknown
  items: T[] | TxGroup<T>[]
  count: number
}
```

| Feld | Bedeutung |
| --- | --- |
| key | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| items | Einträge; bei Datenbindung durch dataSource ersetzt. |
| count | Anzahl Datensätze der Gruppe. |

```ts
import type { TxGroup } from '@tekocloud.de/tecexpress'
const example: TxGroup<{ id: number }> = { key: 'team', items: [{ id: 1 }], count: 1 }
console.log(example)
```

<a id="de-txloadoptions"></a>
### TxLoadOptions

Abfragevertrag für Stores: Filter, Suche, Sortierung, Gruppierung, Paging, Projektion und Abbruch.

Vue: nicht gesetzte Optionen sind undefined; die DataSource ergänzt Counts und Paging. Dart-Standards stehen im Konstruktor. skip/take gelten für Zeilen und oberste Gruppen. Lokale Verarbeitung liefert Counts auch ohne Count-Anforderung. Vue select ist eine Feldliste, Dart select ein T→T-Callback. signal/cancellation wird an eigene asynchrone Operationen weitergereicht.

```ts
interface TxLoadOptions<T> {
  sort?: TxSort<T>[]
  filter?: TxFilter<T>
  searchExpr?: TxSelector<T>[]
  searchValue?: string
  group?: TxSort<T>[]
  skip?: number
  take?: number
  select?: string[]
  requireTotalCount?: boolean
  requireGroupCount?: boolean
  signal?: AbortSignal
}
```

| Feld | Bedeutung |
| --- | --- |
| sort | Sortierbeschreibungen in Prioritätsreihenfolge. |
| filter | Filterausdruck. |
| searchExpr | Felder beziehungsweise Getter der Suche. |
| searchValue | Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung. |
| group | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| skip | Anzahl zu überspringender Ergebnisse. |
| take | Maximale Anzahl zurückzugebender Ergebnisse. |
| select | Projektion vor dem abschließenden Mapping. |
| requireTotalCount | Fordert die Gesamtanzahl vor Paging an. |
| requireGroupCount | Fordert die Anzahl oberster Gruppen an. |
| signal | AbortSignal für kooperativen Abbruch. |

```ts
import type { TxLoadOptions } from '@tekocloud.de/tecexpress'
const example: TxLoadOptions<{ id: number }> = { take: 10, requireTotalCount: true }
console.log(example)
```

<a id="de-txloadresult"></a>
### TxLoadResult

Ladeergebnis mit flachen Datensätzen und optionaler Gesamtanzahl und Gruppenhierarchie.

```ts
interface TxLoadResult<T> {
  data: T[]
  groups?: TxGroup<T>[]
  totalCount?: number
  groupCount?: number
}
```

| Feld | Bedeutung |
| --- | --- |
| data | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| groups | Gruppenhierarchie des Ergebnisses. |
| totalCount | Gesamtanzahl gefilterter Datensätze vor Paging. |
| groupCount | Anzahl oberster Gruppen vor Paging. |

```ts
import type { TxLoadResult } from '@tekocloud.de/tecexpress'
const example: TxLoadResult<{ id: number }> = { data: [{ id: 1 }], totalCount: 1 }
console.log(example)
```

<a id="de-txstore"></a>
### TxStore

Store-Vertrag für Laden sowie optionale Schlüsselauflösung und Schreiboperationen.

```ts
interface TxStore<T> {
  load(options: TxLoadOptions<T>): Promise<TxLoadResult<T>> | TxLoadResult<T>
  byKey?(key: TxKey): Promise<T | undefined> | T | undefined
  insert?(item: T): Promise<T> | T
  update?(key: TxKey, changes: Partial<T>): Promise<T> | T
  remove?(key: TxKey): Promise<void> | void
}
```

| Feld | Bedeutung |
| --- | --- |
| load | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| byKey | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| insert | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| update | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| remove | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

```ts
import type { TxStore } from '@tekocloud.de/tecexpress'
const example: TxStore<{ id: number }> = { load: () => ({ data: [{ id: 1 }] }) }
console.log(example)
```

<a id="de-txdatasourceconfig"></a>
### TxDataSourceConfig

Konfiguration für Store, Schlüssel, Abfrage, Paging und lokale oder entfernte Verarbeitung.

```ts
interface TxDataSourceConfig<T> extends Omit<
  TxLoadOptions<T>,
  'skip' | 'take' | 'signal'
> {
  store: TxStore<T> | T[]
  key?: TxSelector<T>
  pageSize?: number
  pageIndex?: number
  paginate?: boolean
  remoteOperations?: boolean
  map?: (item: T) => T
}
```

| Feld | Bedeutung |
| --- | --- |
| store | Datenbestand oder eigener Store-Vertrag. |
| key | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| pageSize | Anzahl Datensätze je Seite. |
| pageIndex | Nullbasierter Seitenindex. |
| paginate | Aktiviert Paging; false lädt den gesamten Bestand. |
| remoteOperations | Store verarbeitet Abfragen selbst; automatisch für CustomStores aktiviert. |
| map | Transformation jedes geladenen sichtbaren Datensatzes. |
| sort | Sortierbeschreibungen in Prioritätsreihenfolge. |
| filter | Filterausdruck. |
| searchExpr | Felder beziehungsweise Getter der Suche. |
| searchValue | Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung. |
| group | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| select | Projektion vor dem abschließenden Mapping. |
| requireTotalCount | Fordert die Gesamtanzahl vor Paging an. |
| requireGroupCount | Fordert die Anzahl oberster Gruppen an. |

```ts
import type { TxDataSourceConfig } from '@tekocloud.de/tecexpress'
const example: TxDataSourceConfig<{ id: number }> = { store: [{ id: 1 }], key: 'id', pageSize: 10 }
console.log(example)
```

<a id="de-txsource"></a>
### TxSource

Zulässige Datenbindung: Array, DataSource-Konfiguration oder bestehende DataSource.

```ts
type TxSource<T> = T[] | TxDataSourceConfig<T> | TxDataSource<T>
```

```ts
import type { TxSource } from '@tekocloud.de/tecexpress'
const example: TxSource<{ id: number }> = [{ id: 1 }]
console.log(example)
```

<a id="de-txpush"></a>
### TxPush

Einfüge-, Änderungs- oder Löschoperation für push. Mehrere Operationen laufen nacheinander, ohne Transaktion.

```ts
type TxPush<T> =
  | { type: 'insert'; data: T }
  | { type: 'update'; key: TxKey; data: Partial<T> }
  | { type: 'remove'; key: TxKey }
```

```ts
import type { TxPush } from '@tekocloud.de/tecexpress'
const example: TxPush<{ id: number }> = { type: 'insert', data: { id: 1 } }
console.log(example)
```

<a id="de-txarraystore"></a>
### TxArrayStore

Kopierter Speicherbestand mit lokaler Abfrage und schlüsselbasierten CRUD-Operationen.

Vue: data = [], key = "id". Dart: data ist erforderlich; ohne keyOf sind nur Abfragen möglich. Konstruktion kopiert die Liste. Doppelte Schlüssel, Einfügen vorhandener Schlüssel und Schlüsseländerungen werden abgelehnt. update/remove mit unbekanntem Schlüssel schlagen fehl; byKey liefert undefined/null.

```ts
new TxArrayStore<T>(data?: readonly T[], key?: TxSelector<T>): TxArrayStore<T>
```

| Mitglied | Typ / Rückgabe | Verhalten |
| --- | --- | --- |
| data | `T[]` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| key | `TxSelector<T>` | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| load | `(o: TxLoadOptions<T>) => TxLoadResult<T>` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| byKey | `(key: TxKey) => T &#124; undefined` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| insert | `(item: T) => T` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| update | `(key: TxKey, changes: Partial<T>) => T & Partial<T>` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| remove | `(key: TxKey) => void` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

```ts
import { TxArrayStore } from '@tekocloud.de/tecexpress'
const store = new TxArrayStore([{ id: 1, text: 'One' }], 'id')
console.log(store.load({ take: 10 }), store.byKey(1))
store.insert({ id: 2, text: 'Two' })
store.update(2, { text: 'Updated' })
store.remove(2)
```

<a id="de-txcustomstore"></a>
### TxCustomStore

Adapter für eigene synchrone oder asynchrone Store-Callbacks. Nicht angebotene Operationen sind nicht verfügbar.

load ist erforderlich; byKey/insert/update/remove sind optional. load erhält TxLoadOptions und liefert TxLoadResult direkt oder asynchron. Eigene HTTP-Callbacks müssen Statuscodes prüfen und Fehler weitergeben. byKey liefert undefined/null bei fehlendem Datensatz. Für Paging muss der Store data und totalCount vor Paging liefern. Bei remoteOperations false liefert er alle Rohdaten. Das Beispiel verwendet einen lokalen asynchronen Callback und benötigt keinen Server.

```ts
new TxCustomStore<T>(callbacks: TxStore<T>): TxCustomStore<T>
```

| Mitglied | Typ / Rückgabe | Verhalten |
| --- | --- | --- |
| load | `(options: TxLoadOptions<T>) => TxLoadResult<T> &#124; Promise<TxLoadResult<T>>` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| byKey | `((key: TxKey) => T &#124; Promise<T &#124; undefined> &#124; undefined) &#124; undefined` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| insert | `((item: T) => T &#124; Promise<T>) &#124; undefined` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| update | `((key: TxKey, changes: Partial<T>) => T &#124; Promise<T>) &#124; undefined` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| remove | `((key: TxKey) => Promise<void> &#124; void) &#124; undefined` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

```ts
import { TxCustomStore, txQuery } from '@tekocloud.de/tecexpress'
// Replace callbacks with your own HTTP/database integration.
const store = new TxCustomStore<{ id: number }>({ load: async options => txQuery([{ id: 1 }], options), byKey: async id => id === 1 ? { id: 1 } : undefined })
console.log(await store.load({}), await store.byKey?.(1))
```

<a id="de-txdatasource"></a>
### TxDataSource

Beobachtbare Datenquelle mit Abfragezustand und asynchronem Laden. Schreiboperationen laden anschließend neu; der Eigentümer entsorgt die Instanz.

Standardkonfiguration: pageSize 20, pageIndex 0, paginate true; ArrayStore lokal, andere Stores entfernt. Der Vue-Arraykurzaufruf behält Paging bei; Dart TxDataSource.array verwendet paginate false. items startet leer; load() ist erforderlich, sofern kein gebundener Konsument initial lädt. Ungültiges Paging wird abgelehnt. Store und Schlüssel durch eine neue Instanz ersetzen. configure liefert Promise/Future der neu geladenen Liste. byKey liefert Promise/Future des Datensatzes oder undefined/null; insert/update liefern den geschriebenen Datensatz, remove keinen Wert. Vue push liefert die neue Liste, Dart push keinen Wert. cancel/dispose liefern keinen Wert. Lade-/Schreibfehler stehen zusätzlich in error. Bei Stores ohne optionale Operation wirft Vue Error, Dart UnsupportedError. Nach dispose schlägt load fehl.

```ts
new TxDataSource<T>(config: TxDataSourceConfig<T> | T[]): TxDataSource<T>
```

| Mitglied | Typ / Rückgabe | Verhalten |
| --- | --- | --- |
| store | `TxStore<T>` | Datenbestand oder eigener Store-Vertrag. |
| key | `TxSelector<T>` | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| items | `T[]` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| groups | `TxGroup<T>[] &#124; undefined` | Gruppenhierarchie des Ergebnisses. |
| totalCount | `number` | Gesamtanzahl gefilterter Datensätze vor Paging. |
| groupCount | `number &#124; undefined` | Anzahl oberster Gruppen vor Paging. |
| loading | `boolean` | Zeigt den Ladezustand. |
| error | `unknown` | Letzter Lade-/Schreibfehler. |
| loaded | `boolean` | Mindestens ein Ladevorgang war erfolgreich. |
| config | `TxDataSourceConfig<T>` | Konfiguration der Instanz. |
| containsKey | `(key: TxKey) => boolean &#124; undefined` | Liefert false für bekannte Löschungen, beim ArrayStore einen Wahrheitswert, sonst undefined/null. |
| subscribe | `(listener: () => void) => () => void` | Registriert einen Änderungslistener und liefert eine Abmeldefunktion. |
| pendingLoad | `Promise<T[]> &#124; undefined` | Promise des zuletzt gestarteten Ladevorgangs. |
| load | `() => Promise<T[]>` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| reload | `() => Promise<T[]>` | Lädt den aktuellen Abfragezustand erneut und liefert die sichtbaren Datensätze. |
| configure | `(changes: Partial<TxDataSourceConfig<T>>) => Promise<T[]>` | Ändert Abfrageoptionen und lädt neu. Suche, Filter und Seitengröße setzen die Seite zurück, sofern nicht ausdrücklich angegeben. |
| cancel | `() => void` | Synchron auf true setzen, um die Aktion abzubrechen. |
| byKey | `(key: TxKey) => Promise<Awaited<T> &#124; undefined>` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| insert | `(item: T) => Promise<T>` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| update | `(key: TxKey, changes: Partial<T>) => Promise<T>` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| remove | `(key: TxKey) => Promise<void>` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |
| push | `(changes: TxPush<T>[]) => Promise<T[]>` | Führt Store-Schreiboperationen nacheinander aus und lädt einmal neu; keine Transaktion, Teilerfolg bei Fehler möglich. |
| dispose | `() => void` | Beendet Abfragen und Listener; danach die Instanz nicht mehr verwenden. |

```ts
import { TxDataSource } from '@tekocloud.de/tecexpress'
const source = new TxDataSource({ store: [{ id: 1, text: 'One' }], key: 'id', pageSize: 10 })
const unsubscribe = source.subscribe(() => console.log(source.loading, source.error))
await source.load()
await source.configure({ searchExpr: ['text'], searchValue: 'One' })
console.log(await source.byKey(1), source.containsKey(1))
await source.insert({ id: 2, text: 'Two' })
await source.update(2, { text: 'Updated' })
await source.push([{ type: 'update', key: 2, data: { text: 'Changed' } }])
await source.remove(2)
await source.reload()
source.cancel()
unsubscribe()
source.dispose()
```

<a id="de-txfilestore"></a>
### txFileStore

Verbindet einen Provider und einen Getter des aktuellen Ordners mit einem abfragbaren Store.

Parameter: provider und parent als Getter der aktuellen Ordner-ID (null = Wurzel). Rückgabe: TxStore&lt;TxFileEntry&gt;. load liefert Promise/Future&lt;TxLoadResult&lt;TxFileEntry&gt;&gt;. Providerfehler werden weitergegeben. Nach einem Ordnerwechsel erneut laden.

```ts
function txFileStore(provider: TxFileProvider, parent: () => string | null): TxStore<TxFileEntry>
```

```ts
import { TxMemoryFileProvider, txFileStore } from '@tekocloud.de/tecexpress'
const provider = new TxMemoryFileProvider()
const store = txFileStore(provider, () => null)
console.log(await store.load({ take: 10 }))
```

<a id="de-txhttpupload"></a>
### txHttpUpload

Erzeugt einen Multipart-POST-Adapter. Der Server muss Chunks zusammensetzen. Nicht erfolgreiche HTTP-Antworten und Netzwerkfehler schlagen fehl.

Parameter: config mit erforderlicher URL; Rückgabe TxUploadAdapter. Der Adapter erhält file und context und liefert asynchron den letzten HTTP-Antworttext. fieldName = file; zusätzliche Felder/Header standardmäßig leer. chunkSize muss positiv sein; chunkFields erhält file, nullbasierten index und count. Abbruch und HTTP-/Netzwerkfehler lehnen die Operation ab. Kein automatisches JSON-Parsing und keine automatische serverseitige Chunk-Zusammenführung.

```ts
function txHttpUpload(config: TxHttpUploadConfig): TxUploadAdapter
```

```ts
import { txHttpUpload } from '@tekocloud.de/tecexpress'
const upload = txHttpUpload({ url: '/api/upload', fieldName: 'file', chunkSize: 1024 * 1024 })
// Browser only; requires your own multipart server and chunk assembly.
const controller = new AbortController()
await upload(new File(['Hello'], 'hello.txt'), { signal: controller.signal, onProgress: (loaded, total) => console.log(loaded, total) })
```

<a id="de-txfileentry"></a>
### TxFileEntry

Datei-/Ordnermetadaten mit stabiler ID; parentId null bezeichnet das Wurzelverzeichnis.

Dart copyWith behält nicht angegebene Felder bei; root: true setzt parentId ausdrücklich auf null. parentId: null allein behält den bisherigen Elternordner.

```ts
interface TxFileEntry {
  id: string
  parentId: string | null
  name: string
  isDirectory: boolean
  size?: number
  modified?: Date
  content?: Blob
}
```

| Feld | Bedeutung |
| --- | --- |
| id | Eindeutige stabile ID. |
| parentId | Elternordner-ID; null bezeichnet die Wurzel. |
| name | Name des Eingabefelds beziehungsweise Dateiname. |
| isDirectory | Kennzeichnet einen Ordner. |
| size | Dateigröße in Bytes. |
| modified | Letzter Änderungszeitpunkt. |
| content | Eigener Inhalt beziehungsweise Dateiinhalt als Blob. |

```ts
import type { TxFileEntry } from '@tekocloud.de/tecexpress'
const example: TxFileEntry = { id: '1', parentId: null, name: 'Documents', isDirectory: true }
console.log(example)
```

<a id="de-txfileprovider"></a>
### TxFileProvider

Asynchroner Vertrag für Verzeichnislisten und Dateioperationen.

list ist erforderlich. Vue bietet optionale Methoden; Dart-Implementierungen deklarieren Fähigkeiten in capabilities und überschreiben die entsprechenden Methoden. Nicht implementierte Dart-Operationen werfen UnsupportedError. list/upload berücksichtigen kooperativen Abbruch. createDirectory/upload liefern einen Eintrag; rename/copy/move/remove keinen Wert; download liefert Blob (Vue) oder Uint8List (Dart).

```ts
interface TxFileProvider {
  list(parentId: string | null, signal?: AbortSignal): Promise<TxFileEntry[]>
  createDirectory?(parentId: string | null, name: string): Promise<TxFileEntry>
  rename?(id: string, name: string): Promise<void>
  copy?(id: string, target: string | null): Promise<void>
  move?(id: string, target: string | null): Promise<void>
  remove?(id: string): Promise<void>
  upload?(
    parentId: string | null,
    file: File,
    signal?: AbortSignal,
  ): Promise<TxFileEntry>
  download?(id: string): Promise<Blob>
}
```

| Feld | Bedeutung |
| --- | --- |
| list | Liefert Einträge des angegebenen Elternordners; null liest die Wurzel. |
| createDirectory | Legt einen Ordner mit gültigem, im Elternordner eindeutigem Namen an. |
| rename | Benennt eine Datei oder einen Ordner um; ID und Elternordner bleiben erhalten. |
| copy | Kopiert einen Eintrag rekursiv in den Zielordner; neue IDs werden vergeben. |
| move | Verschiebt einen Eintrag in den Zielordner; Zyklen werden abgelehnt. |
| remove | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |
| upload | Lädt eine Datei in den angegebenen Ordner; liefert den neuen Dateieintrag. |
| download | Liefert Dateiinhalt; Ordnerdownloads schlagen fehl. |

```ts
import type { TxFileProvider } from '@tekocloud.de/tecexpress'
const example: TxFileProvider = { list: async () => [] }
console.log(example)
```

<a id="de-txmemoryfileprovider"></a>
### TxMemoryFileProvider

Flüchtiger Datei-Provider mit rekursivem Kopieren/Löschen, Namensprüfung und Zyklusschutz; Daten überleben keinen Neustart.

Alle Dateioperationen sind asynchron. Ordner-IDs und Datei-IDs sind Strings, null als Eltern-/Ziel-ID bezeichnet die Wurzel. Ungültige Namen, Namenskollisionen, unbekannte IDs, doppelte IDs und Zyklen schlagen fehl. Kopieren erhält Inhalte, vergibt neue IDs und kopiert Unterordner. Entfernen löscht rekursiv. Ohne gespeicherten Inhalt ist der Download leer; Ordnerdownloads sind nicht möglich.

```ts
new TxMemoryFileProvider(entries?: TxFileEntry[]): TxMemoryFileProvider
```

| Mitglied | Typ / Rückgabe | Verhalten |
| --- | --- | --- |
| list | `(parentId: string &#124; null, signal?: AbortSignal) => Promise<{ id: string; parentId: string &#124; null; name: string; isDirectory: boolean; size?: number; modified?: Date; content?: Blob; }[]>` | Liefert Einträge des angegebenen Elternordners; null liest die Wurzel. |
| createDirectory | `(parentId: string &#124; null, name: string) => Promise<{ id: string; parentId: string &#124; null; name: string; isDirectory: boolean; size?: number; modified?: Date; content?: Blob; }>` | Legt einen Ordner mit gültigem, im Elternordner eindeutigem Namen an. |
| rename | `(id: string, name: string) => Promise<void>` | Benennt eine Datei oder einen Ordner um; ID und Elternordner bleiben erhalten. |
| move | `(id: string, target: string &#124; null) => Promise<void>` | Verschiebt einen Eintrag in den Zielordner; Zyklen werden abgelehnt. |
| copy | `(id: string, target: string &#124; null) => Promise<void>` | Kopiert einen Eintrag rekursiv in den Zielordner; neue IDs werden vergeben. |
| remove | `(id: string) => Promise<void>` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |
| upload | `(parentId: string &#124; null, file: File, signal?: AbortSignal) => Promise<{ id: string; parentId: string &#124; null; name: string; size: number; isDirectory: boolean; content: Blob; modified: Date; }>` | Lädt eine Datei in den angegebenen Ordner; liefert den neuen Dateieintrag. |
| download | `(id: string) => Promise<Blob>` | Liefert Dateiinhalt; Ordnerdownloads schlagen fehl. |

```ts
import { TxMemoryFileProvider } from '@tekocloud.de/tecexpress'
const provider = new TxMemoryFileProvider()
const folder = await provider.createDirectory(null, 'Documents')
const file = await provider.upload(folder.id, new File(['Hello'], 'hello.txt'))
await provider.rename(file.id, 'renamed.txt')
await provider.copy(file.id, null)
await provider.move(file.id, null).catch(error => console.log(error.message)) // name collision
console.log(await provider.list(folder.id), await provider.download(file.id))
await provider.remove(folder.id) // recursive
```

<a id="de-txuploadcontext"></a>
### TxUploadContext

Abbruch und Fortschrittsmeldung einer einzelnen Uploadoperation; Fortschritt wird in Bytes gemeldet.

```ts
interface TxUploadContext {
  signal: AbortSignal
  onProgress: (loaded: number, total: number) => void
}
```

| Feld | Bedeutung |
| --- | --- |
| signal | AbortSignal für kooperativen Abbruch. |
| onProgress | Meldet abgeschlossene Bytes und Gesamtgröße. |

```ts
import type { TxUploadContext } from '@tekocloud.de/tecexpress'
const example: TxUploadContext = { signal: new AbortController().signal, onProgress: (loaded, total) => console.log(loaded, total) }
console.log(example)
```

<a id="de-txuploadadapter"></a>
### TxUploadAdapter

Asynchroner Callback für den Upload einer Datei; Ergebnis geht an den Erfolgs-Callback, Fehler an die Fehlerbehandlung.

```ts
type TxUploadAdapter = (
  file: File,
  context: TxUploadContext,
) => Promise<unknown>
```

```ts
import type { TxUploadAdapter } from '@tekocloud.de/tecexpress'
const example: TxUploadAdapter = async (file, context) => { context.signal.throwIfAborted(); context.onProgress(file.size, file.size); return file.name }
console.log(example)
```

<a id="de-txhttpuploadconfig"></a>
### TxHttpUploadConfig

Multipart-HTTP-Konfiguration mit Zieladresse, Feldern, Headern und optionalen Chunks.

```ts
interface TxHttpUploadConfig {
  url: string
  fieldName?: string
  headers?: Record<string, string>
  withCredentials?: boolean
  fields?: Record<string, string>
  chunkSize?: number
  chunkFields?: (
    file: File,
    index: number,
    count: number,
  ) => Record<string, string>
}
```

| Feld | Bedeutung |
| --- | --- |
| url | Zieladresse des Uploadservers. |
| fieldName | Multipart-Feldname der Datei. |
| headers | Zusätzliche HTTP-Header. |
| withCredentials | Sendet Browser-Credentials bei XHR. |
| fields | Zusätzliche Multipart-Textfelder. |
| chunkSize | Chunkgröße in Bytes; muss positiv sein. |
| chunkFields | Felder je Chunk; Index ist nullbasiert. |

```ts
import type { TxHttpUploadConfig } from '@tekocloud.de/tecexpress'
const example: TxHttpUploadConfig = { url: '/api/upload', fieldName: 'file' }
console.log(example)
```

<a id="de-development"></a>
### Entwicklung und weiterführende Dokumentation

```sh
npm install
npm run typecheck
npm test
npm run test:package
npm pack --dry-run
```

Die Befehle im jeweiligen Paketordner ausführen. Ein Dry-run veröffentlicht nichts.

[Veröffentlichungsanleitung](https://github.com/tekocloud/tecexpress/blob/main/PUBLISHING.md) · [Showcase](https://github.com/tekocloud/tecexpress/blob/main/npm/demo/App.vue) · [Änderungen](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/CHANGELOG.md) · [MIT](https://github.com/tekocloud/tecexpress/blob/main/npm/LICENSE)
[DataSource](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/data-source.md) · [Scheduler](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/scheduler.md) · [Cards / Chat](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/cards-chat.md) · [Erweiterungen](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/extensions.md)

<a id="en"></a>
## English

Complete public API for tecexpress 0.5.0 for Vue 3. MIT licensed, no license key.

[Installation and getting started](#en-start) · [Data and state](#en-data) · [Files, uploads and maps](#en-adapters) · [API index](#en-api) · [Development](#en-development)

<a id="en-start"></a>
### Installation and getting started

```sh
npm install @tekocloud.de/tecexpress vue@^3.5.0
```

All Vue examples below are complete single-file components. Save as App.vue in a Vue 3 application with TypeScript. For local development use Node.js 24.15+ within 24.x.

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTextBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const text = ref('Alex')
</script>

<template>
  <TxTextBox v-model="text" label="Name" />
</template>
```

Import components individually or register all of them with `app.use(Tecexpress)`. camelCase props can be written as kebab-case in templates.

**Themes**

```ts
import '@tekocloud.de/tecexpress/themes/index.css'
document.documentElement.dataset.txTheme = 'dark' // 'light'
// Fixed theme: import only themes/light.css or themes/dark.css instead.
```

Without data-tx-theme, light is used. The attribute also works on a container and is retained for overlays. Override tokens on the container after importing CSS.

```css
.my-app { --tx-accent: #6636c6; --tx-radius: 10px; --tx-control-height: 44px; }
```

Available tokens: `--tx-font`, `--tx-font-size`, `--tx-radius`, `--tx-space`, `--tx-control-height`, `--tx-bg`, `--tx-surface`, `--tx-surface-alt`, `--tx-text`, `--tx-muted`, `--tx-border`, `--tx-accent`, `--tx-accent-text`, `--tx-hover`, `--tx-selection`, `--tx-danger`, `--tx-success`, `--tx-focus`, `--tx-shadow`, `--tx-backdrop`, `--tx-scheduler-slot-height`.

<a id="en-data"></a>
### Data and state

Data binding accepts arrays, configurations or existing DataSource instances. A component owns and disposes sources created from configurations; the application owns borrowed instances. dataSource takes precedence over items. Shared instances also share filters, search, sort and page state. Use separate instances for independent views.

Accept controlled values using v-model or update events. Without a value binding, supported components manage state internally.

ArrayStores process queries locally; custom stores process them remotely by default. With remoteOperations = false, custom stores must return all raw data. The application defines the server protocol; getters are not serializable. Supply totalCount for server paging. Calendar and chat need full histories or an intentionally limited dataset; paginate = false loads everything.

load/reload/configure can fail: await with try/catch and display error. New loads replace old loads; late responses cannot overwrite newer state. Keys remain unique and immutable. Writes without the required store operation fail. push is not a transaction.

Appointment ends follow their starts. All-day appointments use local day boundaries with an exclusive end. UTC instants display in local time. Chat displays plain text, not HTML; the application supplies backend and AI services.

```ts
import { TxDataSource } from '@tekocloud.de/tecexpress'
const source = new TxDataSource({ store: [{ id: 1, text: 'One' }], paginate: false })
try { await source.load() } catch (error) { console.error(error) }
source.dispose()
```

<a id="en-adapters"></a>
### Files, uploads and maps

MemoryFileProvider stores only in memory. Invalid names, duplicate IDs/names, invalid parents and cyclic moves are rejected. File operations are asynchronous. Optional provider methods determine visible actions; txFileStore supports loading, removal and renaming when offered.

HTTP uploads require your own multipart POST endpoint. fieldName defaults to file. With chunkSize, the server must assemble the protocol agreed through chunkFields. Retrying starts from the beginning. XHR reports progress during transmission; withCredentials defaults to false.

Map tiles use {z}/{x}/{y}. Configure tile sources, credentials and attribution yourself. The application calls GeoAdapter and binds its results as markers/routes. Without a source, no implicit external map request is made.

<a id="en-api"></a>
### API index

- [TxRadioGroup](#en-txradiogroup)
- [TxButtonGroup](#en-txbuttongroup)
- [TxLookup](#en-txlookup)
- [TxTagBox](#en-txtagbox)
- [TxList](#en-txlist)
- [TxGallery](#en-txgallery)
- [TxFloatingActionButton](#en-txfloatingactionbutton)
- [TxContextMenu](#en-txcontextmenu)
- [TxActionSheet](#en-txactionsheet)
- [TxRangeSlider](#en-txrangeslider)
- [TxRangeSelector](#en-txrangeselector)
- [TxFileManager](#en-txfilemanager)
- [TxFileUploader](#en-txfileuploader)
- [TxMap](#en-txmap)
- [TxTabPanel](#en-txtabpanel)
- [TxLoadPanel](#en-txloadpanel)
- [useTxSource](#en-usetxsource)
- [notify](#en-notify)
- [TxNotifyOptions](#en-txnotifyoptions)
- [TxNotifyHandle](#en-txnotifyhandle)
- [TxCollectionItem](#en-txcollectionitem)
- [TxEntry](#en-txentry)
- [TxRangeValue](#en-txrangevalue)
- [txProject](#en-txproject)
- [txUnproject](#en-txunproject)
- [TxCoordinate](#en-txcoordinate)
- [TxMapMarker](#en-txmapmarker)
- [TxMapRoute](#en-txmaproute)
- [TxGeoAdapter](#en-txgeoadapter)
- [TxButton](#en-txbutton)
- [TxTextBox](#en-txtextbox)
- [TxTextArea](#en-txtextarea)
- [TxNumberBox](#en-txnumberbox)
- [TxCheckBox](#en-txcheckbox)
- [TxSwitch](#en-txswitch)
- [TxSelectBox](#en-txselectbox)
- [TxDateBox](#en-txdatebox)
- [TxTabs](#en-txtabs)
- [TxToolbar](#en-txtoolbar)
- [TxMenu](#en-txmenu)
- [TxPopup](#en-txpopup)
- [TxTooltip](#en-txtooltip)
- [TxToast](#en-txtoast)
- [TxLoadIndicator](#en-txloadindicator)
- [TxDataGrid](#en-txdatagrid)
- [TxColumn](#en-txcolumn)
- [TxScheduler](#en-txscheduler)
- [TxCard](#en-txcard)
- [TxCardView](#en-txcardview)
- [TxChat](#en-txchat)
- [EditorValue](#en-editorvalue)
- [ValueChangedEvent](#en-valuechangedevent)
- [Item](#en-item)
- [RowKey](#en-rowkey)
- [DataRow](#en-datarow)
- [Column](#en-column)
- [SortDescriptor](#en-sortdescriptor)
- [RowClickEvent](#en-rowclickevent)
- [SelectionChangedEvent](#en-selectionchangedevent)
- [Appointment](#en-appointment)
- [SchedulerView](#en-schedulerview)
- [SchedulerDate](#en-schedulerdate)
- [SchedulerEditing](#en-schedulerediting)
- [AppointmentEvent](#en-appointmentevent)
- [AppointmentChangeEvent](#en-appointmentchangeevent)
- [AppointmentClickEvent](#en-appointmentclickevent)
- [AppointmentUpdatingEvent](#en-appointmentupdatingevent)
- [AppointmentUpdatedEvent](#en-appointmentupdatedevent)
- [SchedulerCellClickEvent](#en-schedulercellclickevent)
- [CardField](#en-cardfield)
- [CardClickEvent](#en-cardclickevent)
- [CardSelectionChangedEvent](#en-cardselectionchangedevent)
- [ChatUser](#en-chatuser)
- [ChatMessage](#en-chatmessage)
- [ChatMessageEvent](#en-chatmessageevent)
- [ChatMessageEnteredEvent](#en-chatmessageenteredevent)
- [ChatTypingEvent](#en-chattypingevent)
- [Tecexpress](#en-tecexpress)
- [txRead](#en-txread)
- [txMatches](#en-txmatches)
- [txQuery](#en-txquery)
- [TxKey](#en-txkey)
- [TxSelector](#en-txselector)
- [TxSort](#en-txsort)
- [TxFilter](#en-txfilter)
- [TxGroup](#en-txgroup)
- [TxLoadOptions](#en-txloadoptions)
- [TxLoadResult](#en-txloadresult)
- [TxStore](#en-txstore)
- [TxDataSourceConfig](#en-txdatasourceconfig)
- [TxSource](#en-txsource)
- [TxPush](#en-txpush)
- [TxArrayStore](#en-txarraystore)
- [TxCustomStore](#en-txcustomstore)
- [TxDataSource](#en-txdatasource)
- [txFileStore](#en-txfilestore)
- [txHttpUpload](#en-txhttpupload)
- [TxFileEntry](#en-txfileentry)
- [TxFileProvider](#en-txfileprovider)
- [TxMemoryFileProvider](#en-txmemoryfileprovider)
- [TxUploadContext](#en-txuploadcontext)
- [TxUploadAdapter](#en-txuploadadapter)
- [TxHttpUploadConfig](#en-txhttpuploadconfig)

`undefined` (Vue) or optional nullable parameters (Dart) mean no externally supplied value. Boolean Vue props without an explicit default are false. Types and defaults below come from the current implementation; they do not promise additional capabilities.

<a id="en-txradiogroup"></a>
### TxRadioGroup

Visible radio options for a single selection.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `modelValue` | `any` | `undefined` | Controlled v-model value. |
| `selectionMode` | `"none" &#124; "single" &#124; "multiple" &#124; undefined` | `single` | Selection mode. |
| `layout` | `string &#124; undefined` | `horizontal` | Horizontal or vertical arrangement. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| selectionChanged | New selection: { value, itemData }. |
| itemClick | { itemData } |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item, selected } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxRadioGroup } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxRadioGroup v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="en-txbuttongroup"></a>
### TxButtonGroup

Group of actions with no, single or multiple selection.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `modelValue` | `any` | `undefined` | Controlled v-model value. |
| `selectionMode` | `"none" &#124; "single" &#124; "multiple" &#124; undefined` | `single` | Selection mode. |
| `layout` | `string &#124; undefined` | `horizontal` | Horizontal or vertical arrangement. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| selectionChanged | New selection: { value, itemData }. |
| itemClick | { itemData } |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item, selected } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxButtonGroup, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxButtonGroup v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="en-txlookup"></a>
### TxLookup

Searchable single selection backed by a loadable data source.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `modelValue` | `any` | `undefined` | Controlled v-model value. |
| `placeholder` | `string &#124; undefined` | `Auswählen …` | Hint for an empty input. |
| `searchEnabled` | `boolean &#124; undefined` | `true` | Enables searching. |
| `acceptCustomValue` | `boolean &#124; undefined` | `false` | Allows custom entries. |
| `showSelectionControls` | `boolean &#124; undefined` | `false` | Shows multiple/select-all controls. |
| `showClearButton` | `boolean &#124; undefined` | `true` | Shows the clear action. |
| `maxDisplayedTags` | `number &#124; undefined` | `4` | Maximum visible tags before summarizing. |
| `applyValueMode` | `string &#124; undefined` | `instantly` | Apply immediately or through confirmation. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |
| customItemCreating | Custom text in { text }; add a custom entry through the application. |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxLookup } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxLookup v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="en-txtagbox"></a>
### TxTagBox

Searchable multiple selection with tags. Select all applies to loaded results.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `modelValue` | `any` | `undefined` | Controlled v-model value. |
| `placeholder` | `string &#124; undefined` | `Auswählen …` | Hint for an empty input. |
| `searchEnabled` | `boolean &#124; undefined` | `true` | Enables searching. |
| `acceptCustomValue` | `boolean &#124; undefined` | `false` | Allows custom entries. |
| `showSelectionControls` | `boolean &#124; undefined` | `false` | Shows multiple/select-all controls. |
| `showClearButton` | `boolean &#124; undefined` | `true` | Shows the clear action. |
| `maxDisplayedTags` | `number &#124; undefined` | `4` | Maximum visible tags before summarizing. |
| `applyValueMode` | `string &#124; undefined` | `instantly` | Apply immediately or through confirmation. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |
| customItemCreating | Custom text in { text }; add a custom entry through the application. |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTagBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const keys = ref<number[]>([])
</script>

<template>
  <TxTagBox v-model="keys" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="en-txlist"></a>
### TxList

List with search, selection and optional deletion or reordering through events.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `modelValue` | `unknown[] &#124; undefined` | `[]` | Controlled v-model value. |
| `selectionMode` | `string &#124; undefined` | `none` | Selection mode. |
| `searchEnabled` | `boolean &#124; undefined` | `false` | Enables searching. |
| `grouped` | `boolean &#124; undefined` | `false` | Displays loaded entries by group. |
| `allowDeleting` | `boolean &#124; undefined` | `false` | Shows list entry delete actions. |
| `allowReordering` | `boolean &#124; undefined` | `false` | Shows list entry reorder actions. |
| `virtual` | `boolean &#124; undefined` | `false` | Renders only the visible list region. |
| `itemHeight` | `number &#124; undefined` | `44` | Fixed row height for virtual lists. |
| `height` | `number &#124; undefined` | `300` | Height; Vue numbers use pixels, Flutter uses logical pixels. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| itemClick | { itemData, itemIndex } |
| itemDeleted | Deleted list entry in { itemData }. |
| itemReordered | Reordering as { itemData, fromIndex, toIndex, items }; items contains the new list. |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item, index, selected } |

```vue
<script setup lang="ts">
import { TxList } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxList :items="[{ id: 1, text: 'One' }]" search-enabled />
</template>
```

<a id="en-txgallery"></a>
### TxGallery

Browsable gallery with optional autoplay; it is not a media player.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `selectedIndex` | `number &#124; undefined` | `undefined` | Zero-based active entry. |
| `loop` | `boolean &#124; undefined` | `false` | Allows wrapping from the last gallery entry to the first. |
| `slideshowDelay` | `number &#124; undefined` | `0` | Automatic navigation interval; 0 disables it. |
| `showIndicator` | `boolean &#124; undefined` | `true` | Shows gallery indicators. |
| `height` | `number &#124; undefined` | `240` | Height; Vue numbers use pixels, Flutter uses logical pixels. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:selectedIndex | New selectedIndex value; accept using v-model:selectedIndex (modelValue: v-model). |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item, index } |

```vue
<script setup lang="ts">
import { TxGallery } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxGallery :items="['One', 'Two']"><template #item="{ item }">{{ item }}</template></TxGallery>
</template>
```

<a id="en-txfloatingactionbutton"></a>
### TxFloatingActionButton

Floating primary action or expandable action group.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `icon` | `string &#124; undefined` | `+` | Action icon. |
| `position` | `string &#124; undefined` | `bottom-right` | Position of the notification or overlay. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| itemClick | { itemData } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxFloatingActionButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxFloatingActionButton :items="[{ text: 'Add' }]" @item-click="saved = true" />
</template>
```

<a id="en-txcontextmenu"></a>
### TxContextMenu

Context actions opened by right-clicking or long-pressing the target.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `visible` | `boolean &#124; undefined` | `false` | Controls visibility. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:visible | New visible value; accept using v-model:visible (modelValue: v-model). |
| itemClick | { itemData } |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxContextMenu } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxContextMenu :items="[{ text: 'Copy' }]" @item-click="saved = true">Right click here</TxContextMenu>
</template>
```

<a id="en-txactionsheet"></a>
### TxActionSheet

Bottom action sheet with a cancel action.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `items` | `TxEntry[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `dataSource` | `TxSource<TxEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `visible` | `boolean &#124; undefined` | `false` | Controls visibility. |
| `title` | `string &#124; undefined` | `undefined` | View title. |
| `cancelText` | `string &#124; undefined` | `Abbrechen` | Cancel action label. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:visible | New visible value; accept using v-model:visible (modelValue: v-model). |
| itemClick | { itemData } |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { item } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxActionSheet, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const visible = ref(false)
</script>

<template>
  <TxButton text="Actions" @click="visible = true" />
  <TxActionSheet v-model:visible="visible" :items="[{ text: 'Copy' }]" />
</template>
```

<a id="en-txrangeslider"></a>
### TxRangeSlider

Select an interval using two bounds, steps and minimum/maximum distances.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `[TxRangeValue, TxRangeValue] &#124; undefined` | `undefined` | Controlled v-model value. |
| `min` | `number &#124; Date &#124; undefined` | `0` | Lower allowed bound. |
| `max` | `number &#124; Date &#124; undefined` | `100` | Upper allowed bound. |
| `step` | `number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `minRange` | `number &#124; undefined` | `0` | Minimum distance between range bounds. |
| `maxRange` | `number &#124; undefined` | `undefined` | Maximum distance between range bounds. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `label` | `string &#124; undefined` | `Bereich` | Label or accessible name. |
| `showLabels` | `boolean &#124; undefined` | `true` | Displays both range bounds as text. |
| `dataSource` | `TxSource<Record<string, unknown>> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `argumentExpr` | `string &#124; undefined` | `argument` | Field for the series X axis. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `seriesType` | `string &#124; undefined` | `area` | Series appearance: area/line/bar. |
| `tickCount` | `number &#124; undefined` | `5` | Number of axis labels. |
| `format` | `((v: TxRangeValue) => string) &#124; undefined` | `undefined` | Formats range values for display. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | { value } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxRangeSlider } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const range = ref<[number, number]>([20, 80])
</script>

<template>
  <TxRangeSlider v-model="range" :min="0" :max="100" />
</template>
```

<a id="en-txrangeselector"></a>
### TxRangeSelector

Interval selection over a simple area, line or bar series.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `[TxRangeValue, TxRangeValue] &#124; undefined` | `undefined` | Controlled v-model value. |
| `min` | `number &#124; Date &#124; undefined` | `0` | Lower allowed bound. |
| `max` | `number &#124; Date &#124; undefined` | `100` | Upper allowed bound. |
| `step` | `number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `minRange` | `number &#124; undefined` | `0` | Minimum distance between range bounds. |
| `maxRange` | `number &#124; undefined` | `undefined` | Maximum distance between range bounds. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `label` | `string &#124; undefined` | `Bereich` | Label or accessible name. |
| `showLabels` | `boolean &#124; undefined` | `true` | Displays both range bounds as text. |
| `dataSource` | `TxSource<Record<string, unknown>> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `argumentExpr` | `string &#124; undefined` | `argument` | Field for the series X axis. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `seriesType` | `string &#124; undefined` | `area` | Series appearance: area/line/bar. |
| `tickCount` | `number &#124; undefined` | `5` | Number of axis labels. |
| `format` | `((v: TxRangeValue) => string) &#124; undefined` | `undefined` | Formats range values for display. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | { value } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxRangeSelector } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const range = ref<[number, number]>([20, 80])
</script>

<template>
  <TxRangeSelector v-model="range" :data-source="[{ argument: 0, value: 4 }, { argument: 100, value: 8 }]" />
</template>
```

<a id="en-txfilemanager"></a>
### TxFileManager

Directory navigation and file actions. Provider capabilities determine available operations; no file server is included.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<TxFileEntry> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `provider` | `TxFileProvider` | `required` | File provider with supported operations. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `view` | `string &#124; undefined` | `details` | Display mode. |
| `label` | `string &#124; undefined` | `Dateimanager` | Label or accessible name. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| selectionChanged | New selection: TxFileEntry[]. |
| fileOpened | Activated TxFileEntry. |
| error | File operation error object. |

```vue
<script setup lang="ts">
import { TxFileManager, TxMemoryFileProvider } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const provider = new TxMemoryFileProvider([{ id: '1', parentId: null, name: 'Documents', isDirectory: true }])
</script>

<template>
  <TxFileManager :provider="provider" />
</template>
```

<a id="en-txfileuploader"></a>
### TxFileUploader

File picker and upload queue with size/type checks, progress and retry from the beginning.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<File> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `adapter` | `TxUploadAdapter &#124; undefined` | `undefined` | Upload function for one file. |
| `multiple` | `boolean &#124; undefined` | `false` | Allows multiple files. |
| `accept` | `string &#124; undefined` | `undefined` | Browser file type filter, such as .pdf or image/*. |
| `maxFileSize` | `number &#124; undefined` | `undefined` | Maximum file size in bytes. |
| `minFileSize` | `number &#124; undefined` | `0` | Minimum file size in bytes. |
| `uploadMode` | `string &#124; undefined` | `useButtons` | Immediate upload or upload started through buttons. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `Dateien hochladen` | Label or accessible name. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| valueChanged | New value in { value }; editors also include previousValue and event. |
| uploaded | Upload succeeded: { file, result }. |
| uploadError | Upload failed: { file, error }. |
| progress | Upload progress in bytes: { file, loaded, total }. |

Available through a template ref: `upload(): Promise<void[]>` starts all ready queued entries in parallel; `cancel(): void` cancels all active entries. Example: `await uploader.value?.upload()` or `uploader.value?.cancel()`. Declare `const uploader = ref<{ upload(): Promise<void[]>; cancel(): void } | null>(null)` and bind `ref="uploader"`.

```vue
<script setup lang="ts">
import { TxFileUploader, txHttpUpload } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
// Replace with your server's multipart endpoint.
const upload = txHttpUpload({ url: '/api/upload' })
</script>

<template>
  <TxFileUploader :adapter="upload" accept=".txt" />
</template>
```

<a id="en-txmap"></a>
### TxMap

Map with pan/zoom, markers and route lines. Without tileUrl the background is neutral; the application configures sources and attribution.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `center` | `TxCoordinate &#124; undefined` | `{"lat":52.52,"lng":13.405}` | Geographic map center. |
| `zoom` | `number &#124; undefined` | `5` | Map zoom level. |
| `minZoom` | `number &#124; undefined` | `1` | Minimum zoom level. |
| `maxZoom` | `number &#124; undefined` | `19` | Maximum zoom level. |
| `tileUrl` | `string &#124; undefined` | `undefined` | Tile URL with {z}/{x}/{y} placeholders. |
| `attribution` | `string &#124; undefined` | `undefined` | Map provider attribution/license text. |
| `width` | `number &#124; undefined` | `640` | Width; Vue numbers use pixels, Flutter uses logical pixels. |
| `height` | `number &#124; undefined` | `360` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| `dataSource` | `TxSource<TxMapMarker> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `markers` | `TxMapMarker[] &#124; undefined` | `[]` | Map markers to display. |
| `routes` | `TxMapRoute[] &#124; undefined` | `[]` | Route lines to display. |
| `routeDataSource` | `TxSource<TxMapRoute> &#124; undefined` | `undefined` | Separate data source for route lines. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:center | New center value; accept using v-model:center (modelValue: v-model). |
| update:zoom | New zoom value; accept using v-model:zoom (modelValue: v-model). |
| markerClick | Activated TxMapMarker. |
| tileError | Failed tile as { x, y, zoom }. |

```vue
<script setup lang="ts">
import { TxMap } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxMap :markers="[{ id: 1, lat: 52.52, lng: 13.405, text: 'Berlin' }]" />
</template>
```

<a id="en-txtabpanel"></a>
### TxTabPanel

Tabs and their active content in one view.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `unknown` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown` | `[]` | Entries; replaced by dataSource when bound. |
| `selectedIndex` | `unknown` | `undefined` | Zero-based active entry. |
| `modelValue` | `unknown` | `undefined` | Controlled v-model value. |
| `disabled` | `unknown` | `false` | Disables interaction. |
| `label` | `unknown` | `Reiter` | Label or accessible name. |
| `orientation` | `unknown` | `horizontal` | Tab orientation. |
| `scrollByContent` | `unknown` | `true` | Allows scrolling through tab content. |
| `swipeEnabled` | `unknown` | `false` | Allows switching tabs by swiping. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:selectedIndex | New selectedIndex value; accept using v-model:selectedIndex (modelValue: v-model). |
| selectionChanged | New selection: { selectedIndex, itemData }. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | { selectedIndex, item } |

```vue
<script setup lang="ts">
import { TxTabPanel } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxTabPanel :items="[{ text: 'Home' }]">
    <template #default="{ selectedIndex }">Page {{ selectedIndex + 1 }}</template>
  </TxTabPanel>
</template>
```

<a id="en-txloadpanel"></a>
### TxLoadPanel

Loading overlay controlled by visibility or a DataSource loading state.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `undefined` | Controls visibility. |
| `dataSource` | `Pick<TxDataSource<unknown>, "loading" &#124; "subscribe"> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `message` | `string &#124; undefined` | `Wird geladen …` | Notification text. |
| `delay` | `number &#124; undefined` | `0` | Delay before showing the loading overlay. |
| `shading` | `boolean &#124; undefined` | `true` | Shows a shaded background. |
| `fullScreen` | `boolean &#124; undefined` | `false` | Fills the screen. |

```vue
<script setup lang="ts">
import { TxLoadPanel } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <div style="position: relative; height: 160px"><TxLoadPanel :visible="true" message="Loading" /></div>
</template>
```

<a id="en-usetxsource"></a>
### useTxSource

Vue composable exposing reactive items/source/loading/error/revision refs. Call inside setup; borrowed instances are not disposed.

Parameters: getSource reads the current binding; optional fallback returns a fallback list (default []). Returns items/source/loading/error/revision as Vue refs. Lifecycle hooks require setup. Unmount removes listeners and disposes only instances created from configurations.

```ts
function useTxSource<T>(getSource: () => TxSource<T> | undefined, fallback?: () => T[]): { items: ComputedRef<T[]>; source: ShallowRef<TxDataSource<T> | undefined, TxDataSource<T> | undefined>; loading: ComputedRef<boolean>; error: ComputedRef<unknown>; revision: ShallowRef<number, number>; }
```

```ts
import { defineComponent, h } from 'vue'
import { useTxSource } from '@tekocloud.de/tecexpress'
export default defineComponent({ setup() {
  const rows = [{ id: 1, text: 'One' }]
  const { items, loading, error, source, revision } = useTxSource(() => rows)
  return () => h('p', error.value ? String(error.value) : `${items.value.length} / ${loading.value} / ${revision.value} / ${!!source.value}`)
} })
```

<a id="en-notify"></a>
### notify

Shows a stacked notification and returns close/update. Defaults: info, 3500 ms, bottom-right; displayTime 0 stays open. Under SSR the handle is a no-op.

Parameter options is a message string or TxNotifyOptions. Synchronously returns TxNotifyHandle. close(): void closes idempotently; update(changes): void applies partial options and restarts the timer. Stack position is fixed at creation. Actions use action.text/onClick. The current theme must also be available on the document body because notifications are mounted there.

```ts
function notify(options: string | TxNotifyOptions): TxNotifyHandle
```

```ts
import { notify } from '@tekocloud.de/tecexpress'
const handle = notify({ message: 'Working', displayTime: 0 })
handle.update({ message: 'Done', type: 'success', displayTime: 3000 })
handle.close()
```

<a id="en-txnotifyoptions"></a>
### TxNotifyOptions

Message, appearance, duration, position and optional notification action.

```ts
interface TxNotifyOptions {
  message: string
  type?: 'info' | 'success' | 'warning' | 'error'
  displayTime?: number
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left'
  action?: { text: string; onClick: () => void }
}
```

| Field | Meaning |
| --- | --- |
| message | Notification text. |
| type | Appearance/input type; see the signature for allowed values. |
| displayTime | Display duration; 0 or Duration.zero stays open. |
| position | Position of the notification or overlay. |
| action | Optional action with text and an onClick callback. |

```ts
import type { TxNotifyOptions } from '@tekocloud.de/tecexpress'
const example: TxNotifyOptions = { message: 'Saved', type: 'success' }
console.log(example)
```

<a id="en-txnotifyhandle"></a>
### TxNotifyHandle

Handle for closing or updating an existing notification.

```ts
interface TxNotifyHandle {
  close(): void
  update(changes: Partial<TxNotifyOptions>): void
}
```

| Field | Meaning |
| --- | --- |
| close | Closes the associated notification. |
| update | Updates a notification or record. |

```ts
import type { TxNotifyHandle } from '@tekocloud.de/tecexpress'
const example: TxNotifyHandle = { close: () => {}, update: changes => console.log(changes) }
console.log(example)
```

<a id="en-txcollectionitem"></a>
### TxCollectionItem

Selection entry; value resolves through value, then id, then text.

```ts
interface TxCollectionItem {
  id?: string | number
  value?: unknown
  text: string
  icon?: string
  disabled?: boolean
  group?: string
  imageUrl?: string
  items?: TxCollectionItem[]
  destructive?: boolean
  separator?: boolean
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| value | Current input/option value. |
| text | Text to display. |
| icon | Action icon. |
| disabled | Disables interaction. |
| group | Group descriptors or group name. |
| imageUrl | Card image URL. |
| items | Entries; replaced by dataSource when bound. |
| destructive | Marks a destructive action. |
| separator | Marks a menu separator. |

```ts
import type { TxCollectionItem } from '@tekocloud.de/tecexpress'
const example: TxCollectionItem = { id: 1, text: 'One', value: 1 }
console.log(example)
```

<a id="en-txentry"></a>
### TxEntry

String or structured selection entry.

```ts
type TxEntry = string | TxCollectionItem
```

```ts
import type { TxEntry } from '@tekocloud.de/tecexpress'
const example: TxEntry = 'One'
console.log(example)
```

<a id="en-txrangevalue"></a>
### TxRangeValue

Numeric or date range boundary; Dates use milliseconds for steps and distances.

```ts
type TxRangeValue = number | Date
```

```ts
import type { TxRangeValue } from '@tekocloud.de/tecexpress'
const example: TxRangeValue = 20
console.log(example)
```

<a id="en-txproject"></a>
### txProject

Projects geographic coordinates to Web Mercator world pixels at a given zoom; clamps latitude to about ±85.05°.

Parameters: point with lat/lng in degrees and zoom. Synchronous return: { x, y } in Vue, Offset in Dart; world pixels, not pixels relative to the visible viewport.

```ts
function txProject(point: TxCoordinate, zoom: number): { x: number; y: number; }
```

```ts
import { txProject } from '@tekocloud.de/tecexpress'
const pixel = txProject({ lat: 52.52, lng: 13.405 }, 5)
console.log(pixel.x, pixel.y)
```

<a id="en-txunproject"></a>
### txUnproject

Converts Web Mercator world pixels back to geographic coordinates at the same zoom.

Parameters: Vue x, y, zoom; Dart Offset point, zoom. Synchronously returns TxCoordinate with lat/lng in degrees; use the same zoom as txProject.

```ts
function txUnproject(x: number, y: number, zoom: number): TxCoordinate
```

```ts
import { txProject, txUnproject } from '@tekocloud.de/tecexpress'
const pixel = txProject({ lat: 52.52, lng: 13.405 }, 5)
console.log(txUnproject(pixel.x, pixel.y, 5))
```

<a id="en-txcoordinate"></a>
### TxCoordinate

Geographic latitude and longitude in degrees.

```ts
interface TxCoordinate {
  lat: number
  lng: number
}
```

| Field | Meaning |
| --- | --- |
| lat | Latitude in degrees. |
| lng | Longitude in degrees. |

```ts
import type { TxCoordinate } from '@tekocloud.de/tecexpress'
const example: TxCoordinate = { lat: 52.52, lng: 13.405 }
console.log(example)
```

<a id="en-txmapmarker"></a>
### TxMapMarker

Coordinate with a unique ID and optional popup text and color.

```ts
interface TxMapMarker extends TxCoordinate {
  id: string | number
  text?: string
  color?: string
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| text | Text to display. |
| color | Display color. |
| lat | Latitude in degrees. |
| lng | Longitude in degrees. |

```ts
import type { TxMapMarker } from '@tekocloud.de/tecexpress'
const example: TxMapMarker = { id: 1, lat: 52.52, lng: 13.405, text: 'Berlin' }
console.log(example)
```

<a id="en-txmaproute"></a>
### TxMapRoute

Route line to draw from coordinates; it does not calculate a route.

```ts
interface TxMapRoute {
  id: string | number
  points: TxCoordinate[]
  color?: string
  width?: number
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| points | Route line coordinates in order. |
| color | Display color. |
| width | Width; Vue numbers use pixels, Flutter uses logical pixels. |

```ts
import type { TxMapRoute } from '@tekocloud.de/tecexpress'
const example: TxMapRoute = { id: 1, points: [{ lat: 52.52, lng: 13.405 }, { lat: 52.53, lng: 13.41 }] }
console.log(example)
```

<a id="en-txgeoadapter"></a>
### TxGeoAdapter

Contract for custom geocoding/routing services. Call services yourself and bind results to the map.

```ts
interface TxGeoAdapter {
  geocode?(query: string, signal?: AbortSignal): Promise<TxCoordinate[]>
  route?(points: TxCoordinate[], signal?: AbortSignal): Promise<TxCoordinate[]>
}
```

| Field | Meaning |
| --- | --- |
| geocode | Queries a custom geographic service for coordinates matching text. |
| route | Queries a custom routing service for a route through waypoints. |

```ts
import type { TxGeoAdapter } from '@tekocloud.de/tecexpress'
const example: TxGeoAdapter = { geocode: async query => query ? [{ lat: 52.52, lng: 13.405 }] : [], route: async points => points }
console.log(example)
```

<a id="en-txbutton"></a>
### TxButton

Button with text, an icon and a click action.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `text` | `string &#124; undefined` | `undefined` | Text to display. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `type` | `"default" &#124; "normal" &#124; "danger" &#124; "success" &#124; undefined` | `normal` | Appearance/input type; see the signature for allowed values. |
| `useSubmitBehavior` | `boolean &#124; undefined` | `false` | Uses a native submit button. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| click | Click event carrying MouseEvent. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxButton text="Save" @click="saved = true" />
</template>
```

<a id="en-txtextbox"></a>
### TxTextBox

Single-line text input; accept edits through its model or callback.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTextBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const text = ref('Alex')
</script>

<template>
  <TxTextBox v-model="text" label="Name" />
</template>
```

<a id="en-txtextarea"></a>
### TxTextArea

Multiline text input with a configurable row count.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxTextArea } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const text = ref('Alex')
</script>

<template>
  <TxTextArea v-model="text" label="Notes" :rows="4" />
</template>
```

<a id="en-txnumberbox"></a>
### TxNumberBox

Numeric input with bounds and steps. An empty input produces null.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxNumberBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const amount = ref<number | null>(10)
</script>

<template>
  <TxNumberBox v-model="amount" :min="0" :max="100" />
</template>
```

<a id="en-txcheckbox"></a>
### TxCheckBox

Checkbox for a boolean value.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxCheckBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const enabled = ref(true)
</script>

<template>
  <TxCheckBox v-model="enabled" label="Active" />
</template>
```

<a id="en-txswitch"></a>
### TxSwitch

Switch for a boolean value.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxSwitch } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const enabled = ref(true)
</script>

<template>
  <TxSwitch v-model="enabled" label="Active" />
</template>
```

<a id="en-txselectbox"></a>
### TxSelectBox

Single selection from a list or data source.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxSelectBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const choice = ref(1)
</script>

<template>
  <TxSelectBox v-model="choice" :items="[{ value: 1, text: 'One' }]" />
</template>
```

<a id="en-txdatebox"></a>
### TxDateBox

Date input with lower and upper bounds.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `modelValue` | `EditorValue &#124; undefined` | `undefined` | Controlled v-model value. |
| `value` | `EditorValue &#124; undefined` | `undefined` | Current input/option value. |
| `label` | `string &#124; undefined` | `undefined` | Label or accessible name. |
| `name` | `string &#124; undefined` | `undefined` | Input field name or file name. |
| `placeholder` | `string &#124; undefined` | `undefined` | Hint for an empty input. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `required` | `boolean &#124; undefined` | `false` | Marks a required input. |
| `isValid` | `boolean &#124; undefined` | `true` | Controls error presentation; does not perform validation. |
| `validationMessage` | `string &#124; undefined` | `Bitte Eingabe prüfen.` | Error message when isValid is false. |
| `min` | `string &#124; number &#124; undefined` | `undefined` | Lower allowed bound. |
| `max` | `string &#124; number &#124; undefined` | `undefined` | Upper allowed bound. |
| `step` | `string &#124; number &#124; undefined` | `1` | Step size; milliseconds for Vue date ranges. |
| `rows` | `number &#124; undefined` | `3` | Visible text rows. |
| `dataSource` | `TxSource<any> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `unknown[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `displayExpr` | `string &#124; undefined` | `text` | Field used for visible option text. |
| `valueExpr` | `string &#124; undefined` | `value` | Field used for the option value or series value. |
| `type` | `string &#124; undefined` | `text` | Appearance/input type; see the signature for allowed values. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:value | New value value; accept using v-model:value (modelValue: v-model). |
| valueChanged | New value in { value }; editors also include previousValue and event. |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxDateBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const date = ref('2026-10-28')
</script>

<template>
  <TxDateBox v-model="date" label="Date" />
</template>
```

<a id="en-txtabs"></a>
### TxTabs

Tab navigation with optional content for the active tab.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<string &#124; Item> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `(string &#124; Item)[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `selectedIndex` | `number &#124; undefined` | `undefined` | Zero-based active entry. |
| `modelValue` | `number &#124; undefined` | `undefined` | Controlled v-model value. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `Reiter` | Label or accessible name. |
| `orientation` | `string &#124; undefined` | `horizontal` | Tab orientation. |
| `scrollByContent` | `boolean &#124; undefined` | `true` | Allows scrolling through tab content. |
| `swipeEnabled` | `boolean &#124; undefined` | `false` | Allows switching tabs by swiping. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:modelValue | New modelValue value; accept using v-model:modelValue (modelValue: v-model). |
| update:selectedIndex | New selectedIndex value; accept using v-model:selectedIndex (modelValue: v-model). |
| selectionChanged | New selection: { selectedIndex, itemData }. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | { selectedIndex, item } |

```vue
<script setup lang="ts">
import { TxTabs } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxTabs :items="[{ text: 'Home' }, { text: 'Settings' }]">
    <template #default="{ selectedIndex }">Page {{ selectedIndex + 1 }}</template>
  </TxTabs>
</template>
```

<a id="en-txtoolbar"></a>
### TxToolbar

Toolbar with primary content and trailing actions.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `label` | `string &#124; undefined` | `Werkzeugleiste` | Label or accessible name. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |
| after | () |

```vue
<script setup lang="ts">
import { TxToolbar } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxToolbar><button>Save</button><template #after>Ready</template></TxToolbar>
</template>
```

<a id="en-txmenu"></a>
### TxMenu

Flat list of menu actions; use ContextMenu for nested actions.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<string &#124; Item> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `items` | `(string &#124; Item)[] &#124; undefined` | `[]` | Entries; replaced by dataSource when bound. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `label` | `string &#124; undefined` | `Menü` | Label or accessible name. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| itemClick | { itemData, itemIndex, event } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxMenu } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const saved = ref(false)
</script>

<template>
  <TxMenu :items="[{ text: 'Home' }]" @item-click="saved = true" />
</template>
```

<a id="en-txpopup"></a>
### TxPopup

Dialog with a title and content. Before-events can be cancelled synchronously; external visibility remains authoritative.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `false` | Controls visibility. |
| `title` | `string &#124; undefined` | `Dialog` | View title. |
| `showCloseButton` | `boolean &#124; undefined` | `true` | Shows a close action. |
| `hideOnOutsideClick` | `boolean &#124; undefined` | `false` | Allows closing by clicking outside. |
| `width` | `string &#124; number &#124; undefined` | `480` | Width; Vue numbers use pixels, Flutter uses logical pixels. |
| `height` | `string &#124; number &#124; undefined` | `undefined` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| `fullScreen` | `boolean &#124; undefined` | `false` | Fills the screen. |
| `dragEnabled` | `boolean &#124; undefined` | `false` | Allows dragging the dialog. |
| `resizeEnabled` | `boolean &#124; undefined` | `false` | Allows resizing the dialog. |
| `position` | `string &#124; undefined` | `center` | Position of the notification or overlay. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:visible | New visible value; accept using v-model:visible (modelValue: v-model). |
| showing | Before showing: { cancel }; set synchronously to true to cancel. |
| hiding | Before user-initiated closing: { cancel }; synchronously cancellable. |
| shown | After showing, without a payload. |
| hidden | After hiding, without a payload. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |
| footer | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxPopup, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const visible = ref(false)
</script>

<template>
  <TxButton text="Open" @click="visible = true" />
  <TxPopup v-model:visible="visible" title="Details">Hello</TxPopup>
</template>
```

<a id="en-txtooltip"></a>
### TxTooltip

Hint for target content with a delay and optional custom content.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `text` | `string &#124; undefined` | `` | Text to display. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `visible` | `boolean &#124; undefined` | `undefined` | Controls visibility. |
| `showDelay` | `number &#124; undefined` | `0` | Delay before showing, in milliseconds. |
| `hideDelay` | `number &#124; undefined` | `0` | Delay before hiding, in milliseconds. |
| `position` | `string &#124; undefined` | `top` | Position of the notification or overlay. |
| `showOn` | `string &#124; undefined` | `hover` | Tooltip trigger. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:visible | New visible value; accept using v-model:visible (modelValue: v-model). |
| shown | After showing, without a payload. |
| hidden | After hiding, without a payload. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |
| content | () |

```vue
<script setup lang="ts">
import { TxTooltip } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxTooltip text="More information"><button>Help</button></TxTooltip>
</template>
```

<a id="en-txtoast"></a>
### TxToast

Timed status message; accept visibility changes in the application.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `false` | Controls visibility. |
| `message` | `string &#124; undefined` | `undefined` | Notification text. |
| `position` | `string &#124; undefined` | `bottom-right` | Position of the notification or overlay. |
| `type` | `"error" &#124; "success" &#124; "info" &#124; "warning" &#124; undefined` | `info` | Appearance/input type; see the signature for allowed values. |
| `displayTime` | `number &#124; undefined` | `3500` | Display duration; 0 or Duration.zero stays open. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:visible | New visible value; accept using v-model:visible (modelValue: v-model). |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |
| actions | () |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxToast, TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const visible = ref(false)
</script>

<template>
  <TxButton text="Notify" @click="visible = true" />
  <TxToast v-model:visible="visible" message="Saved" type="success" />
</template>
```

<a id="en-txloadindicator"></a>
### TxLoadIndicator

Accessible loading indicator with a label.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `visible` | `boolean &#124; undefined` | `true` | Controls visibility. |
| `label` | `string &#124; undefined` | `Wird geladen …` | Label or accessible name. |

```vue
<script setup lang="ts">
import { TxLoadIndicator } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxLoadIndicator label="Loading" />
</template>
```

<a id="en-txdatagrid"></a>
### TxDataGrid

Data table with single-column sorting, AND text filters, paging, selection and custom cells.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<DataRow> &#124; undefined` | `[]` | List, configuration or DataSource instance; takes precedence over items. |
| `keyExpr` | `string &#124; undefined` | `id` | Field containing the stable record key. |
| `columns` | `Column[] &#124; undefined` | `undefined` | Column or card field configurations. |
| `filterRow` | `boolean &#124; { visible: boolean; } &#124; undefined` | `true` | Shows the text filter row. |
| `pageSize` | `number &#124; undefined` | `10` | Records per page. |
| `pageIndex` | `number &#124; undefined` | `undefined` | Zero-based page index. |
| `selection` | `"none" &#124; "single" &#124; "multiple" &#124; { mode: "none" &#124; "single" &#124; "multiple"; } &#124; undefined` | `none` | Selection mode. |
| `selectedRowKeys` | `RowKey[] &#124; undefined` | `undefined` | Controlled set of selected row keys. |
| `loading` | `boolean &#124; undefined` | `false` | Shows the loading state. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `noDataText` | `string &#124; undefined` | `Keine Daten vorhanden.` | Text for an empty collection. |
| `label` | `string &#124; undefined` | `Datentabelle` | Label or accessible name. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| rowClick | RowClickEvent: data, key, rowIndex, event. |
| selectionChanged | New selection: { selectedRowKeys, selectedRowsData }. |
| update:selectedRowKeys | New selectedRowKeys value; accept using v-model:selectedRowKeys (modelValue: v-model). |
| update:pageIndex | New pageIndex value; accept using v-model:pageIndex (modelValue: v-model). |
| sortChanged | Current SortDescriptor or null. |
| filterChanged | Current text filters as Record&lt;string, string&gt;. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | TxColumn[] |
| [cellTemplate] | { data, value, column, rowIndex } |

```vue
<script setup lang="ts">
import { TxDataGrid, TxColumn } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const rows = [{ id: 1, name: 'Alex' }]
</script>

<template>
  <TxDataGrid :data-source="rows" key-expr="id">
    <TxColumn data-field="name" caption="Name" />
  </TxDataGrid>
</template>
```

<a id="en-txcolumn"></a>
### TxColumn

DataGrid column configuration; it has no standalone UI.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataField` | `string` | `required` | Field name; must be unique within a grid. |
| `caption` | `string &#124; undefined` | `undefined` | Visible field/column caption. |
| `width` | `string &#124; number &#124; undefined` | `undefined` | Width; Vue numbers use pixels, Flutter uses logical pixels. |
| `allowSorting` | `boolean &#124; undefined` | `true` | Allows sorting this column. |
| `allowFiltering` | `boolean &#124; undefined` | `true` | Allows filtering this column. |
| `cellTemplate` | `string &#124; undefined` | `undefined` | Vue slot name for custom cells. |
| `visible` | `boolean &#124; undefined` | `true` | Controls visibility. |
| `alignment` | `"center" &#124; "left" &#124; "right" &#124; undefined` | `undefined` | Content alignment. |

```vue
<script setup lang="ts">
import { TxColumn, TxDataGrid } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const rows = [{ id: 1, name: 'Alex' }]
</script>

<template>
  <TxDataGrid :data-source="rows" key-expr="id">
    <TxColumn data-field="name" caption="Name" cell-template="nameCell" />
    <template #nameCell="{ value }"><strong>{{ value }}</strong></template>
  </TxDataGrid>
</template>
```

<a id="en-txscheduler"></a>
### TxScheduler

Day, week and month calendar with appointment editing. All-day end dates are exclusive; recurrence, resources and drag-and-drop are unavailable.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<Appointment> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `currentDate` | `SchedulerDate &#124; undefined` | `undefined` | Current calendar date; update a controlled value for navigation. |
| `currentView` | `SchedulerView &#124; undefined` | `undefined` | Current calendar view. |
| `views` | `SchedulerView[] &#124; undefined` | `["day","week","month"]` | Available calendar views. |
| `firstDayOfWeek` | `number &#124; undefined` | `1` | First weekday; 1 = Monday. |
| `startDayHour` | `number &#124; undefined` | `8` | First visible hour of the day. |
| `endDayHour` | `number &#124; undefined` | `18` | Last visible hour of the day. |
| `cellDuration` | `number &#124; undefined` | `30` | Calendar cell duration in minutes. |
| `editing` | `boolean &#124; SchedulerEditing &#124; undefined` | `true` | Permissions to create, update and delete. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `loading` | `boolean &#124; undefined` | `false` | Shows the loading state. |
| `locale` | `string &#124; undefined` | `de-DE` | Locale for date/time formatting. |
| `label` | `string &#124; undefined` | `Terminplaner` | Label or accessible name. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:dataSource | New dataSource value; accept using v-model:dataSource (modelValue: v-model). |
| update:currentDate | New currentDate value; accept using v-model:currentDate (modelValue: v-model). |
| update:currentView | New currentView value; accept using v-model:currentView (modelValue: v-model). |
| appointmentClick | AppointmentClickEvent: appointmentData, event. |
| cellClick | SchedulerCellClickEvent: startDate, endDate, allDay, event. |
| appointmentAdding | AppointmentChangeEvent with cancel before adding. |
| appointmentAdded | AppointmentEvent after local insertion. |
| appointmentUpdating | AppointmentUpdatingEvent with oldData, newData and cancel. |
| appointmentUpdated | AppointmentUpdatedEvent with oldData and newData. |
| appointmentDeleting | AppointmentChangeEvent with cancel before deleting. |
| appointmentDeleted | AppointmentEvent after local deletion. |

**Slots**

| Slot | Arguments |
| --- | --- |
| appointment | { appointmentData, startDate, endDate, view } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxScheduler, type Appointment } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const appointments = ref<Appointment[]>([{ id: 1, text: 'Meeting', startDate: new Date(2026, 9, 28, 9), endDate: new Date(2026, 9, 28, 10) }])
const calendarDate = ref(new Date(2026, 9, 28))
</script>

<template>
  <TxScheduler v-model:data-source="appointments" v-model:current-date="calendarDate" />
</template>
```

<a id="en-txcard"></a>
### TxCard

Presentation card with a title, media, content and actions.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `title` | `string &#124; undefined` | `undefined` | View title. |
| `subtitle` | `string &#124; undefined` | `undefined` | Additional subtitle. |
| `imageUrl` | `string &#124; undefined` | `undefined` | Card image URL. |
| `imageAlt` | `string &#124; undefined` | `` | Image alternative text. |
| `variant` | `"outlined" &#124; "elevated" &#124; "filled" &#124; undefined` | `outlined` | Card appearance variant. |
| `loading` | `boolean &#124; undefined` | `false` | Shows the loading state. |

**Slots**

| Slot | Arguments |
| --- | --- |
| default | () |
| header | () |
| media | () |
| actions | () |
| footer | () |

```vue
<script setup lang="ts">
import { TxCard } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxCard title="Project" subtitle="Active">Hello<template #footer>Updated today</template></TxCard>
</template>
```

<a id="en-txcardview"></a>
### TxCardView

Card collection with search, paging, selection and custom content.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<DataRow> &#124; undefined` | `[]` | List, configuration or DataSource instance; takes precedence over items. |
| `keyExpr` | `string &#124; undefined` | `id` | Field containing the stable record key. |
| `titleExpr` | `string &#124; undefined` | `title` | Card title field. |
| `subtitleExpr` | `string &#124; undefined` | `subtitle` | Card subtitle field. |
| `imageExpr` | `string &#124; undefined` | `imageUrl` | Card image URL field. |
| `imageAltExpr` | `string &#124; undefined` | `imageAlt` | Image alternative text field. |
| `columns` | `CardField[] &#124; undefined` | `[]` | Column or card field configurations. |
| `searchEnabled` | `boolean &#124; undefined` | `true` | Enables searching. |
| `searchExpr` | `string &#124; string[] &#124; undefined` | `undefined` | Search fields or getters. |
| `pageSize` | `number &#124; undefined` | `6` | Records per page. |
| `pageIndex` | `number &#124; undefined` | `undefined` | Zero-based page index. |
| `selection` | `"none" &#124; "single" &#124; "multiple" &#124; undefined` | `none` | Selection mode. |
| `selectedCardKeys` | `RowKey[] &#124; undefined` | `undefined` | Controlled set of selected card keys. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `loading` | `boolean &#124; undefined` | `false` | Shows the loading state. |
| `noDataText` | `string &#124; undefined` | `Keine Karten vorhanden.` | Text for an empty collection. |
| `label` | `string &#124; undefined` | `Kartenansicht` | Label or accessible name. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| cardClick | CardClickEvent: data, key, index, event. |
| selectionChanged | New selection: { selectedCardKeys, selectedCardsData }. |
| update:selectedCardKeys | New selectedCardKeys value; accept using v-model:selectedCardKeys (modelValue: v-model). |
| update:pageIndex | New pageIndex value; accept using v-model:pageIndex (modelValue: v-model). |
| searchChanged | New search text as a string. |

**Slots**

| Slot | Arguments |
| --- | --- |
| item | { data, key, index, selected } |
| media | { data, key, index, selected } |
| content | { data, key, index, selected } |
| footer | { data, key, index, selected } |
| field | { data, column, value } |

```vue
<script setup lang="ts">
import { TxCardView } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'

</script>

<template>
  <TxCardView :data-source="[{ id: 1, title: 'Project' }]" />
</template>
```

<a id="en-txchat"></a>
### TxChat

Local message history with authors, typing indicators and send events. sent confirms local acceptance, not server delivery.

| Prop | Type | Default | Meaning |
| --- | --- | --- | --- |
| `dataSource` | `TxSource<ChatMessage> &#124; undefined` | `undefined` | List, configuration or DataSource instance; takes precedence over items. |
| `user` | `ChatUser` | `required` | Current chat author. |
| `items` | `ChatMessage[] &#124; undefined` | `undefined` | Entries; replaced by dataSource when bound. |
| `inputFieldText` | `string &#124; undefined` | `undefined` | Controlled message draft. |
| `title` | `string &#124; undefined` | `Chat` | View title. |
| `subtitle` | `string &#124; undefined` | `` | Additional subtitle. |
| `label` | `string &#124; undefined` | `Chat` | Label or accessible name. |
| `placeholder` | `string &#124; undefined` | `Nachricht schreiben …` | Hint for an empty input. |
| `emptyText` | `string &#124; undefined` | `Noch keine Nachrichten. Starte die Unterhaltung.` | Empty state text. |
| `disabled` | `boolean &#124; undefined` | `false` | Disables interaction. |
| `readOnly` | `boolean &#124; undefined` | `false` | Prevents value changes. |
| `loading` | `boolean &#124; undefined` | `false` | Shows the loading state. |
| `sending` | `boolean &#124; undefined` | `false` | Disables sending during an application request. |
| `maxLength` | `number &#124; undefined` | `4000` | Maximum text length. |
| `typingUsers` | `ChatUser[] &#124; undefined` | `[]` | Authors currently typing. |
| `showAvatar` | `boolean &#124; undefined` | `true` | Shows author avatars. |
| `showUserName` | `boolean &#124; undefined` | `true` | Shows author names. |
| `showDayHeaders` | `boolean &#124; undefined` | `true` | Groups messages using day headers. |
| `showMessageTimestamp` | `boolean &#124; undefined` | `true` | Shows message timestamps. |
| `locale` | `string &#124; undefined` | `de-DE` | Locale for date/time formatting. |

**Events**

| Event | Payload / behavior |
| --- | --- |
| update:items | New items value; accept using v-model:items (modelValue: v-model). |
| update:inputFieldText | New inputFieldText value; accept using v-model:inputFieldText (modelValue: v-model). |
| messageEntered | ChatMessageEnteredEvent; set cancel synchronously to start custom server processing. |
| messageSent | ChatMessageEvent after local acceptance. |
| typingStart | ChatTypingEvent when typing starts. |
| typingEnd | ChatTypingEvent when typing ends. |

**Slots**

| Slot | Arguments |
| --- | --- |
| header | { user } |
| empty | () |
| message | { message, isOwn } |

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxChat, type ChatMessage } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const messages = ref<ChatMessage[]>([])
</script>

<template>
  <TxChat v-model:items="messages" :user="{ id: 'me', name: 'Alex' }" />
</template>
```

<a id="en-editorvalue"></a>
### EditorValue

Editor input value.

```ts
type EditorValue = string | number | boolean | null
```

```ts
import type { EditorValue } from '@tekocloud.de/tecexpress'
const example: EditorValue = 'Hello'
console.log(example)
```

<a id="en-valuechangedevent"></a>
### ValueChangedEvent

Typed event contract for ValueChangedEvent; fields below describe the payload.

```ts
interface ValueChangedEvent<T = EditorValue> {
  value: T
  previousValue: T
  event: Event
}
```

| Field | Meaning |
| --- | --- |
| value | Current input/option value. |
| previousValue | Value before the change. |
| event | Original input/mouse event. |

```ts
import type { ValueChangedEvent } from '@tekocloud.de/tecexpress'
const example: ValueChangedEvent<string> = { value: 'New', previousValue: 'Old', event: new Event('input') }
console.log(example)
```

<a id="en-item"></a>
### Item

Menu/tab entry.

```ts
interface Item {
  text: string
  icon?: string
  visible?: boolean
  disabled?: boolean
  id?: string | number
}
```

| Field | Meaning |
| --- | --- |
| text | Text to display. |
| icon | Action icon. |
| visible | Controls visibility. |
| disabled | Disables interaction. |
| id | Unique stable ID. |

```ts
import type { Item } from '@tekocloud.de/tecexpress'
const example: Item = { text: 'Home', id: 1 }
console.log(example)
```

<a id="en-rowkey"></a>
### RowKey

Unique string or numeric record key.

```ts
type RowKey = string | number
```

```ts
import type { RowKey } from '@tekocloud.de/tecexpress'
const example: RowKey = 1
console.log(example)
```

<a id="en-datarow"></a>
### DataRow

Flexible record with named fields.

```ts
type DataRow = Record<string, unknown>
```

```ts
import type { DataRow } from '@tekocloud.de/tecexpress'
const example: DataRow = { id: 1, name: 'Alex' }
console.log(example)
```

<a id="en-column"></a>
### Column

DataGrid column configuration; it has no standalone UI.

```ts
interface Column {
  dataField: string
  caption?: string
  width?: string | number
  allowSorting?: boolean
  allowFiltering?: boolean
  cellTemplate?: string
  visible?: boolean
  alignment?: 'left' | 'center' | 'right'
}
```

| Field | Meaning |
| --- | --- |
| dataField | Field name; must be unique within a grid. |
| caption | Visible field/column caption. |
| width | Width; Vue numbers use pixels, Flutter uses logical pixels. |
| allowSorting | Allows sorting this column. |
| allowFiltering | Allows filtering this column. |
| cellTemplate | Vue slot name for custom cells. |
| visible | Controls visibility. |
| alignment | Content alignment. |

```ts
import type { Column } from '@tekocloud.de/tecexpress'
const example: Column = { dataField: 'name', caption: 'Name' }
console.log(example)
```

<a id="en-sortdescriptor"></a>
### SortDescriptor

Sort or group descriptor with a selector and descending direction.

```ts
interface SortDescriptor {
  dataField: string
  desc: boolean
}
```

| Field | Meaning |
| --- | --- |
| dataField | Field name; must be unique within a grid. |
| desc | Descending sort order. |

```ts
import type { SortDescriptor } from '@tekocloud.de/tecexpress'
const example: SortDescriptor = { dataField: 'name', desc: false }
console.log(example)
```

<a id="en-rowclickevent"></a>
### RowClickEvent

Typed event contract for RowClickEvent; fields below describe the payload.

```ts
interface RowClickEvent {
  data: DataRow
  key: RowKey
  rowIndex: number
  event: MouseEvent
}
```

| Field | Meaning |
| --- | --- |
| data | Records or event payload. |
| key | Stable key or selector; distinct from a widget key. |
| rowIndex | Zero-based visible row index. |
| event | Original input/mouse event. |

```ts
import type { RowClickEvent } from '@tekocloud.de/tecexpress'
const example: RowClickEvent = { data: { id: 1 }, key: 1, rowIndex: 0, event: new MouseEvent('click') }
console.log(example)
```

<a id="en-selectionchangedevent"></a>
### SelectionChangedEvent

Typed event contract for SelectionChangedEvent; fields below describe the payload.

```ts
interface SelectionChangedEvent {
  selectedRowKeys: RowKey[]
  selectedRowsData: DataRow[]
}
```

| Field | Meaning |
| --- | --- |
| selectedRowKeys | Controlled set of selected row keys. |
| selectedRowsData | Selected row records. |

```ts
import type { SelectionChangedEvent } from '@tekocloud.de/tecexpress'
const example: SelectionChangedEvent = { selectedRowKeys: [1], selectedRowsData: [{ id: 1 }] }
console.log(example)
```

<a id="en-appointment"></a>
### Appointment

Immutable appointment with a validated key, title and end after start. All-day bounds must be local midnight.

```ts
interface Appointment {
  id: RowKey
  text: string
  startDate: SchedulerDate
  endDate: SchedulerDate
  allDay?: boolean
  description?: string
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| text | Text to display. |
| startDate | Appointment/cell start. |
| endDate | Appointment/cell end; exclusive for all-day entries. |
| allDay | All-day appointment with local day boundaries. |
| description | Optional appointment description. |

```ts
import type { Appointment } from '@tekocloud.de/tecexpress'
const example: Appointment = { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }
console.log(example)
```

<a id="en-schedulerview"></a>
### SchedulerView

Day, week or month view.

```ts
type SchedulerView = 'day' | 'week' | 'month'
```

```ts
import type { SchedulerView } from '@tekocloud.de/tecexpress'
const example: SchedulerView = 'week'
console.log(example)
```

<a id="en-schedulerdate"></a>
### SchedulerDate

Date or parseable string; local ISO values without Z denote local time.

```ts
type SchedulerDate = Date | string
```

```ts
import type { SchedulerDate } from '@tekocloud.de/tecexpress'
const example: SchedulerDate = new Date(2026, 9, 28)
console.log(example)
```

<a id="en-schedulerediting"></a>
### SchedulerEditing

Permissions to create, update and delete appointments; none disables all three actions.

```ts
interface SchedulerEditing {
  allowAdding?: boolean
  allowUpdating?: boolean
  allowDeleting?: boolean
}
```

| Field | Meaning |
| --- | --- |
| allowAdding | Allows creating appointments. |
| allowUpdating | Allows updating appointments. |
| allowDeleting | Shows list entry delete actions. |

```ts
import type { SchedulerEditing } from '@tekocloud.de/tecexpress'
const example: SchedulerEditing = { allowAdding: true, allowUpdating: false }
console.log(example)
```

<a id="en-appointmentevent"></a>
### AppointmentEvent

Typed event contract for AppointmentEvent; fields below describe the payload.

```ts
interface AppointmentEvent {
  appointmentData: Appointment
}
```

| Field | Meaning |
| --- | --- |
| appointmentData | Affected appointment. |

```ts
import type { AppointmentEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentEvent = { appointmentData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' } }
console.log(example)
```

<a id="en-appointmentchangeevent"></a>
### AppointmentChangeEvent

Typed event contract for AppointmentChangeEvent; fields below describe the payload.

```ts
interface AppointmentChangeEvent extends AppointmentEvent {
  cancel: boolean
}
```

| Field | Meaning |
| --- | --- |
| cancel | Set synchronously to true to cancel the action. |
| appointmentData | Affected appointment. |

```ts
import type { AppointmentChangeEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentChangeEvent = { appointmentData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, cancel: false }
console.log(example)
```

<a id="en-appointmentclickevent"></a>
### AppointmentClickEvent

Typed event contract for AppointmentClickEvent; fields below describe the payload.

```ts
interface AppointmentClickEvent extends AppointmentEvent {
  event: MouseEvent
}
```

| Field | Meaning |
| --- | --- |
| event | Original input/mouse event. |
| appointmentData | Affected appointment. |

```ts
import type { AppointmentClickEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentClickEvent = { appointmentData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, event: new MouseEvent('click') }
console.log(example)
```

<a id="en-appointmentupdatingevent"></a>
### AppointmentUpdatingEvent

Typed event contract for AppointmentUpdatingEvent; fields below describe the payload.

```ts
interface AppointmentUpdatingEvent {
  oldData: Appointment
  newData: Appointment
  cancel: boolean
}
```

| Field | Meaning |
| --- | --- |
| oldData | Previous record. |
| newData | Proposed new record. |
| cancel | Set synchronously to true to cancel the action. |

```ts
import type { AppointmentUpdatingEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentUpdatingEvent = { oldData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, newData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, cancel: false }
console.log(example)
```

<a id="en-appointmentupdatedevent"></a>
### AppointmentUpdatedEvent

Typed event contract for AppointmentUpdatedEvent; fields below describe the payload.

```ts
interface AppointmentUpdatedEvent {
  oldData: Appointment
  newData: Appointment
}
```

| Field | Meaning |
| --- | --- |
| oldData | Previous record. |
| newData | Proposed new record. |

```ts
import type { AppointmentUpdatedEvent } from '@tekocloud.de/tecexpress'
const example: AppointmentUpdatedEvent = { oldData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' }, newData: { id: 1, text: 'Meeting', startDate: '2026-10-28T09:00', endDate: '2026-10-28T10:00' } }
console.log(example)
```

<a id="en-schedulercellclickevent"></a>
### SchedulerCellClickEvent

Typed event contract for SchedulerCellClickEvent; fields below describe the payload.

```ts
interface SchedulerCellClickEvent {
  startDate: Date
  endDate: Date
  allDay: boolean
  event: MouseEvent
}
```

| Field | Meaning |
| --- | --- |
| startDate | Appointment/cell start. |
| endDate | Appointment/cell end; exclusive for all-day entries. |
| allDay | All-day appointment with local day boundaries. |
| event | Original input/mouse event. |

```ts
import type { SchedulerCellClickEvent } from '@tekocloud.de/tecexpress'
const example: SchedulerCellClickEvent = { startDate: new Date(2026, 9, 28, 9), endDate: new Date(2026, 9, 28, 10), allDay: false, event: new MouseEvent('click') }
console.log(example)
```

<a id="en-cardfield"></a>
### CardField

Card field with a caption, getter and optional builder.

```ts
interface CardField {
  dataField: string
  caption?: string
}
```

| Field | Meaning |
| --- | --- |
| dataField | Field name; must be unique within a grid. |
| caption | Visible field/column caption. |

```ts
import type { CardField } from '@tekocloud.de/tecexpress'
const example: CardField = { dataField: 'name', caption: 'Name' }
console.log(example)
```

<a id="en-cardclickevent"></a>
### CardClickEvent

Typed event contract for CardClickEvent; fields below describe the payload.

```ts
interface CardClickEvent {
  data: DataRow
  key: RowKey
  index: number
  event: MouseEvent
}
```

| Field | Meaning |
| --- | --- |
| data | Records or event payload. |
| key | Stable key or selector; distinct from a widget key. |
| index | Zero-based entry index. |
| event | Original input/mouse event. |

```ts
import type { CardClickEvent } from '@tekocloud.de/tecexpress'
const example: CardClickEvent = { data: { id: 1 }, key: 1, index: 0, event: new MouseEvent('click') }
console.log(example)
```

<a id="en-cardselectionchangedevent"></a>
### CardSelectionChangedEvent

Typed event contract for CardSelectionChangedEvent; fields below describe the payload.

```ts
interface CardSelectionChangedEvent {
  selectedCardKeys: RowKey[]
  selectedCardsData: DataRow[]
}
```

| Field | Meaning |
| --- | --- |
| selectedCardKeys | Controlled set of selected card keys. |
| selectedCardsData | Selected card records. |

```ts
import type { CardSelectionChangedEvent } from '@tekocloud.de/tecexpress'
const example: CardSelectionChangedEvent = { selectedCardKeys: [1], selectedCardsData: [{ id: 1 }] }
console.log(example)
```

<a id="en-chatuser"></a>
### ChatUser

Author with a validated key and non-empty name.

```ts
interface ChatUser {
  id: RowKey
  name: string
  avatarUrl?: string
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| name | Input field name or file name. |
| avatarUrl | Optional avatar image URL. |

```ts
import type { ChatUser } from '@tekocloud.de/tecexpress'
const example: ChatUser = { id: 'me', name: 'Alex' }
console.log(example)
```

<a id="en-chatmessage"></a>
### ChatMessage

Immutable message with an author, timestamp and non-empty text.

```ts
interface ChatMessage {
  id: RowKey
  text: string
  timestamp: Date | string
  author: ChatUser
  status?: 'pending' | 'sent' | 'error'
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| text | Text to display. |
| timestamp | Message timestamp. |
| author | Message author. |
| status | Local message status. |

```ts
import type { ChatMessage } from '@tekocloud.de/tecexpress'
const example: ChatMessage = { id: 1, text: 'Hello', timestamp: new Date(), author: { id: 'me', name: 'Alex' } }
console.log(example)
```

<a id="en-chatmessageevent"></a>
### ChatMessageEvent

Typed event contract for ChatMessageEvent; fields below describe the payload.

```ts
interface ChatMessageEvent {
  message: ChatMessage
}
```

| Field | Meaning |
| --- | --- |
| message | Notification text. |

```ts
import type { ChatMessageEvent } from '@tekocloud.de/tecexpress'
const example: ChatMessageEvent = { message: { id: 1, text: 'Hello', timestamp: new Date(), author: { id: 'me', name: 'Alex' } } }
console.log(example)
```

<a id="en-chatmessageenteredevent"></a>
### ChatMessageEnteredEvent

Typed event contract for ChatMessageEnteredEvent; fields below describe the payload.

```ts
interface ChatMessageEnteredEvent extends ChatMessageEvent {
  cancel: boolean
  event: Event
}
```

| Field | Meaning |
| --- | --- |
| cancel | Set synchronously to true to cancel the action. |
| event | Original input/mouse event. |
| message | Notification text. |

```ts
import type { ChatMessageEnteredEvent } from '@tekocloud.de/tecexpress'
const example: ChatMessageEnteredEvent = { message: { id: 1, text: 'Hello', timestamp: new Date(), author: { id: 'me', name: 'Alex' } }, cancel: false, event: new Event('submit') }
console.log(example)
```

<a id="en-chattypingevent"></a>
### ChatTypingEvent

Typed event contract for ChatTypingEvent; fields below describe the payload.

```ts
interface ChatTypingEvent {
  user: ChatUser
}
```

| Field | Meaning |
| --- | --- |
| user | Current chat author. |

```ts
import type { ChatTypingEvent } from '@tekocloud.de/tecexpress'
const example: ChatTypingEvent = { user: { id: 'me', name: 'Alex' } }
console.log(example)
```

<a id="en-tecexpress"></a>
### Tecexpress

Vue plugin: install(app) registers every component globally; also available as the default export.

```ts
import { createApp, h } from 'vue'
import Tecexpress, { TxButton } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
createApp({ render: () => h(TxButton, { text: 'Hello' }) }).use(Tecexpress).mount('#app')
```

<a id="en-txread"></a>
### txRead

Reads a nested field path or calls a getter. Missing paths return undefined.

Parameters: item = record, selector = dotted path or getter. Returns unknown; a missing path yields undefined. Getter errors propagate.

```ts
function txRead<T>(item: T, selector: TxSelector<T>): unknown
```

```ts
import { txRead } from '@tekocloud.de/tecexpress'
console.log(txRead({ address: { city: 'Berlin' } }, 'address.city')) // Berlin
```

<a id="en-txmatches"></a>
### txMatches

Synchronously tests a record against a filter; text comparisons ignore case.

Parameters: item = record to test, f = TxFilter. Returns boolean without modifying the record. Getter errors propagate.

```ts
function txMatches<T>(item: T, f: TxFilter<T>): boolean
```

```ts
import { txMatches } from '@tekocloud.de/tecexpress'
console.log(txMatches({ age: 20 }, { selector: 'age', operator: '>=', value: 18 })) // true
```

<a id="en-txquery"></a>
### txQuery

Synchronously processes local data: filter/search, sort/group, page and project. The input array is preserved.

Parameters: input = source list, o/options = TxLoadOptions. Synchronous result: TxLoadResult with flat data, totalCount before paging and optional groups/groupCount. Grouping does not change the shape of data. Getter/projection errors propagate; Dart skip/take must not be negative.

```ts
function txQuery<T>(input: readonly T[], o: TxLoadOptions<T>): TxLoadResult<T>
```

```ts
import { txQuery } from '@tekocloud.de/tecexpress'
console.log(txQuery([{ id: 2 }, { id: 1 }], { sort: [{ selector: 'id' }], take: 1 })) // data: [{ id: 1 }], totalCount: 2
```

<a id="en-txkey"></a>
### TxKey

Unique string or numeric record key.

```ts
type TxKey = string | number
```

```ts
import type { TxKey } from '@tekocloud.de/tecexpress'
const example: TxKey = 1
console.log(example)
```

<a id="en-txselector"></a>
### TxSelector

Field path or getter for reading a value from a record.

```ts
type TxSelector<T> = string | ((item: T) => unknown)
```

```ts
import type { TxSelector } from '@tekocloud.de/tecexpress'
const example: TxSelector<{ id: number }> = 'id'
console.log(example)
```

<a id="en-txsort"></a>
### TxSort

Sort or group descriptor with a selector and descending direction.

```ts
interface TxSort<T> {
  selector: TxSelector<T>
  desc?: boolean
}
```

| Field | Meaning |
| --- | --- |
| selector | Field path or getter for a query value. |
| desc | Descending sort order. |

```ts
import type { TxSort } from '@tekocloud.de/tecexpress'
const example: TxSort<{ id: number }> = { selector: 'id', desc: false }
console.log(example)
```

<a id="en-txfilter"></a>
### TxFilter

Comparison/text filter and nested AND, OR and NOT expressions.

The default operator is equality. Text operators ignore case. Empty AND is true; empty OR is false. Dart matches(item) returns bool; Vue txMatches(item, filter) returns boolean. Getter errors propagate.

```ts
type TxFilter<T> =
  | {
      selector: TxSelector<T>
      operator?:
        | '='
        | '<>'
        | '>'
        | '>='
        | '<'
        | '<='
        | 'contains'
        | 'startswith'
        | 'endswith'
      value: unknown
    }
  | { and: TxFilter<T>[] }
  | { or: TxFilter<T>[] }
  | { not: TxFilter<T> }
```

```ts
import type { TxFilter } from '@tekocloud.de/tecexpress'
const example: TxFilter<{ id: number }> = { selector: 'id', operator: '>=', value: 1 }
console.log(example)
```

<a id="en-txgroup"></a>
### TxGroup

Grouped query data with a group key and count before paging.

```ts
interface TxGroup<T> {
  key: unknown
  items: T[] | TxGroup<T>[]
  count: number
}
```

| Field | Meaning |
| --- | --- |
| key | Stable key or selector; distinct from a widget key. |
| items | Entries; replaced by dataSource when bound. |
| count | Record count in the group. |

```ts
import type { TxGroup } from '@tekocloud.de/tecexpress'
const example: TxGroup<{ id: number }> = { key: 'team', items: [{ id: 1 }], count: 1 }
console.log(example)
```

<a id="en-txloadoptions"></a>
### TxLoadOptions

Store query contract: filtering, searching, sorting, grouping, paging, projection and cancellation.

Vue: omitted options are undefined; DataSource supplies count and paging defaults. Dart defaults appear in the constructor. skip/take apply to rows and top-level groups. Local processing returns counts even without a count request. Vue select is a field list; Dart select is a T→T callback. Forward signal/cancellation to custom async operations.

```ts
interface TxLoadOptions<T> {
  sort?: TxSort<T>[]
  filter?: TxFilter<T>
  searchExpr?: TxSelector<T>[]
  searchValue?: string
  group?: TxSort<T>[]
  skip?: number
  take?: number
  select?: string[]
  requireTotalCount?: boolean
  requireGroupCount?: boolean
  signal?: AbortSignal
}
```

| Field | Meaning |
| --- | --- |
| sort | Sort descriptors in priority order. |
| filter | Filter expression. |
| searchExpr | Search fields or getters. |
| searchValue | Search text; local search ignores case. |
| group | Group descriptors or group name. |
| skip | Number of results to skip. |
| take | Maximum number of results to return. |
| select | Projection before final mapping. |
| requireTotalCount | Requests the total count before paging. |
| requireGroupCount | Requests the number of top-level groups. |
| signal | AbortSignal for cooperative cancellation. |

```ts
import type { TxLoadOptions } from '@tekocloud.de/tecexpress'
const example: TxLoadOptions<{ id: number }> = { take: 10, requireTotalCount: true }
console.log(example)
```

<a id="en-txloadresult"></a>
### TxLoadResult

Load result with flat records and optional total count and group hierarchy.

```ts
interface TxLoadResult<T> {
  data: T[]
  groups?: TxGroup<T>[]
  totalCount?: number
  groupCount?: number
}
```

| Field | Meaning |
| --- | --- |
| data | Records or event payload. |
| groups | Result group hierarchy. |
| totalCount | Total filtered record count before paging. |
| groupCount | Top-level group count before paging. |

```ts
import type { TxLoadResult } from '@tekocloud.de/tecexpress'
const example: TxLoadResult<{ id: number }> = { data: [{ id: 1 }], totalCount: 1 }
console.log(example)
```

<a id="en-txstore"></a>
### TxStore

Store contract for loading and optional key resolution and writes.

```ts
interface TxStore<T> {
  load(options: TxLoadOptions<T>): Promise<TxLoadResult<T>> | TxLoadResult<T>
  byKey?(key: TxKey): Promise<T | undefined> | T | undefined
  insert?(item: T): Promise<T> | T
  update?(key: TxKey, changes: Partial<T>): Promise<T> | T
  remove?(key: TxKey): Promise<void> | void
}
```

| Field | Meaning |
| --- | --- |
| load | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| byKey | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| insert | Inserts a record with a unique key and returns it. |
| update | Updates a notification or record. |
| remove | Removes the record or recursively removes a file/directory tree. |

```ts
import type { TxStore } from '@tekocloud.de/tecexpress'
const example: TxStore<{ id: number }> = { load: () => ({ data: [{ id: 1 }] }) }
console.log(example)
```

<a id="en-txdatasourceconfig"></a>
### TxDataSourceConfig

Configuration for the store, keys, query, paging and local or remote processing.

```ts
interface TxDataSourceConfig<T> extends Omit<
  TxLoadOptions<T>,
  'skip' | 'take' | 'signal'
> {
  store: TxStore<T> | T[]
  key?: TxSelector<T>
  pageSize?: number
  pageIndex?: number
  paginate?: boolean
  remoteOperations?: boolean
  map?: (item: T) => T
}
```

| Field | Meaning |
| --- | --- |
| store | Data collection or custom store contract. |
| key | Stable key or selector; distinct from a widget key. |
| pageSize | Records per page. |
| pageIndex | Zero-based page index. |
| paginate | Enables paging; false loads the whole collection. |
| remoteOperations | Store handles queries itself; automatically enabled for custom stores. |
| map | Transformation of each loaded visible record. |
| sort | Sort descriptors in priority order. |
| filter | Filter expression. |
| searchExpr | Search fields or getters. |
| searchValue | Search text; local search ignores case. |
| group | Group descriptors or group name. |
| select | Projection before final mapping. |
| requireTotalCount | Requests the total count before paging. |
| requireGroupCount | Requests the number of top-level groups. |

```ts
import type { TxDataSourceConfig } from '@tekocloud.de/tecexpress'
const example: TxDataSourceConfig<{ id: number }> = { store: [{ id: 1 }], key: 'id', pageSize: 10 }
console.log(example)
```

<a id="en-txsource"></a>
### TxSource

Accepted data binding: array, DataSource configuration or existing DataSource.

```ts
type TxSource<T> = T[] | TxDataSourceConfig<T> | TxDataSource<T>
```

```ts
import type { TxSource } from '@tekocloud.de/tecexpress'
const example: TxSource<{ id: number }> = [{ id: 1 }]
console.log(example)
```

<a id="en-txpush"></a>
### TxPush

Insert, update or remove operation for push. Multiple operations run sequentially without a transaction.

```ts
type TxPush<T> =
  | { type: 'insert'; data: T }
  | { type: 'update'; key: TxKey; data: Partial<T> }
  | { type: 'remove'; key: TxKey }
```

```ts
import type { TxPush } from '@tekocloud.de/tecexpress'
const example: TxPush<{ id: number }> = { type: 'insert', data: { id: 1 } }
console.log(example)
```

<a id="en-txarraystore"></a>
### TxArrayStore

Copied in-memory collection with local queries and key-based CRUD operations.

Vue: data = [], key = "id". Dart: data is required; without keyOf only queries are supported. Construction copies the list. Duplicate keys, insertion of existing keys and key changes are rejected. update/remove with an unknown key fail; byKey returns undefined/null.

```ts
new TxArrayStore<T>(data?: readonly T[], key?: TxSelector<T>): TxArrayStore<T>
```

| Member | Type / return | Behavior |
| --- | --- | --- |
| data | `T[]` | Records or event payload. |
| key | `TxSelector<T>` | Stable key or selector; distinct from a widget key. |
| load | `(o: TxLoadOptions<T>) => TxLoadResult<T>` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| byKey | `(key: TxKey) => T &#124; undefined` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| insert | `(item: T) => T` | Inserts a record with a unique key and returns it. |
| update | `(key: TxKey, changes: Partial<T>) => T & Partial<T>` | Updates a notification or record. |
| remove | `(key: TxKey) => void` | Removes the record or recursively removes a file/directory tree. |

```ts
import { TxArrayStore } from '@tekocloud.de/tecexpress'
const store = new TxArrayStore([{ id: 1, text: 'One' }], 'id')
console.log(store.load({ take: 10 }), store.byKey(1))
store.insert({ id: 2, text: 'Two' })
store.update(2, { text: 'Updated' })
store.remove(2)
```

<a id="en-txcustomstore"></a>
### TxCustomStore

Adapter for custom synchronous or asynchronous store callbacks. Operations without callbacks are unavailable.

load is required; byKey/insert/update/remove are optional. load receives TxLoadOptions and returns TxLoadResult directly or asynchronously. Custom HTTP callbacks must check status codes and propagate failures. byKey returns undefined/null for a missing record. For paging, return data and totalCount before paging. With remoteOperations false, return all raw data. The example uses a local async callback and requires no server.

```ts
new TxCustomStore<T>(callbacks: TxStore<T>): TxCustomStore<T>
```

| Member | Type / return | Behavior |
| --- | --- | --- |
| load | `(options: TxLoadOptions<T>) => TxLoadResult<T> &#124; Promise<TxLoadResult<T>>` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| byKey | `((key: TxKey) => T &#124; Promise<T &#124; undefined> &#124; undefined) &#124; undefined` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| insert | `((item: T) => T &#124; Promise<T>) &#124; undefined` | Inserts a record with a unique key and returns it. |
| update | `((key: TxKey, changes: Partial<T>) => T &#124; Promise<T>) &#124; undefined` | Updates a notification or record. |
| remove | `((key: TxKey) => Promise<void> &#124; void) &#124; undefined` | Removes the record or recursively removes a file/directory tree. |

```ts
import { TxCustomStore, txQuery } from '@tekocloud.de/tecexpress'
// Replace callbacks with your own HTTP/database integration.
const store = new TxCustomStore<{ id: number }>({ load: async options => txQuery([{ id: 1 }], options), byKey: async id => id === 1 ? { id: 1 } : undefined })
console.log(await store.load({}), await store.byKey?.(1))
```

<a id="en-txdatasource"></a>
### TxDataSource

Observable data source with query state and asynchronous loading. Writes reload the data; its owner disposes the instance.

Default configuration: pageSize 20, pageIndex 0, paginate true; array stores are local, other stores remote. The Vue array shorthand retains paging; Dart TxDataSource.array defaults to paginate false. items starts empty; call load() unless a bound consumer triggers the initial load. Invalid paging is rejected. Replace the store and key by creating a new instance. configure returns a Promise/Future of the reloaded list. byKey returns a Promise/Future of a record or undefined/null; insert/update return the written record and remove returns no value. Vue push returns the new list; Dart push returns no value. cancel/dispose return no value. Load/write failures are also exposed in error. For unsupported operations Vue throws Error and Dart throws UnsupportedError. Loading after disposal fails.

```ts
new TxDataSource<T>(config: TxDataSourceConfig<T> | T[]): TxDataSource<T>
```

| Member | Type / return | Behavior |
| --- | --- | --- |
| store | `TxStore<T>` | Data collection or custom store contract. |
| key | `TxSelector<T>` | Stable key or selector; distinct from a widget key. |
| items | `T[]` | Entries; replaced by dataSource when bound. |
| groups | `TxGroup<T>[] &#124; undefined` | Result group hierarchy. |
| totalCount | `number` | Total filtered record count before paging. |
| groupCount | `number &#124; undefined` | Top-level group count before paging. |
| loading | `boolean` | Shows the loading state. |
| error | `unknown` | Most recent load/write error. |
| loaded | `boolean` | At least one load completed successfully. |
| config | `TxDataSourceConfig<T>` | Instance configuration. |
| containsKey | `(key: TxKey) => boolean &#124; undefined` | Returns false for known removals, a boolean for an array store, otherwise undefined/null. |
| subscribe | `(listener: () => void) => () => void` | Registers a change listener and returns an unsubscribe function. |
| pendingLoad | `Promise<T[]> &#124; undefined` | Promise for the most recently started load. |
| load | `() => Promise<T[]>` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| reload | `() => Promise<T[]>` | Reloads the current query and returns visible records. |
| configure | `(changes: Partial<TxDataSourceConfig<T>>) => Promise<T[]>` | Changes query options and reloads. Search, filter and page size reset the page unless explicitly supplied. |
| cancel | `() => void` | Set synchronously to true to cancel the action. |
| byKey | `(key: TxKey) => Promise<Awaited<T> &#124; undefined>` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| insert | `(item: T) => Promise<T>` | Inserts a record with a unique key and returns it. |
| update | `(key: TxKey, changes: Partial<T>) => Promise<T>` | Updates a notification or record. |
| remove | `(key: TxKey) => Promise<void>` | Removes the record or recursively removes a file/directory tree. |
| push | `(changes: TxPush<T>[]) => Promise<T[]>` | Runs store writes sequentially and reloads once; not a transaction, partial success is possible on error. |
| dispose | `() => void` | Stops queries and listeners; do not use the instance afterward. |

```ts
import { TxDataSource } from '@tekocloud.de/tecexpress'
const source = new TxDataSource({ store: [{ id: 1, text: 'One' }], key: 'id', pageSize: 10 })
const unsubscribe = source.subscribe(() => console.log(source.loading, source.error))
await source.load()
await source.configure({ searchExpr: ['text'], searchValue: 'One' })
console.log(await source.byKey(1), source.containsKey(1))
await source.insert({ id: 2, text: 'Two' })
await source.update(2, { text: 'Updated' })
await source.push([{ type: 'update', key: 2, data: { text: 'Changed' } }])
await source.remove(2)
await source.reload()
source.cancel()
unsubscribe()
source.dispose()
```

<a id="en-txfilestore"></a>
### txFileStore

Connects a provider and a current-directory getter to a queryable store.

Parameters: provider and parent, a getter for the current directory ID (null = root). Returns TxStore&lt;TxFileEntry&gt;. load returns Promise/Future&lt;TxLoadResult&lt;TxFileEntry&gt;&gt;. Provider failures propagate. Reload after changing directories.

```ts
function txFileStore(provider: TxFileProvider, parent: () => string | null): TxStore<TxFileEntry>
```

```ts
import { TxMemoryFileProvider, txFileStore } from '@tekocloud.de/tecexpress'
const provider = new TxMemoryFileProvider()
const store = txFileStore(provider, () => null)
console.log(await store.load({ take: 10 }))
```

<a id="en-txhttpupload"></a>
### txHttpUpload

Creates a multipart POST adapter. The server must assemble chunks. Non-success HTTP responses and network errors fail the upload.

Parameter: config with a required URL; returns TxUploadAdapter. The adapter receives file and context and asynchronously returns the final HTTP response text. fieldName = file; extra fields/headers default to empty. chunkSize must be positive; chunkFields receives file, zero-based index and count. Cancellation and HTTP/network failures reject the operation. No automatic JSON parsing or server-side chunk assembly.

```ts
function txHttpUpload(config: TxHttpUploadConfig): TxUploadAdapter
```

```ts
import { txHttpUpload } from '@tekocloud.de/tecexpress'
const upload = txHttpUpload({ url: '/api/upload', fieldName: 'file', chunkSize: 1024 * 1024 })
// Browser only; requires your own multipart server and chunk assembly.
const controller = new AbortController()
await upload(new File(['Hello'], 'hello.txt'), { signal: controller.signal, onProgress: (loaded, total) => console.log(loaded, total) })
```

<a id="en-txfileentry"></a>
### TxFileEntry

File/directory metadata with a stable ID; a null parentId denotes the root directory.

Dart copyWith preserves omitted fields; root: true explicitly sets parentId to null. Passing parentId: null alone preserves the existing parent.

```ts
interface TxFileEntry {
  id: string
  parentId: string | null
  name: string
  isDirectory: boolean
  size?: number
  modified?: Date
  content?: Blob
}
```

| Field | Meaning |
| --- | --- |
| id | Unique stable ID. |
| parentId | Parent directory ID; null denotes the root. |
| name | Input field name or file name. |
| isDirectory | Identifies a directory. |
| size | File size in bytes. |
| modified | Last modification time. |
| content | Custom content or file contents as a Blob. |

```ts
import type { TxFileEntry } from '@tekocloud.de/tecexpress'
const example: TxFileEntry = { id: '1', parentId: null, name: 'Documents', isDirectory: true }
console.log(example)
```

<a id="en-txfileprovider"></a>
### TxFileProvider

Asynchronous contract for directory listings and file operations.

list is required. Vue offers optional methods; Dart implementations declare capabilities and override matching methods. Unimplemented Dart operations throw UnsupportedError. list/upload support cooperative cancellation. createDirectory/upload return an entry; rename/copy/move/remove return no value; download returns Blob (Vue) or Uint8List (Dart).

```ts
interface TxFileProvider {
  list(parentId: string | null, signal?: AbortSignal): Promise<TxFileEntry[]>
  createDirectory?(parentId: string | null, name: string): Promise<TxFileEntry>
  rename?(id: string, name: string): Promise<void>
  copy?(id: string, target: string | null): Promise<void>
  move?(id: string, target: string | null): Promise<void>
  remove?(id: string): Promise<void>
  upload?(
    parentId: string | null,
    file: File,
    signal?: AbortSignal,
  ): Promise<TxFileEntry>
  download?(id: string): Promise<Blob>
}
```

| Field | Meaning |
| --- | --- |
| list | Returns entries in the parent directory; null reads the root. |
| createDirectory | Creates a directory with a valid name unique within its parent. |
| rename | Renames a file or directory; preserves its ID and parent. |
| copy | Recursively copies an entry to the target directory, assigning new IDs. |
| move | Moves an entry to the target directory; cycles are rejected. |
| remove | Removes the record or recursively removes a file/directory tree. |
| upload | Uploads a file to the specified directory and returns its new entry. |
| download | Returns file contents; downloading a directory fails. |

```ts
import type { TxFileProvider } from '@tekocloud.de/tecexpress'
const example: TxFileProvider = { list: async () => [] }
console.log(example)
```

<a id="en-txmemoryfileprovider"></a>
### TxMemoryFileProvider

Volatile file provider with recursive copy/delete, name validation and cycle protection; data does not survive a restart.

All file operations are asynchronous. Directory and file IDs are strings; null as parent/target denotes the root. Invalid names, name collisions, unknown IDs, duplicate IDs and cycles fail. Copy preserves contents, assigns new IDs and includes descendants. Remove deletes recursively. Without stored contents, download is empty; directory downloads are unavailable.

```ts
new TxMemoryFileProvider(entries?: TxFileEntry[]): TxMemoryFileProvider
```

| Member | Type / return | Behavior |
| --- | --- | --- |
| list | `(parentId: string &#124; null, signal?: AbortSignal) => Promise<{ id: string; parentId: string &#124; null; name: string; isDirectory: boolean; size?: number; modified?: Date; content?: Blob; }[]>` | Returns entries in the parent directory; null reads the root. |
| createDirectory | `(parentId: string &#124; null, name: string) => Promise<{ id: string; parentId: string &#124; null; name: string; isDirectory: boolean; size?: number; modified?: Date; content?: Blob; }>` | Creates a directory with a valid name unique within its parent. |
| rename | `(id: string, name: string) => Promise<void>` | Renames a file or directory; preserves its ID and parent. |
| move | `(id: string, target: string &#124; null) => Promise<void>` | Moves an entry to the target directory; cycles are rejected. |
| copy | `(id: string, target: string &#124; null) => Promise<void>` | Recursively copies an entry to the target directory, assigning new IDs. |
| remove | `(id: string) => Promise<void>` | Removes the record or recursively removes a file/directory tree. |
| upload | `(parentId: string &#124; null, file: File, signal?: AbortSignal) => Promise<{ id: string; parentId: string &#124; null; name: string; size: number; isDirectory: boolean; content: Blob; modified: Date; }>` | Uploads a file to the specified directory and returns its new entry. |
| download | `(id: string) => Promise<Blob>` | Returns file contents; downloading a directory fails. |

```ts
import { TxMemoryFileProvider } from '@tekocloud.de/tecexpress'
const provider = new TxMemoryFileProvider()
const folder = await provider.createDirectory(null, 'Documents')
const file = await provider.upload(folder.id, new File(['Hello'], 'hello.txt'))
await provider.rename(file.id, 'renamed.txt')
await provider.copy(file.id, null)
await provider.move(file.id, null).catch(error => console.log(error.message)) // name collision
console.log(await provider.list(folder.id), await provider.download(file.id))
await provider.remove(folder.id) // recursive
```

<a id="en-txuploadcontext"></a>
### TxUploadContext

Cancellation and progress reporting for one upload operation; progress is reported in bytes.

```ts
interface TxUploadContext {
  signal: AbortSignal
  onProgress: (loaded: number, total: number) => void
}
```

| Field | Meaning |
| --- | --- |
| signal | AbortSignal for cooperative cancellation. |
| onProgress | Reports completed bytes and total size. |

```ts
import type { TxUploadContext } from '@tekocloud.de/tecexpress'
const example: TxUploadContext = { signal: new AbortController().signal, onProgress: (loaded, total) => console.log(loaded, total) }
console.log(example)
```

<a id="en-txuploadadapter"></a>
### TxUploadAdapter

Asynchronous callback uploading one file; its result reaches the success callback and errors reach error handling.

```ts
type TxUploadAdapter = (
  file: File,
  context: TxUploadContext,
) => Promise<unknown>
```

```ts
import type { TxUploadAdapter } from '@tekocloud.de/tecexpress'
const example: TxUploadAdapter = async (file, context) => { context.signal.throwIfAborted(); context.onProgress(file.size, file.size); return file.name }
console.log(example)
```

<a id="en-txhttpuploadconfig"></a>
### TxHttpUploadConfig

Multipart HTTP configuration with a destination, fields, headers and optional chunks.

```ts
interface TxHttpUploadConfig {
  url: string
  fieldName?: string
  headers?: Record<string, string>
  withCredentials?: boolean
  fields?: Record<string, string>
  chunkSize?: number
  chunkFields?: (
    file: File,
    index: number,
    count: number,
  ) => Record<string, string>
}
```

| Field | Meaning |
| --- | --- |
| url | Upload server destination. |
| fieldName | Multipart file field name. |
| headers | Additional HTTP headers. |
| withCredentials | Sends browser credentials with XHR. |
| fields | Additional multipart text fields. |
| chunkSize | Chunk size in bytes; must be positive. |
| chunkFields | Fields per chunk; index is zero-based. |

```ts
import type { TxHttpUploadConfig } from '@tekocloud.de/tecexpress'
const example: TxHttpUploadConfig = { url: '/api/upload', fieldName: 'file' }
console.log(example)
```

<a id="en-development"></a>
### Development and further documentation

```sh
npm install
npm run typecheck
npm test
npm run test:package
npm pack --dry-run
```

Run commands from the respective package directory. A dry run does not publish anything.

[Publishing guide](https://github.com/tekocloud/tecexpress/blob/main/PUBLISHING.md) · [Showcase](https://github.com/tekocloud/tecexpress/blob/main/npm/demo/App.vue) · [Changelog](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/CHANGELOG.md) · [MIT](https://github.com/tekocloud/tecexpress/blob/main/npm/LICENSE)
[DataSource](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/data-source.md) · [Scheduler](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/scheduler.md) · [Cards / Chat](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/cards-chat.md) · [Extensions](https://github.com/tekocloud/tecexpress/blob/main/npm/docs/extensions.md)
