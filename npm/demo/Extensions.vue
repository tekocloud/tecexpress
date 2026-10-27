<script setup lang="ts">
import { onBeforeUnmount, ref } from 'vue'
import {
  TxRadioGroup,
  TxButtonGroup,
  TxTagBox,
  TxLookup,
  TxRangeSlider,
  TxRangeSelector,
  TxTabPanel,
  TxList,
  TxGallery,
  TxContextMenu,
  TxActionSheet,
  TxFloatingActionButton,
  TxFileManager,
  TxFileUploader,
  TxMap,
  TxLoadPanel,
  TxPopup,
  TxTooltip,
  TxToast,
  TxDataSource,
  TxCustomStore,
  TxMemoryFileProvider,
  TxDataGrid,
  TxSelectBox,
  notify,
  txQuery,
  type TxEntry,
  type TxRangeValue,
} from '@tekocloud.de/tecexpress'
const entries = [
  { id: 'design', text: 'Design', group: 'Produkt' },
  { id: 'development', text: 'Entwicklung', group: 'Produkt' },
  { id: 'sales', text: 'Vertrieb', group: 'Geschäft' },
  { id: 'archive', text: 'Archiv', disabled: true },
]
const shared = new TxDataSource<TxEntry>({
  store: entries,
  key: 'id',
  paginate: false,
})
const remote = new TxDataSource<TxEntry>({
  store: new TxCustomStore({
    load: async (options) => {
      await new Promise<void>((resolve, reject) => {
        const timer = setTimeout(resolve, 250)
        options.signal?.addEventListener(
          'abort',
          () => {
            clearTimeout(timer)
            reject(new DOMException('Aborted', 'AbortError'))
          },
          { once: true },
        )
      })
      return txQuery(entries, options)
    },
    byKey: (key) => entries.find((v) => v.id === key),
  }),
  key: 'id',
  pageSize: 2,
})
const choice = ref<string | null>('design'),
  tags = ref<unknown[]>(['design']),
  buttons = ref<unknown[]>([]),
  range = ref<[TxRangeValue, TxRangeValue]>([20, 70]),
  sheet = ref(false),
  popup = ref(false),
  toast = ref(false),
  tab = ref(0),
  tileUrl = ref('')
const provider = new TxMemoryFileProvider([
  { id: 'docs', parentId: null, name: 'Dokumente', isDirectory: true },
  {
    id: 'welcome',
    parentId: 'docs',
    name: 'Willkommen.txt',
    isDirectory: false,
    size: 15,
    content: new Blob(['Hallo tecexpress']),
  },
])
const points = Array.from({ length: 21 }, (_, i) => ({
  argument: i * 5,
  value: 30 + Math.sin(i / 2) * 20,
}))
const pictures = ['#347a90', '#855ac4', '#41975e'].map((color, i) => ({
  id: i,
  text: `Motiv ${i + 1}`,
  imageUrl: `data:image/svg+xml,${encodeURIComponent(`<svg xmlns="http://www.w3.org/2000/svg" width="600" height="220"><rect width="600" height="220" fill="${color}"/><text x="50%" y="50%" text-anchor="middle" fill="white" font-size="36">Motiv ${i + 1}</text></svg>`)}`,
}))
const actions = [
  { id: 'new', text: 'Neu erstellen', icon: '+' },
  {
    id: 'more',
    text: 'Weitere Aktionen',
    items: [
      { id: 'save', text: 'Speichern' },
      { id: 'delete', text: 'Löschen', destructive: true },
    ],
  },
]
onBeforeUnmount(() => {
  shared.dispose()
  remote.dispose()
})
</script>
<template>
  <section id="extensions" class="demo-section">
    <div class="section-heading">
      <div>
        <div class="eyebrow">08 / KOMPONENTEN & DATEN</div>
        <h2>Ein Datenmodell. Viele Möglichkeiten.</h2>
        <p>
          Gemeinsame DataSources, konfigurierbare Stores und neue
          Bedienelemente.
        </p>
      </div>
    </div>
    <div class="input-grid">
      <article class="panel sample-panel">
        <h3>RadioGroup und ButtonGroup</h3>
        <TxRadioGroup
          v-model="choice"
          :data-source="shared"
          label="Bereich"
        /><TxButtonGroup
          v-model="buttons"
          :items="entries"
          selection-mode="multiple"
        />
        <p>Auswahl: {{ choice }}</p>
        <TxSelectBox
          v-model="choice"
          :data-source="shared"
          value-expr="id"
          label="Dieselbe DataSource"
        />
      </article>
      <article class="panel sample-panel">
        <h3>TagBox und Lookup</h3>
        <TxTagBox
          v-model="tags"
          :data-source="shared"
          show-selection-controls
          accept-custom-value
          apply-value-mode="useButtons"
        /><TxLookup
          v-model="choice"
          :data-source="remote"
          label="Remote-Suche (simulierter Store)"
        />
      </article>
      <article class="panel sample-panel">
        <h3>RangeSlider und RangeSelector</h3>
        <TxRangeSlider
          v-model="range"
          :min-range="5"
          :step="5"
        /><TxRangeSelector v-model="range" :data-source="points" :step="5" />
      </article>
      <article class="panel sample-panel">
        <h3>TabPanel und List</h3>
        <TxTabPanel
          v-model="tab"
          :items="['Datenübersicht', 'Datendetails']"
          swipe-enabled
          ><template #default="{ selectedIndex }"
            ><p>Inhalt {{ selectedIndex + 1 }}</p></template
          ></TxTabPanel
        ><TxList
          grouped
          :data-source="shared"
          search-enabled
          selection-mode="multiple"
          :height="180"
        />
      </article>
      <article class="panel sample-panel">
        <h3>Gallery und ContextMenu</h3>
        <TxContextMenu
          :items="actions"
          @item-click="notify($event.itemData.text)"
          ><TxGallery :items="pictures" loop :height="170" />
          <p>Rechtsklick oder lang drücken für Aktionen.</p></TxContextMenu
        ><button class="tx-button" @click="sheet = true">
          ActionSheet öffnen
        </button>
      </article>
      <article class="panel sample-panel">
        <h3>Popup, Toast, Tooltip und notify</h3>
        <div class="tx-choice">
          <button class="tx-button" @click="popup = true">
            Verschiebbarer Dialog</button
          ><button class="tx-button" @click="toast = true">Toast</button
          ><TxTooltip text="Auch per Tastatur erreichbar" :show-delay="200"
            ><button class="tx-button">Tooltip</button></TxTooltip
          ><button
            class="tx-button"
            @click="notify({ message: 'Gespeichert', type: 'success' })"
          >
            notify()
          </button>
        </div>
        <div style="position: relative; min-height: 120px">
          <p>Ladezustand des entfernten Stores</p>
          <button class="tx-button" @click="remote.reload().catch(() => {})">
            Neu laden</button
          ><TxLoadPanel :data-source="remote" />
        </div>
      </article>
    </div>
    <article class="panel sample-panel">
      <h3>File Manager</h3>
      <TxFileManager :provider="provider" />
    </article>
    <article class="panel sample-panel">
      <h3>File Uploader</h3>
      <TxFileUploader
        multiple
        :max-file-size="10000000"
        :adapter="
          async (file, context) => {
            const result = await provider.upload(null, file, context.signal)
            context.onProgress(file.size, file.size)
            return result
          }
        "
      />
      <p>Die Dateien werden im Speicher des Beispiels abgelegt.</p>
    </article>
    <article class="panel sample-panel">
      <h3>Map</h3>
      <label
        >Kachel-URL
        <input
          class="tx-control"
          v-model="tileUrl"
          placeholder="https://…/{z}/{x}/{y}.png" /></label
      ><TxMap
        :tile-url="tileUrl || undefined"
        :markers="[
          { id: 'berlin', lat: 52.52, lng: 13.405, text: 'Berlin' },
          { id: 'hamburg', lat: 53.55, lng: 10, text: 'Hamburg' },
        ]"
        :routes="[
          {
            id: 'route',
            points: [
              { lat: 52.52, lng: 13.405 },
              { lat: 53.55, lng: 10 },
            ],
          },
        ]"
      />
    </article>
    <article class="panel sample-panel">
      <h3>DataSource-Konfiguration im DataGrid</h3>
      <TxDataGrid
        :data-source="{ store: entries, key: 'id', pageSize: 2 }"
        :columns="[
          { dataField: 'text', caption: 'Team' },
          { dataField: 'group', caption: 'Gruppe' },
        ]"
        selection="multiple"
      />
    </article>
    <TxPopup
      v-model:visible="popup"
      title="Flexibler Dialog"
      drag-enabled
      resize-enabled
      hide-on-outside-click
      ><p>Am Titel verschieben und an der Ecke vergrößern.</p></TxPopup
    >
    <TxToast v-model:visible="toast" message="Beispielmeldung" type="warning" />
    <TxActionSheet
      v-model:visible="sheet"
      title="Aktion wählen"
      :items="actions"
      @item-click="notify($event.itemData.text)"
    />
    <TxFloatingActionButton
      :items="[
        { id: 'help', text: 'Hilfe' },
        { id: 'create', text: 'Neu erstellen' },
      ]"
      @item-click="notify($event.itemData.text)"
    />
  </section>
</template>
