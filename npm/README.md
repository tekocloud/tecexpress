# @tekocloud.de/tecexpress

Eigenständige Vue-3-Komponentenbibliothek unter MIT-Lizenz, ohne Lizenzkey. Version 0.5.0 enthält 36 UI-Komponenten und `TxColumn` als DataGrid-Konfiguration, TypeScript-Deklarationen sowie Light- und Dark-Theme.

**Veröffentlichen:** [Zentrale Anleitung für npm und pub.dev](https://github.com/tekocloud/tecexpress/blob/main/PUBLISHING.md).

## Neu in 0.5.0

`TxDataSource`, Array-/Custom-Stores und gemeinsame lokale/entfernte Datenbindung für bestehende und neue Komponenten. RadioGroup, RangeSlider/Selector, TagBox, Lookup, ButtonGroup, FAB, FileManager/Uploader, TabPanel, ContextMenu, ActionSheet, List, Gallery, LoadPanel, Map und `notify`; bestehende Overlays erweitert. [DataSource](docs/data-source.md) · [Neue APIs und Adapter](docs/extensions.md).

## Lokal starten

Für die Entwicklung Node.js **24.15 oder neuer innerhalb von 24.x** verwenden (die Testumgebung benötigt eine aktuelle Node-Version).

```sh
npm install
npm run build
npm run dev
```

Demo: http://127.0.0.1:5173. Nach Änderungen unter `src/` erneut `npm run build` ausführen: Die Demo verwendet bewusst das gebaute Paket über seine öffentlichen Exporte. Änderungen an Demo und CSS werden von Vite direkt übernommen.

```sh
npm run typecheck
npm test
npx playwright install chromium
npm run test:browser
npm run test:package
npm run build:demo
npm pack
```

`npm pack` erzeugt `tekocloud.de-tecexpress-0.5.0.tgz`. In einem anderen Vue-Projekt mit `npm install /pfad/zu/tekocloud.de-tecexpress-0.5.0.tgz` installieren. `npm run test:package` prüft eine echte Installation in einem temporären Consumer-Projekt und gibt dessen Pfad aus. `demo/dist/` enthält nach `build:demo` die statisch hostbare Demo.

## Installation

```sh
npm install @tekocloud.de/tecexpress vue@^3.5.0
```

## Einzelimporte

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxButton, TxTextBox } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/light.css'
const name = ref('Stefan')
</script>

<template>
  <TxTextBox v-model="name" label="Name" />
  <TxButton text="Speichern" type="default" @click="console.log(name)" />
</template>
```

Optional alle Komponenten global registrieren:

```ts
import { createApp } from 'vue'
import Tecexpress from '@tekocloud.de/tecexpress'
import App from './App.vue'
import '@tekocloud.de/tecexpress/themes/index.css'
createApp(App).use(Tecexpress).mount('#app')
```

## Themes

Für ein festes Theme genau einen Import verwenden:

```ts
import '@tekocloud.de/tecexpress/themes/light.css'
// alternativ: import '@tekocloud.de/tecexpress/themes/dark.css'
```

Für Laufzeitumschaltung:

```ts
import '@tekocloud.de/tecexpress/themes/index.css'
document.documentElement.dataset.txTheme = 'dark' // oder 'light'
```

Ohne Attribut startet der gemeinsame Export im Light-Theme. `data-tx-theme` funktioniert auch auf einem umschließenden Element. Overlays bleiben in diesem Theme-Kontext. Tokens nach dem Theme-Import auf einem eigenen Container überschreiben:

```css
.my-app {
  --tx-accent: #6636c6;
  --tx-accent-text: #ffffff;
  --tx-radius: 10px;
  --tx-control-height: 44px;
}
```

Semantische Tokens: `--tx-bg`, `--tx-surface`, `--tx-surface-alt`, `--tx-text`, `--tx-muted`, `--tx-border`, `--tx-accent`, `--tx-accent-text`, `--tx-hover`, `--tx-selection`, `--tx-danger`, `--tx-success`, `--tx-focus`, `--tx-shadow`, `--tx-backdrop`. Grundlagen: `--tx-font`, `--tx-font-size`, `--tx-radius`, `--tx-space`, `--tx-control-height`. Die Bibliothek setzt kein globales Body-Layout; die Anwendung kann `background: var(--tx-bg); color: var(--tx-text)` verwenden.

## DataGrid

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxDataGrid, TxColumn, type RowKey } from '@tekocloud.de/tecexpress'
const selected = ref<RowKey[]>([])
const orders = [
  { id: 'TX-1', customer: 'Werkraum Berlin', amount: 120 },
  { id: 'TX-2', customer: 'Atelier Fischer', amount: 80 }
]
</script>

<template>
  <TxDataGrid :data-source="orders" key-expr="id" :page-size="10"
    selection="multiple" v-model:selected-row-keys="selected">
    <TxColumn data-field="customer" caption="Kunde" />
    <TxColumn data-field="amount" caption="Betrag" cell-template="money" />
    <template #money="{ value }">{{ Number(value).toFixed(2) }} €</template>
  </TxDataGrid>
</template>
```

## Scheduler

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxScheduler, type Appointment } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const appointments = ref<Appointment[]>([
  { id: 1, text: 'Projektbesprechung', startDate: '2026-10-23T09:00', endDate: '2026-10-23T10:00' }
])
</script>

<template>
  <TxScheduler v-model:data-source="appointments" current-date="2026-10-23" />
</template>
```

Tag, Woche und Monat; Termine anlegen, bearbeiten und löschen; Ganztagstermine, mehrtägige Termine und nebeneinander angeordnete Überschneidungen. Datumsnavigation ohne feste Datumsbindung: `current-date` weglassen oder `v-model:current-date` verwenden. [Scheduler-API, Datenvertrag und Grenzen](docs/scheduler.md).

## Karten und Chat

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxCard, TxCardView, TxChat, type ChatMessage } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const messages = ref<ChatMessage[]>([])
const user = { id: 'me', name: 'Stefan' }
const projects = [{ id: 1, title: 'Kundenportal', subtitle: 'In Bearbeitung' }]
</script>

<template>
  <TxCard title="Mein Projekt" subtitle="Alles im Blick">Eigener Inhalt.</TxCard>
  <TxCardView :data-source="projects" />
  <TxChat v-model:items="messages" :user="user" title="Projektchat" />
</template>
```

Karten mit frei gestaltbaren Slots; CardView mit Suche, Auswahl und Pagination. Chat mit lokalen Nachrichten, Autoren, Schreibanzeige, Zeitstempeln und Sendeereignissen für eigene APIs. Kein Backend oder KI-Dienst enthalten. [API und Beispiele](docs/cards-chat.md).

Ausführliche Props, Events, Slots und Beispiele für **jede** ausgelieferte Komponente: [API](docs/api.md). Den vollständigen ausführbaren Showcase findest du in [demo/App.vue](demo/App.vue).

## Umfang und Weiterentwicklung

- Enthalten: Button, TextBox, TextArea, NumberBox, CheckBox, Switch, SelectBox, DateBox, Popup, Tabs, Toolbar, Menu, Tooltip, Toast, LoadIndicator, DataGrid, Column, Scheduler, Card, CardView und Chat.
- DataGrid: lokale Arrays, Einspaltensortierung, kombinierte Textfilter, Pagination, Auswahl und Zell-Slots.
- Noch nicht enthalten: DataGrid-Bearbeitung, Remote-Stores, Virtualisierung, Charts, Form, Scheduler-Wiederholungen/Ressourcen/Drag-and-drop und die übrigen Komponenten der langfristigen Suite.
- DevExtreme-ähnliche Namen erleichtern den Einstieg; tecexpress ist kein unveränderter Ersatz. Eigene Gestaltung und Implementierung, keine DevExtreme-Laufzeitabhängigkeit, kein Instanzobjekt oder `option()`-API.

[Versionierter Komponenten-Katalog und Entwicklungsphasen](docs/catalog-26.1.md) · [Änderungen](docs/CHANGELOG.md) · [MIT-Lizenz](LICENSE)
