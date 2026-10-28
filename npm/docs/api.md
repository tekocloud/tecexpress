# API · tecexpress 0.7.0

Die vollständige Referenz aller öffentlichen Exporte mit deutschen und englischen
Erklärungen und einfachen Beispielen steht direkt in der
[Paket-README](https://github.com/tekocloud/tecexpress/blob/main/npm/README.md#de-api).
Diese Seite ergänzt sie um thematische Hinweise zu den ursprünglichen Komponenten.

Alle Komponenten werden aus `@tekocloud.de/tecexpress` importiert. CamelCase-Props lassen sich in Templates als kebab-case schreiben. Native Attribute und Listener sind möglich; bei Editoren gehen sie an das Eingabeelement, bei anderen Komponenten an das Wurzelelement. Globale Registrierung: `app.use(Tecexpress)`.

## DataSource und Erweiterungen

[TxDataSource, Stores und Konfiguration](data-source.md) · [Neue Komponenten, Adapter und notify](extensions.md).

## Karten und Chat

Seit 0.3.0: `TxCard`, `TxCardView` und `TxChat`. Vollständige Props, Events, Slots, Datenverträge, Grenzen und Beispiele: [Karten und Chat](cards-chat.md).

## Scheduler

Seit 0.2.0: `TxScheduler` mit Tag/Woche/Monat, lokaler Terminbearbeitung, Ganztags- und mehrtägigen Terminen. Vollständige Props, Events, Slots, Date-/Zeitzonenvertrag und Beispiel: [Scheduler](scheduler.md).

## Editoren

`TxTextBox`, `TxTextArea`, `TxNumberBox`, `TxDateBox`, `TxCheckBox`, `TxSwitch` und `TxSelectBox` unterstützen:

| Prop / Event | Verhalten |
| --- | --- |
| `modelValue`, `value` | Kontrollierter Wert über `v-model` oder `v-model:value`; `modelValue` hat Vorrang, wenn gesetzt. Nicht gleichzeitig verwenden. Ohne beide Props interner Wert. |
| `label`, `name`, `placeholder` | Beschriftung, natives Formularfeld und Platzhalter. Bei CheckBox/Switch Beschriftung neben dem Schalter. |
| `disabled`, `readOnly`, `required` | Standard `false`; keine Wertänderungs-Events im deaktivierten oder schreibgeschützten Zustand. Native Formularvalidierung, kein eigenes Validierungssystem. |
| `isValid`, `validationMessage` | Standard `true` bzw. `Bitte Eingabe prüfen.`; steuert Fehlerdarstellung und ARIA-Verknüpfung. Führt selbst keine Validierung aus. |
| `update:modelValue`, `update:value` | Neuer primitiver Wert. |
| `valueChanged` | `{ value, previousValue, event }`, nur bei tatsächlich geändertem Wert. `event` ist das native DOM-Event. |

| Komponente | Wert / zusätzliche Props | Minimalbeispiel |
| --- | --- | --- |
| `TxTextBox` | String, anfangs `''`; `type='text'`, z. B. `email`, `password`, `search` | `<TxTextBox v-model="name" label="Name" />` |
| `TxTextArea` | String, anfangs `''`; `rows=3` | `<TxTextArea v-model="note" label="Notiz" :rows="4" />` |
| `TxNumberBox` | `number \| null`, anfangs `null`; `min`, `max`, `step=1`. Leeren ergibt `null`. Grenzen folgen nativer HTML-Validierung, kein automatisches Begrenzen. | `<TxNumberBox v-model="count" label="Anzahl" :min="0" />` |
| `TxDateBox` | ISO-Datumsstring `YYYY-MM-DD`, anfangs `''`; `min`, `max` als ISO-Strings. Kein Date-Objekt und keine Uhrzeit. | `<TxDateBox v-model="date" label="Datum" min="2026-01-01" />` |
| `TxCheckBox` | Boolean, anfangs `false`; keine Dreizustandsauswahl | `<TxCheckBox v-model="accepted" label="Zustimmen" />` |
| `TxSwitch` | Boolean, anfangs `false`; native Checkbox mit `role="switch"` | `<TxSwitch v-model="enabled" label="Aktiv" />` |
| `TxSelectBox` | String, Zahl, Boolean oder `null`; `items=[]`, `displayExpr='text'`, `valueExpr='value'`. Primitive Items oder Objekte, optionale `disabled`-Eigenschaft je Objekt. `dataSource` akzeptiert Arrays, Konfigurationen und Instanzen einschließlich Remote-Stores; keine eigene Suche. | `<TxSelectBox v-model="category" label="Kategorie" :items="['A', 'B']" />` |

Editorwerte sind primitiv; ganze Objekte als SelectBox-Wert werden nicht unterstützt. `id`, `autocomplete`, `aria-label` und weitere native Attribute können direkt gesetzt werden. Immer `label` oder `aria-label` für namenlose Editoren angeben. Die native Datumsdarstellung hängt vom Browser und dessen Sprache ab. Schreibgeschützte SelectBoxen können ihren nativen Picker öffnen, übernehmen aber keine Änderungen.

## Button

`TxButton`: `text`, `type='normal'` (`normal | default | danger | success`), `disabled=false`, `useSubmitBehavior=false`. Standardmäßig `type="button"`, mit Submit-Flag ein natives Submit-Element. Event `click(MouseEvent)`; Default-Slot ersetzt `text`.

```vue
<TxButton text="Speichern" type="default" @click="save" />
<TxButton disabled>Momentan nicht verfügbar</TxButton>
```

## Navigation

`Item` ist `{ text: string; disabled?: boolean; id?: string | number }`; alternativ Strings.

| Komponente | Props und Slots | Events und Bedienung |
| --- | --- | --- |
| `TxTabs` | `items=[]`, `modelValue` oder `selectedIndex`, `disabled=false`, `label='Reiter'`. Default-Slot `{ selectedIndex, item }` für aktiven Panelinhalt. | `update:modelValue`, `update:selectedIndex`, `selectionChanged({ selectedIndex, itemData })`. Ohne gesteuerten Index interne Auswahl. Ungültige oder gesperrte Auswahl fällt auf den ersten verfügbaren Reiter zurück. Pfeiltasten, Home/End; gesperrte Reiter werden übersprungen. |
| `TxToolbar` | `label='Werkzeugleiste'`; Default-Slot links, `after` rechts | Gruppiert native Bedienelemente; normale Tab-Reihenfolge, kein Roving-Tabindex. |
| `TxMenu` | `items=[]`, `disabled=false`, `label='Menü'` | Flache Liste von Aktionsbuttons in einem Navigationselement; `itemClick({ itemData, itemIndex, event })`. Keine Untermenüs; normale native Tab-/Enter-/Leertastenbedienung. |

```vue
<TxTabs v-model="tab" :items="['Übersicht', 'Details']">
  <template #default="{ selectedIndex }">Bereich {{ selectedIndex + 1 }}</template>
</TxTabs>
<TxToolbar label="Aktionen">
  <strong>Aufträge</strong>
  <template #after><TxButton text="Neu" @click="create" /></template>
</TxToolbar>
<TxMenu :items="['Datei', { text: 'Export', disabled: true }]" @item-click="handleItem" />
```

## Overlays und Rückmeldungen

| Komponente | Props und Slots | Events / Verhalten |
| --- | --- | --- |
| `TxPopup` | `visible=false`, `title='Dialog'`, `width=480` (Zahl in px oder CSS-String), `showCloseButton=true`, `hideOnOutsideClick=false`. Default-Inhalt und `footer`-Slot. | `update:visible`, `shown`, `hidden`. Mit `v-model:visible` steuern. Escape und Close-Button fordern Schließen an; kontrollierender Parent muss den Wert übernehmen. Fokus wird im obersten Dialog gehalten und nach Schließen zurückgesetzt. |
| `TxTooltip` | `text=''`, `disabled=false`; Default-Slot für den Trigger, `content` für eigenen Hinweisinhalt; `visible`, `showDelay/hideDelay`, `showOn`, `position` | Umschließt seinen Trigger; Anzeige auf Hover/Fokus beziehungsweise Klick, Escape blendet aus. `update:visible`, `shown`, `hidden`. Wrapper ist per Tab erreichbar. Kein `target`-Selektor, kein Teleport. |
| `TxToast` | `visible=false`, `message`, `type='info'` (`info | success | warning | error`), `displayTime=3500` in ms, `position`; Default-Slot ersetzt Nachricht, Slot `actions` ergänzt Aktionen | `update:visible`; `v-model:visible` verwenden. `displayTime<=0` deaktiviert Zeitlimit. Timer startet bei geänderter Nachricht, Dauer oder Sichtbarkeit neu. Live-Region, Fehler mit `role="alert"`. |
| `TxLoadIndicator` | `visible=true`, `label='Wird geladen …'` | Animierte Ladeanzeige mit Statusrolle; berücksichtigt reduzierte Bewegung. |

```vue
<TxPopup v-model:visible="open" title="Bestätigen" hide-on-outside-click>
  Fortfahren?
  <template #footer><TxButton text="OK" @click="open = false" /></template>
</TxPopup>
<TxTooltip text="Weitere Informationen"><TxButton text="Info" /></TxTooltip>
<TxToast v-model:visible="notice" message="Gespeichert" type="success" />
<TxLoadIndicator :visible="loading" label="Daten werden geladen" />
```

Overlays werden im Komponentenbaum gerendert und erben dessen Theme. Popup und Toast sind per CSS viewport-fixiert; innerhalb transformierter oder abschneidender Container möglichst weit oben im App-Baum platzieren. Die Anwendung steuert bei Bedarf Scroll-Locking. Tooltip-Inhalte sind kurze Texte, keine interaktiven Dialoge.

## DataGrid und Column

| Prop | Standard / Verhalten |
| --- | --- |
| `dataSource` | `[]`; `Record<string, unknown>[]`, DataSource-Konfiguration oder Instanz. Arrays werden lokal verarbeitet; Stores können Remote-Operationen übernehmen. Geladene DataSource-Seiten werden nicht erneut lokal verarbeitet. |
| `keyExpr` | `'id'`; eindeutiger String oder endliche Zahl je Datensatz, auch Punktpfade wie `order.id`. Fehlende oder doppelte Schlüssel werfen einen erklärenden Fehler. |
| `columns` | Optionales `Column[]`. Ohne Konfiguration Felder der ersten Zeile. Direkte `TxColumn`-Kinder (auch in `v-for`/Fragmenten) haben Vorrang vor dem gesamten `columns`-Prop. |
| `filterRow` | `true`, alternativ `{ visible: boolean }`; Textfilter pro Spalte. Alle Filter werden mit UND verknüpft; Groß-/Kleinschreibung wird ignoriert. Zahlen und Boolean-Werte werden ebenfalls als Text gefiltert. |
| `pageSize` | `10`; mindestens 1, auf ganze Zahl abgerundet. Nicht endliche Werte fallen auf 10 zurück. |
| `pageIndex` | Optional, nullbasiert über `v-model:pageIndex` steuerbar; sonst interner Zustand. Angezeigte Seite wird auf vorhandene Seiten begrenzt. Filter und Änderung der Seitengröße setzen auf Seite 0 zurück. |
| `selection` | `'none'`, `'single'`, `'multiple'` oder `{ mode: ... }`. Auswahl erfolgt über Checkboxen; in Single-Modus höchstens eine Zeile. |
| `selectedRowKeys` | Optionales Array über `v-model:selectedRowKeys`; sonst intern. Auswahl bleibt über Seiten und Filter erhalten. Entfernte Datensätze werden aus der Auswahl bereinigt. Header-Checkbox betrifft nur die aktuelle Seite. |
| `loading`, `disabled` | `false`; sperren Tabellenaktionen. Loading ersetzt Tabelleninhalt durch Ladehinweis. |
| `noDataText`, `label` | `'Keine Daten vorhanden.'`, `'Datentabelle'` |

`TxColumn` ist reine Konfiguration und rendert außerhalb des Grids keine Oberfläche:

| Column-Option | Verhalten |
| --- | --- |
| `dataField` | Pflichtfeld; auch Punktpfade möglich |
| `caption` | Standard ist `dataField` |
| `width` | Zahl in px oder CSS-String |
| `allowSorting`, `allowFiltering`, `visible` | Standard `true`; explizit `false` deaktiviert |
| `alignment` | `left | center | right` |
| `cellTemplate` | Name eines Zell-Slots; ohne Angabe `cell-<dataField>` |

Zell-Slot-Props: `{ data, value, column, rowIndex }`. `rowIndex` ist nullbasiert innerhalb der gefilterten, sortierten Gesamtliste. Zellen rendern ohne Slot den Stringwert; HTML wird nicht ungeprüft eingefügt.

Events:

- `rowClick({ data, key, rowIndex, event })`: Klick auf Zeile, nicht auf deren Auswahlcheckbox.
- `selectionChanged({ selectedRowKeys, selectedRowsData })` und `update:selectedRowKeys(keys)`.
- `update:pageIndex(index)`.
- `sortChanged({ dataField, desc } | null)`: Einspaltensortierung; Klickfolge aufsteigend, absteigend, unsortiert. Zahlen numerisch, Strings mit natürlicher Sortierung, Nullwerte zuerst aufsteigend. Gleiche Werte behalten ihre Reihenfolge.
- `filterChanged(filters)`: Kopie des Feld-zu-Text-Mappings.

```vue
<TxDataGrid :data-source="orders" :page-size="5" selection="multiple"
  v-model:selected-row-keys="selected" @row-click="openOrder($event.data)">
  <TxColumn data-field="id" caption="Auftrag" />
  <TxColumn data-field="amount" caption="Betrag" alignment="right" />
  <template #cell-amount="{ value }">{{ Number(value).toFixed(2) }} €</template>
</TxDataGrid>
```

Die vollständige ausführbare Kombination aller Beispiele steht in `demo/App.vue`. Remote-Abfragen und Gruppierung sind über die gemeinsame DataSource verfügbar; Gruppen werden im Grid weiterhin als flache Zeilen angezeigt. Nicht implementiert sind verschachtelte DevExtreme-Option-Komponenten wie `DxPaging`, eine DevExtreme-Instanz-API, lokale Mehrspaltensortierung im Grid, Bearbeitung und Virtualisierung. Nur dokumentierte Optionen werden unterstützt.
