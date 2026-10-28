# Vue ↔ Flutter · Komponenten und API · 0.7.0

Die vollständige Referenz aller öffentlichen Widgets, Modelle, Funktionen und
Methoden mit einfachen Beispielen steht auf Deutsch und Englisch direkt in der
[Paket-README](https://github.com/tekocloud/tecexpress/blob/main/flutter/README.md#de-api).
Diese Zuordnung und `EXTENSIONS.md` ergänzen die Referenz um Framework-Unterschiede.

Alle bisherigen 21 öffentlichen Vue-Komponenten beziehungsweise Konfigurationen haben weiterhin ein natives Flutter-Gegenstück. Weitere 16 Widgets und die DataSource-Infrastruktur sind in [Erweiterungen 0.7.0](EXTENSIONS.md) dokumentiert. Die Tabelle beschreibt den vorhandenen Umfang, keine vollständige DevExtreme-Kompatibilität. Sämtliche Flutter-Widgets werden aus `package:tecexpress/tecexpress.dart` importiert. Der Showcase enthält jede Tabellenzeile; `TxColumn` wird als DataGrid-Konfiguration gezeigt.

| Vue / Flutter | Flutter-Funktionen und wesentliche API |
| --- | --- |
| `TxButton` | `text`/`child`, `icon`, `onPressed`, `disabled`; `TxButtonType.normal/primary/danger/success`. `primary` entspricht Vue `type="default"`. Kein DOM-Submit-Flag. |
| `TxTextBox` | `controller` oder `initialValue`, `onChanged`, `onValueChanged`, `label`, `placeholder`, `required`, `isValid`, `validationMessage`, `disabled`, `readOnly`, `obscureText`, `keyboardType`, `focusNode`. |
| `TxTextArea` | Wie TextBox; zusätzlich `rows`, mehrzeilig, kein `obscureText`. |
| `TxNumberBox` | `value`/`initialValue` als `num?`, `onChanged`, `onValueChanged`, `min`, `max`, `step`, Plus-/Minusaktionen und Fehlerdarstellung. Leer ergibt `null`; Komma und Punkt als Dezimaltrenner. Ungültige/unzulässige Zahlen werden nicht als Werte emittiert, sichtbarer Entwurf bleibt korrigierbar. |
| `TxCheckBox` | `value`/`initialValue`, `onChanged`, `label`, `disabled`, `readOnly`, Fehlerdarstellung. Boolean, kein Dreizustandsmodus. |
| `TxSwitch` | `value`/`initialValue`, `onChanged`, `label`, `disabled`, `readOnly`, Fehlerdarstellung. Native Switch-Semantik. |
| `TxSelectBox<T>` | `List<TxItem<T>>`, `value`, `onChanged`, gesperrte Items und Fehlerdarstellung. Typisierte Werte statt `displayExpr`/`valueExpr`. |
| `TxDateBox` | `DateTime? value/initialValue`, `onChanged`, `min/max`, Datumspicker, Fehlerdarstellung, Schreibschutz. Flutter verwendet `DateTime` statt ISO-String. |
| `TxPopup` | Deklarativ `visible`/`onVisibleChanged`, `title`, `child`, `actions`, `width`, `showCloseButton`, `hideOnOutsideClick`, `onShown/onHidden`. Zusätzlich `TxPopup.show<T>(...)`. Native Dialogroute, Tab-Fokusbegrenzung und Escape. |
| `TxTabs` | `List<TxMenuItem>`, `selectedIndex`/`initialIndex`, `onChanged`, Inhalts-`builder`, gesperrte Reiter, Pfeile/Home/End. |
| `TxToolbar` | `children` und `after`, responsive Wrap-Anordnung und `label`. |
| `TxMenu` | Flache `TxMenuItem`-Liste, `onItemClick(item, index)`, `disabled`, native Buttons. Keine Untermenüs. |
| `TxTooltip` | `text`, `child`, `disabled`; native Tooltip-/Semantik-Unterstützung. |
| `TxToast` | Deklarativ `visible`/`onVisibleChanged`, `message`, `type`, `displayTime`. Zusätzlich `TxToast.show(context, ...)`; benötigt `ScaffoldMessenger`. `Duration.zero` hält die Meldung praktisch dauerhaft bis zum Schließen. |
| `TxLoadIndicator` | `visible`, `label`, zugängliche Fortschrittsanzeige, statisches Symbol bei reduzierter Bewegung. |
| `TxDataGrid<T>` | `dataSource`, `keyOf`, `columns`, `filterRow`, `pageSize`, `pageIndex/onPageIndexChanged`, `selection`, `selectedRowKeys/onSelectedRowKeysChanged`, `onSelectionChanged`, `onRowClick`, `onSortChanged`, `onFilterChanged`, `loading/disabled`, `noDataText`, `label`. Lokale numerische/natürliche Einspaltensortierung, UND-Textfilter, Pagination, Auswahl und Zell-Builder. |
| `TxColumn<T>` | Konfigurationsklasse mit `caption`, `dataField`, `valueGetter`, `width`, `allowSorting`, `allowFiltering`, `visible`, `alignment`, `cellBuilder`. Keine eigene Oberfläche. `dataField` beziehungsweise Caption muss pro Grid eindeutig sein. |
| `TxScheduler` | `dataSource/onDataSourceChanged`, `currentDate/onCurrentDateChanged`, `currentView/onCurrentViewChanged`, `views`, `firstDayOfWeek`, Stundenbereich, Zelllänge, `TxSchedulerEditing`, `readOnly/disabled/loading`, `locale`, `label`, `appointmentBuilder`. Tag/Woche/Monat, CRUD, exklusive Ganztagsgrenzen, mehrtägige Termine und parallele Layout-Spalten. |
| `TxCard` | `title`, `subtitle`, `imageUrl/imageAlt`, `header`, `media`, `child`, `actions`, `footer`, `variant`, `loading`, `semanticLabel`. Präsenta­tionskarte ohne implizite Klickaktion. |
| `TxCardView<T>` | `dataSource`, `keyOf`, `titleOf`, optionale Untertitel-/Bildgetter, `TxCardField<T>`-Liste, Suche, Pagination, Auswahl, Lade-/Leerzustand und Karten-/Medien-/Inhalts-/Footer-Builder. `onCardClick` wird vom Details-Button ausgelöst. |
| `TxChat` | `user`, `items/onItemsChanged`, `controller`/`initialText`, `onInputFieldTextChanged`, `onMessageEntered`, `onMessageSent`, Schreibereignisse/-nutzer, Autoren/Avatar/Datum/Zeit-Optionen, `height`, `header`, `empty`, `messageBuilder`, gesperrte Zustände und Eingabelimit. Lokaler Verlauf, Enter/Shift+Enter, IME und Auto-Scroll. |

## Daten und Zustandskontrolle

- Keys sind eindeutige `String`- oder `int`-Werte, keine DOM- oder Widget-Keys. Doppelte IDs werfen einen Fehler; Daten werden nicht stillschweigend überschrieben.
- `TxSelection<T>` liefert unveränderliche `keys` und `data`. Auswahl bleibt über Seiten und Filter erhalten; entfernte Datensätze werden bereinigt.
- Tabellen-/Kartendaten sind typisiert. `valueGetter` und `cellBuilder` ersetzen JavaScript-Feldpfade/Slots. Verschachtelte Felder können über Getter gelesen werden.
- `TxAppointment`, `TxChatUser` und `TxChatMessage` sind typisierte unveränderliche Datenmodelle. UTC-Zeitpunkte werden lokal dargestellt. Ganztagstermine müssen lokale Mitternachtsgrenzen haben, ihr Ende ist exklusiv.
- `TxChange<T>.cancel` ist ein synchroner Abbruchmechanismus. Scheduler-Ereignisse: `onAppointmentAdding/Updating/Deleting`, anschließend `onAppointmentAdded/Updated/Deleted`. Updates verwenden `TxAppointmentUpdate(oldData, newData)`. `onAppointmentClick` und `onCellClick` melden Aktivierungen.
- Chat: `onMessageEntered` meldet vor Aufnahme eine `TxChange<TxChatMessage>`; `onMessageSent` nach lokalem Änderungsvorschlag eine Nachricht. `TxMessageStatus.sent` bestätigt keine Serverzustellung. `pending/error` sind von der Anwendung steuerbare Anzeigen.
- Wer Werte oder Listen übergibt, übernimmt Änderungen mit den passenden Callbacks. Textcontroller können sowohl programmatisch als auch durch Eingaben aktualisiert werden; nur intern erzeugte Controller werden vom Paket entsorgt.
- Es gibt keine implizite Persistenz oder Dienstanbindung. Remote-Stores und Dateiuploads stehen seit 0.5.0 über konfigurierbare Adapter zur Verfügung. Scheduler-Serien/Ressourcen/Drag-and-drop und HTML-Chat sind weiterhin nicht enthalten.

## Themen, Plattformen und Prüfungen

`TxTheme.light/dark` mit `TxThemeData` als ThemeExtension; `TxLocalizations.delegates` und `supportedLocales` in die MaterialApp einbinden. Deutsche Picker/UI-Texte; Datumsformatierung über Locale. Touch-, Maus- und Tastaturbedienung werden über gemeinsame Flutter-Widgets umgesetzt.

Android, iOS, Web, Windows, macOS und Linux sind als Ziele vorgesehen. Die lokalen Build-/Testergebnisse und noch nicht ausgeführte CI-Jobs stehen im Root-`VALIDATION.md`. Widgettests liegen in `test/`, der Showcase in `example/lib/showcase.dart`.
