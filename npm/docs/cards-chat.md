# Karten und Chat · Spezifikation und API · 0.3.0

Eigenständige Vue-Komponenten, orientiert an den öffentlichen Bereichen [CardView](https://js.devexpress.com/Vue/Documentation/ApiReference/UI_Components/dxCardView/Configuration/) und [Chat](https://js.devexpress.com/Vue/Documentation/ApiReference/UI_Components/dxChat/Configuration/). Keine DevExtreme-Implementierung oder Assets übernommen.

## TxCard

Präsentationskomponente mit `title`, `subtitle`, `imageUrl`, `imageAlt=''`, `variant='outlined'` (`outlined | elevated | filled`) und `loading=false`. Semantisches `article`, beschriftet durch den Titel; ohne Titel über `aria-label` beschriften. Slots `header`, `media`, Default-Inhalt, `actions` und `footer`. Header und Media ersetzen jeweils den Standardinhalt. Ladezustand ersetzt den Body durch einen zugänglichen Ladehinweis. Die Karte selbst ist kein Button; Aktionen sind eigenständige Bedienelemente im Slot.

## TxCardView

Lokales responsives Kartenraster mit Suche, Pagination, Auswahl und Vorlagen. `dataSource: DataRow[]=[]`, `keyExpr='id'`, `titleExpr='title'`, `subtitleExpr='subtitle'`, `imageExpr='imageUrl'`, `imageAltExpr='imageAlt'`. IDs sind eindeutige Strings oder endliche Zahlen; fehlende/doppelte IDs werfen einen erklärenden Fehler. Feldpfade unterstützen Punktnotation.

- `columns: CardField[]=[]`, wobei `CardField = { dataField: string; caption?: string }`. Standarddarstellung als Beschreibungslisten, keine verschachtelten Konfigurationskomponenten.
- `searchEnabled=true`, `searchExpr?: string | string[]`; ohne Angabe Titel, Untertitel und konfigurierte Spalten. Textsuche ignoriert Groß-/Kleinschreibung und kombiniert die Suchfelder mit ODER.
- `pageSize=6` (mindestens 1; nicht endliche Werte fallen auf 6), `pageIndex?` mit `v-model:page-index`; sonst intern. Suche und Seitengröße setzen auf Seite 0 zurück, schrumpfende Ergebnisse begrenzen die Seite.
- `selection='none'` (`none | single | multiple`), `selectedCardKeys?` mit `v-model:selected-card-keys`; sonst intern. Auswahl per Checkbox, bleibt über Suche und Seiten erhalten; entfernte Datensätze werden bereinigt.
- `loading=false`, `disabled=false`, `noDataText='Keine Karten vorhanden.'`, `label='Kartenansicht'`.
- Events: `cardClick({ data, key, index, event })` über den „Details“-Button; `selectionChanged({ selectedCardKeys, selectedCardsData })`, `update:selectedCardKeys`, `update:pageIndex`, `searchChanged(text)`.
- Slots mit `{ data, key, index, selected }`: `item` ersetzt die ganze Karte, `media` deren Medium, `content` deren Inhalt, `footer` deren Fußbereich einschließlich Details-Button. `field({ data, column, value })` formatiert einzelne Felder. `index` liegt innerhalb der gefilterten Gesamtliste. Die separate Auswahlcheckbox bleibt auch beim `item`-Slot erhalten. Eigene Slot-Aktionen muss die Anwendung bei Bedarf selbst sperren.

Kein Remote-Store, Sortier-/Filterbuilder oder eingebautes CRUD in dieser Version. Suchergebnisse behalten die Eingabereihenfolge; Daten werden nicht mutiert.

## TxChat

```ts
interface ChatUser { id: string | number; name: string; avatarUrl?: string }
interface ChatMessage {
  id: string | number
  text: string
  timestamp: Date | string
  author: ChatUser
  status?: 'pending' | 'sent' | 'error'
}
```

`user: ChatUser` ist Pflicht. Nachrichten benötigen eindeutige IDs, nichtleeren Text, einen Autor und einen gültigen ISO-Zeitstempel oder ein `Date`-Objekt. Anzeige in chronologischer Reihenfolge, bei gleichen Zeiten stabil. Eingabedaten werden nicht mutiert. Zeitstempel mit Offset/Z bezeichnen Zeitpunkte, lokale ISO-Datumszeiten die Browserzeitzone; Darstellung immer in der lokalen Browserzeitzone.

| Prop | Standard / Verhalten |
| --- | --- |
| `items` | Optional `ChatMessage[]`, `v-model:items`; ohne Prop interne Liste. Bei `:items` übernimmt der Parent `update:items`. |
| `inputFieldText` | Optionaler Entwurf mit `v-model:input-field-text`, sonst intern. |
| `title`, `subtitle`, `label` | `'Chat'`, `''`, `'Chat'` |
| `placeholder`, `emptyText` | `'Nachricht schreiben …'`, `'Noch keine Nachrichten. Starte die Unterhaltung.'` |
| `disabled`, `readOnly`, `loading`, `sending` | `false`; alle sperren Senden, Disabled zusätzlich Eingabe. Read-only zeigt den Verlauf ohne Composer, Loading zeigt Ladehinweis. Sending sperrt Senden, Entwurf bleibt editierbar. |
| `maxLength` | `4000`, positive ganze Zahl; Leer-/Whitespace-Nachrichten und längere Texte werden nicht gesendet. |
| `typingUsers` | `ChatUser[]=[]`; eigener Nutzer wird ausgeblendet. |
| `showAvatar`, `showUserName`, `showDayHeaders`, `showMessageTimestamp` | Jeweils `true`. |
| `locale` | `'de-DE'`; Datum/Zeit, Bedientexte bleiben deutsch. |

Events:

- `messageEntered({ message, cancel, event })`: synchron vor Aufnahme in die lokale Liste; `cancel=true` verhindert Aufnahme und lässt den Entwurf stehen. Keine Promise-Cancellation.
- `update:items(messages)` und anschließend `messageSent({ message })`: lokaler Änderungsvorschlag; bestätigt keine serverseitige Zustellung. Neue Nachrichten erhalten eine kollisionsgeprüfte ID, `Date`-Zeitstempel und Status `sent`.
- `update:inputFieldText(text)` bei Eingaben bzw. Leeren nach erfolgreichem lokalen Senden.
- `typingStart({ user })`, `typingEnd({ user })`: Beginn beim ersten Text, Ende nach 1,5 s Inaktivität, beim Leeren, Blur oder Senden. Timer werden beim Unmount entfernt.

Enter sendet, Shift+Enter fügt einen Zeilenumbruch ein, laufende IME-Komposition sendet nicht. Verlauf als zugängliches Log. Auto-Scroll nur, wenn zuvor am Ende; bei neuen Nachrichten während des Hochscrollens erscheint ein „Neue Nachrichten“-Button. Nach eigenem Senden wird zum Ende gescrollt. Inhalte werden als Text gerendert; kein HTML/Markdown-Parser. Slots `header`, `empty` und `message({ message, isOwn })` ersetzen Teilbereiche. Nachrichtenslots sollten keine eigenen Live-Regionen enthalten.

Kein Backend, keine KI, Uploads, Nachrichtenedits, Lesebestätigungen oder echten Zustellgarantien. Die Anwendung kann `messageEntered` abbrechen, selbst an ein Backend senden und `items` mit Status `pending`, `sent` oder `error` aktualisieren. Status `error` ist eine Anzeige, kein automatischer Retry.

## Beispiel

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { TxCard, TxCardView, TxChat, type ChatMessage } from '@tekocloud.de/tecexpress'
import '@tekocloud.de/tecexpress/themes/index.css'
const messages = ref<ChatMessage[]>([])
const user = { id: 'me', name: 'Stefan' }
const projects = [{ id: 1, title: 'Portal', subtitle: 'In Bearbeitung', owner: 'Designteam' }]
</script>
<template>
  <TxCard title="Projektübersicht" subtitle="Alles im Blick">Deine Projektinformationen.</TxCard>
  <TxCardView :data-source="projects" :columns="[{ dataField: 'owner', caption: 'Team' }]" />
  <TxChat v-model:items="messages" :user="user" title="Projektchat" />
</template>
```

Abnahme: Karten-Slots, Suche/Paging/Auswahl und Datenwechsel; Chat-Modelle, Autorenausrichtung, Sortierung, Eingabe/Enter/Shift+Enter/IME, Cancellation, gesperrte Zustände und Entwurfserhalt; Schreibanzeige und Timer-Cleanup; Scrollposition; XSS-freie Textdarstellung; Light/Dark, Mobil, SSR und isolierte Paketinstallation.
