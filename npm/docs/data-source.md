# TxDataSource · 0.7.1

Importe: `TxDataSource`, `TxDataSourceConfig`, `TxArrayStore`, `TxCustomStore`, `TxStore`, `TxLoadOptions`, `TxLoadResult`, `TxFilter`, `TxSort`, `TxGroup`, `TxSource`, `TxPush`. Konfigurationen und Verträge sind TypeScript-Typen; Stores und DataSource sind Klassen.

## Drei Arten der Datenbindung

```ts
import { TxDataSource, TxCustomStore, txQuery } from '@tekocloud.de/tecexpress'

const teams = [{ id: 1, text: 'Entwicklung', group: 'Produkt' }, { id: 2, text: 'Vertrieb', group: 'Geschäft' }]
const config = { store: teams, key: 'id', pageSize: 10 }
const shared = new TxDataSource(config)
```

```vue
<TxRadioGroup :data-source="teams" v-model="team" />
<TxLookup :data-source="config" v-model="team" />
<TxTagBox :data-source="shared" v-model="selectedTeams" />
<TxList :data-source="shared" search-enabled />
```

Listen werden weiterhin synchron dargestellt. Bei einer Konfiguration erzeugt die Komponente eine eigene DataSource und entsorgt sie bei Austausch/Unmount. Eine übergebene Instanz bleibt im Besitz der Anwendung. Sie wird beim ersten Binden geladen; bei mehreren Konsumenten läuft nur die erste initiale Anfrage. Ein explizites `load()`/`reload()` ersetzt eine noch laufende Anfrage. `dataSource` hat Vorrang vor `items`, auch bei einer leeren Liste.

Eine geteilte Instanz teilt **auch Suche, Filter, Sortierung und Seite**. Unabhängige Ansichten erhalten eigene Instanzen desselben Stores. Die Auswahl gehört zur jeweiligen Komponente. `source.dispose()` beim Ende des Anwendungseigentümers aufrufen. Arrays und Instanzen nicht bei jedem Render neu erzeugen.

## Konfiguration

| Feld | Bedeutung |
| --- | --- |
| `store` | Array oder `TxStore<T>`; `TxArrayStore` kopiert das Eingangsarray. |
| `key` | Feldpfad oder Getter, Standard `id`. Für Schlüsselauflösung/Schreiboperationen eindeutige String-/Number-Werte verwenden. |
| `sort`, `group` | Listen aus `{ selector, desc? }`; Selector ist Feldpfad oder Getter. |
| `filter` | `{ selector, operator?, value }` sowie verschachtelte `{ and: [...] }`, `{ or: [...] }`, `{ not: ... }`. |
| `searchExpr`, `searchValue` | Suchfelder/-getter und Suchtext. Lokale Suche ignoriert Groß-/Kleinschreibung. |
| `pageSize`, `pageIndex`, `paginate` | Seitengröße, nullbasierte Seite; Standard 20/0/true. `paginate: false` lädt alle Datensätze. |
| `remoteOperations` | Standard false für ArrayStore, true für CustomStore. Bei false liefert der CustomStore alle Rohdaten; die DataSource verarbeitet sie lokal. |
| `select`, `map` | Projektion durch Feldnamen; anschließende Transformation jedes sichtbaren Datensatzes. |
| `requireTotalCount`, `requireGroupCount` | Anforderungen an Store-Ergebnisse. |

Filteroperatoren: `=`, `<>`, `>`, `>=`, `<`, `<=`, `contains`, `startswith`, `endswith`. Lokale Verarbeitung: Filtern/Suchen → Gruppierungs-/Sortierschlüssel → Gruppenbildung → Paging → Projektion → Mapping. `data` bleibt eine flache Zeilenliste; `groups` enthält die Hierarchie. Gruppenpaging bezieht sich auf die oberste Gruppenebene. Die einfache Zeilendarstellung verwendet `data`.

## Entfernte Daten

```ts
type Team = { id: number; text: string }
const store = new TxCustomStore<Team>({
  async load(options) {
    // Optionen gezielt in das eigene API-Protokoll übersetzen.
    // Getterfunktionen sind nicht JSON-serialisierbar.
    const response = await fetch(`/api/teams?skip=${options.skip ?? 0}&take=${options.take ?? 20}`, {
      signal: options.signal,
    })
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    return response.json() // { data: Team[], totalCount: number }
  },
  async byKey(id) {
    const response = await fetch(`/api/teams/${encodeURIComponent(id)}`)
    if (response.status === 404) return undefined
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    return response.json()
  },
  // insert, update und remove bei Bedarf ergänzen.
})
const source = new TxDataSource({ store, key: 'id', pageSize: 20 })
```

Der Store erhält `sort`, `filter`, `searchExpr`, `searchValue`, `group`, `skip`, `take`, `select`, Count-Anforderungen und `signal`. Er liefert `{ data, totalCount?, groups?, groupCount? }`. Für korrektes serverseitiges Paging ist `totalCount` erforderlich. Ohne Count entspricht die gemeldete Anzahl der geladenen Zeilen. Die Bibliothek legt kein REST-/OData-Protokoll fest. Der Beispielcode zeigt ausschließlich die Paging-Übersetzung; weitere konfigurierte Operationen muss das Backend ebenfalls verarbeiten oder `remoteOperations: false` verwenden.

## Zustand und Änderungen

- `items`, `groups`, `totalCount`, `groupCount`, `loading`, `loaded`, `error` beschreiben den letzten Zustand. `subscribe(callback)` liefert eine Abmeldefunktion; Vue-Komponenten benutzen diese bereits. Außerhalb der Komponenten dient `useTxSource(() => source)` als reaktive Brücke.
- `load()`, `reload()`, `configure(changes)` liefern Promises. Suche, Filter und Seitengröße setzen die Seite auf 0 zurück, sofern kein expliziter `pageIndex` angegeben wurde. Store/Key werden durch eine neue Instanz ersetzt.
- `cancel()` bricht das Signal ab. Auch Stores, die das Signal ignorieren, können mit verspäteten Antworten keine neuere Anfrage überschreiben. Ein Ladefehler bleibt in `error`, `loading` endet; erneutes Laden ist möglich.
- `byKey`, `insert`, `update`, `remove` delegieren an den Store. Nicht unterstützte Operationen werfen Fehler. ArrayStore-Schlüssel sind unveränderlich und dürfen nicht doppelt sein.
- `push([{ type: 'insert', data }, { type: 'update', key, data }, { type: 'remove', key }])` führt Store-Operationen nacheinander aus und lädt danach neu. Dies ist keine Datenbanktransaktion und kein eingebautes WebSocket-Protokoll. Bei CustomStores nur verwenden, wenn diese Operationen tatsächlich ausgeführt werden sollen.
- DataGrid/CardView verarbeiten eine DataSource-Seite nicht erneut lokal. Auswahl bleibt über Filter und Seiten erhalten; lokal beziehungsweise durch `remove()` bekannte Löschungen werden bereinigt. Extern entfernte Remote-Schlüssel benötigen eine entsprechende Store-/Anwendungsaktualisierung.

## Unterstützte Bindungen

DataGrid, CardView, Scheduler, Chat, SelectBox, Tabs, Menu sowie die neuen datenführenden Komponenten akzeptieren Listen/Konfigurationen/Instanzen. Chat behält zusätzlich `items`; Scheduler/Chat schreiben bei Instanzbindung über den Store. Für vollständige Kalender-/Chatverläufe `paginate: false` konfigurieren oder die gewünschte Datenmenge selbst laden.

Auswahlkomponenten verwenden String-Einträge oder `{ id?, value?, text, disabled?, group?, icon? }`; der Auswahlwert ist `value`, sonst `id`, sonst `text`. Beliebige Geschäftsdaten lassen sich mit `map` in diese Form überführen. SelectBox behält `displayExpr`/`valueExpr`. Flutter verwendet dafür `TxItem<T>` und Getter.

FileManager verwendet zusätzlich `provider` und optional eine eigene `dataSource`. `txFileStore(provider, parentGetter)` verbindet den Provider mit der DataSource. FileUploader kann über `dataSource` mit `File`-Objekten initialisiert werden. Map hat `dataSource` für Marker und `routeDataSource` für Routen. RangeSelector liest seine Serien über `argumentExpr`/`valueExpr`. LoadPanel beobachtet den Ladezustand einer Instanz.

TextBox, NumberBox, Button, Card, Popup, Tooltip und Toast sind keine Datensatzlisten. Ihre Werte/Inhalte werden über die vorhandenen Props/Slots aus der Anwendung gebunden, beispielsweise `:message="source.error ? String(source.error) : ''"`; es wird keine unsichtbare Liste erzeugt.
