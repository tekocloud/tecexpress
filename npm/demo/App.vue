<script setup lang="ts">
import Extensions from './Extensions.vue'
import { ref, watch } from 'vue'
import { TxButton, TxTextBox, TxTextArea, TxNumberBox, TxCheckBox, TxSwitch, TxSelectBox, TxDateBox, TxTabs, TxToolbar, TxMenu, TxPopup, TxTooltip, TxToast, TxLoadIndicator, TxDataGrid, TxColumn, TxScheduler, TxCard, TxCardView, TxChat, type RowKey, type DataRow, type Appointment, type SchedulerView, type ChatMessage } from '@tekocloud.de/tecexpress'

const theme = ref(localStorage.getItem('tx-demo-theme') === 'dark' ? 'dark' : 'light')
watch(theme, value => { document.documentElement.dataset.txTheme = value; localStorage.setItem('tx-demo-theme', value) }, { immediate: true })
const name = ref('Stefan Bess'), notes = ref('Lieferung bitte am Vormittag.'), quantity = ref(12), newsletter = ref(true), enabled = ref(true), category = ref('technik'), date = ref('2026-10-23')
const popup = ref(false), toast = ref(false), tab = ref(0), loading = ref(false), selected = ref<RowKey[]>([]), lastAction = ref('Bereit')
const selectedCards = ref<RowKey[]>([]), chatReadOnly = ref(false), chatTyping = ref(false)
const chatUser = { id: 'stefan', name: 'Stefan Bess' }, colleague = { id: 'lena', name: 'Lena Fischer' }
const messages = ref<ChatMessage[]>([
  { id: 'welcome', text: 'Hallo Stefan! Die neuen Karten sind bereit für den Review.', timestamp: '2026-10-23T09:00:00', author: colleague },
  { id: 'reply', text: 'Sehr gut. Die Projektübersicht sieht schon übersichtlich aus. 👋', timestamp: '2026-10-23T09:02:00', author: chatUser, status: 'sent' },
  { id: 'note', text: 'Du kannst Karten durchsuchen und auswählen. Im Chat funktioniert Enter zum Senden, Shift+Enter für eine neue Zeile.', timestamp: '2026-10-23T09:03:00', author: colleague }
])
const projects: DataRow[] = [
  { id: 'portal', title: 'Kundenportal', subtitle: 'Ein Ort für alles Wichtige.', team: 'Produkt & Design', status: 'In Bearbeitung', progress: '68 %', mark: 'KP', tone: 'blue' },
  { id: 'workspace', title: 'Team Workspace', subtitle: 'Zusammen wird aus Ideen mehr.', team: 'Entwicklung', status: 'Review', progress: '92 %', mark: 'TW', tone: 'green' },
  { id: 'brand', title: 'Brand Studio', subtitle: 'Eine klare visuelle Sprache.', team: 'Kreation', status: 'Geplant', progress: '24 %', mark: 'BS', tone: 'purple' },
  { id: 'analytics', title: 'Analytics Hub', subtitle: 'Aus Zahlen werden Entscheidungen.', team: 'Data & Insights', status: 'In Bearbeitung', progress: '45 %', mark: 'AH', tone: 'blue' },
  { id: 'shop', title: 'Commerce', subtitle: 'Einfacher einkaufen.', team: 'Produkt & Design', status: 'Geplant', progress: '15 %', mark: 'CO', tone: 'green' },
  { id: 'mobile', title: 'Mobile App', subtitle: 'Dein Workspace für unterwegs.', team: 'Entwicklung', status: 'Review', progress: '85 %', mark: 'MA', tone: 'purple' }
]
function addDemoReply() {
  messages.value = [...messages.value, { id: `demo-${Date.now()}`, text: 'Das ist eine lokal eingefügte Beispielnachricht. Es ist kein Server oder KI-Dienst angebunden.', timestamp: new Date(), author: colleague }]
}
const schedulerDate = ref<Date | string>('2026-10-23'), schedulerView = ref<SchedulerView>('week'), schedulerReadOnly = ref(false)
const appointments = ref<Appointment[]>([
  { id: 'team', text: 'Wochenplanung', startDate: '2026-10-19T09:00', endDate: '2026-10-19T10:00', description: 'Prioritäten und Aufgaben für die neue Woche.' },
  { id: 'design', text: 'Design-Workshop', startDate: '2026-10-20T10:00', endDate: '2026-10-20T12:00' },
  { id: 'delivery', text: 'Vorbereitung & Lieferung', startDate: '2026-10-21T16:00', endDate: '2026-10-22T10:00' },
  { id: 'release', text: 'Release-Tag', startDate: '2026-10-22', endDate: '2026-10-23', allDay: true },
  { id: 'review', text: 'Projektbesprechung', startDate: '2026-10-23T09:00', endDate: '2026-10-23T10:30', description: 'Fortschritt und nächste Schritte besprechen.' },
  { id: 'customer', text: 'Kundengespräch', startDate: '2026-10-23T09:30', endDate: '2026-10-23T11:00' },
  { id: 'focus', text: 'Fokuszeit', startDate: '2026-10-23T14:00', endDate: '2026-10-23T16:00' }
])
const rows: DataRow[] = Array.from({ length: 24 }, (_, index) => ({
  id: `TX-${2401 + index}`, customer: ['Nordlicht Studio', 'Bergwerk Digital', 'Atelier Fischer', 'Werkraum Berlin', 'Morgenrot GmbH', 'Studio Elbe'][index % 6],
  city: ['Hamburg', 'München', 'Köln', 'Berlin', 'Leipzig', 'Dresden'][index % 6],
  amount: [1280, 2450, 680, 3690, 945, 1820][index % 6] + index * 10,
  status: ['Abgeschlossen', 'In Bearbeitung', 'Offen'][index % 3], date: `2026-10-${String(23 - index % 20).padStart(2, '0')}`
}))
const money = (value: unknown) => new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(Number(value))
function notify(message: string) { lastAction.value = message; toast.value = true }
</script>

<template>
  <div class="demo-shell">
    <aside class="sidebar">
      <a class="brand" href="#overview"><span class="brand-symbol">t<span>×</span></span>tecexpress<span class="version">0.5</span></a>
      <div class="sidebar-label">COMPONENT WORKSPACE</div>
      <nav class="sidebar-nav" aria-label="Bereiche">
        <a href="#overview"><span>◈</span> Übersicht</a>
        <a href="#orders"><span>▦</span> DataGrid <small>01</small></a>
        <a href="#scheduler"><span>▤</span> Scheduler <small>NEU</small></a>
        <a href="#cards"><span>▱</span> Cards <small>NEU</small></a>
        <a href="#chat"><span>☷</span> Chat <small>NEU</small></a>
        <a href="#extensions"><span>＋</span> Erweiterungen <small>NEU</small></a>
        <a href="#editors"><span>☷</span> Eingaben <small>08</small></a>
        <a href="#interface"><span>▱</span> Oberfläche <small>07</small></a>
        <a href="#states"><span>◉</span> Zustände</a>
      </nav>
      <div class="sidebar-note"><span class="online-dot"></span> Eigenständig. Offen. Vue 3.<p>Deine Oberfläche.<br>Deine Komponenten.</p><span class="license-badge">MIT LICENSE ↗</span></div>
      <div class="sidebar-footer">CRAFTED WITH TECEXPRESS</div>
    </aside>

    <div class="demo-workspace">
      <header class="topbar"><span>Workspace <span class="breadcrumb">/</span> Komponenten</span><div class="topbar-actions"><span class="release">● &nbsp;v0.5.0</span><TxButton :text="theme === 'light' ? '☾ Dark' : '☀ Light'" aria-label="Theme wechseln" @click="theme = theme === 'light' ? 'dark' : 'light'" /></div></header>
      <main>
        <section id="overview" class="intro"><div><div class="eyebrow">TECEXPRESS / VUE COMPONENT LIBRARY</div><h1>Gute Oberflächen.<br><span>Von Grund auf.</span></h1><p>Eine klare Basis für deine nächste Anwendung. Reaktive Vue-Komponenten, durchdachte Details und zwei Themes, die zusammengehören.</p><div class="intro-badges"><span>Vue 3 + TypeScript</span><span>Light & Dark</span><span>Ohne Lizenzkey</span></div></div><div class="intro-code"><div class="code-dots"><i></i><i></i><i></i><span>deine-anwendung.vue</span></div><pre><span class="code-purple">import</span> { TxButton }<br>  <span class="code-purple">from</span> <span class="code-green">'@tekocloud.de/tecexpress'</span><br><br>&lt;<span class="code-blue">TxButton</span><br>  text=<span class="code-green">"Los geht’s"</span><br>  type=<span class="code-green">"default"</span><br>/&gt;</pre><div class="code-footer"><span class="online-dot"></span> Bereit für dein Projekt</div></div></section>

        <div class="stats"><div><span class="stat-icon">▦</span><div><strong>37</strong><span>Komponenten & Konfiguration</span></div></div><div><span class="stat-icon">◐</span><div><strong>2 Themes</strong><span>Ein konsistentes Designsystem</span></div></div><div><span class="stat-icon">⌘</span><div><strong>TypeScript</strong><span>Typisiert bis zur öffentlichen API</span></div></div></div>

        <section id="orders" class="demo-section"><div class="section-heading"><div><div class="eyebrow">01 / DATEN & INTERAKTION</div><h2>Ordnung für deine Daten.</h2><p>Sortieren, filtern und auswählen. Direkt in der Tabelle ausprobieren.</p></div><span class="component-tag">TxDataGrid</span></div>
          <div class="panel"><TxToolbar class="orders-toolbar"><div><h3>Auftragsübersicht <span class="count-badge">24</span></h3><p>Alle Aufträge auf einen Blick</p></div><template #after><TxSwitch v-model="loading" label="Ladezustand"/><TxButton text="＋ Neuer Auftrag" type="default" @click="popup = true"/></template></TxToolbar>
            <TxDataGrid :data-source="rows" key-expr="id" :page-size="5" selection="multiple" v-model:selected-row-keys="selected" :loading="loading" label="Aufträge" @row-click="notify(`Auftrag ${$event.key} geöffnet`)">
              <TxColumn data-field="id" caption="Auftrag" :width="130" />
              <TxColumn data-field="customer" caption="Kunde" />
              <TxColumn data-field="city" caption="Standort" />
              <TxColumn data-field="amount" caption="Betrag" alignment="right" cell-template="amount" />
              <TxColumn data-field="status" caption="Status" cell-template="status" />
              <template #amount="{ value }"><strong>{{ money(value) }}</strong></template>
              <template #status="{ value }"><span :class="['status-pill', value === 'Abgeschlossen' ? 'status-success' : value === 'Offen' ? 'status-open' : 'status-progress']"><i></i>{{ value }}</span></template>
            </TxDataGrid>
          </div>
        </section>

        <section id="scheduler" class="demo-section"><div class="section-heading"><div><div class="eyebrow">02 / ZEIT & PLANUNG</div><h2>Platz für deine nächsten Schritte.</h2><p>Deine Woche im Blick. Termine anlegen, bearbeiten und zusammen planen.</p></div><span class="component-tag">TxScheduler · NEU</span></div>
          <div class="scheduler-demo-options"><span>Tag, Woche oder Monat. Wähle einen Termin oder ein freies Zeitfenster.</span><TxSwitch v-model="schedulerReadOnly" label="Nur lesen"/></div>
          <TxScheduler v-model:data-source="appointments" v-model:current-date="schedulerDate" v-model:current-view="schedulerView" :read-only="schedulerReadOnly" label="Teamkalender" @appointment-added="notify(`Termin „${$event.appointmentData.text}“ angelegt`)" @appointment-updated="notify('Termin aktualisiert')" @appointment-deleted="notify('Termin gelöscht')"/>
          <p class="action-log">{{ appointments.length }} Termine · Änderungen bleiben bis zum Neuladen in dieser Demo erhalten.</p>
        </section>

        <section id="cards" class="demo-section"><div class="section-heading"><div><div class="eyebrow">03 / KARTEN & PROJEKTE</div><h2>Eine Karte. Viele Möglichkeiten.</h2><p>Informationen mit Raum zum Atmen. Als einzelne Karte oder als durchsuchbare Übersicht.</p></div><span class="component-tag">TxCard + TxCardView</span></div>
          <div class="card-demo-intro"><TxCard title="Dein nächstes Projekt" subtitle="Ein guter Anfang braucht eine klare Basis." variant="filled"><p>Header, Inhalt, Medien und Aktionen lassen sich über Slots frei gestalten.</p><template #footer><span class="component-tag">TxCard</span><TxButton text="Mehr entdecken →" @click="notify('Die Karte ist frei mit deinen Inhalten kombinierbar.')"/></template></TxCard><TxCard title="Bereit für dein Team" subtitle="Gestaltet für echte Anwendungen."><div class="card-feature-list"><span>✓ Responsive Kartenraster</span><span>✓ Suche und Auswahl</span><span>✓ Light- und Dark-Theme</span></div><template #footer><span class="status-pill status-success">{{ selectedCards.length }} Projekte ausgewählt</span><span class="component-tag">v-model ready</span></template></TxCard></div>
          <TxCardView :data-source="projects" :columns="[{ dataField: 'team', caption: 'Team' }, { dataField: 'status', caption: 'Status' }, { dataField: 'progress', caption: 'Fortschritt' }]" :page-size="3" selection="multiple" v-model:selected-card-keys="selectedCards" label="Projektkarten" @card-click="notify(`Projekt „${$event.data.title}“ geöffnet`)">
            <template #media="{ data }"><div :class="['project-preview', `project-preview-${data.tone}`]"><span class="project-preview-mark">{{ data.mark }}</span><div class="project-preview-lines"><i></i><i></i><i></i></div><span class="project-preview-label">TECEXPRESS / PROJECT</span></div></template>
          </TxCardView>
        </section>

        <section id="chat" class="demo-section"><div class="section-heading"><div><div class="eyebrow">04 / NACHRICHTEN & AUSTAUSCH</div><h2>Im Gespräch bleiben.</h2><p>Ein Chat für deine Anwendung. Mit deinem Team, deinem Backend und deinen Ideen.</p></div><span class="component-tag">TxChat</span></div>
          <div class="chat-demo-layout"><TxChat v-model:items="messages" :user="chatUser" title="Projektchat" subtitle="Kundenportal · Produkt & Design" label="Projektchat" :read-only="chatReadOnly" :typing-users="chatTyping ? [colleague] : []"/>
            <div class="chat-demo-notes"><TxCard title="Deine Verbindung nach außen" subtitle="Die Oberfläche steht. Du bestimmst, was dahinter passiert." variant="filled"><p>Neue Nachrichten landen im Vue-Modell. Über <code>messageEntered</code> kannst du deine eigene API anbinden.</p><div class="chat-demo-controls"><TxSwitch v-model="chatReadOnly" label="Chat nur lesen"/><TxSwitch v-model="chatTyping" label="Schreibanzeige simulieren"/><TxButton text="Beispielantwort einfügen" @click="addDemoReply"/></div><template #footer><span class="component-tag">Lokale Demo · kein Backend</span></template></TxCard><p class="action-log">{{ messages.length }} Nachrichten · Die Demo wird beim Neuladen zurückgesetzt.</p></div>
          </div>
        </section>

        <section id="editors" class="demo-section"><div class="section-heading"><div><div class="eyebrow">05 / EINGABEN</div><h2>Alles beginnt mit einer Eingabe.</h2><p>Native Bedienelemente. Reaktive Werte. Eine gemeinsame Formensprache.</p></div><span class="component-tag">v-model ready</span></div>
          <div class="panel editor-panel"><div class="input-grid"><TxTextBox v-model="name" label="Name" placeholder="Vor- und Nachname"/><TxSelectBox v-model="category" label="Kategorie" :items="[{ value: 'technik', text: 'Technik & Zubehör' }, { value: 'design', text: 'Design & Gestaltung' }]"/><TxNumberBox v-model="quantity" label="Stückzahl" :min="1" :max="100"/><TxDateBox v-model="date" label="Lieferdatum"/><TxTextArea v-model="notes" label="Notiz zur Bestellung" class="wide-field"/><div class="toggle-stack"><TxCheckBox v-model="newsletter" label="Updates per E-Mail erhalten"/><TxSwitch v-model="enabled" label="Benachrichtigungen aktiv"/></div></div><div class="editor-footer"><code>{{ name }} · {{ quantity }} Stück · {{ date }}</code><TxButton text="Änderungen speichern" type="default" @click="notify('Änderungen wurden gespeichert.')"/></div></div>
        </section>

        <section id="interface" class="demo-section"><div class="section-heading"><div><div class="eyebrow">06 / OBERFLÄCHE</div><h2>Kleine Details. Klare Interaktion.</h2><p>Navigation, Rückmeldungen und Dialoge aus einem Guss.</p></div></div>
          <div class="showcase-grid"><div class="panel sample-panel"><div class="sample-label">BUTTONS</div><div class="button-row"><TxButton text="Primär" type="default" @click="notify('Primäre Aktion')"/><TxButton text="Standard" @click="notify('Standardaktion')"/><TxButton text="Erfolg" type="success" @click="notify('Erfolg')"/><TxButton text="Löschen" type="danger" @click="notify('Löschaktion ausgelöst')"/><TxButton text="Deaktiviert" disabled/></div><div class="sample-label">TOOLTIP & LADEANZEIGE</div><div class="button-row"><TxTooltip text="Deine Daten werden nur lokal in dieser Demo verwendet."><TxButton text="ⓘ Gut zu wissen"/></TxTooltip><TxLoadIndicator label="Daten werden geladen"/></div></div>
          <div class="panel sample-panel"><div class="sample-label">TABS & MENU</div><TxTabs v-model="tab" :items="['Übersicht', 'Details', { text: 'Archiv', disabled: true }]"><template #default="{ selectedIndex }"><p class="tab-copy">{{ selectedIndex === 0 ? 'Ein guter Überblick macht den Unterschied.' : 'Hier finden deine Details ihren Platz.' }}</p></template></TxTabs><TxMenu :items="['Datei', 'Bearbeiten', { text: 'Exportieren', disabled: true }]" @item-click="notify(`Menü: ${typeof $event.itemData === 'string' ? $event.itemData : $event.itemData.text}`)"/></div></div>
        </section>

        <section id="states" class="demo-section"><div class="section-heading"><div><div class="eyebrow">07 / ZUSTÄNDE & FEEDBACK</div><h2>Auch die Details sind dabei.</h2></div></div><div class="panel sample-panel state-grid"><TxTextBox label="Deaktiviert" value="Nicht bearbeitbar" disabled/><TxTextBox label="Nur lesen" value="TX-2026-001" read-only/><TxTextBox label="Fehlerzustand" value="ungueltig" :is-valid="false" validation-message="Bitte eine gültige E-Mail eingeben."/><div class="feedback-actions"><TxButton text="Dialog öffnen" @click="popup = true"/><TxButton text="Toast anzeigen" @click="notify('Alles erledigt. Deine Änderungen sind gespeichert.')"/></div></div><p class="action-log" role="status">Letzte Aktion: {{ lastAction }}</p></section>
        <Extensions/>
        <footer class="page-footer"><span>tecexpress <strong>·</strong> Ein Anfang mit System.</span><span>Vue 3 / MIT / v0.5.0</span></footer>
      </main>
    </div>
    <TxPopup v-model:visible="popup" title="Neuen Auftrag vorbereiten" hide-on-outside-click><p>Die Komponenten sind bereit für deinen Workflow. Diese Demo speichert keine Aufträge.</p><TxTextBox label="Kundenname" v-model="name"/><template #footer><TxButton text="Abbrechen" @click="popup = false"/><TxButton text="Bestätigen" type="default" @click="popup = false; notify('Auftrag vorbereitet.')"/></template></TxPopup>
    <TxToast v-model:visible="toast" :message="lastAction" type="success"/>
  </div>
</template>
