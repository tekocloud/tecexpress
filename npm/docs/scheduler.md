# TxScheduler · Spezifikation und API · 0.2.0

Eigenständiger lokaler Kalender für Vue 3. Öffentliche Namen orientieren sich an der [Scheduler-Konfiguration](https://js.devexpress.com/Vue/Documentation/ApiReference/UI_Components/dxScheduler/Configuration/); keine DevExtreme-Implementierung oder Assets werden verwendet.

## Umfang und Datenvertrag

- Tages-, Wochen- und Monatsansicht, Heute-/Vor-/Zurück-Navigation und Datumswahl. Woche beginnt standardmäßig montags.
- Lokale Termine mit stabilen IDs, Titel, Beginn, exklusivem Ende, optionaler Beschreibung und `allDay`. Zeitlich überlappende Termine erscheinen nebeneinander; mehrtägige Termine werden pro betroffenem Tag dargestellt. Ganztagstermine haben eine eigene Zeile.
- Anlegen über freie Zeitzelle oder „Neuer Termin“, Bearbeiten per Terminbutton und Löschen im Dialog. Native Tastaturbedienung, Pfeilnavigation in den Zeitzellen, Fokusführung über `TxPopup`, beide bestehenden Themes.
- Keine Wiederholungsregeln, Ressourcen, Remote-Stores, Drag-and-drop oder explizite IANA-Zeitzonen in dieser Version. Die Darstellung verwendet die lokale Zeitzone des Browsers. Serverseitiges Speichern übernimmt die Anwendung.

```ts
type SchedulerView = 'day' | 'week' | 'month'
type SchedulerDate = Date | string
interface Appointment {
  id: string | number
  text: string
  startDate: SchedulerDate
  endDate: SchedulerDate
  allDay?: boolean
  description?: string
}
```

`YYYY-MM-DD` und lokale ISO-Datumszeiten werden als lokale Kalenderwerte gelesen; ISO-Zeitstempel mit Offset/Z als Zeitpunkt. Bearbeitete Termine liefern neue `Date`-Objekte. Eingabedaten werden nie mutiert. Für Ganztagstermine liegen Anfang und Ende auf lokalem Tagesbeginn; das Ende ist exklusiv (23.–24. Oktober bedeutet genau den 23.). Ungültige Daten, doppelte IDs und Ende ≤ Beginn werden mit erklärendem Fehler zurückgewiesen. Sommerzeit: Kalendertage werden mit Kalenderarithmetik statt festen 24-Stunden-Abständen berechnet. Nicht existierende lokale Zeiten werden im Formular abgewiesen; mehrdeutige Zeiten folgen der nativen Date-Auflösung des Browsers.

## Props

| Prop | Standard / Verhalten |
| --- | --- |
| `dataSource` | Optional `Appointment[]`; `v-model:data-source` übernimmt Änderungen. Ohne Prop interne Liste. Mit einfachem `:data-source` muss der Parent `update:dataSource` selbst übernehmen. |
| `currentDate` | Optional `Date \| string`; sonst lokales Heute. `v-model:current-date` möglich; Updates liefern `Date`. |
| `currentView` | Optional `'day' \| 'week' \| 'month'`; sonst Woche, falls aktiviert, andernfalls erste aktivierte Ansicht. `v-model:current-view` möglich. |
| `views` | `['day', 'week', 'month']`; nicht leer, nur diese Werte. |
| `firstDayOfWeek` | `1`; ganze Zahl 0 (Sonntag) bis 6 (Samstag). |
| `startDayHour`, `endDayHour` | `8`, `18`; ganze Stunden, `0 ≤ start < end ≤ 24`. Begrenzen die sichtbare Zeitachse, nicht gespeicherte Termine. |
| `cellDuration` | `30`; `15`, `30` oder `60` Minuten. |
| `editing` | `true`; Boolean oder `{ allowAdding?: boolean; allowUpdating?: boolean; allowDeleting?: boolean }`, fehlende Flags sind `true`. |
| `readOnly`, `disabled`, `loading` | `false`; Read-only erlaubt Navigation und Terminansicht, sperrt Änderungen. Disabled sperrt zusätzlich Navigation. Loading sperrt Aktionen und zeigt Ladehinweis. |
| `locale`, `label` | `'de-DE'`, `'Terminplaner'`; Datums-/Zeitformatierung und zugänglicher Bereichsname. Bedientexte bleiben deutsch. |

## Events und Slots

- `update:dataSource(appointments)`, `update:currentDate(date)`, `update:currentView(view)`.
- `appointmentClick({ appointmentData, event })` und `cellClick({ startDate, endDate, allDay, event })` beim Aktivieren der jeweiligen Buttons.
- `appointmentAdding({ appointmentData, cancel })`, `appointmentUpdating({ oldData, newData, cancel })`, `appointmentDeleting({ appointmentData, cancel })` vor Änderungen. Synchrones Setzen von `event.cancel = true` verhindert die Änderung und lässt den Dialog offen. Keine Promise-Cancellation.
- `appointmentAdded({ appointmentData })`, `appointmentUpdated({ oldData, newData })`, `appointmentDeleted({ appointmentData })` nach Ausgabe des neuen Arrays. Bei kontrollierten Daten bestätigt das den Änderungsvorschlag, nicht eine serverseitige Speicherung.
- Slot `appointment({ appointmentData, startDate, endDate, view })` ersetzt den Inhalt eines Terminbuttons, nicht den Button selbst. Slot-Inhalte sollten keine verschachtelten interaktiven Elemente enthalten.

Externe Datenänderungen während eines geöffneten Bearbeitungsdialogs werden vor dem Speichern geprüft. Wurde der Termin geändert oder entfernt, bleibt das Formular mit einer Konfliktmeldung offen. Schließen und erneut öffnen lädt den aktuellen Stand.

## Verwendung

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxScheduler, type Appointment } from 'tecexpress'
import 'tecexpress/themes/index.css'
const appointments = ref<Appointment[]>([
  { id: 1, text: 'Projektbesprechung', startDate: '2026-10-23T09:00', endDate: '2026-10-23T10:00' }
])
const currentDate = ref<Date | string>('2026-10-23')
</script>

<template>
  <TxScheduler v-model:data-source="appointments" v-model:current-date="currentDate"
    :start-day-hour="8" :end-day-hour="18" />
</template>
```

## Abnahme

Navigation über Monats-/Jahresgrenzen; Montag-/Sonntag-Wochenstart; Februar/Schaltjahr; Monatsraster; überschneidende, ganztägige und mehrtägige Termine; exklusive Tagesgrenzen; Datumseingaben und Sommerzeit; kontrollierte/unkontrollierte Daten; CRUD einschließlich Validierung, Cancellation und Konflikten; Editierrechte und deaktivierte Zustände; Tastatur und Popup-Fokus; Desktop/Mobil in Light und Dark; öffentliche Paketexporte und SSR prüfen.
