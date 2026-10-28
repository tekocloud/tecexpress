# tecexpress for Flutter

[Deutsch](#de) · [English](#en)

<!-- API tables are generated from source. See tools/documentation/README.md in the repository. -->

<a id="de"></a>
## Deutsch

Vollständige öffentliche API von tecexpress 0.7.1 für Flutter. MIT-Lizenz, ohne Lizenzkey.

[Installation und Einstieg](#de-start) · [Daten und Zustandsverwaltung](#de-data) · [Dateien, Uploads und Karten](#de-adapters) · [API-Verzeichnis](#de-api) · [Entwicklung](#de-development)

<a id="de-start"></a>
### Installation und Einstieg

```sh
flutter pub add tecexpress
```

Ab 0.7.0 nur Flutter-SDK-Laufzeitabhängigkeiten. Eigene Datei-API: `TxFile` und `TxFileDialogs`. Breaking Changes, Ressourcenbesitz und Plattformkonfiguration: [Migration 0.7](MIGRATION-0.7.md). Native Apps nach dem Update vollständig neu bauen.

Benötigt Flutter 3.47.7+ und Dart 3.13.5+. Zielplattformen: Android, iOS, Web, Windows, macOS und Linux.

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

void main() => runApp(MaterialApp(
  theme: TxTheme.light(),
  darkTheme: TxTheme.dark(),
  themeMode: ThemeMode.system,
  locale: const Locale('de'),
  localizationsDelegates: TxLocalizations.delegates,
  supportedLocales: TxLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: TxButton(text: 'Hello', onPressed: () {}))),
));
```

Widgetbeispiele definieren jeweils `Widget example()`. Zum Ausprobieren innerhalb einer MaterialApp `Scaffold(body: example())` verwenden. Alle Widgets akzeptieren zusätzlich den optionalen Flutter-Parameter `Key? key = null`; dieser steht hier einmal gemeinsam statt in jeder Tabelle. Der lokale Zustand entsteht einmal beim Erzeugen des Widgets; in einer produktiven App gehört er in den eigenen State. Beispiele für Datenoperationen definieren eine asynchrone Funktion, die separat aufgerufen wird.

Eigene Tokens: `TxTheme.light(tokens: TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12))`. `txThemeOf(context)` liest aktuelle Tokens. Lokalisierungsdelegates aktivieren deutsche/englische Material-Steuerelemente; paketinterne Bedientexte sind derzeit deutsch.

<a id="de-data"></a>
### Daten und Zustandsverwaltung

Eine Datenbindung akzeptiert List&lt;T&gt;, Konfigurationen oder bestehende DataSource-Instanzen. Bei einer Konfiguration besitzt und entsorgt die Komponente ihre Source; eine übergebene Instanz bleibt Aufgabe der Anwendung. dataSource hat Vorrang vor items. Geteilte Instanzen teilen auch Filter, Suche, Sortierung und Seite. Für unabhängige Ansichten eigene Instanzen verwenden.

Kontrollierte Werte und Listen über on…Changed in den eigenen State übernehmen. Externe TextEditingController entsorgt die Anwendung; interne Controller entsorgt das Widget.

ArrayStores verarbeiten Abfragen lokal; CustomStores standardmäßig auf dem Server. Bei remoteOperations = false müssen CustomStores sämtliche Rohdaten liefern. Der Serververtrag wird von der Anwendung bestimmt; Getter sind nicht serialisierbar. Für serverseitiges Paging totalCount liefern. Kalender und Chat benötigen vollständige Verläufe oder eine bewusst begrenzte Datenmenge; paginate = false lädt alles.

load/reload/configure können fehlschlagen: await mit try/catch verwenden und error anzeigen. Neue Ladevorgänge ersetzen alte; verspätete Antworten überschreiben keinen neueren Zustand. Schlüssel bleiben eindeutig und unveränderlich. Schreiben ohne passende Store-Operation schlägt fehl. push ist keine Transaktion.

Terminenden liegen nach dem Beginn. Ganztagstermine verwenden lokale Tagesgrenzen mit exklusivem Ende. UTC-Zeitpunkte werden lokal dargestellt. Chat zeigt Text, kein HTML; Backend und KI-Dienst richtet die Anwendung ein.

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final source = TxDataSource.array([1, 2], keyOf: (v) => v);
  try { await source.load(); } catch (error) { print(error); }
  source.dispose();
}
```

<a id="de-adapters"></a>
### Dateien, Uploads und Karten

Der MemoryFileProvider speichert nur im Arbeitsspeicher. Ungültige Namen, doppelte IDs/Namen, ungültige Eltern und zyklische Verschiebungen werden abgelehnt. Dateioperationen sind asynchron. Die capabilities-Menge bestimmt sichtbare Aktionen. txFileStore unterstützt Laden und optional Löschen; Umbenennen wird nicht als Store-Update angeboten.

HTTP-Uploads benötigen einen eigenen Multipart-POST-Endpunkt. fieldName ist standardmäßig file. Bei chunkSize muss der Server das durch chunkFields vereinbarte Protokoll zusammensetzen. Wiederholung beginnt von vorn. Der HTTP-Adapter liest die Datei in den Speicher und meldet Fortschritt nach abgeschlossenen Chunks. Dateiauswahl/Drop und Speicherdialoge hängen von OS und Plugins ab; onDownload ermöglicht eigene Speicherung.

Kartenkacheln verwenden {z}/{x}/{y}. Kachelquelle, Zugangsdaten und Attribution müssen selbst konfiguriert werden. GeoAdapter wird von der Anwendung aufgerufen; seine Ergebnisse werden als Marker/Routen gebunden. Ohne Quelle erfolgt kein impliziter externer Kartenaufruf.

<a id="de-api"></a>
### API-Verzeichnis

- [TxCard](#de-txcard)
- [TxCardView](#de-txcardview)
- [TxChat](#de-txchat)
- [TxRadioGroup](#de-txradiogroup)
- [TxButtonGroup](#de-txbuttongroup)
- [TxLookup](#de-txlookup)
- [TxTagBox](#de-txtagbox)
- [TxList](#de-txlist)
- [TxGallery](#de-txgallery)
- [TxAction](#de-txaction)
- [TxFloatingActionButton](#de-txfloatingactionbutton)
- [TxActionSheet](#de-txactionsheet)
- [TxContextMenu](#de-txcontextmenu)
- [TxDataGrid](#de-txdatagrid)
- [TxButton](#de-txbutton)
- [TxTextBox](#de-txtextbox)
- [TxTextArea](#de-txtextarea)
- [TxNumberBox](#de-txnumberbox)
- [TxCheckBox](#de-txcheckbox)
- [TxSwitch](#de-txswitch)
- [TxSelectBox](#de-txselectbox)
- [TxDateBox](#de-txdatebox)
- [TxFileEntry](#de-txfileentry)
- [TxFileProvider](#de-txfileprovider)
- [TxMemoryFileProvider](#de-txmemoryfileprovider)
- [txFileStore](#de-txfilestore)
- [TxUploadContext](#de-txuploadcontext)
- [TxUploadAdapter](#de-txuploadadapter)
- [TxHttpUploadConfig](#de-txhttpuploadconfig)
- [txHttpUpload](#de-txhttpupload)
- [TxFileUploader](#de-txfileuploader)
- [TxFileManager](#de-txfilemanager)
- [TxFileException](#de-txfileexception)
- [TxFile](#de-txfile)
- [TxFileDialogs](#de-txfiledialogs)
- [TxCoordinate](#de-txcoordinate)
- [TxMapMarker](#de-txmapmarker)
- [TxMapRoute](#de-txmaproute)
- [TxGeoAdapter](#de-txgeoadapter)
- [txProject](#de-txproject)
- [txUnproject](#de-txunproject)
- [TxMap](#de-txmap)
- [TxButtonType](#de-txbuttontype)
- [TxSelectionMode](#de-txselectionmode)
- [TxSchedulerView](#de-txschedulerview)
- [TxMessageStatus](#de-txmessagestatus)
- [TxCardVariant](#de-txcardvariant)
- [TxChange](#de-txchange)
- [TxValueChange](#de-txvaluechange)
- [TxItem](#de-txitem)
- [TxMenuItem](#de-txmenuitem)
- [TxColumn](#de-txcolumn)
- [TxCardField](#de-txcardfield)
- [TxSelection](#de-txselection)
- [TxAppointment](#de-txappointment)
- [TxAppointmentUpdate](#de-txappointmentupdate)
- [TxSchedulerEditing](#de-txschedulerediting)
- [TxChatUser](#de-txchatuser)
- [TxChatMessage](#de-txchatmessage)
- [txValidateKey](#de-txvalidatekey)
- [txValidateKeys](#de-txvalidatekeys)
- [TxTabs](#de-txtabs)
- [TxToolbar](#de-txtoolbar)
- [TxMenu](#de-txmenu)
- [TxPopup](#de-txpopup)
- [TxTooltip](#de-txtooltip)
- [TxToastType](#de-txtoasttype)
- [TxToast](#de-txtoast)
- [TxLoadIndicator](#de-txloadindicator)
- [TxRangeSlider](#de-txrangeslider)
- [TxRangeSelector](#de-txrangeselector)
- [TxScheduler](#de-txscheduler)
- [TxTabPanel](#de-txtabpanel)
- [TxLoadPanel](#de-txloadpanel)
- [TxNotifyHandle](#de-txnotifyhandle)
- [txNotify](#de-txnotify)
- [TxKeyOf](#de-txkeyof)
- [TxGetter](#de-txgetter)
- [TxSort](#de-txsort)
- [TxFilterOperator](#de-txfilteroperator)
- [TxFilter](#de-txfilter)
- [txSourceCompare](#de-txsourcecompare)
- [TxCancellation](#de-txcancellation)
- [TxLoadOptions](#de-txloadoptions)
- [TxGroup](#de-txgroup)
- [TxLoadResult](#de-txloadresult)
- [TxStore](#de-txstore)
- [txQuery](#de-txquery)
- [TxArrayStore](#de-txarraystore)
- [TxCustomStore](#de-txcustomstore)
- [TxDataSourceConfig](#de-txdatasourceconfig)
- [TxPush](#de-txpush)
- [TxDataSource](#de-txdatasource)
- [TxSourceState](#de-txsourcestate)
- [TxDataSourceBuilder](#de-txdatasourcebuilder)
- [TxThemeData](#de-txthemedata)
- [TxTheme](#de-txtheme)
- [txThemeOf](#de-txthemeof)
- [TxLocalizations](#de-txlocalizations)

`undefined` (Vue) beziehungsweise optionale nullable Parameter (Dart) bedeuten keinen extern vorgegebenen Wert. Boolean-Props ohne expliziten Vue-Standard sind false. Typen und Standardwerte unten stammen aus der aktuellen Implementierung; zusätzliche Fähigkeiten werden dadurch nicht zugesagt.

<a id="de-txcard"></a>
### TxCard

Präsentationskarte mit Titel, Medien, Inhalt und Aktionen.

`TxCard`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| title | `String?` | `null` | Titel der Ansicht. |
| subtitle | `String?` | `null` | Zusätzlicher Untertitel. |
| imageUrl | `String?` | `null` | Bildadresse der Karte. |
| imageAlt | `String` | `''` | Alternativtext des Bildes. |
| header | `Widget?` | `null` | Eigener Kopfbereich. |
| media | `Widget?` | `null` | Eigener Medienbereich. |
| child | `Widget?` | `null` | Inhalt beziehungsweise Zielwidget. |
| actions | `List<Widget>` | `const []` | Aktionen des Dialogs beziehungsweise der Karte. |
| footer | `Widget?` | `null` | Eigener Fußbereich. |
| variant | `TxCardVariant` | `TxCardVariant.outlined` | Darstellungsvariante der Karte. |
| loading | `bool` | `false` | Zeigt den Ladezustand. |
| semanticLabel | `String?` | `null` | Zugänglicher Name der Karte. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxCard(title: 'Project', subtitle: 'Active', child: Text('Hello'));
}
```

<a id="de-txcardview"></a>
### TxCardView

Kartenliste mit Suche, Pagination, Auswahl und eigenen Karteninhalten.

`TxCardView`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| dataSource | `Object` | `erforderlich` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| keyOf | `Object Function(T row)` | `erforderlich` | Liest den stabilen Datensatzschlüssel. |
| titleOf | `String Function(T row)` | `erforderlich` | Getter des Kartentitels. |
| subtitleOf | `String? Function(T row)?` | `null` | Getter des Kartenuntertitels. |
| imageOf | `String? Function(T row)?` | `null` | Getter der Kartenbildadresse. |
| imageAltOf | `String? Function(T row)?` | `null` | Getter des Bildalternativtexts. |
| columns | `List<TxCardField<T>>` | `const []` | Spalten- beziehungsweise Kartenfeldkonfigurationen. |
| searchEnabled | `bool` | `true` | Aktiviert die Suche. |
| searchTextOf | `String? Function(T row)?` | `null` | Getter des durchsuchbaren Kartentexts. |
| pageSize | `int` | `6` | Anzahl Datensätze je Seite. |
| pageIndex | `int?` | `null` | Nullbasierter Seitenindex. |
| onPageIndexChanged | `ValueChanged<int>?` | `null` | Meldet pageIndex; kontrollierten Zustand im Callback aktualisieren. |
| selection | `TxSelectionMode` | `TxSelectionMode.none` | Auswahlmodus. |
| selectedCardKeys | `Set<Object>?` | `null` | Kontrollierte Menge ausgewählter Kartenschlüssel. |
| onSelectedCardKeysChanged | `ValueChanged<Set<Object>>?` | `null` | Meldet selectedCardKeys; kontrollierten Zustand im Callback aktualisieren. |
| onSelectionChanged | `ValueChanged<TxSelection<T>>?` | `null` | Meldet selection; kontrollierten Zustand im Callback aktualisieren. |
| onCardClick | `ValueChanged<T>?` | `null` | Meldet den über die Details-Aktion aktivierten Datensatz. |
| onSearchChanged | `ValueChanged<String>?` | `null` | Meldet search; kontrollierten Zustand im Callback aktualisieren. |
| loading | `bool` | `false` | Zeigt den Ladezustand. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| noDataText | `String` | `'Keine Karten vorhanden.'` | Text bei leerem Datenbestand. |
| label | `String` | `'Kartenansicht'` | Beschriftung beziehungsweise zugänglicher Name. |
| itemBuilder | `Widget Function(BuildContext context, T row, bool selected)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| mediaBuilder | `Widget Function(BuildContext context, T row)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| contentBuilder | `Widget Function(BuildContext context, T row)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| footerBuilder | `Widget Function(BuildContext context, T row)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final rows = <Map<String, Object>>[{'id': 1, 'name': 'Alex'}];
  return TxCardView<Map<String, Object>>(dataSource: rows, keyOf: (row) => row['id']!, titleOf: (row) => '${row['name']}');
}
```

<a id="de-txchat"></a>
### TxChat

Lokaler Nachrichtenverlauf mit Autoren, Schreibanzeige und Sendeereignissen. sent bestätigt die lokale Aufnahme, keine Serverzustellung.

`TxChat`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| user | `TxChatUser` | `erforderlich` | Aktueller Chatautor. |
| items | `List<TxChatMessage>?` | `null` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| onItemsChanged | `ValueChanged<List<TxChatMessage>>?` | `null` | Meldet items; kontrollierten Zustand im Callback aktualisieren. |
| controller | `TextEditingController?` | `null` | Externer Textcontroller; Entsorgung bleibt Aufgabe der Anwendung. |
| initialText | `String` | `''` | Anfänglicher Entwurf ohne externen Controller. |
| onInputFieldTextChanged | `ValueChanged<String>?` | `null` | Meldet inputFieldText; kontrollierten Zustand im Callback aktualisieren. |
| onMessageEntered | `ValueChanged<TxChange<TxChatMessage>>?` | `null` | Vor lokaler Aufnahme: TxChange&lt;TxChatMessage&gt;; cancel synchron setzen, um eigene Verarbeitung zu übernehmen. |
| onMessageSent | `ValueChanged<TxChatMessage>?` | `null` | Liefert die lokal aufgenommene TxChatMessage; keine Serverzustellbestätigung. |
| onTypingStart | `ValueChanged<TxChatUser>?` | `null` | Meldet den Beginn des Schreibens mit dem betroffenen TxChatUser. |
| onTypingEnd | `ValueChanged<TxChatUser>?` | `null` | Meldet das Ende des Schreibens mit dem betroffenen TxChatUser. |
| title | `String` | `'Chat'` | Titel der Ansicht. |
| subtitle | `String` | `''` | Zusätzlicher Untertitel. |
| label | `String` | `'Chat'` | Beschriftung beziehungsweise zugänglicher Name. |
| placeholder | `String` | `'Nachricht schreiben …'` | Hinweis bei leerer Eingabe. |
| emptyText | `String` | `'Noch keine Nachrichten. Starte die Unterhaltung.'` | Text des Leerzustands. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| loading | `bool` | `false` | Zeigt den Ladezustand. |
| sending | `bool` | `false` | Sperrt Senden während einer eigenen laufenden Anfrage. |
| maxLength | `int` | `4000` | Maximale Textlänge. |
| typingUsers | `List<TxChatUser>` | `const []` | Aktuell schreibende Autoren. |
| showAvatar | `bool` | `true` | Zeigt Autorenbilder. |
| showUserName | `bool` | `true` | Zeigt Autorennamen. |
| showDayHeaders | `bool` | `true` | Gruppiert Nachrichten mit Tagesüberschriften. |
| showMessageTimestamp | `bool` | `true` | Zeigt Nachrichtenzeiten. |
| locale | `String` | `'de'` | Locale für Datums-/Zeitformatierung. |
| height | `double` | `560` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| header | `Widget?` | `null` | Eigener Kopfbereich. |
| empty | `Widget?` | `null` | Eigener Leerzustand. |
| messageBuilder | `Widget Function(BuildContext context, TxChatMessage message, bool isOwn)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var messages = <TxChatMessage>[];
  return StatefulBuilder(
    builder: (context, setState) => TxChat(user: TxChatUser(id: 'me', name: 'Alex'), items: messages, onItemsChanged: (v) => setState(() => messages = v)),
  );
}
```

<a id="de-txradiogroup"></a>
### TxRadioGroup

Sichtbare Optionsfelder für eine Einzelwahl.

`TxRadioGroup`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| value | `T?` | `null` | Aktueller Eingabe-/Optionswert. |
| onChanged | `ValueChanged<T>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| direction | `Axis` | `Axis.vertical` | Anordnung der Einträge. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| label | `String` | `'Auswahl'` | Beschriftung beziehungsweise zugänglicher Name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  int? choice = 1;
  return StatefulBuilder(
    builder: (context, setState) => TxRadioGroup<int>(items: options, value: choice, onChanged: (v) => setState(() => choice = v)),
  );
}
```

<a id="de-txbuttongroup"></a>
### TxButtonGroup

Gruppe von Aktionen mit keiner, einfacher oder mehrfacher Auswahl.

`TxButtonGroup`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| values | `Set<T>` | `const {}` | Aktuell ausgewählte Werte. |
| onChanged | `ValueChanged<Set<T>>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| onItemClick | `ValueChanged<TxItem<T>>?` | `null` | Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur. |
| selection | `TxSelectionMode` | `TxSelectionMode.single` | Auswahlmodus. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| direction | `Axis` | `Axis.horizontal` | Anordnung der Einträge. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  var keys = <int>{};
  return StatefulBuilder(
    builder: (context, setState) => TxButtonGroup<int>(items: options, values: keys, onChanged: (v) => setState(() => keys = v)),
  );
}
```

<a id="de-txlookup"></a>
### TxLookup

Suchbare Einzelwahl mit nachladbarer Datenquelle.

`TxLookup`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| value | `T?` | `null` | Aktueller Eingabe-/Optionswert. |
| onChanged | `ValueChanged<T?>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| label | `String` | `'Auswählen'` | Beschriftung beziehungsweise zugänglicher Name. |
| searchEnabled | `bool` | `true` | Aktiviert die Suche. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  int? choice = 1;
  return StatefulBuilder(
    builder: (context, setState) => TxLookup<int>(items: options, value: choice, onChanged: (v) => setState(() => choice = v)),
  );
}
```

<a id="de-txtagbox"></a>
### TxTagBox

Suchbare Mehrfachauswahl mit Tags. Alle auswählen betrifft die geladenen Ergebnisse.

`TxTagBox`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| values | `Set<T>` | `const {}` | Aktuell ausgewählte Werte. |
| onChanged | `ValueChanged<Set<T>>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| label | `String` | `'Auswählen'` | Beschriftung beziehungsweise zugänglicher Name. |
| maxDisplayedTags | `int` | `4` | Maximal sichtbare Tags vor der Zusammenfassung. |
| applyOnConfirm | `bool` | `false` | Übernimmt die Auswahl erst bei Bestätigung. |
| onCustomItemCreating | `FutureOr<TxItem<T>> Function(String)?` | `null` | Erzeugt synchron oder asynchron einen TxItem aus dem eingegebenen Text. |
| showSelectionControls | `bool` | `true` | Zeigt Mehrfachauswahl-/Alle-Steuerelemente. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  var keys = <int>{};
  return StatefulBuilder(
    builder: (context, setState) => TxTagBox<int>(items: options, values: keys, onChanged: (v) => setState(() => keys = v)),
  );
}
```

<a id="de-txlist"></a>
### TxList

Liste mit Suche, Auswahl und optionalem Löschen oder Umordnen über Ereignisse.

`TxList`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<T>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| textOf | `String Function(T)` | `erforderlich` | Getter des sichtbaren Listentexts. |
| keyOf | `Object Function(T)` | `erforderlich` | Liest den stabilen Datensatzschlüssel. |
| itemBuilder | `Widget Function(BuildContext, T)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| groupOf | `String? Function(T)?` | `null` | Getter für die Gruppierung der Liste. |
| selectedKeys | `Set<Object>` | `const {}` | Ausgewählte Eintragsschlüssel. |
| onSelectionChanged | `ValueChanged<Set<Object>>?` | `null` | Meldet selection; kontrollierten Zustand im Callback aktualisieren. |
| onItemClick | `ValueChanged<T>?` | `null` | Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur. |
| onDelete | `ValueChanged<T>?` | `null` | Meldet den zu löschenden Listeneintrag; die Anwendung aktualisiert ihre Liste. |
| onReorder | `void Function(int, int)?` | `null` | Meldet Quell- und Zielindex; die Anwendung aktualisiert ihre Liste. |
| selection | `TxSelectionMode` | `TxSelectionMode.none` | Auswahlmodus. |
| searchEnabled | `bool` | `false` | Aktiviert die Suche. |
| height | `double` | `300` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| itemExtent | `double?` | `null` | Feste Flutter-Listenzeilenhöhe, wenn angegeben. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxList<String>(items: const ['One', 'Two'], keyOf: (v) => v, textOf: (v) => v, searchEnabled: true);
}
```

<a id="de-txgallery"></a>
### TxGallery

Durchblätterbare Galerie mit optionaler automatischer Wiedergabe; kein Medienplayer.

`TxGallery`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<T>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| itemBuilder | `Widget Function(BuildContext, T)` | `erforderlich` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| selectedIndex | `int` | `0` | Nullbasierter aktiver Eintrag. |
| onChanged | `ValueChanged<int>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| loop | `bool` | `false` | Erlaubt Umlauf vom letzten zum ersten Galerieeintrag. |
| slideshowDelay | `Duration` | `Duration.zero` | Intervall der automatischen Navigation; 0 schaltet sie aus. |
| height | `double` | `240` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxGallery<String>(items: const ['One', 'Two'], itemBuilder: (context, item) => Center(child: Text(item)));
}
```

<a id="de-txaction"></a>
### TxAction

Kontext-/Sheet-/FAB-Aktion mit ID, Text und optionalen Unteraktionen.

`TxAction`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| id | `Object` | `erforderlich` | Eindeutige stabile ID. |
| text | `String` | `erforderlich` | Anzuzeigender Text. |
| icon | `IconData?` | `null` | Symbol der Aktion. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| destructive | `bool` | `false` | Kennzeichnet eine destruktive Aktion. |
| items | `List<TxAction>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| separator | `bool` | `false` | Kennzeichnet einen Menütrenner. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const action = TxAction(id: 'copy', text: 'Copy');
  print(action.id);
}
```

<a id="de-txfloatingactionbutton"></a>
### TxFloatingActionButton

Schwebende Hauptaktion oder aufklappbare Aktionsgruppe.

`TxFloatingActionButton`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxAction>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| onItemClick | `ValueChanged<TxAction>?` | `null` | Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| icon | `IconData` | `Icons.add` | Symbol der Aktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxFloatingActionButton(items: const [TxAction(id: 'add', text: 'Add')], onItemClick: (action) {});
}
```

<a id="de-txactionsheet"></a>
### TxActionSheet

Aktionsauswahl am unteren Bildschirmrand mit Abbrechen-Aktion.

`TxActionSheet`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxAction>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| title | `String?` | `null` | Titel der Ansicht. |
| onItemClick | `ValueChanged<TxAction>?` | `null` | Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur. |
| cancelText | `String` | `'Abbrechen'` | Beschriftung der Abbrechen-Aktion. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static Future<TxAction?> show(BuildContext context, {List<TxAction> items = const [], Object? dataSource, String? title})` | Öffnet die native Overlay-Alternative; den Rückgabevertrag der jeweiligen Signatur beachten. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxActionSheet(title: 'Actions', items: const [TxAction(id: 'copy', text: 'Copy')], onItemClick: (action) {});
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> open(BuildContext context) async {
  final selected = await TxActionSheet.show(context, items: const [TxAction(id: 'copy', text: 'Copy')]);
  debugPrint('${selected?.id}');
}
```

<a id="de-txcontextmenu"></a>
### TxContextMenu

Kontextaktionen über Rechtsklick oder langes Drücken auf den Zielinhalt.

`TxContextMenu`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| child | `Widget` | `erforderlich` | Inhalt beziehungsweise Zielwidget. |
| items | `List<TxAction>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| onItemClick | `ValueChanged<TxAction>?` | `null` | Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxContextMenu(items: const [TxAction(id: 'copy', text: 'Copy')], onItemClick: (action) {}, child: const Text('Right click here'));
}
```

<a id="de-txdatagrid"></a>
### TxDataGrid

Datentabelle mit Einspaltensortierung, UND-Textfiltern, Pagination, Auswahl und eigenen Zellen.

`TxDataGrid`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| dataSource | `Object` | `erforderlich` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| keyOf | `Object Function(T row)` | `erforderlich` | Liest den stabilen Datensatzschlüssel. |
| columns | `List<TxColumn<T>>` | `erforderlich` | Spalten- beziehungsweise Kartenfeldkonfigurationen. |
| filterRow | `bool` | `true` | Zeigt die Textfilterzeile. |
| pageSize | `int` | `10` | Anzahl Datensätze je Seite. |
| pageIndex | `int?` | `null` | Nullbasierter Seitenindex. |
| onPageIndexChanged | `ValueChanged<int>?` | `null` | Meldet pageIndex; kontrollierten Zustand im Callback aktualisieren. |
| selection | `TxSelectionMode` | `TxSelectionMode.none` | Auswahlmodus. |
| selectedRowKeys | `Set<Object>?` | `null` | Kontrollierte Menge ausgewählter Zeilenschlüssel. |
| onSelectedRowKeysChanged | `ValueChanged<Set<Object>>?` | `null` | Meldet selectedRowKeys; kontrollierten Zustand im Callback aktualisieren. |
| onSelectionChanged | `ValueChanged<TxSelection<T>>?` | `null` | Meldet selection; kontrollierten Zustand im Callback aktualisieren. |
| onRowClick | `ValueChanged<T>?` | `null` | Meldet den angeklickten Datensatz. |
| onSortChanged | `void Function(String? field, bool descending)?` | `null` | Meldet sort; kontrollierten Zustand im Callback aktualisieren. |
| onFilterChanged | `ValueChanged<Map<String, String>>?` | `null` | Meldet filter; kontrollierten Zustand im Callback aktualisieren. |
| loading | `bool` | `false` | Zeigt den Ladezustand. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| noDataText | `String` | `'Keine Daten vorhanden.'` | Text bei leerem Datenbestand. |
| label | `String` | `'Datentabelle'` | Beschriftung beziehungsweise zugänglicher Name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final rows = <Map<String, Object>>[{'id': 1, 'name': 'Alex'}];
  return TxDataGrid<Map<String, Object>>(dataSource: rows, keyOf: (row) => row['id']!, columns: [TxColumn(caption: 'Name', valueGetter: (row) => row['name'])]);
}
```

<a id="de-txbutton"></a>
### TxButton

Schaltfläche mit Text, Symbol und Klickaktion.

`TxButton`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| text | `String?` | `null` | Anzuzeigender Text. |
| child | `Widget?` | `null` | Inhalt beziehungsweise Zielwidget. |
| onPressed | `VoidCallback?` | `null` | Callback für pressed; Argumente und Rückgabetyp siehe Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| type | `TxButtonType` | `TxButtonType.normal` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |
| icon | `IconData?` | `null` | Symbol der Aktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var saved = false;
  return StatefulBuilder(
    builder: (context, setState) => TxButton(text: 'Save', onPressed: () => setState(() => saved = true)),
  );
}
```

<a id="de-txtextbox"></a>
### TxTextBox

Einzeilige Texteingabe; Änderungen über das Modell oder den Callback übernehmen.

`TxTextBox`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| controller | `TextEditingController?` | `null` | Externer Textcontroller; Entsorgung bleibt Aufgabe der Anwendung. |
| initialValue | `String?` | `null` | Startwert im unkontrollierten Modus. |
| onChanged | `ValueChanged<String>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| onValueChanged | `ValueChanged<TxValueChange<String>>?` | `null` | Meldet value; kontrollierten Zustand im Callback aktualisieren. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| placeholder | `String?` | `null` | Hinweis bei leerer Eingabe. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| required | `bool` | `false` | Kennzeichnet die erforderliche Eingabe. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |
| obscureText | `bool` | `false` | Verbirgt die Texteingabe. |
| keyboardType | `TextInputType?` | `null` | Gewünschte Bildschirmtastatur. |
| focusNode | `FocusNode?` | `null` | Externer Fokuscontroller. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var text = '';
  return StatefulBuilder(
    builder: (context, setState) => TxTextBox(label: 'Name', initialValue: 'Alex', onChanged: (v) => setState(() => text = v)),
  );
}
```

<a id="de-txtextarea"></a>
### TxTextArea

Mehrzeilige Texteingabe mit konfigurierbarer Zeilenzahl.

`TxTextArea`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| controller | `TextEditingController?` | `null` | Externer Textcontroller; Entsorgung bleibt Aufgabe der Anwendung. |
| initialValue | `String?` | `null` | Startwert im unkontrollierten Modus. |
| onChanged | `ValueChanged<String>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| onValueChanged | `ValueChanged<TxValueChange<String>>?` | `null` | Meldet value; kontrollierten Zustand im Callback aktualisieren. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| placeholder | `String?` | `null` | Hinweis bei leerer Eingabe. |
| rows | `int` | `3` | Sichtbare Textzeilen. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| required | `bool` | `false` | Kennzeichnet die erforderliche Eingabe. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |
| focusNode | `FocusNode?` | `null` | Externer Fokuscontroller. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var text = '';
  return StatefulBuilder(
    builder: (context, setState) => TxTextArea(label: 'Notes', rows: 4, onChanged: (v) => setState(() => text = v)),
  );
}
```

<a id="de-txnumberbox"></a>
### TxNumberBox

Zahleneingabe mit Grenzen und Schritten. Ein leerer Wert ergibt null.

`TxNumberBox`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `num?` | `null` | Aktueller Eingabe-/Optionswert. |
| initialValue | `num?` | `null` | Startwert im unkontrollierten Modus. |
| onChanged | `ValueChanged<num?>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| onValueChanged | `ValueChanged<TxValueChange<num?>>?` | `null` | Meldet value; kontrollierten Zustand im Callback aktualisieren. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| placeholder | `String?` | `null` | Hinweis bei leerer Eingabe. |
| min | `num?` | `null` | Untere zulässige Grenze. |
| max | `num?` | `null` | Obere zulässige Grenze. |
| step | `num` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  num? amount = 10;
  return StatefulBuilder(
    builder: (context, setState) => TxNumberBox(value: amount, min: 0, max: 100, onChanged: (v) => setState(() => amount = v)),
  );
}
```

<a id="de-txcheckbox"></a>
### TxCheckBox

Kontrollkästchen für einen booleschen Wert.

`TxCheckBox`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `bool?` | `null` | Aktueller Eingabe-/Optionswert. |
| initialValue | `bool` | `false` | Startwert im unkontrollierten Modus. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| onChanged | `ValueChanged<bool>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var enabled = true;
  return StatefulBuilder(
    builder: (context, setState) => TxCheckBox(value: enabled, label: 'Active', onChanged: (v) => setState(() => enabled = v)),
  );
}
```

<a id="de-txswitch"></a>
### TxSwitch

Schalter für einen booleschen Wert.

`TxSwitch`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `bool?` | `null` | Aktueller Eingabe-/Optionswert. |
| initialValue | `bool` | `false` | Startwert im unkontrollierten Modus. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| onChanged | `ValueChanged<bool>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var enabled = true;
  return StatefulBuilder(
    builder: (context, setState) => TxSwitch(value: enabled, label: 'Active', onChanged: (v) => setState(() => enabled = v)),
  );
}
```

<a id="de-txselectbox"></a>
### TxSelectBox

Einfachauswahl aus einer Liste oder Datenquelle.

`TxSelectBox`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| value | `T?` | `null` | Aktueller Eingabe-/Optionswert. |
| onChanged | `ValueChanged<T?>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| placeholder | `String` | `'Bitte wählen'` | Hinweis bei leerer Eingabe. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  int? choice = 1;
  return StatefulBuilder(
    builder: (context, setState) => TxSelectBox<int>(items: options, value: choice, onChanged: (v) => setState(() => choice = v)),
  );
}
```

<a id="de-txdatebox"></a>
### TxDateBox

Datumseingabe mit unterer und oberer Grenze.

`TxDateBox`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `DateTime?` | `null` | Aktueller Eingabe-/Optionswert. |
| initialValue | `DateTime?` | `null` | Startwert im unkontrollierten Modus. |
| onChanged | `ValueChanged<DateTime?>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| label | `String?` | `null` | Beschriftung beziehungsweise zugänglicher Name. |
| min | `DateTime?` | `null` | Untere zulässige Grenze. |
| max | `DateTime?` | `null` | Obere zulässige Grenze. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| isValid | `bool` | `true` | Steuert die Fehlerdarstellung; führt keine eigene Validierung aus. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Fehlermeldung bei isValid = false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  DateTime? date = DateTime(2026, 10, 28);
  return StatefulBuilder(
    builder: (context, setState) => TxDateBox(value: date, onChanged: (v) => setState(() => date = v)),
  );
}
```

<a id="de-txfileentry"></a>
### TxFileEntry

Datei-/Ordnermetadaten mit stabiler ID; parentId null bezeichnet das Wurzelverzeichnis.

Dart copyWith behält nicht angegebene Felder bei; root: true setzt parentId ausdrücklich auf null. parentId: null allein behält den bisherigen Elternordner.

`TxFileEntry`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| id | `String` | `erforderlich` | Eindeutige stabile ID. |
| name | `String` | `erforderlich` | Name des Eingabefelds beziehungsweise Dateiname. |
| parentId | `String?` | `null` | Elternordner-ID; null bezeichnet die Wurzel. |
| isDirectory | `bool` | `false` | Kennzeichnet einen Ordner. |
| size | `int` | `0` | Dateigröße in Bytes. |
| modified | `DateTime?` | `null` | Letzter Änderungszeitpunkt. |
| bytes | `Uint8List?` | `null` | Dateiinhalt im Speicher. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `TxFileEntry copyWith({String? id, String? name, String? parentId, bool root = false})` | Erzeugt eine Kopie mit den angegebenen Änderungen; alle übrigen Werte bleiben erhalten. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const entry = TxFileEntry(id: '1', name: 'hello.txt');
  print(entry.copyWith(name: 'renamed.txt').name);
}
```

<a id="de-txfileprovider"></a>
### TxFileProvider

Asynchroner Vertrag für Verzeichnislisten und Dateioperationen.

list ist erforderlich. Vue bietet optionale Methoden; Dart-Implementierungen deklarieren Fähigkeiten in capabilities und überschreiben die entsprechenden Methoden. Nicht implementierte Dart-Operationen werfen UnsupportedError. list/upload berücksichtigen kooperativen Abbruch. createDirectory/upload liefern einen Eintrag; rename/copy/move/remove keinen Wert; download liefert Blob (Vue) oder Uint8List (Dart).

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `Set<String> get capabilities` | Unterstützte Dateiaufgaben; steuert sichtbare Aktionen. |
| `Future<List<TxFileEntry>> list(String? parentId, {TxCancellation? cancellation})` | Liefert Einträge des angegebenen Elternordners; null liest die Wurzel. |
| `Future<TxFileEntry> createDirectory(String? parentId, String name)` | Legt einen Ordner mit gültigem, im Elternordner eindeutigem Namen an. |
| `Future<void> rename(String id, String name)` | Benennt eine Datei oder einen Ordner um; ID und Elternordner bleiben erhalten. |
| `Future<void> copy(String id, String? target)` | Kopiert einen Eintrag rekursiv in den Zielordner; neue IDs werden vergeben. |
| `Future<void> move(String id, String? target)` | Verschiebt einen Eintrag in den Zielordner; Zyklen werden abgelehnt. |
| `Future<void> remove(String id)` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |
| `Future<TxFileEntry> upload(String? parentId, TxFile file, {TxCancellation? cancellation})` | Lädt eine Datei in den angegebenen Ordner; liefert den neuen Dateieintrag. |
| `Future<Uint8List> download(String id)` | Liefert Dateiinhalt; Ordnerdownloads schlagen fehl. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxFileProvider provider = TxMemoryFileProvider();
  print(provider.capabilities);
  print(await provider.list(null));
}
```

<a id="de-txmemoryfileprovider"></a>
### TxMemoryFileProvider

Flüchtiger Datei-Provider mit rekursivem Kopieren/Löschen, Namensprüfung und Zyklusschutz; Daten überleben keinen Neustart.

Alle Dateioperationen sind asynchron. Ordner-IDs und Datei-IDs sind Strings, null als Eltern-/Ziel-ID bezeichnet die Wurzel. Ungültige Namen, Namenskollisionen, unbekannte IDs, doppelte IDs und Zyklen schlagen fehl. Kopieren erhält Inhalte, vergibt neue IDs und kopiert Unterordner. Entfernen löscht rekursiv. Ohne gespeicherten Inhalt ist der Download leer; Ordnerdownloads sind nicht möglich.

`TxMemoryFileProvider`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| entries | `List<TxFileEntry>` | `const []` | Anfängliche Datei-/Ordnereinträge des Speicher-Providers. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `Set<String> get capabilities` | Unterstützte Dateiaufgaben; steuert sichtbare Aktionen. |
| `Future<List<TxFileEntry>> list(String? parentId, {TxCancellation? cancellation})` | Liefert Einträge des angegebenen Elternordners; null liest die Wurzel. |
| `Future<TxFileEntry> createDirectory(String? parentId, String name)` | Legt einen Ordner mit gültigem, im Elternordner eindeutigem Namen an. |
| `Future<void> rename(String id, String name)` | Benennt eine Datei oder einen Ordner um; ID und Elternordner bleiben erhalten. |
| `Future<void> move(String id, String? target)` | Verschiebt einen Eintrag in den Zielordner; Zyklen werden abgelehnt. |
| `Future<void> copy(String id, String? target)` | Kopiert einen Eintrag rekursiv in den Zielordner; neue IDs werden vergeben. |
| `Future<void> remove(String id)` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |
| `Future<TxFileEntry> upload(String? parentId, TxFile file, {TxCancellation? cancellation})` | Lädt eine Datei in den angegebenen Ordner; liefert den neuen Dateieintrag. |
| `Future<Uint8List> download(String id)` | Liefert Dateiinhalt; Ordnerdownloads schlagen fehl. |

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final provider = TxMemoryFileProvider();
  final folder = await provider.createDirectory(null, 'Documents');
  final file = await provider.upload(folder.id, TxFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt'));
  await provider.rename(file.id, 'renamed.txt');
  await provider.copy(file.id, null);
  await provider.rename(file.id, 'moved.txt');
  await provider.move(file.id, null);
  print(await provider.list(null));
  print(await provider.download(file.id));
  await provider.remove(folder.id);
}
```

<a id="de-txfilestore"></a>
### txFileStore

Verbindet einen Provider und einen Getter des aktuellen Ordners mit einem abfragbaren Store.

Parameter: provider und parent als Getter der aktuellen Ordner-ID (null = Wurzel). Rückgabe: TxStore&lt;TxFileEntry&gt;. load liefert Promise/Future&lt;TxLoadResult&lt;TxFileEntry&gt;&gt;. Providerfehler werden weitergegeben. Nach einem Ordnerwechsel erneut laden.

```dart
TxStore<TxFileEntry> txFileStore(TxFileProvider provider, String? Function() parent)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final store = txFileStore(TxMemoryFileProvider(), () => null);
  print(await store.load(const TxLoadOptions()));
}
```

<a id="de-txuploadcontext"></a>
### TxUploadContext

Abbruch und Fortschrittsmeldung einer einzelnen Uploadoperation; Fortschritt wird in Bytes gemeldet.

`TxUploadContext`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| cancellation | `TxCancellation` | `erforderlich` | Token für kooperativen Abbruch. |
| onProgress | `void Function(int loaded, int total)` | `erforderlich` | Meldet abgeschlossene Bytes und Gesamtgröße. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final context = TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) => print(loaded));
  context.onProgress(10, 20);
}
```

<a id="de-txuploadadapter"></a>
### TxUploadAdapter

Asynchroner Callback für den Upload einer Datei; Ergebnis geht an den Erfolgs-Callback, Fehler an die Fehlerbehandlung.

```dart
typedef TxUploadAdapter = Future<Object?> Function(TxFile file, TxUploadContext context);
```

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxUploadAdapter adapter = (file, context) async {
    context.cancellation.throwIfCancelled();
    final size = await file.length();
    context.onProgress(size, size);
    return file.name;
  };
  print(await adapter(TxFile.fromData(Uint8List(0), name: 'empty.txt'), TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) {})));
}
```

<a id="de-txhttpuploadconfig"></a>
### TxHttpUploadConfig

Multipart-HTTP-Konfiguration mit Zieladresse, Feldern, Headern und optionalen Chunks.

`TxHttpUploadConfig`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| url | `Uri` | `erforderlich` | Zieladresse des Uploadservers. |
| fieldName | `String` | `'file'` | Multipart-Feldname der Datei. |
| headers | `Map<String, String>` | `const {}` | Zusätzliche HTTP-Header. |
| fields | `Map<String, String>` | `const {}` | Zusätzliche Multipart-Textfelder. |
| chunkSize | `int?` | `null` | Chunkgröße in Bytes; muss positiv sein. |
| chunkFields | `Map<String, String> Function(TxFile, int, int)?` | `null` | Felder je Chunk; Index ist nullbasiert. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final config = TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload'), fieldName: 'file', chunkSize: 1024 * 1024);
  final adapter = txHttpUpload(config);
  print(adapter);
}
```

<a id="de-txhttpupload"></a>
### txHttpUpload

Erzeugt einen Multipart-POST-Adapter. Der Server muss Chunks zusammensetzen. Nicht erfolgreiche HTTP-Antworten und Netzwerkfehler schlagen fehl.

Parameter: config mit erforderlicher URL; Rückgabe TxUploadAdapter. Der Adapter erhält file und context und liefert asynchron den letzten HTTP-Antworttext. fieldName = file; zusätzliche Felder/Header standardmäßig leer. chunkSize muss positiv sein; chunkFields erhält file, nullbasierten index und count. Abbruch und HTTP-/Netzwerkfehler lehnen die Operation ab. Kein automatisches JSON-Parsing und keine automatische serverseitige Chunk-Zusammenführung.

```dart
TxUploadAdapter txHttpUpload(TxHttpUploadConfig config)
```

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  // Requires your own multipart server with matching chunk assembly.
  final upload = txHttpUpload(TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload')));
  await upload(TxFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt'), TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) => print('$loaded/$total')));
}
```

<a id="de-txfileuploader"></a>
### TxFileUploader

Dateiauswahl und Uploadwarteschlange mit Größen-/Typprüfung, Fortschritt und Wiederholung ab Dateianfang.

`TxFileUploader`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| adapter | `TxUploadAdapter?` | `null` | Uploadfunktion für eine Datei. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| multiple | `bool` | `false` | Erlaubt mehrere Dateien. |
| maxFileSize | `int?` | `null` | Maximale Dateigröße in Bytes. |
| minFileSize | `int` | `0` | Minimale Dateigröße in Bytes. |
| extensions | `List<String>` | `const []` | Erlaubte Dateiendungen ohne Punkt. |
| instantly | `bool` | `false` | Startet gültige Dateien unmittelbar nach Auswahl. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| onUploaded | `void Function(TxFile, Object?)?` | `null` | Liefert die hochgeladene TxFile und das Adapterergebnis. |
| onError | `void Function(TxFile, Object)?` | `null` | Meldet Datei und Fehler einer fehlgeschlagenen Uploadoperation. |
| onChanged | `ValueChanged<List<TxFile>>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  // Replace with your server's multipart endpoint.
  final upload = txHttpUpload(TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload')));
  return TxFileUploader(adapter: upload, extensions: const ['txt']);
}
```

<a id="de-txfilemanager"></a>
### TxFileManager

Ordnernavigation und Dateiaktionen. Der Provider bestimmt die verfügbaren Operationen; kein Dateiserver enthalten.

`TxFileManager`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| provider | `TxFileProvider` | `erforderlich` | Datei-Provider mit unterstützten Operationen. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| height | `double` | `360` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| onSelectionChanged | `ValueChanged<List<TxFileEntry>>?` | `null` | Meldet selection; kontrollierten Zustand im Callback aktualisieren. |
| onFileOpened | `ValueChanged<TxFileEntry>?` | `null` | Meldet den aktivierten Dateieintrag. |
| onDownload | `void Function(TxFileEntry, Uint8List)?` | `null` | Liefert Dateieintrag und Bytes für eine eigene Speicherintegration. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final provider = TxMemoryFileProvider([const TxFileEntry(id: '1', name: 'Documents', isDirectory: true)]);
  return TxFileManager(provider: provider);
}
```

<a id="de-txfileexception"></a>
### TxFileException

Fehler einer Dateioperation mit optionaler ursprünglicher Ursache.

`TxFileException`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| message | `String` | `erforderlich` | Meldungstext. |
| cause | `Object?` | `null` | Ursprünglicher Plattformfehler, falls vorhanden. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `String toString()` | Liefert eine lesbare Fehlerbeschreibung. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const error = TxFileException('Cannot read file');
  print(error.message);
}
```

<a id="de-txfile"></a>
### TxFile

Eigener portabler Dateityp mit Bereichslesen und expliziter Ressourcenfreigabe. Keine Fremdpaketabhängigkeit.

`TxFile.fromData`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| bytes | `Uint8List` | `erforderlich` | Dateiinhalt im Speicher. |
| name | `String` | `erforderlich` | Name des Eingabefelds beziehungsweise Dateiname. |
| mimeType | `String?` | `null` | Optionaler MIME-Typ. |

`TxFile.fromPath`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| path | `String` | `erforderlich` | Nativer Dateipfad; im Browser nicht verfügbar. |
| name | `String?` | `null` | Name des Eingabefelds beziehungsweise Dateiname. |
| mimeType | `String?` | `null` | Optionaler MIME-Typ. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `String get name` | Name des Eingabefelds beziehungsweise Dateiname. |
| `String? get mimeType` | Optionaler MIME-Typ. |
| `String? get path` | Nativer Dateipfad; im Browser nicht verfügbar. |
| `Future<int> length()` | Liefert die Dateigröße in Bytes. |
| `Future<Uint8List> readAsBytes()` | Liest den gesamten Inhalt; für große Dateien openRead verwenden. |
| `Stream<List<int>> openRead([int start = 0, int? end])` | Liest start inklusive bis end exklusiv; Standard: gesamte Datei. |
| `Future<void> dispose()` | Beendet Abfragen und Listener; danach die Instanz nicht mehr verwenden. |

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final file = TxFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt');
  print(await file.readAsBytes());
  await file.dispose();
}
```

<a id="de-txfiledialogs"></a>
### TxFileDialogs

Eingebaute System-Dateidialoge für Dateiauswahl und Speichern; Abbruch liefert eine leere Liste oder false.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static Future<List<TxFile>> pickFiles({bool multiple = false, List<String> extensions = const []})` | Öffnet den Dateidialog. Ergebnisdateien nach Gebrauch mit dispose freigeben. |
| `static Future<bool> saveFile(TxFile file, {String? suggestedName})` | Speichert eine Datei; false bei Dialogabbruch. Im Web bedeutet true, dass der Download ausgelöst wurde. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final files = await TxFileDialogs.pickFiles(extensions: ['txt']);
  for (final file in files) {
    try { await TxFileDialogs.saveFile(file); } finally { await file.dispose(); }
  }
}
```

<a id="de-txcoordinate"></a>
### TxCoordinate

Geografische Breite und Länge in Grad.

`TxCoordinate`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| lat | `double` | `erforderlich` | Geografische Breite in Grad. |
| lng | `double` | `erforderlich` | Geografische Länge in Grad. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const point = TxCoordinate(52.52, 13.405);
  print(point.lat);
}
```

<a id="de-txmapmarker"></a>
### TxMapMarker

Koordinate mit eindeutiger ID und optionalem Popuptext und Farbe.

`TxMapMarker`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| lat | `double` | `erforderlich` | Geografische Breite in Grad. |
| lng | `double` | `erforderlich` | Geografische Länge in Grad. |
| id | `Object` | `erforderlich` | Eindeutige stabile ID. |
| text | `String?` | `null` | Anzuzeigender Text. |
| color | `Color?` | `null` | Darstellungsfarbe. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const marker = TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin');
  print(marker.text);
}
```

<a id="de-txmaproute"></a>
### TxMapRoute

Darzustellende Routenlinie aus Koordinaten; berechnet keine Route.

`TxMapRoute`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| id | `Object` | `erforderlich` | Eindeutige stabile ID. |
| points | `List<TxCoordinate>` | `erforderlich` | Koordinaten der Routenlinie in Reihenfolge. |
| color | `Color` | `Colors.blue` | Darstellungsfarbe. |
| width | `double` | `3` | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const route = TxMapRoute(id: 'walk', points: [TxCoordinate(52.52, 13.405), TxCoordinate(52.53, 13.41)]);
  print(route.points.length);
}
```

<a id="de-txgeoadapter"></a>
### TxGeoAdapter

Vertrag eigener Geocoding-/Routing-Dienste. Dienste selbst aufrufen und Ergebnisse an die Karte binden.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `Future<List<TxCoordinate>> geocode(String query, {TxCancellation? cancellation})` | Fragt den eigenen Geodienst nach Koordinaten für einen Suchtext. |
| `Future<List<TxCoordinate>> route(List<TxCoordinate> points, {TxCancellation? cancellation})` | Fragt den eigenen Routingdienst nach einer Route durch die Wegpunkte. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  // An implementation is supplied by your application.
  Future<void> locate(TxGeoAdapter adapter) async {
    final points = await adapter.geocode('Berlin');
    if (points.length >= 2) print(await adapter.route(points));
  }
  print(locate);
}
```

<a id="de-txproject"></a>
### txProject

Projiziert geografische Koordinaten in Web-Mercator-Weltpixel bei gegebenem Zoom; begrenzt die Breite auf etwa ±85,05°.

Parameter: point mit lat/lng in Grad und zoom. Rückgabe synchron: { x, y } in Vue, Offset in Dart; Weltpixel, keine Pixel relativ zum sichtbaren Kartenausschnitt.

```dart
Offset txProject(TxCoordinate point, double zoom)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(txProject(const TxCoordinate(52.52, 13.405), 5));
}
```

<a id="de-txunproject"></a>
### txUnproject

Wandelt Web-Mercator-Weltpixel beim gleichen Zoom zurück in geografische Koordinaten.

Parameter: Vue x, y, zoom; Dart Offset point, zoom. Rückgabe synchron TxCoordinate mit lat/lng in Grad; denselben Zoom wie bei txProject verwenden.

```dart
TxCoordinate txUnproject(Offset point, double zoom)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final pixel = txProject(const TxCoordinate(52.52, 13.405), 5);
  print(txUnproject(pixel, 5).lat);
}
```

<a id="de-txmap"></a>
### TxMap

Karte mit Pan/Zoom, Markern und Routenlinien. Ohne tileUrl bleibt die Fläche neutral; Quellen und Attribution richtet die Anwendung ein.

`TxMap`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| center | `TxCoordinate` | `const TxCoordinate(52.52, 13.405)` | Geografischer Kartenmittelpunkt. |
| zoom | `int` | `5` | Kartenzoomstufe. |
| minZoom | `int` | `1` | Kleinste Zoomstufe. |
| maxZoom | `int` | `19` | Größte Zoomstufe. |
| tileUrl | `String?` | `null` | Kachel-URL mit Platzhaltern {z}/{x}/{y}. |
| attribution | `String?` | `null` | Quellen-/Lizenzhinweis des Kartenanbieters. |
| markers | `List<TxMapMarker>` | `const []` | Darzustellende Kartenmarker. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| routes | `List<TxMapRoute>` | `const []` | Darzustellende Routenlinien. |
| routeDataSource | `Object?` | `null` | Separate Datenquelle für Routenlinien. |
| onCenterChanged | `ValueChanged<TxCoordinate>?` | `null` | Meldet center; kontrollierten Zustand im Callback aktualisieren. |
| onZoomChanged | `ValueChanged<int>?` | `null` | Meldet zoom; kontrollierten Zustand im Callback aktualisieren. |
| onMarkerClick | `ValueChanged<TxMapMarker>?` | `null` | Aktivierter TxMapMarker. |
| height | `double` | `360` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxMap(markers: [TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin')]);
}
```

<a id="de-txbuttontype"></a>
### TxButtonType

Darstellungsvarianten einer Schaltfläche.

```dart
enum TxButtonType {normal, primary, danger, success}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxButtonType.values);
}
```

<a id="de-txselectionmode"></a>
### TxSelectionMode

Keine, einfache oder mehrfache Auswahl.

```dart
enum TxSelectionMode {none, single, multiple}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxSelectionMode.values);
}
```

<a id="de-txschedulerview"></a>
### TxSchedulerView

Tages-, Wochen- oder Monatsansicht.

```dart
enum TxSchedulerView {day, week, month}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxSchedulerView.values);
}
```

<a id="de-txmessagestatus"></a>
### TxMessageStatus

Lokaler Anzeigestatus einer Nachricht; keine Zustellbestätigung.

```dart
enum TxMessageStatus {pending, sent, error}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxMessageStatus.values);
}
```

<a id="de-txcardvariant"></a>
### TxCardVariant

Kartenvarianten mit Rahmen, Schatten oder Füllung.

```dart
enum TxCardVariant {outlined, elevated, filled}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxCardVariant.values);
}
```

<a id="de-txchange"></a>
### TxChange

Synchron veränderbares Vorereignis. cancel = true verhindert die vorgesehene Änderung.

`TxChange`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| data | `T` | `erforderlich` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| ` bool cancel = false` | Synchron auf true setzen, um die Aktion abzubrechen. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final change = TxChange<int>(1);
  change.cancel = true;
  print(change.data);
}
```

<a id="de-txvaluechange"></a>
### TxValueChange

Neuer und vorheriger Eingabewert.

`TxValueChange`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `T` | `erforderlich` | Aktueller Eingabe-/Optionswert. |
| previousValue | `T` | `erforderlich` | Wert vor der Änderung. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const change = TxValueChange(value: 2, previousValue: 1);
  print(change.value);
}
```

<a id="de-txitem"></a>
### TxItem

Typisierte Auswahloption mit Wert, Text und optionaler Gruppe oder Symbol.

`TxItem`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `T` | `erforderlich` | Aktueller Eingabe-/Optionswert. |
| text | `String` | `erforderlich` | Anzuzeigender Text. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| group | `String?` | `null` | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| icon | `IconData?` | `null` | Symbol der Aktion. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const option = TxItem(value: 1, text: 'One');
  print(option.value);
}
```

<a id="de-txmenuitem"></a>
### TxMenuItem

Reiter-/Menüeintrag mit Text, Symbol und Sperrzustand.

`TxMenuItem`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| text | `String` | `erforderlich` | Anzuzeigender Text. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| icon | `IconData?` | `null` | Symbol der Aktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const item = TxMenuItem('Home', icon: Icons.home);
  print(item.text);
}
```

<a id="de-txcolumn"></a>
### TxColumn

Spaltenkonfiguration des DataGrid; keine eigenständige Oberfläche.

`TxColumn`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| caption | `String` | `erforderlich` | Sichtbare Feld-/Spaltenüberschrift. |
| valueGetter | `Object? Function(T row)` | `erforderlich` | Liest den darzustellenden Feldwert. |
| dataField | `String?` | `null` | Feldname; muss im Grid eindeutig sein. |
| width | `double` | `160` | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| allowSorting | `bool` | `true` | Erlaubt Sortierung dieser Spalte. |
| allowFiltering | `bool` | `true` | Erlaubt Filtern dieser Spalte. |
| visible | `bool` | `true` | Steuert die Sichtbarkeit. |
| alignment | `Alignment` | `Alignment.centerLeft` | Ausrichtung des Inhalts. |
| cellBuilder | `Widget Function(BuildContext context, T row, Object? value)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final rows = <Map<String, Object>>[{'id': 1, 'name': 'Alex'}];
  return TxDataGrid<Map<String, Object>>(dataSource: rows, keyOf: (row) => row['id']!, columns: [TxColumn(caption: 'Name', valueGetter: (row) => row['name'], cellBuilder: (context, row, value) => Text('$value'))]);
}
```

<a id="de-txcardfield"></a>
### TxCardField

Feld einer Karte mit Beschriftung, Getter und optionalem Builder.

`TxCardField`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| caption | `String` | `erforderlich` | Sichtbare Feld-/Spaltenüberschrift. |
| valueGetter | `Object? Function(T row)` | `erforderlich` | Liest den darzustellenden Feldwert. |
| builder | `Widget Function(BuildContext context, T row, Object? value)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final field = TxCardField<int>(caption: 'Number', valueGetter: (v) => v);
  print(field.valueGetter(1));
}
```

<a id="de-txselection"></a>
### TxSelection

Unveränderliche Auswahl mit Schlüsseln und zugehörigen Datensätzen.

`TxSelection`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| keys | `Iterable<Object>` | `erforderlich` | Stabile Schlüssel der Auswahl. |
| data | `Iterable<T>` | `erforderlich` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final selection = TxSelection<int>(keys: [1], data: [1]);
  print(selection.keys);
}
```

<a id="de-txappointment"></a>
### TxAppointment

Unveränderlicher Termin mit validiertem Schlüssel, Titel und Ende nach Beginn. Ganztagsgrenzen müssen lokale Mitternacht sein.

`TxAppointment`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| id | `Object` | `erforderlich` | Eindeutige stabile ID. |
| text | `String` | `erforderlich` | Anzuzeigender Text. |
| startDate | `DateTime` | `erforderlich` | Termin-/Zellenbeginn. |
| endDate | `DateTime` | `erforderlich` | Termin-/Zellenende, bei Ganztag exklusiv. |
| allDay | `bool` | `false` | Ganztagstermin mit lokalen Tagesgrenzen. |
| description | `String` | `''` | Optionale Terminbeschreibung. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `TxAppointment copyWith({String? text, DateTime? startDate, DateTime? endDate, bool? allDay, String? description})` | Erzeugt eine Kopie mit den angegebenen Änderungen; alle übrigen Werte bleiben erhalten. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final meeting = TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10));
  print(meeting.copyWith(text: 'Updated').text);
}
```

<a id="de-txappointmentupdate"></a>
### TxAppointmentUpdate

Alter und vorgeschlagener neuer Termin einer Aktualisierung.

`TxAppointmentUpdate`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| oldData | `TxAppointment` | `erforderlich` | Vorheriger Datensatz. |
| newData | `TxAppointment` | `erforderlich` | Neuer vorgeschlagener Datensatz. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final old = TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10));
  final update = TxAppointmentUpdate(oldData: old, newData: old.copyWith(text: 'Updated'));
  print(update.newData.text);
}
```

<a id="de-txschedulerediting"></a>
### TxSchedulerEditing

Berechtigungen zum Anlegen, Ändern und Löschen von Terminen; none sperrt alle drei Aktionen.

`TxSchedulerEditing`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| allowAdding | `bool` | `true` | Erlaubt neue Termine. |
| allowUpdating | `bool` | `true` | Erlaubt Terminänderungen. |
| allowDeleting | `bool` | `true` | Zeigt Aktionen zum Löschen von Listeneinträgen. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const editing = TxSchedulerEditing(allowDeleting: false);
  print(editing.allowAdding);
  print(const TxSchedulerEditing.none().allowAdding);
}
```

<a id="de-txchatuser"></a>
### TxChatUser

Autor mit validiertem Schlüssel und nicht leerem Namen.

`TxChatUser`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| id | `Object` | `erforderlich` | Eindeutige stabile ID. |
| name | `String` | `erforderlich` | Name des Eingabefelds beziehungsweise Dateiname. |
| avatarUrl | `String?` | `null` | Optionale Avatar-Bildadresse. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final user = TxChatUser(id: 'me', name: 'Alex');
  print(user.name);
}
```

<a id="de-txchatmessage"></a>
### TxChatMessage

Unveränderliche Nachricht mit Autor, Zeitstempel und nicht leerem Text.

`TxChatMessage`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| id | `Object` | `erforderlich` | Eindeutige stabile ID. |
| text | `String` | `erforderlich` | Anzuzeigender Text. |
| timestamp | `DateTime` | `erforderlich` | Zeitpunkt der Nachricht. |
| author | `TxChatUser` | `erforderlich` | Autor der Nachricht. |
| status | `TxMessageStatus` | `TxMessageStatus.sent` | Lokaler Nachrichtenstatus. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final message = TxChatMessage(id: 1, text: 'Hello', timestamp: DateTime.now(), author: TxChatUser(id: 'me', name: 'Alex'));
  print(message.text);
}
```

<a id="de-txvalidatekey"></a>
### txValidateKey

Prüft einen Schlüssel; andere Typen als String und int werfen ArgumentError.

Parameter key ist Object. Erfolgreiche Prüfung liefert void; andere Typen als String/int werfen ArgumentError.

```dart
void txValidateKey(Object key)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  txValidateKey('id-1'); // valid
}
```

<a id="de-txvalidatekeys"></a>
### txValidateKeys

Prüft Schlüsseltypen und Eindeutigkeit einer Liste; ungültige oder doppelte Schlüssel werfen ArgumentError.

Parameter items ist die Liste, keyOf liest jeden Schlüssel. Erfolgreiche Prüfung liefert void; ungültige oder doppelte Schlüssel werfen ArgumentError.

```dart
void txValidateKeys<T>(List<T> items, Object Function(T) keyOf)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  txValidateKeys<Map<String, Object>>([{'id': 1}], (row) => row['id']!);
}
```

<a id="de-txtabs"></a>
### TxTabs

Reiternavigation mit optionalem Inhalt des aktiven Reiters.

`TxTabs`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxMenuItem>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| selectedIndex | `int?` | `null` | Nullbasierter aktiver Eintrag. |
| initialIndex | `int` | `0` | Anfänglicher Reiter im unkontrollierten Modus. |
| onChanged | `ValueChanged<int>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| builder | `Widget Function(BuildContext context, int selectedIndex)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| label | `String` | `'Reiter'` | Beschriftung beziehungsweise zugänglicher Name. |
| orientation | `Axis` | `Axis.horizontal` | Ausrichtung der Reiter. |
| swipeEnabled | `bool` | `false` | Erlaubt Reiterwechsel durch Wischen. |
| animationEnabled | `bool` | `true` | Aktiviert Inhaltsübergänge. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxTabs(items: const [TxMenuItem('Home'), TxMenuItem('Settings')], builder: (context, index) => Text('Page $index'));
}
```

<a id="de-txtoolbar"></a>
### TxToolbar

Werkzeugleiste mit Hauptinhalt und nachgestellten Aktionen.

`TxToolbar`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| children | `List<Widget>` | `const []` | Unterfilter beziehungsweise enthaltene Widgets. |
| after | `List<Widget>` | `const []` | Nachgestellte Toolbar-Aktionen. |
| label | `String` | `'Werkzeugleiste'` | Beschriftung beziehungsweise zugänglicher Name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxToolbar(children: [TxButton(text: 'Save', onPressed: () {})], after: const [Text('Ready')]);
}
```

<a id="de-txmenu"></a>
### TxMenu

Flache Liste von Menüaktionen; verschachtelte Aktionen gehören ins ContextMenu.

`TxMenu`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxMenuItem>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| onItemClick | `void Function(TxMenuItem item, int index)?` | `null` | Meldet den aktivierten Eintrag; Parameter gemäß der Callbacksignatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| label | `String` | `'Menü'` | Beschriftung beziehungsweise zugänglicher Name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var saved = false;
  return StatefulBuilder(
    builder: (context, setState) => TxMenu(items: const [TxMenuItem('Home')], onItemClick: (item, index) => setState(() => saved = true)),
  );
}
```

<a id="de-txpopup"></a>
### TxPopup

Dialog mit Titel und Inhalt. Vorereignisse können synchron abgebrochen werden; externe Sichtbarkeit bleibt maßgeblich.

`TxPopup`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| visible | `bool` | `erforderlich` | Steuert die Sichtbarkeit. |
| child | `Widget` | `erforderlich` | Inhalt beziehungsweise Zielwidget. |
| title | `String` | `'Dialog'` | Titel der Ansicht. |
| actions | `List<Widget>` | `const []` | Aktionen des Dialogs beziehungsweise der Karte. |
| onVisibleChanged | `ValueChanged<bool>?` | `null` | Meldet visible; kontrollierten Zustand im Callback aktualisieren. |
| onShown | `VoidCallback?` | `null` | Nach Anzeige, ohne Payload. |
| onHidden | `VoidCallback?` | `null` | Nach Verbergen, ohne Payload. |
| showCloseButton | `bool` | `true` | Zeigt die Schließen-Aktion. |
| hideOnOutsideClick | `bool` | `false` | Erlaubt Schließen über den Außenbereich. |
| width | `double` | `480` | Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| height | `double?` | `null` | Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln. |
| fullScreen | `bool` | `false` | Füllt den Bildschirm. |
| dragEnabled | `bool` | `false` | Erlaubt das Verschieben des Dialogs. |
| resizeEnabled | `bool` | `false` | Erlaubt Größenänderungen des Dialogs. |
| alignment | `Alignment` | `Alignment.center` | Ausrichtung des Inhalts. |
| onShowing | `ValueChanged<TxChange<bool>>?` | `null` | Vor Anzeige: TxChange&lt;bool&gt;; cancel synchron setzen, um abzubrechen. |
| onHiding | `ValueChanged<TxChange<bool>>?` | `null` | Vor benutzerinitiiertem Schließen: TxChange&lt;bool&gt;; synchron abbrechbar. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static Future<T?> show<T>(BuildContext context, {required String title, required Widget child, List<Widget> actions = const [], double width = 480, bool hideOnOutsideClick = false})` | Öffnet die native Overlay-Alternative; den Rückgabevertrag der jeweiligen Signatur beachten. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var visible = false;
  return StatefulBuilder(
    builder: (context, setState) => Column(mainAxisSize: MainAxisSize.min, children: [TxButton(text: 'Open', onPressed: () => setState(() => visible = true)), TxPopup(visible: visible, onVisibleChanged: (v) => setState(() => visible = v), child: const Text('Hello'))]),
  );
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> open(BuildContext context) async {
  final result = await TxPopup.show<bool>(context, title: 'Confirm', child: const Text('Continue?'), actions: [Builder(builder: (dialogContext) => TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('OK')))]);
  debugPrint('$result');
}
```

<a id="de-txtooltip"></a>
### TxTooltip

Hinweis zum Zielinhalt mit Verzögerung und optional eigenem Inhalt.

`TxTooltip`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| text | `String` | `erforderlich` | Anzuzeigender Text. |
| child | `Widget` | `erforderlich` | Inhalt beziehungsweise Zielwidget. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| waitDuration | `Duration` | `Duration.zero` | Wartezeit vor dem Tooltip. |
| showDuration | `Duration` | `const Duration(seconds: 3)` | Dauer des Tooltips nach Aktivierung. |
| preferBelow | `bool` | `false` | Bevorzugt die Position unter dem Ziel. |
| triggerMode | `TooltipTriggerMode` | `TooltipTriggerMode.longPress` | Native Tooltip-Aktivierungsart. |
| visible | `bool?` | `null` | Steuert die Sichtbarkeit. |
| content | `Widget?` | `null` | Eigener Inhalt beziehungsweise Dateiinhalt als Blob. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxTooltip(text: 'More information', child: Text('Help'));
}
```

<a id="de-txtoasttype"></a>
### TxToastType

Statusfarben einer Meldung: Info, Erfolg, Warnung oder Fehler.

```dart
enum TxToastType {info, success, warning, error}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxToastType.values);
}
```

<a id="de-txtoast"></a>
### TxToast

Zeitlich begrenzte Statusmeldung; Sichtbarkeitsänderungen in der Anwendung übernehmen.

`TxToast`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| visible | `bool` | `erforderlich` | Steuert die Sichtbarkeit. |
| message | `String` | `erforderlich` | Meldungstext. |
| onVisibleChanged | `ValueChanged<bool>?` | `null` | Meldet visible; kontrollierten Zustand im Callback aktualisieren. |
| type | `TxToastType` | `TxToastType.info` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |
| displayTime | `Duration` | `const Duration(milliseconds: 3500)` | Anzeigedauer; 0 beziehungsweise Duration.zero bleibt offen. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static void show(BuildContext context, String message, {TxToastType type = TxToastType.info, Duration displayTime = const Duration(milliseconds: 3500)})` | Öffnet die native Overlay-Alternative; den Rückgabevertrag der jeweiligen Signatur beachten. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var visible = false;
  return StatefulBuilder(
    builder: (context, setState) => Column(mainAxisSize: MainAxisSize.min, children: [TxButton(text: 'Notify', onPressed: () => setState(() => visible = true)), TxToast(visible: visible, message: 'Saved', onVisibleChanged: (v) => setState(() => visible = v))]),
  );
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

void showToast(BuildContext context) {
  TxToast.show(context, 'Saved', type: TxToastType.success);
}
```

<a id="de-txloadindicator"></a>
### TxLoadIndicator

Zugängliche Ladeanzeige mit Beschriftung.

`TxLoadIndicator`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| visible | `bool` | `true` | Steuert die Sichtbarkeit. |
| label | `String` | `'Wird geladen …'` | Beschriftung beziehungsweise zugänglicher Name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxLoadIndicator(label: 'Loading');
}
```

<a id="de-txrangeslider"></a>
### TxRangeSlider

Auswahl eines Intervalls mit zwei Grenzen, Schritten und Mindest-/Höchstabstand.

`TxRangeSlider`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `RangeValues` | `erforderlich` | Aktueller Eingabe-/Optionswert. |
| onChanged | `ValueChanged<RangeValues>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| min | `double` | `0` | Untere zulässige Grenze. |
| max | `double` | `100` | Obere zulässige Grenze. |
| step | `double` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| minRange | `double` | `0` | Mindestabstand zwischen den Bereichsgrenzen. |
| maxRange | `double?` | `null` | Höchstabstand zwischen den Bereichsgrenzen. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| format | `String Function(double)?` | `null` | Formatiert Bereichswerte für die Anzeige. |
| label | `String` | `'Bereich'` | Beschriftung beziehungsweise zugänglicher Name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var range = const RangeValues(20, 80);
  return StatefulBuilder(
    builder: (context, setState) => TxRangeSlider(value: range, onChanged: (v) => setState(() => range = v)),
  );
}
```

<a id="de-txrangeselector"></a>
### TxRangeSelector

Intervallauswahl über einer einfachen Flächen-, Linien- oder Balkenserie.

`TxRangeSelector.date`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `DateTimeRange` | `erforderlich` | Aktueller Eingabe-/Optionswert. |
| min | `DateTime` | `erforderlich` | Untere zulässige Grenze. |
| max | `DateTime` | `erforderlich` | Obere zulässige Grenze. |
| step | `Duration` | `const Duration(days: 1)` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| onChanged | `ValueChanged<DateTimeRange>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| items | `List<T>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| argumentOf | `DateTime Function(T)` | `erforderlich` | Getter der numerischen oder zeitlichen X-Achse. |
| valueOf | `double Function(T)` | `erforderlich` | Getter des numerischen Serienwerts. |
| format | `String Function(DateTime)?` | `null` | Formatiert Bereichswerte für die Anzeige. |
| seriesType | `String` | `'area'` | Seriendarstellung area/line/bar. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |

`TxRangeSelector`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| value | `RangeValues` | `erforderlich` | Aktueller Eingabe-/Optionswert. |
| min | `double` | `erforderlich` | Untere zulässige Grenze. |
| max | `double` | `erforderlich` | Obere zulässige Grenze. |
| step | `double` | `1` | Schrittweite; bei zeitlichen Vue-Bereichen in Millisekunden. |
| onChanged | `ValueChanged<RangeValues>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| items | `List<T>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| argumentOf | `double Function(T)` | `erforderlich` | Getter der numerischen oder zeitlichen X-Achse. |
| valueOf | `double Function(T)` | `erforderlich` | Getter des numerischen Serienwerts. |
| format | `String Function(double)?` | `null` | Formatiert Bereichswerte für die Anzeige. |
| seriesType | `String` | `'area'` | Seriendarstellung area/line/bar. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var range = const RangeValues(20, 80);
  return StatefulBuilder(
    builder: (context, setState) => TxRangeSelector<double>(value: range, min: 0, max: 100, items: const [20, 80], argumentOf: (v) => v, valueOf: (v) => v / 2, onChanged: (v) => setState(() => range = v)),
  );
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget dateRange() => TxRangeSelector<DateTime>.date(value: DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 10)), min: DateTime(2026, 10, 1), max: DateTime(2026, 11, 1), items: [DateTime(2026, 10, 5)], argumentOf: (date) => date, valueOf: (date) => 1, onChanged: (value) => debugPrint('$value'));
```

<a id="de-txscheduler"></a>
### TxScheduler

Tag-, Wochen- und Monatskalender mit Terminbearbeitung. Ganztagsenden sind exklusiv; keine Serien, Ressourcen oder Drag-and-drop.

`TxScheduler`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| onDataSourceChanged | `ValueChanged<List<TxAppointment>>?` | `null` | Meldet dataSource; kontrollierten Zustand im Callback aktualisieren. |
| currentDate | `DateTime?` | `null` | Aktueller Kalendertag; für Navigation kontrollierten Wert aktualisieren. |
| onCurrentDateChanged | `ValueChanged<DateTime>?` | `null` | Meldet currentDate; kontrollierten Zustand im Callback aktualisieren. |
| currentView | `TxSchedulerView?` | `null` | Aktuelle Kalenderansicht. |
| onCurrentViewChanged | `ValueChanged<TxSchedulerView>?` | `null` | Meldet currentView; kontrollierten Zustand im Callback aktualisieren. |
| views | `List<TxSchedulerView>` | `const [TxSchedulerView.day, TxSchedulerView.week, TxSchedulerView.month]` | Angebotene Kalenderansichten. |
| firstDayOfWeek | `int` | `1` | Erster Wochentag; 1 = Montag. |
| startDayHour | `int` | `8` | Erste sichtbare Tagesstunde. |
| endDayHour | `int` | `18` | Letzte sichtbare Tagesstunde. |
| cellDuration | `int` | `30` | Länge einer Kalenderzelle in Minuten. |
| editing | `TxSchedulerEditing` | `const TxSchedulerEditing()` | Berechtigungen zum Anlegen, Ändern und Löschen. |
| readOnly | `bool` | `false` | Verhindert Änderungen des Werts. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| loading | `bool` | `false` | Zeigt den Ladezustand. |
| locale | `String` | `'de'` | Locale für Datums-/Zeitformatierung. |
| label | `String` | `'Terminplaner'` | Beschriftung beziehungsweise zugänglicher Name. |
| appointmentBuilder | `Widget Function(BuildContext context, TxAppointment item, TxSchedulerView view)?` | `null` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| onAppointmentClick | `ValueChanged<TxAppointment>?` | `null` | Meldet den aktivierten TxAppointment. |
| onCellClick | `void Function(DateTime start, DateTime end, bool allDay)?` | `null` | Meldet Zellenbeginn, Zellenende und Ganztagskennzeichen als drei Argumente. |
| onAppointmentAdding | `ValueChanged<TxChange<TxAppointment>>?` | `null` | Vor Anlegen: TxChange&lt;TxAppointment&gt;; cancel synchron setzen, um abzubrechen. |
| onAppointmentUpdating | `ValueChanged<TxChange<TxAppointmentUpdate>>?` | `null` | Vor Ändern: TxChange&lt;TxAppointmentUpdate&gt; mit altem und neuem Termin; synchron abbrechbar. |
| onAppointmentDeleting | `ValueChanged<TxChange<TxAppointment>>?` | `null` | Vor Löschen: TxChange&lt;TxAppointment&gt;; cancel synchron setzen, um abzubrechen. |
| onAppointmentAdded | `ValueChanged<TxAppointment>?` | `null` | Meldet den lokal angelegten TxAppointment. |
| onAppointmentUpdated | `ValueChanged<TxAppointmentUpdate>?` | `null` | Meldet TxAppointmentUpdate mit altem und neuem Termin. |
| onAppointmentDeleted | `ValueChanged<TxAppointment>?` | `null` | Meldet den lokal gelöschten TxAppointment. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var appointments = [TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10))];
  return StatefulBuilder(
    builder: (context, setState) => TxScheduler(dataSource: appointments, onDataSourceChanged: (v) => setState(() => appointments = v)),
  );
}
```

<a id="de-txtabpanel"></a>
### TxTabPanel

Reiter und zugehöriger aktiver Inhalt in einer gemeinsamen Ansicht.

`TxTabPanel`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<TxMenuItem>` | `const []` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| dataSource | `Object?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| selectedIndex | `int?` | `null` | Nullbasierter aktiver Eintrag. |
| onChanged | `ValueChanged<int>?` | `null` | Callback für changed; Argumente und Rückgabetyp siehe Signatur. |
| builder | `Widget Function(BuildContext, int)` | `erforderlich` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |
| disabled | `bool` | `false` | Sperrt die Interaktion. |
| orientation | `Axis` | `Axis.horizontal` | Ausrichtung der Reiter. |
| swipeEnabled | `bool` | `false` | Erlaubt Reiterwechsel durch Wischen. |
| animationEnabled | `bool` | `true` | Aktiviert Inhaltsübergänge. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxTabPanel(items: const [TxMenuItem('Home')], builder: (context, index) => Text('Page $index'));
}
```

<a id="de-txloadpanel"></a>
### TxLoadPanel

Ladeoverlay, gesteuert durch Sichtbarkeit oder den Ladezustand einer DataSource.

`TxLoadPanel`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| visible | `bool?` | `null` | Steuert die Sichtbarkeit. |
| dataSource | `TxDataSource<dynamic>?` | `null` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| message | `String` | `'Wird geladen …'` | Meldungstext. |
| delay | `Duration` | `Duration.zero` | Wartezeit vor Anzeige des Ladeoverlays. |
| shading | `bool` | `true` | Zeigt eine abgedunkelte Hintergrundfläche. |
| child | `Widget?` | `null` | Inhalt beziehungsweise Zielwidget. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const SizedBox(height: 160, child: TxLoadPanel(visible: true, child: Center(child: Text('Content'))));
}
```

<a id="de-txnotifyhandle"></a>
### TxNotifyHandle

Handle zum Schließen oder Aktualisieren einer bestehenden Benachrichtigung.

`TxNotifyHandle`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| close | `VoidCallback` | `erforderlich` | Schließt die zugehörige Benachrichtigung. |
| update | `void Function({String? message, TxToastType? type, Duration? displayTime})` | `erforderlich` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  // Obtain the handle inside a widget callback, below MaterialApp.
  void showMessage(BuildContext context) {
    final handle = txNotify(context, message: 'Working', displayTime: Duration.zero);
    handle.update(message: 'Done', type: TxToastType.success);
    handle.close();
  }
  print(showMessage);
}
```

<a id="de-txnotify"></a>
### txNotify

Zeigt eine gestapelte Meldung im Overlay des Kontexts. Standard: info, 3500 ms, unten rechts; Duration.zero bleibt offen.

Parameter context muss unter einem Overlay liegen, üblicherweise innerhalb einer MaterialApp-Route. message ist erforderlich. Rückgabe synchron TxNotifyHandle; close() liefert void, update({message, type, displayTime}) ändert die Meldung und setzt deren Timer neu. Eigene actionText/onAction sind optional. Das Handle vor Entsorgen des besitzenden Overlays schließen.

```dart
TxNotifyHandle txNotify(BuildContext context, {required String message, TxToastType type = TxToastType.info, Duration displayTime = const Duration(milliseconds: 3500), Alignment position = Alignment.bottomRight, String? actionText, VoidCallback? onAction})
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  void showMessage(BuildContext context) {
    final handle = txNotify(context, message: 'Saved');
    handle.update(message: 'Updated');
    handle.close();
  }
  print(showMessage);
}
```

<a id="de-txkeyof"></a>
### TxKeyOf

Getter für den stabilen eindeutigen Schlüssel eines Datensatzes.

```dart
typedef TxKeyOf<T> = Object Function(T item);
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxKeyOf<int> keyOf = (item) => item;
  print(keyOf(1));
}
```

<a id="de-txgetter"></a>
### TxGetter

Typisierter Getter zum Lesen von Abfragewerten.

```dart
typedef TxGetter<T> = Object? Function(T item);
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxGetter<int> getter = (item) => item * 2;
  print(getter(3));
}
```

<a id="de-txsort"></a>
### TxSort

Sortier- oder Gruppierungsbeschreibung mit Selector und absteigender Richtung.

`TxSort`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| selector | `TxGetter<T>` | `erforderlich` | Feldpfad oder Getter des Abfragewerts. |
| desc | `bool` | `false` | Absteigende Sortierung. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final sort = TxSort<int>((v) => v, desc: true);
  print(txQuery([1, 2], TxLoadOptions(sort: [sort])).data);
}
```

<a id="de-txfilteroperator"></a>
### TxFilterOperator

Vergleichs- und Textoperatoren für TxFilter.

```dart
enum TxFilterOperator {equal, notEqual, greater, greaterOrEqual, less, lessOrEqual, contains, startsWith, endsWith}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxFilterOperator.values);
}
```

<a id="de-txfilter"></a>
### TxFilter

Vergleichs-/Textfilter und verschachtelte UND-, ODER- und NICHT-Verknüpfungen.

Standardoperator ist Gleichheit. Textoperatoren ignorieren Groß-/Kleinschreibung. Leeres AND ist wahr, leeres OR ist falsch. Dart matches(item) liefert bool, Vue txMatches(item, filter) boolean. Getterfehler werden weitergegeben.

`TxFilter`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| selector | `TxGetter<T>?` | `erforderlich` | Feldpfad oder Getter des Abfragewerts. |
| value | `Object?` | `erforderlich` | Aktueller Eingabe-/Optionswert. |
| operator | `TxFilterOperator` | `TxFilterOperator.equal` | Vergleichs-/Textoperator. |

`TxFilter.and`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| filters | `List<TxFilter<T>>` | `erforderlich` | Unterfilter der logischen Verknüpfung. |

`TxFilter.or`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| filters | `List<TxFilter<T>>` | `erforderlich` | Unterfilter der logischen Verknüpfung. |

`TxFilter.not`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| filter | `TxFilter<T>` | `erforderlich` | Filterausdruck. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `final List<TxFilter<T>>? children` | Unterfilter beziehungsweise enthaltene Widgets. |
| `final String? junction` | Verknüpfung and/or/not eines zusammengesetzten Filters. |
| `bool matches(T item)` | Prüft synchron einen Datensatz gegen diesen Filter. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final adult = TxFilter<int>((v) => v, 18, operator: TxFilterOperator.greaterOrEqual);
  print(adult.matches(20));
  print(TxFilter.and([adult, TxFilter.not(TxFilter<int>((v) => v, 30))]).matches(20));
  print(TxFilter.or([adult]).matches(20));
}
```

<a id="de-txsourcecompare"></a>
### txSourceCompare

Vergleicht null, Zahlen, Datumswerte oder kleingeschriebene Textdarstellungen; liefert einen negativen Wert, null oder einen positiven Wert.

Parameter a/b dürfen null sein. null sortiert vor anderen Werten. Zahlen und DateTime werden numerisch/zeitlich verglichen, andere Werte als kleingeschriebener Text. Rückgabe int wie compareTo.

```dart
int txSourceCompare(Object? a, Object? b)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(txSourceCompare(1, 2)); // negative
}
```

<a id="de-txcancellation"></a>
### TxCancellation

Kooperativer Abbruch mit einmaligen Listenern; throwIfCancelled wirft bei Abbruch StateError.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| ` bool isCancelled = false` | Ob der Abbruch bereits ausgelöst wurde. |
| `void cancel()` | Synchron auf true setzen, um die Aktion abzubrechen. |
| `VoidCallback onCancel(VoidCallback listener)` | Registriert einen Abbruchlistener; nach Abbruch sofortiger Aufruf. Rückgabe entfernt den Listener. |
| `void throwIfCancelled()` | Wirft StateError, wenn der Token abgebrochen ist. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final token = TxCancellation();
  final unregister = token.onCancel(() => debugPrint('Cancelled'));
  token.throwIfCancelled();
  token.cancel();
  unregister();
}
```

<a id="de-txloadoptions"></a>
### TxLoadOptions

Abfragevertrag für Stores: Filter, Suche, Sortierung, Gruppierung, Paging, Projektion und Abbruch.

Vue: nicht gesetzte Optionen sind undefined; die DataSource ergänzt Counts und Paging. Dart-Standards stehen im Konstruktor. skip/take gelten für Zeilen und oberste Gruppen. Lokale Verarbeitung liefert Counts auch ohne Count-Anforderung. Vue select ist eine Feldliste, Dart select ein T→T-Callback. signal/cancellation wird an eigene asynchrone Operationen weitergereicht.

`TxLoadOptions`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| sort | `List<TxSort<T>>` | `const []` | Sortierbeschreibungen in Prioritätsreihenfolge. |
| filter | `TxFilter<T>?` | `null` | Filterausdruck. |
| searchExpr | `List<TxGetter<T>>` | `const []` | Felder beziehungsweise Getter der Suche. |
| searchValue | `String` | `''` | Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung. |
| group | `List<TxSort<T>>` | `const []` | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| skip | `int` | `0` | Anzahl zu überspringender Ergebnisse. |
| take | `int?` | `null` | Maximale Anzahl zurückzugebender Ergebnisse. |
| select | `T Function(T)?` | `null` | Projektion vor dem abschließenden Mapping. |
| requireTotalCount | `bool` | `true` | Fordert die Gesamtanzahl vor Paging an. |
| requireGroupCount | `bool` | `false` | Fordert die Anzahl oberster Gruppen an. |
| cancellation | `TxCancellation?` | `null` | Token für kooperativen Abbruch. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final options = TxLoadOptions<int>(sort: [TxSort((v) => v)], take: 1);
  print(txQuery([2, 1], options).data);
}
```

<a id="de-txgroup"></a>
### TxGroup

Gruppierter Abfragebestand mit Gruppenschlüssel und Anzahl vor dem Paging.

`TxGroup`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| key | `Object?` | `erforderlich` | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| items | `List<T>` | `erforderlich` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| count | `int` | `erforderlich` | Anzahl Datensätze der Gruppe. |
| groups | `List<TxGroup<T>>` | `const []` | Gruppenhierarchie des Ergebnisses. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const group = TxGroup<int>(key: 'team', items: [1, 2], count: 2);
  print(group.count);
}
```

<a id="de-txloadresult"></a>
### TxLoadResult

Ladeergebnis mit flachen Datensätzen und optionaler Gesamtanzahl und Gruppenhierarchie.

`TxLoadResult`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| data | `List<T>` | `erforderlich` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| totalCount | `int?` | `null` | Gesamtanzahl gefilterter Datensätze vor Paging. |
| groups | `List<TxGroup<T>>` | `const []` | Gruppenhierarchie des Ergebnisses. |
| groupCount | `int?` | `null` | Anzahl oberster Gruppen vor Paging. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const result = TxLoadResult<int>(data: [1], totalCount: 2);
  print(result.data);
}
```

<a id="de-txstore"></a>
### TxStore

Store-Vertrag für Laden sowie optionale Schlüsselauflösung und Schreiboperationen.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options)` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| `bool get canInsert` | Ob der Store Insert unterstützt. |
| `bool get canUpdate` | Ob der Store Update unterstützt. |
| `bool get canRemove` | Ob der Store Remove unterstützt. |
| `bool get canByKey` | Ob der Store ByKey unterstützt. |
| `FutureOr<T?> byKey(Object key)` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| `FutureOr<T> insert(T item)` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| `FutureOr<T> update(Object key, T Function(T) change)` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| `FutureOr<void> remove(Object key)` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxStore<int> store = TxArrayStore([1, 2], keyOf: (v) => v);
  print(await store.load(const TxLoadOptions()));
}
```

<a id="de-txquery"></a>
### txQuery

Verarbeitet lokale Daten synchron: Filtern/Suchen, Sortieren/Gruppieren, Paging und Projektion. Das Eingangsarray bleibt erhalten.

Parameter: input = Ausgangsliste, o/options = TxLoadOptions. Synchrones Ergebnis: TxLoadResult mit flacher data-Liste, totalCount vor Paging und optionalen groups/groupCount. Gruppierung ändert nicht die Form von data. Getter-/Projektionsfehler werden weitergegeben; Dart skip/take dürfen nicht negativ sein.

```dart
TxLoadResult<T> txQuery<T>(List<T> input, TxLoadOptions<T> options)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(txQuery([2, 1], TxLoadOptions<int>(sort: [TxSort((v) => v)], take: 1)).data);
}
```

<a id="de-txarraystore"></a>
### TxArrayStore

Kopierter Speicherbestand mit lokaler Abfrage und schlüsselbasierten CRUD-Operationen.

Vue: data = [], key = "id". Dart: data ist erforderlich; ohne keyOf sind nur Abfragen möglich. Konstruktion kopiert die Liste. Doppelte Schlüssel, Einfügen vorhandener Schlüssel und Schlüsseländerungen werden abgelehnt. update/remove mit unbekanntem Schlüssel schlagen fehl; byKey liefert undefined/null.

`TxArrayStore`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| data | `List<T>` | `erforderlich` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| keyOf | `TxKeyOf<T>?` | `null` | Liest den stabilen Datensatzschlüssel. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `List<T> get data` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |
| `bool get canByKey` | Ob der Store ByKey unterstützt. |
| `bool get canInsert` | Ob der Store Insert unterstützt. |
| `bool get canUpdate` | Ob der Store Update unterstützt. |
| `bool get canRemove` | Ob der Store Remove unterstützt. |
| `TxLoadResult<T> load(TxLoadOptions<T> options)` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| `T? byKey(Object key)` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| `T insert(T item)` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| `T update(Object key, T Function(T) change)` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| `void remove(Object key)` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final store = TxArrayStore<Map<String, Object>>([{'id': 1}], keyOf: (row) => row['id']!);
  print(store.load(const TxLoadOptions()));
  print(store.byKey(1));
  store.insert({'id': 2});
  store.update(2, (row) => {...row, 'name': 'Two'});
  store.remove(2);
}
```

<a id="de-txcustomstore"></a>
### TxCustomStore

Adapter für eigene synchrone oder asynchrone Store-Callbacks. Nicht angebotene Operationen sind nicht verfügbar.

load ist erforderlich; byKey/insert/update/remove sind optional. load erhält TxLoadOptions und liefert TxLoadResult direkt oder asynchron. Eigene HTTP-Callbacks müssen Statuscodes prüfen und Fehler weitergeben. byKey liefert undefined/null bei fehlendem Datensatz. Für Paging muss der Store data und totalCount vor Paging liefern. Bei remoteOperations false liefert er alle Rohdaten. Das Beispiel verwendet einen lokalen asynchronen Callback und benötigt keinen Server.

`TxCustomStore`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| load | `FutureOr<TxLoadResult<T>> Function(TxLoadOptions<T>)` | `erforderlich` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| byKey | `FutureOr<T?> Function(Object)?` | `null` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| insert | `FutureOr<T> Function(T)?` | `null` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| update | `FutureOr<T> Function(Object, T Function(T))?` | `null` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| remove | `FutureOr<void> Function(Object)?` | `null` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `bool get canByKey` | Ob der Store ByKey unterstützt. |
| `bool get canInsert` | Ob der Store Insert unterstützt. |
| `bool get canUpdate` | Ob der Store Update unterstützt. |
| `bool get canRemove` | Ob der Store Remove unterstützt. |
| `FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options)` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| `FutureOr<T?> byKey(Object key)` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| `FutureOr<T> insert(T item)` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| `FutureOr<T> update(Object key, T Function(T) change)` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| `FutureOr<void> remove(Object key)` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final store = TxCustomStore<int>(load: (options) async => txQuery([1, 2], options), byKey: (key) => key == 1 ? 1 : null);
  print(await store.load(const TxLoadOptions()));
}
```

<a id="de-txdatasourceconfig"></a>
### TxDataSourceConfig

Konfiguration für Store, Schlüssel, Abfrage, Paging und lokale oder entfernte Verarbeitung.

`TxDataSourceConfig`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| store | `TxStore<T>` | `erforderlich` | Datenbestand oder eigener Store-Vertrag. |
| keyOf | `TxKeyOf<T>?` | `null` | Liest den stabilen Datensatzschlüssel. |
| sort | `List<TxSort<T>>` | `const []` | Sortierbeschreibungen in Prioritätsreihenfolge. |
| filter | `TxFilter<T>?` | `null` | Filterausdruck. |
| searchExpr | `List<TxGetter<T>>` | `const []` | Felder beziehungsweise Getter der Suche. |
| searchValue | `String` | `''` | Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung. |
| group | `List<TxSort<T>>` | `const []` | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| pageSize | `int` | `20` | Anzahl Datensätze je Seite. |
| pageIndex | `int` | `0` | Nullbasierter Seitenindex. |
| paginate | `bool` | `true` | Aktiviert Paging; false lädt den gesamten Bestand. |
| remoteOperations | `bool?` | `null` | Store verarbeitet Abfragen selbst; automatisch für CustomStores aktiviert. |
| select | `T Function(T)?` | `null` | Projektion vor dem abschließenden Mapping. |
| map | `T Function(T)?` | `null` | Transformation jedes geladenen sichtbaren Datensatzes. |
| requireTotalCount | `bool` | `true` | Fordert die Gesamtanzahl vor Paging an. |
| requireGroupCount | `bool` | `false` | Fordert die Anzahl oberster Gruppen an. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final config = TxDataSourceConfig<int>(store: TxArrayStore([1, 2], keyOf: (v) => v), keyOf: (v) => v, pageSize: 10);
  final source = TxDataSource(config);
  await source.load();
  source.dispose();
}
```

<a id="de-txpush"></a>
### TxPush

Einfüge-, Änderungs- oder Löschoperation für push. Mehrere Operationen laufen nacheinander, ohne Transaktion.

`TxPush.insert`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| data | `T` | `erforderlich` | Datensätze beziehungsweise Nutzdaten des Ereignisses. |

`TxPush.update`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| key | `Object` | `erforderlich` | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |
| change | `T Function(T)` | `erforderlich` | Transformation des bestehenden Datensatzes. |

`TxPush.remove`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| key | `Object` | `erforderlich` | Stabiler Schlüssel beziehungsweise Selector; nicht mit Widget-Key verwechseln. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `final String type` | Darstellungs-/Eingabetyp; zulässige Werte siehe Signatur. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final source = TxDataSource.array([1], keyOf: (v) => v);
  await source.push([const TxPush.insert(2), const TxPush.remove(1)]);
  source.dispose();
}
```

<a id="de-txdatasource"></a>
### TxDataSource

Beobachtbare Datenquelle mit Abfragezustand und asynchronem Laden. Schreiboperationen laden anschließend neu; der Eigentümer entsorgt die Instanz.

Standardkonfiguration: pageSize 20, pageIndex 0, paginate true; ArrayStore lokal, andere Stores entfernt. Der Vue-Arraykurzaufruf behält Paging bei; Dart TxDataSource.array verwendet paginate false. items startet leer; load() ist erforderlich, sofern kein gebundener Konsument initial lädt. Ungültiges Paging wird abgelehnt. Store und Schlüssel durch eine neue Instanz ersetzen. configure liefert Promise/Future der neu geladenen Liste. byKey liefert Promise/Future des Datensatzes oder undefined/null; insert/update liefern den geschriebenen Datensatz, remove keinen Wert. Vue push liefert die neue Liste, Dart push keinen Wert. cancel/dispose liefern keinen Wert. Lade-/Schreibfehler stehen zusätzlich in error. Bei Stores ohne optionale Operation wirft Vue Error, Dart UnsupportedError. Nach dispose schlägt load fehl.

`TxDataSource`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| config | `TxDataSourceConfig<T>` | `erforderlich` | Konfiguration der Instanz. |

`TxDataSource.array`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| items | `List<T>` | `erforderlich` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| keyOf | `TxKeyOf<T>?` | `null` | Liest den stabilen Datensatzschlüssel. |
| paginate | `bool` | `false` | Aktiviert Paging; false lädt den gesamten Bestand. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `TxStore<T> get store` | Datenbestand oder eigener Store-Vertrag. |
| `List<T> get items` | Einträge; bei Datenbindung durch dataSource ersetzt. |
| ` List<TxGroup<T>> groups = []` | Gruppenhierarchie des Ergebnisses. |
| ` int totalCount = 0` | Gesamtanzahl gefilterter Datensätze vor Paging. |
| ` int revision = 0` | Änderungszähler nach erfolgreichem Laden. |
| `bool? containsKey(Object key)` | Liefert false für bekannte Löschungen, beim ArrayStore einen Wahrheitswert, sonst undefined/null. |
| ` int? groupCount` | Anzahl oberster Gruppen vor Paging. |
| ` bool loading = false` | Zeigt den Ladezustand. |
| ` bool loaded = false` | Mindestens ein Ladevorgang war erfolgreich. |
| ` Object? error` | Letzter Lade-/Schreibfehler. |
| ` List<TxSort<T>> sort` | Sortierbeschreibungen in Prioritätsreihenfolge. |
| ` List<TxSort<T>> group` | Gruppierungsbeschreibungen beziehungsweise Gruppenname. |
| ` TxFilter<T>? filter` | Filterausdruck. |
| ` List<TxGetter<T>> searchExpr` | Felder beziehungsweise Getter der Suche. |
| ` String searchValue` | Suchtext, lokal ohne Beachtung der Groß-/Kleinschreibung. |
| ` int pageSize` | Anzahl Datensätze je Seite. |
| ` int pageIndex` | Nullbasierter Seitenindex. |
| `Future<List<T>> load()` | Lädt mit den angegebenen Optionen; bei DataSource ohne Argumente mit aktuellem Abfragezustand. Fehler werden weitergegeben. |
| `Future<List<T>> reload()` | Lädt den aktuellen Abfragezustand erneut und liefert die sichtbaren Datensätze. |
| `Future<List<T>> configure({List<TxSort<T>>? sort, TxFilter<T>? filter, bool clearFilter = false, String? searchValue, List<TxGetter<T>>? searchExpr, List<TxSort<T>>? group, int? pageSize, int? pageIndex})` | Ändert Abfrageoptionen und lädt neu. Suche, Filter und Seitengröße setzen die Seite zurück, sofern nicht ausdrücklich angegeben. |
| `void cancel()` | Synchron auf true setzen, um die Aktion abzubrechen. |
| `Future<T?> byKey(Object key)` | Liest einen Datensatz anhand seines Schlüssels; fehlende Schlüssel ergeben undefined (Vue) beziehungsweise null (Dart). |
| `Future<T> insert(T item)` | Fügt einen Datensatz mit eindeutigem Schlüssel ein und liefert ihn zurück. |
| `Future<T> update(Object key, T Function(T) change)` | Aktualisiert eine Meldung beziehungsweise einen Datensatz. |
| `Future<void> remove(Object key)` | Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand. |
| `Future<void> push(List<TxPush<T>> changes)` | Führt Store-Schreiboperationen nacheinander aus und lädt einmal neu; keine Transaktion, Teilerfolg bei Fehler möglich. |
| `void dispose()` | Beendet Abfragen und Listener; danach die Instanz nicht mehr verwenden. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final source = TxDataSource.array(<Map<String, Object>>[{'id': 1, 'name': 'One'}], keyOf: (row) => row['id']!);
  void listener() => debugPrint('${source.loading}: ${source.error}');
  source.addListener(listener);
  await source.load();
  await source.configure(searchExpr: [(row) => row['name']], searchValue: 'One');
  await source.insert({'id': 2, 'name': 'Two'});
  await source.update(2, (row) => {...row, 'name': 'Updated'});
  await source.push([TxPush.update(2, (row) => {...row, 'name': 'Changed'})]);
  print(await source.byKey(1));
  print(source.containsKey(1));
  await source.remove(2);
  await source.reload();
  source.cancel();
  source.removeListener(listener);
  source.dispose();
}
```

<a id="de-txsourcestate"></a>
### TxSourceState

Lifecycle-Mixin für eigene StatefulWidgets mit Datenbindung. sourceInput implementieren; nur selbst erzeugte Sources werden entsorgt.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `Object? get sourceInput` | Vom eigenen State implementierte List-/Konfigurations-/Instanzbindung. |
| `List<T> get sourceFallback` | Ersatzliste ohne gebundene Source. |
| ` TxDataSource<T>? boundSource` | Aktuell gebundene Source; fremde Instanzen bleiben im Besitz des Aufrufers. |
| `void sourceChanged()` | Hook nach Änderungen einer gebundenen Source; für eigene States überschreiben. |
| `List<T> get sourceItems` | Aktuell sichtbare Datensätze der Bindung. |
| `void dispose()` | Beendet Abfragen und Listener; danach die Instanz nicht mehr verwenden. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

class BoundLabel extends StatefulWidget {
  const BoundLabel({super.key, required this.source});
  final Object source;
  @override
  State<BoundLabel> createState() => _BoundLabelState();
}

class _BoundLabelState extends State<BoundLabel>
    with TxSourceState<BoundLabel, String> {
  @override
  Object get sourceInput => widget.source;
  @override
  Widget build(BuildContext context) => Text(sourceItems.join(', '));
}
```

<a id="de-txdatasourcebuilder"></a>
### TxDataSourceBuilder

Verbindet eigene Widgets mit List, Konfiguration oder DataSource und baut sie bei Änderungen neu.

`TxDataSourceBuilder`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| dataSource | `Object` | `erforderlich` | Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items. |
| builder | `Widget Function(BuildContext, List<T>, TxDataSource<T>?)` | `erforderlich` | Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxDataSourceBuilder<String>(dataSource: const ['One'], builder: (context, items, source) => Text(items.join(', ')));
}
```

<a id="de-txthemedata"></a>
### TxThemeData

Semantische Farben und Maße als ThemeExtension. copyWith überschreibt einzelne Tokens, lerp interpoliert zwischen Themes.

`TxThemeData`

| Parameter | Typ | Standard | Bedeutung |
| --- | --- | --- | --- |
| background | `Color` | `erforderlich` | Hintergrundfarbe. |
| surface | `Color` | `erforderlich` | Farbe primärer Oberflächen. |
| surfaceAlt | `Color` | `erforderlich` | Farbe alternativer Oberflächen. |
| text | `Color` | `erforderlich` | Anzuzeigender Text. |
| muted | `Color` | `erforderlich` | Farbe sekundärer Texte. |
| border | `Color` | `erforderlich` | Rahmenfarbe. |
| accent | `Color` | `erforderlich` | Akzentfarbe. |
| onAccent | `Color` | `erforderlich` | Textfarbe auf Akzentflächen. |
| hover | `Color` | `erforderlich` | Hintergrund bei Hover. |
| selection | `Color` | `erforderlich` | Auswahlmodus. |
| danger | `Color` | `erforderlich` | Fehlerfarbe. |
| success | `Color` | `erforderlich` | Erfolgsfarbe. |
| focus | `Color` | `erforderlich` | Fokusfarbe. |
| radius | `double` | `8` | Eckenradius in logischen Pixeln. |
| spacing | `double` | `8` | Grundabstand in logischen Pixeln. |
| controlHeight | `double` | `40` | Grundhöhe von Eingaben in logischen Pixeln. |

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static const TxThemeData light = TxThemeData(background: Color(0xfff3f5fa), surface: Colors.white, surfaceAlt: Color(0xfff7f9fc), text: Color(0xff172339), muted: Color(0xff53627a), border: Color(0xffc7d0df), accent: Color(0xff365bc6), onAccent: Colors.white, hover: Color(0xffe9eefb), selection: Color(0xffe1eaff), danger: Color(0xffb42338), success: Color(0xff137553), focus: Color(0xff315dd6))` | Helle Standardtokens beziehungsweise helles Material-Theme. |
| `static const TxThemeData dark = TxThemeData(background: Color(0xff101725), surface: Color(0xff182236), surfaceAlt: Color(0xff1d2a40), text: Color(0xffedf2fc), muted: Color(0xffb0bfd6), border: Color(0xff465974), accent: Color(0xffa9beff), onAccent: Color(0xff132348), hover: Color(0xff283c5c), selection: Color(0xff2b416b), danger: Color(0xffff9cad), success: Color(0xff7bdbb4), focus: Color(0xffb5c8ff))` | Dunkle Standardtokens beziehungsweise dunkles Material-Theme. |
| `TxThemeData copyWith({Color? background, Color? surface, Color? surfaceAlt, Color? text, Color? muted, Color? border, Color? accent, Color? onAccent, Color? hover, Color? selection, Color? danger, Color? success, Color? focus, double? radius, double? spacing, double? controlHeight})` | Erzeugt eine Kopie mit den angegebenen Änderungen; alle übrigen Werte bleiben erhalten. |
| `TxThemeData lerp(covariant TxThemeData? other, double t)` | Interpoliert Tokens zum anderen Theme mit Faktor t; null behält dieses Theme bei. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final tokens = TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12);
  print(tokens.lerp(TxThemeData.dark, 0.5).accent);
}
```

<a id="de-txtheme"></a>
### TxTheme

Erstellt helle oder dunkle Material-Themes mit tecexpress-Tokens.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static ThemeData light({TxThemeData tokens = TxThemeData.light})` | Helle Standardtokens beziehungsweise helles Material-Theme. |
| `static ThemeData dark({TxThemeData tokens = TxThemeData.dark})` | Dunkle Standardtokens beziehungsweise dunkles Material-Theme. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final light = TxTheme.light();
  final dark = TxTheme.dark();
  print(MaterialApp(theme: light, darkTheme: dark));
}
```

<a id="de-txthemeof"></a>
### txThemeOf

Liest die ThemeExtension des Kontexts; ohne Extension gelten passende helle/dunkle Standardtokens.

Parameter context benötigt einen Theme-Vorfahren. Rückgabe synchron TxThemeData; ohne eigene Extension werden Standardtokens passend zur Helligkeit geliefert.

```dart
TxThemeData txThemeOf(BuildContext context)
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  Color accent(BuildContext context) => txThemeOf(context).accent;
  print(accent);
}
```

<a id="de-txlocalizations"></a>
### TxLocalizations

Material-Lokalisierungsdelegates und unterstützte deutsche/englische Locales für MaterialApp.

| Mitglied / Typ / Rückgabe | Bedeutung |
| --- | --- |
| `static const List<LocalizationsDelegate<dynamic>> delegates = GlobalMaterialLocalizations.delegates` | In MaterialApp.localizationsDelegates einbinden. |
| `static const List<Locale> supportedLocales = [Locale('de'), Locale('en')]` | In MaterialApp.supportedLocales einbinden. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(MaterialApp(localizationsDelegates: TxLocalizations.delegates, supportedLocales: TxLocalizations.supportedLocales));
}
```

<a id="de-development"></a>
### Entwicklung und weiterführende Dokumentation

```sh
flutter pub get
flutter analyze
flutter test
dart doc
flutter pub publish --dry-run
```

Die Befehle im jeweiligen Paketordner ausführen. Ein Dry-run veröffentlicht nichts.

[Veröffentlichungsanleitung](https://github.com/tekocloud/tecexpress/blob/main/PUBLISHING.md) · [Showcase](https://github.com/tekocloud/tecexpress/blob/main/flutter/example/lib/showcase.dart) · [Änderungen](https://github.com/tekocloud/tecexpress/blob/main/flutter/CHANGELOG.md) · [MIT](https://github.com/tekocloud/tecexpress/blob/main/flutter/LICENSE)
[Komponentenzuordnung](https://github.com/tekocloud/tecexpress/blob/main/flutter/COMPONENTS.md) · [Erweiterungen](https://github.com/tekocloud/tecexpress/blob/main/flutter/EXTENSIONS.md)

<a id="en"></a>
## English

Complete public API for tecexpress 0.7.1 for Flutter. MIT licensed, no license key.

[Installation and getting started](#en-start) · [Data and state](#en-data) · [Files, uploads and maps](#en-adapters) · [API index](#en-api) · [Development](#en-development)

<a id="en-start"></a>
### Installation and getting started

```sh
flutter pub add tecexpress
```

Since 0.7.0 only Flutter SDK runtime dependencies. Built-in file API: `TxFile` and `TxFileDialogs`. See [migration 0.7](MIGRATION-0.7.md) for breaking changes, ownership and platform setup. Fully rebuild native apps after upgrading.

Requires Flutter 3.47.7+ and Dart 3.13.5+. Targets Android, iOS, web, Windows, macOS and Linux.

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

void main() => runApp(MaterialApp(
  theme: TxTheme.light(),
  darkTheme: TxTheme.dark(),
  themeMode: ThemeMode.system,
  locale: const Locale('de'),
  localizationsDelegates: TxLocalizations.delegates,
  supportedLocales: TxLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: TxButton(text: 'Hello', onPressed: () {}))),
));
```

Widget examples each define `Widget example()`. Try them inside a MaterialApp using `Scaffold(body: example())`. All widgets also accept the optional Flutter parameter `Key? key = null`; it is documented once here instead of in every table. Local state is created once when constructing the widget; in a production app keep it in your own State. Data operation examples define an async function to call separately.

Custom tokens: `TxTheme.light(tokens: TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12))`. `txThemeOf(context)` reads current tokens. Localization delegates enable German/English Material controls; package-specific UI labels are currently German.

<a id="en-data"></a>
### Data and state

Data binding accepts List&lt;T&gt;, configurations or existing DataSource instances. A component owns and disposes sources created from configurations; the application owns borrowed instances. dataSource takes precedence over items. Shared instances also share filters, search, sort and page state. Use separate instances for independent views.

Accept controlled values and lists into application State through on…Changed. The application disposes external TextEditingControllers; widgets dispose internal controllers.

ArrayStores process queries locally; custom stores process them remotely by default. With remoteOperations = false, custom stores must return all raw data. The application defines the server protocol; getters are not serializable. Supply totalCount for server paging. Calendar and chat need full histories or an intentionally limited dataset; paginate = false loads everything.

load/reload/configure can fail: await with try/catch and display error. New loads replace old loads; late responses cannot overwrite newer state. Keys remain unique and immutable. Writes without the required store operation fail. push is not a transaction.

Appointment ends follow their starts. All-day appointments use local day boundaries with an exclusive end. UTC instants display in local time. Chat displays plain text, not HTML; the application supplies backend and AI services.

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final source = TxDataSource.array([1, 2], keyOf: (v) => v);
  try { await source.load(); } catch (error) { print(error); }
  source.dispose();
}
```

<a id="en-adapters"></a>
### Files, uploads and maps

MemoryFileProvider stores only in memory. Invalid names, duplicate IDs/names, invalid parents and cyclic moves are rejected. File operations are asynchronous. The capabilities set determines visible actions. txFileStore supports loading and optional removal; renaming is not offered as a store update.

HTTP uploads require your own multipart POST endpoint. fieldName defaults to file. With chunkSize, the server must assemble the protocol agreed through chunkFields. Retrying starts from the beginning. The HTTP adapter reads the file into memory and reports progress after completed chunks. File pickers/drop and save dialogs depend on OS and plugins; onDownload enables custom saving.

Map tiles use {z}/{x}/{y}. Configure tile sources, credentials and attribution yourself. The application calls GeoAdapter and binds its results as markers/routes. Without a source, no implicit external map request is made.

<a id="en-api"></a>
### API index

- [TxCard](#en-txcard)
- [TxCardView](#en-txcardview)
- [TxChat](#en-txchat)
- [TxRadioGroup](#en-txradiogroup)
- [TxButtonGroup](#en-txbuttongroup)
- [TxLookup](#en-txlookup)
- [TxTagBox](#en-txtagbox)
- [TxList](#en-txlist)
- [TxGallery](#en-txgallery)
- [TxAction](#en-txaction)
- [TxFloatingActionButton](#en-txfloatingactionbutton)
- [TxActionSheet](#en-txactionsheet)
- [TxContextMenu](#en-txcontextmenu)
- [TxDataGrid](#en-txdatagrid)
- [TxButton](#en-txbutton)
- [TxTextBox](#en-txtextbox)
- [TxTextArea](#en-txtextarea)
- [TxNumberBox](#en-txnumberbox)
- [TxCheckBox](#en-txcheckbox)
- [TxSwitch](#en-txswitch)
- [TxSelectBox](#en-txselectbox)
- [TxDateBox](#en-txdatebox)
- [TxFileEntry](#en-txfileentry)
- [TxFileProvider](#en-txfileprovider)
- [TxMemoryFileProvider](#en-txmemoryfileprovider)
- [txFileStore](#en-txfilestore)
- [TxUploadContext](#en-txuploadcontext)
- [TxUploadAdapter](#en-txuploadadapter)
- [TxHttpUploadConfig](#en-txhttpuploadconfig)
- [txHttpUpload](#en-txhttpupload)
- [TxFileUploader](#en-txfileuploader)
- [TxFileManager](#en-txfilemanager)
- [TxFileException](#en-txfileexception)
- [TxFile](#en-txfile)
- [TxFileDialogs](#en-txfiledialogs)
- [TxCoordinate](#en-txcoordinate)
- [TxMapMarker](#en-txmapmarker)
- [TxMapRoute](#en-txmaproute)
- [TxGeoAdapter](#en-txgeoadapter)
- [txProject](#en-txproject)
- [txUnproject](#en-txunproject)
- [TxMap](#en-txmap)
- [TxButtonType](#en-txbuttontype)
- [TxSelectionMode](#en-txselectionmode)
- [TxSchedulerView](#en-txschedulerview)
- [TxMessageStatus](#en-txmessagestatus)
- [TxCardVariant](#en-txcardvariant)
- [TxChange](#en-txchange)
- [TxValueChange](#en-txvaluechange)
- [TxItem](#en-txitem)
- [TxMenuItem](#en-txmenuitem)
- [TxColumn](#en-txcolumn)
- [TxCardField](#en-txcardfield)
- [TxSelection](#en-txselection)
- [TxAppointment](#en-txappointment)
- [TxAppointmentUpdate](#en-txappointmentupdate)
- [TxSchedulerEditing](#en-txschedulerediting)
- [TxChatUser](#en-txchatuser)
- [TxChatMessage](#en-txchatmessage)
- [txValidateKey](#en-txvalidatekey)
- [txValidateKeys](#en-txvalidatekeys)
- [TxTabs](#en-txtabs)
- [TxToolbar](#en-txtoolbar)
- [TxMenu](#en-txmenu)
- [TxPopup](#en-txpopup)
- [TxTooltip](#en-txtooltip)
- [TxToastType](#en-txtoasttype)
- [TxToast](#en-txtoast)
- [TxLoadIndicator](#en-txloadindicator)
- [TxRangeSlider](#en-txrangeslider)
- [TxRangeSelector](#en-txrangeselector)
- [TxScheduler](#en-txscheduler)
- [TxTabPanel](#en-txtabpanel)
- [TxLoadPanel](#en-txloadpanel)
- [TxNotifyHandle](#en-txnotifyhandle)
- [txNotify](#en-txnotify)
- [TxKeyOf](#en-txkeyof)
- [TxGetter](#en-txgetter)
- [TxSort](#en-txsort)
- [TxFilterOperator](#en-txfilteroperator)
- [TxFilter](#en-txfilter)
- [txSourceCompare](#en-txsourcecompare)
- [TxCancellation](#en-txcancellation)
- [TxLoadOptions](#en-txloadoptions)
- [TxGroup](#en-txgroup)
- [TxLoadResult](#en-txloadresult)
- [TxStore](#en-txstore)
- [txQuery](#en-txquery)
- [TxArrayStore](#en-txarraystore)
- [TxCustomStore](#en-txcustomstore)
- [TxDataSourceConfig](#en-txdatasourceconfig)
- [TxPush](#en-txpush)
- [TxDataSource](#en-txdatasource)
- [TxSourceState](#en-txsourcestate)
- [TxDataSourceBuilder](#en-txdatasourcebuilder)
- [TxThemeData](#en-txthemedata)
- [TxTheme](#en-txtheme)
- [txThemeOf](#en-txthemeof)
- [TxLocalizations](#en-txlocalizations)

`undefined` (Vue) or optional nullable parameters (Dart) mean no externally supplied value. Boolean Vue props without an explicit default are false. Types and defaults below come from the current implementation; they do not promise additional capabilities.

<a id="en-txcard"></a>
### TxCard

Presentation card with a title, media, content and actions.

`TxCard`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| title | `String?` | `null` | View title. |
| subtitle | `String?` | `null` | Additional subtitle. |
| imageUrl | `String?` | `null` | Card image URL. |
| imageAlt | `String` | `''` | Image alternative text. |
| header | `Widget?` | `null` | Custom header. |
| media | `Widget?` | `null` | Custom media region. |
| child | `Widget?` | `null` | Content or target widget. |
| actions | `List<Widget>` | `const []` | Dialog or card actions. |
| footer | `Widget?` | `null` | Custom footer. |
| variant | `TxCardVariant` | `TxCardVariant.outlined` | Card appearance variant. |
| loading | `bool` | `false` | Shows the loading state. |
| semanticLabel | `String?` | `null` | Accessible card name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxCard(title: 'Project', subtitle: 'Active', child: Text('Hello'));
}
```

<a id="en-txcardview"></a>
### TxCardView

Card collection with search, paging, selection and custom content.

`TxCardView`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| dataSource | `Object` | `required` | List, configuration or DataSource instance; takes precedence over items. |
| keyOf | `Object Function(T row)` | `required` | Reads the stable record key. |
| titleOf | `String Function(T row)` | `required` | Card title getter. |
| subtitleOf | `String? Function(T row)?` | `null` | Card subtitle getter. |
| imageOf | `String? Function(T row)?` | `null` | Card image URL getter. |
| imageAltOf | `String? Function(T row)?` | `null` | Image alternative text getter. |
| columns | `List<TxCardField<T>>` | `const []` | Column or card field configurations. |
| searchEnabled | `bool` | `true` | Enables searching. |
| searchTextOf | `String? Function(T row)?` | `null` | Searchable card text getter. |
| pageSize | `int` | `6` | Records per page. |
| pageIndex | `int?` | `null` | Zero-based page index. |
| onPageIndexChanged | `ValueChanged<int>?` | `null` | Reports pageIndex; update controlled state in the callback. |
| selection | `TxSelectionMode` | `TxSelectionMode.none` | Selection mode. |
| selectedCardKeys | `Set<Object>?` | `null` | Controlled set of selected card keys. |
| onSelectedCardKeysChanged | `ValueChanged<Set<Object>>?` | `null` | Reports selectedCardKeys; update controlled state in the callback. |
| onSelectionChanged | `ValueChanged<TxSelection<T>>?` | `null` | Reports selection; update controlled state in the callback. |
| onCardClick | `ValueChanged<T>?` | `null` | Reports the record activated through the details action. |
| onSearchChanged | `ValueChanged<String>?` | `null` | Reports search; update controlled state in the callback. |
| loading | `bool` | `false` | Shows the loading state. |
| disabled | `bool` | `false` | Disables interaction. |
| noDataText | `String` | `'Keine Karten vorhanden.'` | Text for an empty collection. |
| label | `String` | `'Kartenansicht'` | Label or accessible name. |
| itemBuilder | `Widget Function(BuildContext context, T row, bool selected)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |
| mediaBuilder | `Widget Function(BuildContext context, T row)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |
| contentBuilder | `Widget Function(BuildContext context, T row)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |
| footerBuilder | `Widget Function(BuildContext context, T row)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final rows = <Map<String, Object>>[{'id': 1, 'name': 'Alex'}];
  return TxCardView<Map<String, Object>>(dataSource: rows, keyOf: (row) => row['id']!, titleOf: (row) => '${row['name']}');
}
```

<a id="en-txchat"></a>
### TxChat

Local message history with authors, typing indicators and send events. sent confirms local acceptance, not server delivery.

`TxChat`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| user | `TxChatUser` | `required` | Current chat author. |
| items | `List<TxChatMessage>?` | `null` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| onItemsChanged | `ValueChanged<List<TxChatMessage>>?` | `null` | Reports items; update controlled state in the callback. |
| controller | `TextEditingController?` | `null` | External text controller; the application disposes it. |
| initialText | `String` | `''` | Initial draft without an external controller. |
| onInputFieldTextChanged | `ValueChanged<String>?` | `null` | Reports inputFieldText; update controlled state in the callback. |
| onMessageEntered | `ValueChanged<TxChange<TxChatMessage>>?` | `null` | Before local acceptance: TxChange&lt;TxChatMessage&gt;; set cancel synchronously to take over processing. |
| onMessageSent | `ValueChanged<TxChatMessage>?` | `null` | Provides the locally accepted TxChatMessage; not a server delivery receipt. |
| onTypingStart | `ValueChanged<TxChatUser>?` | `null` | Reports the start of typing with the affected TxChatUser. |
| onTypingEnd | `ValueChanged<TxChatUser>?` | `null` | Reports the end of typing with the affected TxChatUser. |
| title | `String` | `'Chat'` | View title. |
| subtitle | `String` | `''` | Additional subtitle. |
| label | `String` | `'Chat'` | Label or accessible name. |
| placeholder | `String` | `'Nachricht schreiben …'` | Hint for an empty input. |
| emptyText | `String` | `'Noch keine Nachrichten. Starte die Unterhaltung.'` | Empty state text. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| loading | `bool` | `false` | Shows the loading state. |
| sending | `bool` | `false` | Disables sending during an application request. |
| maxLength | `int` | `4000` | Maximum text length. |
| typingUsers | `List<TxChatUser>` | `const []` | Authors currently typing. |
| showAvatar | `bool` | `true` | Shows author avatars. |
| showUserName | `bool` | `true` | Shows author names. |
| showDayHeaders | `bool` | `true` | Groups messages using day headers. |
| showMessageTimestamp | `bool` | `true` | Shows message timestamps. |
| locale | `String` | `'de'` | Locale for date/time formatting. |
| height | `double` | `560` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| header | `Widget?` | `null` | Custom header. |
| empty | `Widget?` | `null` | Custom empty state. |
| messageBuilder | `Widget Function(BuildContext context, TxChatMessage message, bool isOwn)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var messages = <TxChatMessage>[];
  return StatefulBuilder(
    builder: (context, setState) => TxChat(user: TxChatUser(id: 'me', name: 'Alex'), items: messages, onItemsChanged: (v) => setState(() => messages = v)),
  );
}
```

<a id="en-txradiogroup"></a>
### TxRadioGroup

Visible radio options for a single selection.

`TxRadioGroup`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| value | `T?` | `null` | Current input/option value. |
| onChanged | `ValueChanged<T>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| direction | `Axis` | `Axis.vertical` | Entry layout direction. |
| disabled | `bool` | `false` | Disables interaction. |
| label | `String` | `'Auswahl'` | Label or accessible name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  int? choice = 1;
  return StatefulBuilder(
    builder: (context, setState) => TxRadioGroup<int>(items: options, value: choice, onChanged: (v) => setState(() => choice = v)),
  );
}
```

<a id="en-txbuttongroup"></a>
### TxButtonGroup

Group of actions with no, single or multiple selection.

`TxButtonGroup`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| values | `Set<T>` | `const {}` | Currently selected values. |
| onChanged | `ValueChanged<Set<T>>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| onItemClick | `ValueChanged<TxItem<T>>?` | `null` | Reports the activated entry; arguments follow the callback signature. |
| selection | `TxSelectionMode` | `TxSelectionMode.single` | Selection mode. |
| disabled | `bool` | `false` | Disables interaction. |
| direction | `Axis` | `Axis.horizontal` | Entry layout direction. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  var keys = <int>{};
  return StatefulBuilder(
    builder: (context, setState) => TxButtonGroup<int>(items: options, values: keys, onChanged: (v) => setState(() => keys = v)),
  );
}
```

<a id="en-txlookup"></a>
### TxLookup

Searchable single selection backed by a loadable data source.

`TxLookup`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| value | `T?` | `null` | Current input/option value. |
| onChanged | `ValueChanged<T?>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| disabled | `bool` | `false` | Disables interaction. |
| label | `String` | `'Auswählen'` | Label or accessible name. |
| searchEnabled | `bool` | `true` | Enables searching. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  int? choice = 1;
  return StatefulBuilder(
    builder: (context, setState) => TxLookup<int>(items: options, value: choice, onChanged: (v) => setState(() => choice = v)),
  );
}
```

<a id="en-txtagbox"></a>
### TxTagBox

Searchable multiple selection with tags. Select all applies to loaded results.

`TxTagBox`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| values | `Set<T>` | `const {}` | Currently selected values. |
| onChanged | `ValueChanged<Set<T>>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| disabled | `bool` | `false` | Disables interaction. |
| label | `String` | `'Auswählen'` | Label or accessible name. |
| maxDisplayedTags | `int` | `4` | Maximum visible tags before summarizing. |
| applyOnConfirm | `bool` | `false` | Applies selection only on confirmation. |
| onCustomItemCreating | `FutureOr<TxItem<T>> Function(String)?` | `null` | Creates a TxItem synchronously or asynchronously from entered text. |
| showSelectionControls | `bool` | `true` | Shows multiple/select-all controls. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  var keys = <int>{};
  return StatefulBuilder(
    builder: (context, setState) => TxTagBox<int>(items: options, values: keys, onChanged: (v) => setState(() => keys = v)),
  );
}
```

<a id="en-txlist"></a>
### TxList

List with search, selection and optional deletion or reordering through events.

`TxList`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<T>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| textOf | `String Function(T)` | `required` | Visible list text getter. |
| keyOf | `Object Function(T)` | `required` | Reads the stable record key. |
| itemBuilder | `Widget Function(BuildContext, T)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |
| groupOf | `String? Function(T)?` | `null` | List grouping getter. |
| selectedKeys | `Set<Object>` | `const {}` | Selected entry keys. |
| onSelectionChanged | `ValueChanged<Set<Object>>?` | `null` | Reports selection; update controlled state in the callback. |
| onItemClick | `ValueChanged<T>?` | `null` | Reports the activated entry; arguments follow the callback signature. |
| onDelete | `ValueChanged<T>?` | `null` | Reports the list entry to delete; the application updates its list. |
| onReorder | `void Function(int, int)?` | `null` | Reports source and target indices; the application updates its list. |
| selection | `TxSelectionMode` | `TxSelectionMode.none` | Selection mode. |
| searchEnabled | `bool` | `false` | Enables searching. |
| height | `double` | `300` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| itemExtent | `double?` | `null` | Fixed Flutter list row height when specified. |
| disabled | `bool` | `false` | Disables interaction. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxList<String>(items: const ['One', 'Two'], keyOf: (v) => v, textOf: (v) => v, searchEnabled: true);
}
```

<a id="en-txgallery"></a>
### TxGallery

Browsable gallery with optional autoplay; it is not a media player.

`TxGallery`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<T>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| itemBuilder | `Widget Function(BuildContext, T)` | `required` | Builds custom content; callback arguments and return type are given in the signature. |
| selectedIndex | `int` | `0` | Zero-based active entry. |
| onChanged | `ValueChanged<int>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| loop | `bool` | `false` | Allows wrapping from the last gallery entry to the first. |
| slideshowDelay | `Duration` | `Duration.zero` | Automatic navigation interval; 0 disables it. |
| height | `double` | `240` | Height; Vue numbers use pixels, Flutter uses logical pixels. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxGallery<String>(items: const ['One', 'Two'], itemBuilder: (context, item) => Center(child: Text(item)));
}
```

<a id="en-txaction"></a>
### TxAction

Context/sheet/FAB action with an ID, text and optional nested actions.

`TxAction`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| id | `Object` | `required` | Unique stable ID. |
| text | `String` | `required` | Text to display. |
| icon | `IconData?` | `null` | Action icon. |
| disabled | `bool` | `false` | Disables interaction. |
| destructive | `bool` | `false` | Marks a destructive action. |
| items | `List<TxAction>` | `const []` | Entries; replaced by dataSource when bound. |
| separator | `bool` | `false` | Marks a menu separator. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const action = TxAction(id: 'copy', text: 'Copy');
  print(action.id);
}
```

<a id="en-txfloatingactionbutton"></a>
### TxFloatingActionButton

Floating primary action or expandable action group.

`TxFloatingActionButton`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxAction>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| onItemClick | `ValueChanged<TxAction>?` | `null` | Reports the activated entry; arguments follow the callback signature. |
| disabled | `bool` | `false` | Disables interaction. |
| icon | `IconData` | `Icons.add` | Action icon. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxFloatingActionButton(items: const [TxAction(id: 'add', text: 'Add')], onItemClick: (action) {});
}
```

<a id="en-txactionsheet"></a>
### TxActionSheet

Bottom action sheet with a cancel action.

`TxActionSheet`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxAction>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| title | `String?` | `null` | View title. |
| onItemClick | `ValueChanged<TxAction>?` | `null` | Reports the activated entry; arguments follow the callback signature. |
| cancelText | `String` | `'Abbrechen'` | Cancel action label. |

| Member / type / return | Meaning |
| --- | --- |
| `static Future<TxAction?> show(BuildContext context, {List<TxAction> items = const [], Object? dataSource, String? title})` | Opens the native overlay alternative; follow the return contract in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxActionSheet(title: 'Actions', items: const [TxAction(id: 'copy', text: 'Copy')], onItemClick: (action) {});
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> open(BuildContext context) async {
  final selected = await TxActionSheet.show(context, items: const [TxAction(id: 'copy', text: 'Copy')]);
  debugPrint('${selected?.id}');
}
```

<a id="en-txcontextmenu"></a>
### TxContextMenu

Context actions opened by right-clicking or long-pressing the target.

`TxContextMenu`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| child | `Widget` | `required` | Content or target widget. |
| items | `List<TxAction>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| onItemClick | `ValueChanged<TxAction>?` | `null` | Reports the activated entry; arguments follow the callback signature. |
| disabled | `bool` | `false` | Disables interaction. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxContextMenu(items: const [TxAction(id: 'copy', text: 'Copy')], onItemClick: (action) {}, child: const Text('Right click here'));
}
```

<a id="en-txdatagrid"></a>
### TxDataGrid

Data table with single-column sorting, AND text filters, paging, selection and custom cells.

`TxDataGrid`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| dataSource | `Object` | `required` | List, configuration or DataSource instance; takes precedence over items. |
| keyOf | `Object Function(T row)` | `required` | Reads the stable record key. |
| columns | `List<TxColumn<T>>` | `required` | Column or card field configurations. |
| filterRow | `bool` | `true` | Shows the text filter row. |
| pageSize | `int` | `10` | Records per page. |
| pageIndex | `int?` | `null` | Zero-based page index. |
| onPageIndexChanged | `ValueChanged<int>?` | `null` | Reports pageIndex; update controlled state in the callback. |
| selection | `TxSelectionMode` | `TxSelectionMode.none` | Selection mode. |
| selectedRowKeys | `Set<Object>?` | `null` | Controlled set of selected row keys. |
| onSelectedRowKeysChanged | `ValueChanged<Set<Object>>?` | `null` | Reports selectedRowKeys; update controlled state in the callback. |
| onSelectionChanged | `ValueChanged<TxSelection<T>>?` | `null` | Reports selection; update controlled state in the callback. |
| onRowClick | `ValueChanged<T>?` | `null` | Reports the clicked record. |
| onSortChanged | `void Function(String? field, bool descending)?` | `null` | Reports sort; update controlled state in the callback. |
| onFilterChanged | `ValueChanged<Map<String, String>>?` | `null` | Reports filter; update controlled state in the callback. |
| loading | `bool` | `false` | Shows the loading state. |
| disabled | `bool` | `false` | Disables interaction. |
| noDataText | `String` | `'Keine Daten vorhanden.'` | Text for an empty collection. |
| label | `String` | `'Datentabelle'` | Label or accessible name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final rows = <Map<String, Object>>[{'id': 1, 'name': 'Alex'}];
  return TxDataGrid<Map<String, Object>>(dataSource: rows, keyOf: (row) => row['id']!, columns: [TxColumn(caption: 'Name', valueGetter: (row) => row['name'])]);
}
```

<a id="en-txbutton"></a>
### TxButton

Button with text, an icon and a click action.

`TxButton`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| text | `String?` | `null` | Text to display. |
| child | `Widget?` | `null` | Content or target widget. |
| onPressed | `VoidCallback?` | `null` | Callback for pressed; see the signature for arguments and return type. |
| disabled | `bool` | `false` | Disables interaction. |
| type | `TxButtonType` | `TxButtonType.normal` | Appearance/input type; see the signature for allowed values. |
| icon | `IconData?` | `null` | Action icon. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var saved = false;
  return StatefulBuilder(
    builder: (context, setState) => TxButton(text: 'Save', onPressed: () => setState(() => saved = true)),
  );
}
```

<a id="en-txtextbox"></a>
### TxTextBox

Single-line text input; accept edits through its model or callback.

`TxTextBox`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| controller | `TextEditingController?` | `null` | External text controller; the application disposes it. |
| initialValue | `String?` | `null` | Starting value in uncontrolled mode. |
| onChanged | `ValueChanged<String>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| onValueChanged | `ValueChanged<TxValueChange<String>>?` | `null` | Reports value; update controlled state in the callback. |
| label | `String?` | `null` | Label or accessible name. |
| placeholder | `String?` | `null` | Hint for an empty input. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| required | `bool` | `false` | Marks a required input. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |
| obscureText | `bool` | `false` | Obscures text input. |
| keyboardType | `TextInputType?` | `null` | Requested on-screen keyboard type. |
| focusNode | `FocusNode?` | `null` | External focus controller. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var text = '';
  return StatefulBuilder(
    builder: (context, setState) => TxTextBox(label: 'Name', initialValue: 'Alex', onChanged: (v) => setState(() => text = v)),
  );
}
```

<a id="en-txtextarea"></a>
### TxTextArea

Multiline text input with a configurable row count.

`TxTextArea`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| controller | `TextEditingController?` | `null` | External text controller; the application disposes it. |
| initialValue | `String?` | `null` | Starting value in uncontrolled mode. |
| onChanged | `ValueChanged<String>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| onValueChanged | `ValueChanged<TxValueChange<String>>?` | `null` | Reports value; update controlled state in the callback. |
| label | `String?` | `null` | Label or accessible name. |
| placeholder | `String?` | `null` | Hint for an empty input. |
| rows | `int` | `3` | Visible text rows. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| required | `bool` | `false` | Marks a required input. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |
| focusNode | `FocusNode?` | `null` | External focus controller. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var text = '';
  return StatefulBuilder(
    builder: (context, setState) => TxTextArea(label: 'Notes', rows: 4, onChanged: (v) => setState(() => text = v)),
  );
}
```

<a id="en-txnumberbox"></a>
### TxNumberBox

Numeric input with bounds and steps. An empty input produces null.

`TxNumberBox`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `num?` | `null` | Current input/option value. |
| initialValue | `num?` | `null` | Starting value in uncontrolled mode. |
| onChanged | `ValueChanged<num?>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| onValueChanged | `ValueChanged<TxValueChange<num?>>?` | `null` | Reports value; update controlled state in the callback. |
| label | `String?` | `null` | Label or accessible name. |
| placeholder | `String?` | `null` | Hint for an empty input. |
| min | `num?` | `null` | Lower allowed bound. |
| max | `num?` | `null` | Upper allowed bound. |
| step | `num` | `1` | Step size; milliseconds for Vue date ranges. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  num? amount = 10;
  return StatefulBuilder(
    builder: (context, setState) => TxNumberBox(value: amount, min: 0, max: 100, onChanged: (v) => setState(() => amount = v)),
  );
}
```

<a id="en-txcheckbox"></a>
### TxCheckBox

Checkbox for a boolean value.

`TxCheckBox`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `bool?` | `null` | Current input/option value. |
| initialValue | `bool` | `false` | Starting value in uncontrolled mode. |
| label | `String?` | `null` | Label or accessible name. |
| onChanged | `ValueChanged<bool>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var enabled = true;
  return StatefulBuilder(
    builder: (context, setState) => TxCheckBox(value: enabled, label: 'Active', onChanged: (v) => setState(() => enabled = v)),
  );
}
```

<a id="en-txswitch"></a>
### TxSwitch

Switch for a boolean value.

`TxSwitch`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `bool?` | `null` | Current input/option value. |
| initialValue | `bool` | `false` | Starting value in uncontrolled mode. |
| label | `String?` | `null` | Label or accessible name. |
| onChanged | `ValueChanged<bool>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var enabled = true;
  return StatefulBuilder(
    builder: (context, setState) => TxSwitch(value: enabled, label: 'Active', onChanged: (v) => setState(() => enabled = v)),
  );
}
```

<a id="en-txselectbox"></a>
### TxSelectBox

Single selection from a list or data source.

`TxSelectBox`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxItem<T>>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| value | `T?` | `null` | Current input/option value. |
| onChanged | `ValueChanged<T?>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| label | `String?` | `null` | Label or accessible name. |
| placeholder | `String` | `'Bitte wählen'` | Hint for an empty input. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  const options = [TxItem(value: 1, text: 'One'), TxItem(value: 2, text: 'Two')];
  int? choice = 1;
  return StatefulBuilder(
    builder: (context, setState) => TxSelectBox<int>(items: options, value: choice, onChanged: (v) => setState(() => choice = v)),
  );
}
```

<a id="en-txdatebox"></a>
### TxDateBox

Date input with lower and upper bounds.

`TxDateBox`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `DateTime?` | `null` | Current input/option value. |
| initialValue | `DateTime?` | `null` | Starting value in uncontrolled mode. |
| onChanged | `ValueChanged<DateTime?>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| label | `String?` | `null` | Label or accessible name. |
| min | `DateTime?` | `null` | Lower allowed bound. |
| max | `DateTime?` | `null` | Upper allowed bound. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| isValid | `bool` | `true` | Controls error presentation; does not perform validation. |
| validationMessage | `String` | `'Bitte Eingabe prüfen.'` | Error message when isValid is false. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  DateTime? date = DateTime(2026, 10, 28);
  return StatefulBuilder(
    builder: (context, setState) => TxDateBox(value: date, onChanged: (v) => setState(() => date = v)),
  );
}
```

<a id="en-txfileentry"></a>
### TxFileEntry

File/directory metadata with a stable ID; a null parentId denotes the root directory.

Dart copyWith preserves omitted fields; root: true explicitly sets parentId to null. Passing parentId: null alone preserves the existing parent.

`TxFileEntry`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| id | `String` | `required` | Unique stable ID. |
| name | `String` | `required` | Input field name or file name. |
| parentId | `String?` | `null` | Parent directory ID; null denotes the root. |
| isDirectory | `bool` | `false` | Identifies a directory. |
| size | `int` | `0` | File size in bytes. |
| modified | `DateTime?` | `null` | Last modification time. |
| bytes | `Uint8List?` | `null` | File contents in memory. |

| Member / type / return | Meaning |
| --- | --- |
| `TxFileEntry copyWith({String? id, String? name, String? parentId, bool root = false})` | Creates a copy with the supplied changes; preserves other values. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const entry = TxFileEntry(id: '1', name: 'hello.txt');
  print(entry.copyWith(name: 'renamed.txt').name);
}
```

<a id="en-txfileprovider"></a>
### TxFileProvider

Asynchronous contract for directory listings and file operations.

list is required. Vue offers optional methods; Dart implementations declare capabilities and override matching methods. Unimplemented Dart operations throw UnsupportedError. list/upload support cooperative cancellation. createDirectory/upload return an entry; rename/copy/move/remove return no value; download returns Blob (Vue) or Uint8List (Dart).

| Member / type / return | Meaning |
| --- | --- |
| `Set<String> get capabilities` | Supported file operations; controls visible actions. |
| `Future<List<TxFileEntry>> list(String? parentId, {TxCancellation? cancellation})` | Returns entries in the parent directory; null reads the root. |
| `Future<TxFileEntry> createDirectory(String? parentId, String name)` | Creates a directory with a valid name unique within its parent. |
| `Future<void> rename(String id, String name)` | Renames a file or directory; preserves its ID and parent. |
| `Future<void> copy(String id, String? target)` | Recursively copies an entry to the target directory, assigning new IDs. |
| `Future<void> move(String id, String? target)` | Moves an entry to the target directory; cycles are rejected. |
| `Future<void> remove(String id)` | Removes the record or recursively removes a file/directory tree. |
| `Future<TxFileEntry> upload(String? parentId, TxFile file, {TxCancellation? cancellation})` | Uploads a file to the specified directory and returns its new entry. |
| `Future<Uint8List> download(String id)` | Returns file contents; downloading a directory fails. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxFileProvider provider = TxMemoryFileProvider();
  print(provider.capabilities);
  print(await provider.list(null));
}
```

<a id="en-txmemoryfileprovider"></a>
### TxMemoryFileProvider

Volatile file provider with recursive copy/delete, name validation and cycle protection; data does not survive a restart.

All file operations are asynchronous. Directory and file IDs are strings; null as parent/target denotes the root. Invalid names, name collisions, unknown IDs, duplicate IDs and cycles fail. Copy preserves contents, assigns new IDs and includes descendants. Remove deletes recursively. Without stored contents, download is empty; directory downloads are unavailable.

`TxMemoryFileProvider`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| entries | `List<TxFileEntry>` | `const []` | Initial file/directory entries of the memory provider. |

| Member / type / return | Meaning |
| --- | --- |
| `Set<String> get capabilities` | Supported file operations; controls visible actions. |
| `Future<List<TxFileEntry>> list(String? parentId, {TxCancellation? cancellation})` | Returns entries in the parent directory; null reads the root. |
| `Future<TxFileEntry> createDirectory(String? parentId, String name)` | Creates a directory with a valid name unique within its parent. |
| `Future<void> rename(String id, String name)` | Renames a file or directory; preserves its ID and parent. |
| `Future<void> move(String id, String? target)` | Moves an entry to the target directory; cycles are rejected. |
| `Future<void> copy(String id, String? target)` | Recursively copies an entry to the target directory, assigning new IDs. |
| `Future<void> remove(String id)` | Removes the record or recursively removes a file/directory tree. |
| `Future<TxFileEntry> upload(String? parentId, TxFile file, {TxCancellation? cancellation})` | Uploads a file to the specified directory and returns its new entry. |
| `Future<Uint8List> download(String id)` | Returns file contents; downloading a directory fails. |

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final provider = TxMemoryFileProvider();
  final folder = await provider.createDirectory(null, 'Documents');
  final file = await provider.upload(folder.id, TxFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt'));
  await provider.rename(file.id, 'renamed.txt');
  await provider.copy(file.id, null);
  await provider.rename(file.id, 'moved.txt');
  await provider.move(file.id, null);
  print(await provider.list(null));
  print(await provider.download(file.id));
  await provider.remove(folder.id);
}
```

<a id="en-txfilestore"></a>
### txFileStore

Connects a provider and a current-directory getter to a queryable store.

Parameters: provider and parent, a getter for the current directory ID (null = root). Returns TxStore&lt;TxFileEntry&gt;. load returns Promise/Future&lt;TxLoadResult&lt;TxFileEntry&gt;&gt;. Provider failures propagate. Reload after changing directories.

```dart
TxStore<TxFileEntry> txFileStore(TxFileProvider provider, String? Function() parent)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final store = txFileStore(TxMemoryFileProvider(), () => null);
  print(await store.load(const TxLoadOptions()));
}
```

<a id="en-txuploadcontext"></a>
### TxUploadContext

Cancellation and progress reporting for one upload operation; progress is reported in bytes.

`TxUploadContext`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| cancellation | `TxCancellation` | `required` | Cooperative cancellation token. |
| onProgress | `void Function(int loaded, int total)` | `required` | Reports completed bytes and total size. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final context = TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) => print(loaded));
  context.onProgress(10, 20);
}
```

<a id="en-txuploadadapter"></a>
### TxUploadAdapter

Asynchronous callback uploading one file; its result reaches the success callback and errors reach error handling.

```dart
typedef TxUploadAdapter = Future<Object?> Function(TxFile file, TxUploadContext context);
```

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxUploadAdapter adapter = (file, context) async {
    context.cancellation.throwIfCancelled();
    final size = await file.length();
    context.onProgress(size, size);
    return file.name;
  };
  print(await adapter(TxFile.fromData(Uint8List(0), name: 'empty.txt'), TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) {})));
}
```

<a id="en-txhttpuploadconfig"></a>
### TxHttpUploadConfig

Multipart HTTP configuration with a destination, fields, headers and optional chunks.

`TxHttpUploadConfig`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| url | `Uri` | `required` | Upload server destination. |
| fieldName | `String` | `'file'` | Multipart file field name. |
| headers | `Map<String, String>` | `const {}` | Additional HTTP headers. |
| fields | `Map<String, String>` | `const {}` | Additional multipart text fields. |
| chunkSize | `int?` | `null` | Chunk size in bytes; must be positive. |
| chunkFields | `Map<String, String> Function(TxFile, int, int)?` | `null` | Fields per chunk; index is zero-based. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final config = TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload'), fieldName: 'file', chunkSize: 1024 * 1024);
  final adapter = txHttpUpload(config);
  print(adapter);
}
```

<a id="en-txhttpupload"></a>
### txHttpUpload

Creates a multipart POST adapter. The server must assemble chunks. Non-success HTTP responses and network errors fail the upload.

Parameter: config with a required URL; returns TxUploadAdapter. The adapter receives file and context and asynchronously returns the final HTTP response text. fieldName = file; extra fields/headers default to empty. chunkSize must be positive; chunkFields receives file, zero-based index and count. Cancellation and HTTP/network failures reject the operation. No automatic JSON parsing or server-side chunk assembly.

```dart
TxUploadAdapter txHttpUpload(TxHttpUploadConfig config)
```

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  // Requires your own multipart server with matching chunk assembly.
  final upload = txHttpUpload(TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload')));
  await upload(TxFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt'), TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) => print('$loaded/$total')));
}
```

<a id="en-txfileuploader"></a>
### TxFileUploader

File picker and upload queue with size/type checks, progress and retry from the beginning.

`TxFileUploader`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| adapter | `TxUploadAdapter?` | `null` | Upload function for one file. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| multiple | `bool` | `false` | Allows multiple files. |
| maxFileSize | `int?` | `null` | Maximum file size in bytes. |
| minFileSize | `int` | `0` | Minimum file size in bytes. |
| extensions | `List<String>` | `const []` | Allowed file extensions without a dot. |
| instantly | `bool` | `false` | Starts valid files immediately after selection. |
| disabled | `bool` | `false` | Disables interaction. |
| onUploaded | `void Function(TxFile, Object?)?` | `null` | Provides the uploaded TxFile and adapter result. |
| onError | `void Function(TxFile, Object)?` | `null` | Reports the file and error of a failed upload operation. |
| onChanged | `ValueChanged<List<TxFile>>?` | `null` | Callback for changed; see the signature for arguments and return type. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  // Replace with your server's multipart endpoint.
  final upload = txHttpUpload(TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload')));
  return TxFileUploader(adapter: upload, extensions: const ['txt']);
}
```

<a id="en-txfilemanager"></a>
### TxFileManager

Directory navigation and file actions. Provider capabilities determine available operations; no file server is included.

`TxFileManager`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| provider | `TxFileProvider` | `required` | File provider with supported operations. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| disabled | `bool` | `false` | Disables interaction. |
| height | `double` | `360` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| onSelectionChanged | `ValueChanged<List<TxFileEntry>>?` | `null` | Reports selection; update controlled state in the callback. |
| onFileOpened | `ValueChanged<TxFileEntry>?` | `null` | Reports the activated file entry. |
| onDownload | `void Function(TxFileEntry, Uint8List)?` | `null` | Provides a file entry and bytes for custom saving. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final provider = TxMemoryFileProvider([const TxFileEntry(id: '1', name: 'Documents', isDirectory: true)]);
  return TxFileManager(provider: provider);
}
```

<a id="en-txfileexception"></a>
### TxFileException

File operation error with an optional original cause.

`TxFileException`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| message | `String` | `required` | Notification text. |
| cause | `Object?` | `null` | Original platform error, if any. |

| Member / type / return | Meaning |
| --- | --- |
| `String toString()` | Returns a readable error description. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const error = TxFileException('Cannot read file');
  print(error.message);
}
```

<a id="en-txfile"></a>
### TxFile

Built-in portable file type with range reads and explicit resource disposal. No third-party package dependency.

`TxFile.fromData`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| bytes | `Uint8List` | `required` | File contents in memory. |
| name | `String` | `required` | Input field name or file name. |
| mimeType | `String?` | `null` | Optional MIME type. |

`TxFile.fromPath`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| path | `String` | `required` | Native filesystem path; unavailable in browsers. |
| name | `String?` | `null` | Input field name or file name. |
| mimeType | `String?` | `null` | Optional MIME type. |

| Member / type / return | Meaning |
| --- | --- |
| `String get name` | Input field name or file name. |
| `String? get mimeType` | Optional MIME type. |
| `String? get path` | Native filesystem path; unavailable in browsers. |
| `Future<int> length()` | Returns the file size in bytes. |
| `Future<Uint8List> readAsBytes()` | Reads all contents; prefer openRead for large files. |
| `Stream<List<int>> openRead([int start = 0, int? end])` | Reads from inclusive start to exclusive end; defaults to the entire file. |
| `Future<void> dispose()` | Stops queries and listeners; do not use the instance afterward. |

```dart
import 'dart:typed_data';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final file = TxFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt');
  print(await file.readAsBytes());
  await file.dispose();
}
```

<a id="en-txfiledialogs"></a>
### TxFileDialogs

Built-in system file dialogs for picking and saving files; cancellation returns an empty list or false.

| Member / type / return | Meaning |
| --- | --- |
| `static Future<List<TxFile>> pickFiles({bool multiple = false, List<String> extensions = const []})` | Opens the file picker. Dispose result files after use. |
| `static Future<bool> saveFile(TxFile file, {String? suggestedName})` | Saves a file; false on dialog cancellation. On the web true means a download was initiated. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final files = await TxFileDialogs.pickFiles(extensions: ['txt']);
  for (final file in files) {
    try { await TxFileDialogs.saveFile(file); } finally { await file.dispose(); }
  }
}
```

<a id="en-txcoordinate"></a>
### TxCoordinate

Geographic latitude and longitude in degrees.

`TxCoordinate`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| lat | `double` | `required` | Latitude in degrees. |
| lng | `double` | `required` | Longitude in degrees. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const point = TxCoordinate(52.52, 13.405);
  print(point.lat);
}
```

<a id="en-txmapmarker"></a>
### TxMapMarker

Coordinate with a unique ID and optional popup text and color.

`TxMapMarker`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| lat | `double` | `required` | Latitude in degrees. |
| lng | `double` | `required` | Longitude in degrees. |
| id | `Object` | `required` | Unique stable ID. |
| text | `String?` | `null` | Text to display. |
| color | `Color?` | `null` | Display color. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const marker = TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin');
  print(marker.text);
}
```

<a id="en-txmaproute"></a>
### TxMapRoute

Route line to draw from coordinates; it does not calculate a route.

`TxMapRoute`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| id | `Object` | `required` | Unique stable ID. |
| points | `List<TxCoordinate>` | `required` | Route line coordinates in order. |
| color | `Color` | `Colors.blue` | Display color. |
| width | `double` | `3` | Width; Vue numbers use pixels, Flutter uses logical pixels. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const route = TxMapRoute(id: 'walk', points: [TxCoordinate(52.52, 13.405), TxCoordinate(52.53, 13.41)]);
  print(route.points.length);
}
```

<a id="en-txgeoadapter"></a>
### TxGeoAdapter

Contract for custom geocoding/routing services. Call services yourself and bind results to the map.

| Member / type / return | Meaning |
| --- | --- |
| `Future<List<TxCoordinate>> geocode(String query, {TxCancellation? cancellation})` | Queries a custom geographic service for coordinates matching text. |
| `Future<List<TxCoordinate>> route(List<TxCoordinate> points, {TxCancellation? cancellation})` | Queries a custom routing service for a route through waypoints. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  // An implementation is supplied by your application.
  Future<void> locate(TxGeoAdapter adapter) async {
    final points = await adapter.geocode('Berlin');
    if (points.length >= 2) print(await adapter.route(points));
  }
  print(locate);
}
```

<a id="en-txproject"></a>
### txProject

Projects geographic coordinates to Web Mercator world pixels at a given zoom; clamps latitude to about ±85.05°.

Parameters: point with lat/lng in degrees and zoom. Synchronous return: { x, y } in Vue, Offset in Dart; world pixels, not pixels relative to the visible viewport.

```dart
Offset txProject(TxCoordinate point, double zoom)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(txProject(const TxCoordinate(52.52, 13.405), 5));
}
```

<a id="en-txunproject"></a>
### txUnproject

Converts Web Mercator world pixels back to geographic coordinates at the same zoom.

Parameters: Vue x, y, zoom; Dart Offset point, zoom. Synchronously returns TxCoordinate with lat/lng in degrees; use the same zoom as txProject.

```dart
TxCoordinate txUnproject(Offset point, double zoom)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final pixel = txProject(const TxCoordinate(52.52, 13.405), 5);
  print(txUnproject(pixel, 5).lat);
}
```

<a id="en-txmap"></a>
### TxMap

Map with pan/zoom, markers and route lines. Without tileUrl the background is neutral; the application configures sources and attribution.

`TxMap`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| center | `TxCoordinate` | `const TxCoordinate(52.52, 13.405)` | Geographic map center. |
| zoom | `int` | `5` | Map zoom level. |
| minZoom | `int` | `1` | Minimum zoom level. |
| maxZoom | `int` | `19` | Maximum zoom level. |
| tileUrl | `String?` | `null` | Tile URL with {z}/{x}/{y} placeholders. |
| attribution | `String?` | `null` | Map provider attribution/license text. |
| markers | `List<TxMapMarker>` | `const []` | Map markers to display. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| routes | `List<TxMapRoute>` | `const []` | Route lines to display. |
| routeDataSource | `Object?` | `null` | Separate data source for route lines. |
| onCenterChanged | `ValueChanged<TxCoordinate>?` | `null` | Reports center; update controlled state in the callback. |
| onZoomChanged | `ValueChanged<int>?` | `null` | Reports zoom; update controlled state in the callback. |
| onMarkerClick | `ValueChanged<TxMapMarker>?` | `null` | Activated TxMapMarker. |
| height | `double` | `360` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| disabled | `bool` | `false` | Disables interaction. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxMap(markers: [TxMapMarker(52.52, 13.405, id: 'berlin', text: 'Berlin')]);
}
```

<a id="en-txbuttontype"></a>
### TxButtonType

Button appearance variants.

```dart
enum TxButtonType {normal, primary, danger, success}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxButtonType.values);
}
```

<a id="en-txselectionmode"></a>
### TxSelectionMode

No, single or multiple selection.

```dart
enum TxSelectionMode {none, single, multiple}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxSelectionMode.values);
}
```

<a id="en-txschedulerview"></a>
### TxSchedulerView

Day, week or month view.

```dart
enum TxSchedulerView {day, week, month}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxSchedulerView.values);
}
```

<a id="en-txmessagestatus"></a>
### TxMessageStatus

Local message display status; not a delivery receipt.

```dart
enum TxMessageStatus {pending, sent, error}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxMessageStatus.values);
}
```

<a id="en-txcardvariant"></a>
### TxCardVariant

Card variants using an outline, elevation or fill.

```dart
enum TxCardVariant {outlined, elevated, filled}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxCardVariant.values);
}
```

<a id="en-txchange"></a>
### TxChange

Synchronously mutable before-event. cancel = true prevents the proposed change.

`TxChange`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| data | `T` | `required` | Records or event payload. |

| Member / type / return | Meaning |
| --- | --- |
| ` bool cancel = false` | Set synchronously to true to cancel the action. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final change = TxChange<int>(1);
  change.cancel = true;
  print(change.data);
}
```

<a id="en-txvaluechange"></a>
### TxValueChange

New and previous input value.

`TxValueChange`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `T` | `required` | Current input/option value. |
| previousValue | `T` | `required` | Value before the change. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const change = TxValueChange(value: 2, previousValue: 1);
  print(change.value);
}
```

<a id="en-txitem"></a>
### TxItem

Typed selection option with a value, text and optional group or icon.

`TxItem`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `T` | `required` | Current input/option value. |
| text | `String` | `required` | Text to display. |
| disabled | `bool` | `false` | Disables interaction. |
| group | `String?` | `null` | Group descriptors or group name. |
| icon | `IconData?` | `null` | Action icon. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const option = TxItem(value: 1, text: 'One');
  print(option.value);
}
```

<a id="en-txmenuitem"></a>
### TxMenuItem

Tab/menu entry with text, an icon and a disabled state.

`TxMenuItem`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| text | `String` | `required` | Text to display. |
| disabled | `bool` | `false` | Disables interaction. |
| icon | `IconData?` | `null` | Action icon. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const item = TxMenuItem('Home', icon: Icons.home);
  print(item.text);
}
```

<a id="en-txcolumn"></a>
### TxColumn

DataGrid column configuration; it has no standalone UI.

`TxColumn`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| caption | `String` | `required` | Visible field/column caption. |
| valueGetter | `Object? Function(T row)` | `required` | Reads the field value to display. |
| dataField | `String?` | `null` | Field name; must be unique within a grid. |
| width | `double` | `160` | Width; Vue numbers use pixels, Flutter uses logical pixels. |
| allowSorting | `bool` | `true` | Allows sorting this column. |
| allowFiltering | `bool` | `true` | Allows filtering this column. |
| visible | `bool` | `true` | Controls visibility. |
| alignment | `Alignment` | `Alignment.centerLeft` | Content alignment. |
| cellBuilder | `Widget Function(BuildContext context, T row, Object? value)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  final rows = <Map<String, Object>>[{'id': 1, 'name': 'Alex'}];
  return TxDataGrid<Map<String, Object>>(dataSource: rows, keyOf: (row) => row['id']!, columns: [TxColumn(caption: 'Name', valueGetter: (row) => row['name'], cellBuilder: (context, row, value) => Text('$value'))]);
}
```

<a id="en-txcardfield"></a>
### TxCardField

Card field with a caption, getter and optional builder.

`TxCardField`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| caption | `String` | `required` | Visible field/column caption. |
| valueGetter | `Object? Function(T row)` | `required` | Reads the field value to display. |
| builder | `Widget Function(BuildContext context, T row, Object? value)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final field = TxCardField<int>(caption: 'Number', valueGetter: (v) => v);
  print(field.valueGetter(1));
}
```

<a id="en-txselection"></a>
### TxSelection

Immutable selection containing keys and matching records.

`TxSelection`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| keys | `Iterable<Object>` | `required` | Stable selection keys. |
| data | `Iterable<T>` | `required` | Records or event payload. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final selection = TxSelection<int>(keys: [1], data: [1]);
  print(selection.keys);
}
```

<a id="en-txappointment"></a>
### TxAppointment

Immutable appointment with a validated key, title and end after start. All-day bounds must be local midnight.

`TxAppointment`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| id | `Object` | `required` | Unique stable ID. |
| text | `String` | `required` | Text to display. |
| startDate | `DateTime` | `required` | Appointment/cell start. |
| endDate | `DateTime` | `required` | Appointment/cell end; exclusive for all-day entries. |
| allDay | `bool` | `false` | All-day appointment with local day boundaries. |
| description | `String` | `''` | Optional appointment description. |

| Member / type / return | Meaning |
| --- | --- |
| `TxAppointment copyWith({String? text, DateTime? startDate, DateTime? endDate, bool? allDay, String? description})` | Creates a copy with the supplied changes; preserves other values. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final meeting = TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10));
  print(meeting.copyWith(text: 'Updated').text);
}
```

<a id="en-txappointmentupdate"></a>
### TxAppointmentUpdate

Old and proposed new appointment for an update.

`TxAppointmentUpdate`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| oldData | `TxAppointment` | `required` | Previous record. |
| newData | `TxAppointment` | `required` | Proposed new record. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final old = TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10));
  final update = TxAppointmentUpdate(oldData: old, newData: old.copyWith(text: 'Updated'));
  print(update.newData.text);
}
```

<a id="en-txschedulerediting"></a>
### TxSchedulerEditing

Permissions to create, update and delete appointments; none disables all three actions.

`TxSchedulerEditing`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| allowAdding | `bool` | `true` | Allows creating appointments. |
| allowUpdating | `bool` | `true` | Allows updating appointments. |
| allowDeleting | `bool` | `true` | Shows list entry delete actions. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const editing = TxSchedulerEditing(allowDeleting: false);
  print(editing.allowAdding);
  print(const TxSchedulerEditing.none().allowAdding);
}
```

<a id="en-txchatuser"></a>
### TxChatUser

Author with a validated key and non-empty name.

`TxChatUser`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| id | `Object` | `required` | Unique stable ID. |
| name | `String` | `required` | Input field name or file name. |
| avatarUrl | `String?` | `null` | Optional avatar image URL. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final user = TxChatUser(id: 'me', name: 'Alex');
  print(user.name);
}
```

<a id="en-txchatmessage"></a>
### TxChatMessage

Immutable message with an author, timestamp and non-empty text.

`TxChatMessage`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| id | `Object` | `required` | Unique stable ID. |
| text | `String` | `required` | Text to display. |
| timestamp | `DateTime` | `required` | Message timestamp. |
| author | `TxChatUser` | `required` | Message author. |
| status | `TxMessageStatus` | `TxMessageStatus.sent` | Local message status. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final message = TxChatMessage(id: 1, text: 'Hello', timestamp: DateTime.now(), author: TxChatUser(id: 'me', name: 'Alex'));
  print(message.text);
}
```

<a id="en-txvalidatekey"></a>
### txValidateKey

Validates a key; types other than String and int throw ArgumentError.

Parameter key is Object. Success returns void; types other than String/int throw ArgumentError.

```dart
void txValidateKey(Object key)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  txValidateKey('id-1'); // valid
}
```

<a id="en-txvalidatekeys"></a>
### txValidateKeys

Validates key types and uniqueness in a list; invalid or duplicate keys throw ArgumentError.

Parameter items is the list; keyOf reads each key. Success returns void; invalid or duplicate keys throw ArgumentError.

```dart
void txValidateKeys<T>(List<T> items, Object Function(T) keyOf)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  txValidateKeys<Map<String, Object>>([{'id': 1}], (row) => row['id']!);
}
```

<a id="en-txtabs"></a>
### TxTabs

Tab navigation with optional content for the active tab.

`TxTabs`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxMenuItem>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| selectedIndex | `int?` | `null` | Zero-based active entry. |
| initialIndex | `int` | `0` | Initial tab in uncontrolled mode. |
| onChanged | `ValueChanged<int>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| builder | `Widget Function(BuildContext context, int selectedIndex)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |
| disabled | `bool` | `false` | Disables interaction. |
| label | `String` | `'Reiter'` | Label or accessible name. |
| orientation | `Axis` | `Axis.horizontal` | Tab orientation. |
| swipeEnabled | `bool` | `false` | Allows switching tabs by swiping. |
| animationEnabled | `bool` | `true` | Enables content transitions. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxTabs(items: const [TxMenuItem('Home'), TxMenuItem('Settings')], builder: (context, index) => Text('Page $index'));
}
```

<a id="en-txtoolbar"></a>
### TxToolbar

Toolbar with primary content and trailing actions.

`TxToolbar`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| children | `List<Widget>` | `const []` | Child filters or contained widgets. |
| after | `List<Widget>` | `const []` | Trailing toolbar actions. |
| label | `String` | `'Werkzeugleiste'` | Label or accessible name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxToolbar(children: [TxButton(text: 'Save', onPressed: () {})], after: const [Text('Ready')]);
}
```

<a id="en-txmenu"></a>
### TxMenu

Flat list of menu actions; use ContextMenu for nested actions.

`TxMenu`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxMenuItem>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| onItemClick | `void Function(TxMenuItem item, int index)?` | `null` | Reports the activated entry; arguments follow the callback signature. |
| disabled | `bool` | `false` | Disables interaction. |
| label | `String` | `'Menü'` | Label or accessible name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var saved = false;
  return StatefulBuilder(
    builder: (context, setState) => TxMenu(items: const [TxMenuItem('Home')], onItemClick: (item, index) => setState(() => saved = true)),
  );
}
```

<a id="en-txpopup"></a>
### TxPopup

Dialog with a title and content. Before-events can be cancelled synchronously; external visibility remains authoritative.

`TxPopup`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| visible | `bool` | `required` | Controls visibility. |
| child | `Widget` | `required` | Content or target widget. |
| title | `String` | `'Dialog'` | View title. |
| actions | `List<Widget>` | `const []` | Dialog or card actions. |
| onVisibleChanged | `ValueChanged<bool>?` | `null` | Reports visible; update controlled state in the callback. |
| onShown | `VoidCallback?` | `null` | After showing, without a payload. |
| onHidden | `VoidCallback?` | `null` | After hiding, without a payload. |
| showCloseButton | `bool` | `true` | Shows a close action. |
| hideOnOutsideClick | `bool` | `false` | Allows closing by clicking outside. |
| width | `double` | `480` | Width; Vue numbers use pixels, Flutter uses logical pixels. |
| height | `double?` | `null` | Height; Vue numbers use pixels, Flutter uses logical pixels. |
| fullScreen | `bool` | `false` | Fills the screen. |
| dragEnabled | `bool` | `false` | Allows dragging the dialog. |
| resizeEnabled | `bool` | `false` | Allows resizing the dialog. |
| alignment | `Alignment` | `Alignment.center` | Content alignment. |
| onShowing | `ValueChanged<TxChange<bool>>?` | `null` | Before showing: TxChange&lt;bool&gt;; set cancel synchronously to abort. |
| onHiding | `ValueChanged<TxChange<bool>>?` | `null` | Before user-initiated closing: TxChange&lt;bool&gt;; synchronously cancellable. |

| Member / type / return | Meaning |
| --- | --- |
| `static Future<T?> show<T>(BuildContext context, {required String title, required Widget child, List<Widget> actions = const [], double width = 480, bool hideOnOutsideClick = false})` | Opens the native overlay alternative; follow the return contract in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var visible = false;
  return StatefulBuilder(
    builder: (context, setState) => Column(mainAxisSize: MainAxisSize.min, children: [TxButton(text: 'Open', onPressed: () => setState(() => visible = true)), TxPopup(visible: visible, onVisibleChanged: (v) => setState(() => visible = v), child: const Text('Hello'))]),
  );
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> open(BuildContext context) async {
  final result = await TxPopup.show<bool>(context, title: 'Confirm', child: const Text('Continue?'), actions: [Builder(builder: (dialogContext) => TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('OK')))]);
  debugPrint('$result');
}
```

<a id="en-txtooltip"></a>
### TxTooltip

Hint for target content with a delay and optional custom content.

`TxTooltip`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| text | `String` | `required` | Text to display. |
| child | `Widget` | `required` | Content or target widget. |
| disabled | `bool` | `false` | Disables interaction. |
| waitDuration | `Duration` | `Duration.zero` | Delay before the tooltip. |
| showDuration | `Duration` | `const Duration(seconds: 3)` | Tooltip duration after activation. |
| preferBelow | `bool` | `false` | Prefers placement below the target. |
| triggerMode | `TooltipTriggerMode` | `TooltipTriggerMode.longPress` | Native tooltip trigger mode. |
| visible | `bool?` | `null` | Controls visibility. |
| content | `Widget?` | `null` | Custom content or file contents as a Blob. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxTooltip(text: 'More information', child: Text('Help'));
}
```

<a id="en-txtoasttype"></a>
### TxToastType

Notification status colors: info, success, warning or error.

```dart
enum TxToastType {info, success, warning, error}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxToastType.values);
}
```

<a id="en-txtoast"></a>
### TxToast

Timed status message; accept visibility changes in the application.

`TxToast`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| visible | `bool` | `required` | Controls visibility. |
| message | `String` | `required` | Notification text. |
| onVisibleChanged | `ValueChanged<bool>?` | `null` | Reports visible; update controlled state in the callback. |
| type | `TxToastType` | `TxToastType.info` | Appearance/input type; see the signature for allowed values. |
| displayTime | `Duration` | `const Duration(milliseconds: 3500)` | Display duration; 0 or Duration.zero stays open. |

| Member / type / return | Meaning |
| --- | --- |
| `static void show(BuildContext context, String message, {TxToastType type = TxToastType.info, Duration displayTime = const Duration(milliseconds: 3500)})` | Opens the native overlay alternative; follow the return contract in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var visible = false;
  return StatefulBuilder(
    builder: (context, setState) => Column(mainAxisSize: MainAxisSize.min, children: [TxButton(text: 'Notify', onPressed: () => setState(() => visible = true)), TxToast(visible: visible, message: 'Saved', onVisibleChanged: (v) => setState(() => visible = v))]),
  );
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

void showToast(BuildContext context) {
  TxToast.show(context, 'Saved', type: TxToastType.success);
}
```

<a id="en-txloadindicator"></a>
### TxLoadIndicator

Accessible loading indicator with a label.

`TxLoadIndicator`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| visible | `bool` | `true` | Controls visibility. |
| label | `String` | `'Wird geladen …'` | Label or accessible name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const TxLoadIndicator(label: 'Loading');
}
```

<a id="en-txrangeslider"></a>
### TxRangeSlider

Select an interval using two bounds, steps and minimum/maximum distances.

`TxRangeSlider`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `RangeValues` | `required` | Current input/option value. |
| onChanged | `ValueChanged<RangeValues>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| min | `double` | `0` | Lower allowed bound. |
| max | `double` | `100` | Upper allowed bound. |
| step | `double` | `1` | Step size; milliseconds for Vue date ranges. |
| minRange | `double` | `0` | Minimum distance between range bounds. |
| maxRange | `double?` | `null` | Maximum distance between range bounds. |
| disabled | `bool` | `false` | Disables interaction. |
| readOnly | `bool` | `false` | Prevents value changes. |
| format | `String Function(double)?` | `null` | Formats range values for display. |
| label | `String` | `'Bereich'` | Label or accessible name. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var range = const RangeValues(20, 80);
  return StatefulBuilder(
    builder: (context, setState) => TxRangeSlider(value: range, onChanged: (v) => setState(() => range = v)),
  );
}
```

<a id="en-txrangeselector"></a>
### TxRangeSelector

Interval selection over a simple area, line or bar series.

`TxRangeSelector.date`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `DateTimeRange` | `required` | Current input/option value. |
| min | `DateTime` | `required` | Lower allowed bound. |
| max | `DateTime` | `required` | Upper allowed bound. |
| step | `Duration` | `const Duration(days: 1)` | Step size; milliseconds for Vue date ranges. |
| onChanged | `ValueChanged<DateTimeRange>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| items | `List<T>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| argumentOf | `DateTime Function(T)` | `required` | Getter for the numeric or date X axis. |
| valueOf | `double Function(T)` | `required` | Getter for the numeric series value. |
| format | `String Function(DateTime)?` | `null` | Formats range values for display. |
| seriesType | `String` | `'area'` | Series appearance: area/line/bar. |
| disabled | `bool` | `false` | Disables interaction. |

`TxRangeSelector`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| value | `RangeValues` | `required` | Current input/option value. |
| min | `double` | `required` | Lower allowed bound. |
| max | `double` | `required` | Upper allowed bound. |
| step | `double` | `1` | Step size; milliseconds for Vue date ranges. |
| onChanged | `ValueChanged<RangeValues>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| items | `List<T>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| argumentOf | `double Function(T)` | `required` | Getter for the numeric or date X axis. |
| valueOf | `double Function(T)` | `required` | Getter for the numeric series value. |
| format | `String Function(double)?` | `null` | Formats range values for display. |
| seriesType | `String` | `'area'` | Series appearance: area/line/bar. |
| disabled | `bool` | `false` | Disables interaction. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var range = const RangeValues(20, 80);
  return StatefulBuilder(
    builder: (context, setState) => TxRangeSelector<double>(value: range, min: 0, max: 100, items: const [20, 80], argumentOf: (v) => v, valueOf: (v) => v / 2, onChanged: (v) => setState(() => range = v)),
  );
}
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget dateRange() => TxRangeSelector<DateTime>.date(value: DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 10)), min: DateTime(2026, 10, 1), max: DateTime(2026, 11, 1), items: [DateTime(2026, 10, 5)], argumentOf: (date) => date, valueOf: (date) => 1, onChanged: (value) => debugPrint('$value'));
```

<a id="en-txscheduler"></a>
### TxScheduler

Day, week and month calendar with appointment editing. All-day end dates are exclusive; recurrence, resources and drag-and-drop are unavailable.

`TxScheduler`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| onDataSourceChanged | `ValueChanged<List<TxAppointment>>?` | `null` | Reports dataSource; update controlled state in the callback. |
| currentDate | `DateTime?` | `null` | Current calendar date; update a controlled value for navigation. |
| onCurrentDateChanged | `ValueChanged<DateTime>?` | `null` | Reports currentDate; update controlled state in the callback. |
| currentView | `TxSchedulerView?` | `null` | Current calendar view. |
| onCurrentViewChanged | `ValueChanged<TxSchedulerView>?` | `null` | Reports currentView; update controlled state in the callback. |
| views | `List<TxSchedulerView>` | `const [TxSchedulerView.day, TxSchedulerView.week, TxSchedulerView.month]` | Available calendar views. |
| firstDayOfWeek | `int` | `1` | First weekday; 1 = Monday. |
| startDayHour | `int` | `8` | First visible hour of the day. |
| endDayHour | `int` | `18` | Last visible hour of the day. |
| cellDuration | `int` | `30` | Calendar cell duration in minutes. |
| editing | `TxSchedulerEditing` | `const TxSchedulerEditing()` | Permissions to create, update and delete. |
| readOnly | `bool` | `false` | Prevents value changes. |
| disabled | `bool` | `false` | Disables interaction. |
| loading | `bool` | `false` | Shows the loading state. |
| locale | `String` | `'de'` | Locale for date/time formatting. |
| label | `String` | `'Terminplaner'` | Label or accessible name. |
| appointmentBuilder | `Widget Function(BuildContext context, TxAppointment item, TxSchedulerView view)?` | `null` | Builds custom content; callback arguments and return type are given in the signature. |
| onAppointmentClick | `ValueChanged<TxAppointment>?` | `null` | Reports the activated TxAppointment. |
| onCellClick | `void Function(DateTime start, DateTime end, bool allDay)?` | `null` | Reports cell start, cell end and the all-day flag as three arguments. |
| onAppointmentAdding | `ValueChanged<TxChange<TxAppointment>>?` | `null` | Before insertion: TxChange&lt;TxAppointment&gt;; set cancel synchronously to abort. |
| onAppointmentUpdating | `ValueChanged<TxChange<TxAppointmentUpdate>>?` | `null` | Before updating: TxChange&lt;TxAppointmentUpdate&gt; with old and new appointments; synchronously cancellable. |
| onAppointmentDeleting | `ValueChanged<TxChange<TxAppointment>>?` | `null` | Before deletion: TxChange&lt;TxAppointment&gt;; set cancel synchronously to abort. |
| onAppointmentAdded | `ValueChanged<TxAppointment>?` | `null` | Reports the locally inserted TxAppointment. |
| onAppointmentUpdated | `ValueChanged<TxAppointmentUpdate>?` | `null` | Reports TxAppointmentUpdate containing old and new appointments. |
| onAppointmentDeleted | `ValueChanged<TxAppointment>?` | `null` | Reports the locally deleted TxAppointment. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {
  var appointments = [TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10))];
  return StatefulBuilder(
    builder: (context, setState) => TxScheduler(dataSource: appointments, onDataSourceChanged: (v) => setState(() => appointments = v)),
  );
}
```

<a id="en-txtabpanel"></a>
### TxTabPanel

Tabs and their active content in one view.

`TxTabPanel`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<TxMenuItem>` | `const []` | Entries; replaced by dataSource when bound. |
| dataSource | `Object?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| selectedIndex | `int?` | `null` | Zero-based active entry. |
| onChanged | `ValueChanged<int>?` | `null` | Callback for changed; see the signature for arguments and return type. |
| builder | `Widget Function(BuildContext, int)` | `required` | Builds custom content; callback arguments and return type are given in the signature. |
| disabled | `bool` | `false` | Disables interaction. |
| orientation | `Axis` | `Axis.horizontal` | Tab orientation. |
| swipeEnabled | `bool` | `false` | Allows switching tabs by swiping. |
| animationEnabled | `bool` | `true` | Enables content transitions. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxTabPanel(items: const [TxMenuItem('Home')], builder: (context, index) => Text('Page $index'));
}
```

<a id="en-txloadpanel"></a>
### TxLoadPanel

Loading overlay controlled by visibility or a DataSource loading state.

`TxLoadPanel`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| visible | `bool?` | `null` | Controls visibility. |
| dataSource | `TxDataSource<dynamic>?` | `null` | List, configuration or DataSource instance; takes precedence over items. |
| message | `String` | `'Wird geladen …'` | Notification text. |
| delay | `Duration` | `Duration.zero` | Delay before showing the loading overlay. |
| shading | `bool` | `true` | Shows a shaded background. |
| child | `Widget?` | `null` | Content or target widget. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return const SizedBox(height: 160, child: TxLoadPanel(visible: true, child: Center(child: Text('Content'))));
}
```

<a id="en-txnotifyhandle"></a>
### TxNotifyHandle

Handle for closing or updating an existing notification.

`TxNotifyHandle`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| close | `VoidCallback` | `required` | Closes the associated notification. |
| update | `void Function({String? message, TxToastType? type, Duration? displayTime})` | `required` | Updates a notification or record. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  // Obtain the handle inside a widget callback, below MaterialApp.
  void showMessage(BuildContext context) {
    final handle = txNotify(context, message: 'Working', displayTime: Duration.zero);
    handle.update(message: 'Done', type: TxToastType.success);
    handle.close();
  }
  print(showMessage);
}
```

<a id="en-txnotify"></a>
### txNotify

Shows a stacked notification in the context overlay. Defaults: info, 3500 ms, bottom right; Duration.zero stays open.

Parameter context must be below an Overlay, usually within a MaterialApp route. message is required. Synchronously returns TxNotifyHandle; close() returns void, update({message, type, displayTime}) changes the message and resets its timer. Custom actionText/onAction are optional. Close the handle before disposing its owning overlay.

```dart
TxNotifyHandle txNotify(BuildContext context, {required String message, TxToastType type = TxToastType.info, Duration displayTime = const Duration(milliseconds: 3500), Alignment position = Alignment.bottomRight, String? actionText, VoidCallback? onAction})
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  void showMessage(BuildContext context) {
    final handle = txNotify(context, message: 'Saved');
    handle.update(message: 'Updated');
    handle.close();
  }
  print(showMessage);
}
```

<a id="en-txkeyof"></a>
### TxKeyOf

Getter for a stable unique record key.

```dart
typedef TxKeyOf<T> = Object Function(T item);
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxKeyOf<int> keyOf = (item) => item;
  print(keyOf(1));
}
```

<a id="en-txgetter"></a>
### TxGetter

Typed getter for reading query values.

```dart
typedef TxGetter<T> = Object? Function(T item);
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxGetter<int> getter = (item) => item * 2;
  print(getter(3));
}
```

<a id="en-txsort"></a>
### TxSort

Sort or group descriptor with a selector and descending direction.

`TxSort`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| selector | `TxGetter<T>` | `required` | Field path or getter for a query value. |
| desc | `bool` | `false` | Descending sort order. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final sort = TxSort<int>((v) => v, desc: true);
  print(txQuery([1, 2], TxLoadOptions(sort: [sort])).data);
}
```

<a id="en-txfilteroperator"></a>
### TxFilterOperator

Comparison and text operators for TxFilter.

```dart
enum TxFilterOperator {equal, notEqual, greater, greaterOrEqual, less, lessOrEqual, contains, startsWith, endsWith}
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(TxFilterOperator.values);
}
```

<a id="en-txfilter"></a>
### TxFilter

Comparison/text filter and nested AND, OR and NOT expressions.

The default operator is equality. Text operators ignore case. Empty AND is true; empty OR is false. Dart matches(item) returns bool; Vue txMatches(item, filter) returns boolean. Getter errors propagate.

`TxFilter`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| selector | `TxGetter<T>?` | `required` | Field path or getter for a query value. |
| value | `Object?` | `required` | Current input/option value. |
| operator | `TxFilterOperator` | `TxFilterOperator.equal` | Comparison/text operator. |

`TxFilter.and`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| filters | `List<TxFilter<T>>` | `required` | Child filters of the logical junction. |

`TxFilter.or`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| filters | `List<TxFilter<T>>` | `required` | Child filters of the logical junction. |

`TxFilter.not`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| filter | `TxFilter<T>` | `required` | Filter expression. |

| Member / type / return | Meaning |
| --- | --- |
| `final List<TxFilter<T>>? children` | Child filters or contained widgets. |
| `final String? junction` | and/or/not junction of a compound filter. |
| `bool matches(T item)` | Synchronously tests a record against this filter. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final adult = TxFilter<int>((v) => v, 18, operator: TxFilterOperator.greaterOrEqual);
  print(adult.matches(20));
  print(TxFilter.and([adult, TxFilter.not(TxFilter<int>((v) => v, 30))]).matches(20));
  print(TxFilter.or([adult]).matches(20));
}
```

<a id="en-txsourcecompare"></a>
### txSourceCompare

Compares nulls, numbers, dates or lower-case text representations; returns a negative number, zero or a positive number.

Parameters a/b may be null. null sorts before other values. Numbers and DateTime values compare numerically/chronologically; other values compare as lower-case text. Returns an int following compareTo conventions.

```dart
int txSourceCompare(Object? a, Object? b)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(txSourceCompare(1, 2)); // negative
}
```

<a id="en-txcancellation"></a>
### TxCancellation

Cooperative cancellation with one-shot listeners; throwIfCancelled throws StateError after cancellation.

| Member / type / return | Meaning |
| --- | --- |
| ` bool isCancelled = false` | Whether cancellation has been requested. |
| `void cancel()` | Set synchronously to true to cancel the action. |
| `VoidCallback onCancel(VoidCallback listener)` | Registers a cancellation listener; called immediately if already cancelled. The return value unregisters it. |
| `void throwIfCancelled()` | Throws StateError if the token was cancelled. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final token = TxCancellation();
  final unregister = token.onCancel(() => debugPrint('Cancelled'));
  token.throwIfCancelled();
  token.cancel();
  unregister();
}
```

<a id="en-txloadoptions"></a>
### TxLoadOptions

Store query contract: filtering, searching, sorting, grouping, paging, projection and cancellation.

Vue: omitted options are undefined; DataSource supplies count and paging defaults. Dart defaults appear in the constructor. skip/take apply to rows and top-level groups. Local processing returns counts even without a count request. Vue select is a field list; Dart select is a T→T callback. Forward signal/cancellation to custom async operations.

`TxLoadOptions`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| sort | `List<TxSort<T>>` | `const []` | Sort descriptors in priority order. |
| filter | `TxFilter<T>?` | `null` | Filter expression. |
| searchExpr | `List<TxGetter<T>>` | `const []` | Search fields or getters. |
| searchValue | `String` | `''` | Search text; local search ignores case. |
| group | `List<TxSort<T>>` | `const []` | Group descriptors or group name. |
| skip | `int` | `0` | Number of results to skip. |
| take | `int?` | `null` | Maximum number of results to return. |
| select | `T Function(T)?` | `null` | Projection before final mapping. |
| requireTotalCount | `bool` | `true` | Requests the total count before paging. |
| requireGroupCount | `bool` | `false` | Requests the number of top-level groups. |
| cancellation | `TxCancellation?` | `null` | Cooperative cancellation token. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final options = TxLoadOptions<int>(sort: [TxSort((v) => v)], take: 1);
  print(txQuery([2, 1], options).data);
}
```

<a id="en-txgroup"></a>
### TxGroup

Grouped query data with a group key and count before paging.

`TxGroup`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| key | `Object?` | `required` | Stable key or selector; distinct from a widget key. |
| items | `List<T>` | `required` | Entries; replaced by dataSource when bound. |
| count | `int` | `required` | Record count in the group. |
| groups | `List<TxGroup<T>>` | `const []` | Result group hierarchy. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const group = TxGroup<int>(key: 'team', items: [1, 2], count: 2);
  print(group.count);
}
```

<a id="en-txloadresult"></a>
### TxLoadResult

Load result with flat records and optional total count and group hierarchy.

`TxLoadResult`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| data | `List<T>` | `required` | Records or event payload. |
| totalCount | `int?` | `null` | Total filtered record count before paging. |
| groups | `List<TxGroup<T>>` | `const []` | Result group hierarchy. |
| groupCount | `int?` | `null` | Top-level group count before paging. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  const result = TxLoadResult<int>(data: [1], totalCount: 2);
  print(result.data);
}
```

<a id="en-txstore"></a>
### TxStore

Store contract for loading and optional key resolution and writes.

| Member / type / return | Meaning |
| --- | --- |
| `FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options)` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| `bool get canInsert` | Whether the store supports Insert. |
| `bool get canUpdate` | Whether the store supports Update. |
| `bool get canRemove` | Whether the store supports Remove. |
| `bool get canByKey` | Whether the store supports ByKey. |
| `FutureOr<T?> byKey(Object key)` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| `FutureOr<T> insert(T item)` | Inserts a record with a unique key and returns it. |
| `FutureOr<T> update(Object key, T Function(T) change)` | Updates a notification or record. |
| `FutureOr<void> remove(Object key)` | Removes the record or recursively removes a file/directory tree. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  TxStore<int> store = TxArrayStore([1, 2], keyOf: (v) => v);
  print(await store.load(const TxLoadOptions()));
}
```

<a id="en-txquery"></a>
### txQuery

Synchronously processes local data: filter/search, sort/group, page and project. The input array is preserved.

Parameters: input = source list, o/options = TxLoadOptions. Synchronous result: TxLoadResult with flat data, totalCount before paging and optional groups/groupCount. Grouping does not change the shape of data. Getter/projection errors propagate; Dart skip/take must not be negative.

```dart
TxLoadResult<T> txQuery<T>(List<T> input, TxLoadOptions<T> options)
```

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(txQuery([2, 1], TxLoadOptions<int>(sort: [TxSort((v) => v)], take: 1)).data);
}
```

<a id="en-txarraystore"></a>
### TxArrayStore

Copied in-memory collection with local queries and key-based CRUD operations.

Vue: data = [], key = "id". Dart: data is required; without keyOf only queries are supported. Construction copies the list. Duplicate keys, insertion of existing keys and key changes are rejected. update/remove with an unknown key fail; byKey returns undefined/null.

`TxArrayStore`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| data | `List<T>` | `required` | Records or event payload. |
| keyOf | `TxKeyOf<T>?` | `null` | Reads the stable record key. |

| Member / type / return | Meaning |
| --- | --- |
| `List<T> get data` | Records or event payload. |
| `bool get canByKey` | Whether the store supports ByKey. |
| `bool get canInsert` | Whether the store supports Insert. |
| `bool get canUpdate` | Whether the store supports Update. |
| `bool get canRemove` | Whether the store supports Remove. |
| `TxLoadResult<T> load(TxLoadOptions<T> options)` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| `T? byKey(Object key)` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| `T insert(T item)` | Inserts a record with a unique key and returns it. |
| `T update(Object key, T Function(T) change)` | Updates a notification or record. |
| `void remove(Object key)` | Removes the record or recursively removes a file/directory tree. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final store = TxArrayStore<Map<String, Object>>([{'id': 1}], keyOf: (row) => row['id']!);
  print(store.load(const TxLoadOptions()));
  print(store.byKey(1));
  store.insert({'id': 2});
  store.update(2, (row) => {...row, 'name': 'Two'});
  store.remove(2);
}
```

<a id="en-txcustomstore"></a>
### TxCustomStore

Adapter for custom synchronous or asynchronous store callbacks. Operations without callbacks are unavailable.

load is required; byKey/insert/update/remove are optional. load receives TxLoadOptions and returns TxLoadResult directly or asynchronously. Custom HTTP callbacks must check status codes and propagate failures. byKey returns undefined/null for a missing record. For paging, return data and totalCount before paging. With remoteOperations false, return all raw data. The example uses a local async callback and requires no server.

`TxCustomStore`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| load | `FutureOr<TxLoadResult<T>> Function(TxLoadOptions<T>)` | `required` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| byKey | `FutureOr<T?> Function(Object)?` | `null` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| insert | `FutureOr<T> Function(T)?` | `null` | Inserts a record with a unique key and returns it. |
| update | `FutureOr<T> Function(Object, T Function(T))?` | `null` | Updates a notification or record. |
| remove | `FutureOr<void> Function(Object)?` | `null` | Removes the record or recursively removes a file/directory tree. |

| Member / type / return | Meaning |
| --- | --- |
| `bool get canByKey` | Whether the store supports ByKey. |
| `bool get canInsert` | Whether the store supports Insert. |
| `bool get canUpdate` | Whether the store supports Update. |
| `bool get canRemove` | Whether the store supports Remove. |
| `FutureOr<TxLoadResult<T>> load(TxLoadOptions<T> options)` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| `FutureOr<T?> byKey(Object key)` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| `FutureOr<T> insert(T item)` | Inserts a record with a unique key and returns it. |
| `FutureOr<T> update(Object key, T Function(T) change)` | Updates a notification or record. |
| `FutureOr<void> remove(Object key)` | Removes the record or recursively removes a file/directory tree. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final store = TxCustomStore<int>(load: (options) async => txQuery([1, 2], options), byKey: (key) => key == 1 ? 1 : null);
  print(await store.load(const TxLoadOptions()));
}
```

<a id="en-txdatasourceconfig"></a>
### TxDataSourceConfig

Configuration for the store, keys, query, paging and local or remote processing.

`TxDataSourceConfig`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| store | `TxStore<T>` | `required` | Data collection or custom store contract. |
| keyOf | `TxKeyOf<T>?` | `null` | Reads the stable record key. |
| sort | `List<TxSort<T>>` | `const []` | Sort descriptors in priority order. |
| filter | `TxFilter<T>?` | `null` | Filter expression. |
| searchExpr | `List<TxGetter<T>>` | `const []` | Search fields or getters. |
| searchValue | `String` | `''` | Search text; local search ignores case. |
| group | `List<TxSort<T>>` | `const []` | Group descriptors or group name. |
| pageSize | `int` | `20` | Records per page. |
| pageIndex | `int` | `0` | Zero-based page index. |
| paginate | `bool` | `true` | Enables paging; false loads the whole collection. |
| remoteOperations | `bool?` | `null` | Store handles queries itself; automatically enabled for custom stores. |
| select | `T Function(T)?` | `null` | Projection before final mapping. |
| map | `T Function(T)?` | `null` | Transformation of each loaded visible record. |
| requireTotalCount | `bool` | `true` | Requests the total count before paging. |
| requireGroupCount | `bool` | `false` | Requests the number of top-level groups. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final config = TxDataSourceConfig<int>(store: TxArrayStore([1, 2], keyOf: (v) => v), keyOf: (v) => v, pageSize: 10);
  final source = TxDataSource(config);
  await source.load();
  source.dispose();
}
```

<a id="en-txpush"></a>
### TxPush

Insert, update or remove operation for push. Multiple operations run sequentially without a transaction.

`TxPush.insert`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| data | `T` | `required` | Records or event payload. |

`TxPush.update`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| key | `Object` | `required` | Stable key or selector; distinct from a widget key. |
| change | `T Function(T)` | `required` | Transformation of the existing record. |

`TxPush.remove`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| key | `Object` | `required` | Stable key or selector; distinct from a widget key. |

| Member / type / return | Meaning |
| --- | --- |
| `final String type` | Appearance/input type; see the signature for allowed values. |

```dart
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final source = TxDataSource.array([1], keyOf: (v) => v);
  await source.push([const TxPush.insert(2), const TxPush.remove(1)]);
  source.dispose();
}
```

<a id="en-txdatasource"></a>
### TxDataSource

Observable data source with query state and asynchronous loading. Writes reload the data; its owner disposes the instance.

Default configuration: pageSize 20, pageIndex 0, paginate true; array stores are local, other stores remote. The Vue array shorthand retains paging; Dart TxDataSource.array defaults to paginate false. items starts empty; call load() unless a bound consumer triggers the initial load. Invalid paging is rejected. Replace the store and key by creating a new instance. configure returns a Promise/Future of the reloaded list. byKey returns a Promise/Future of a record or undefined/null; insert/update return the written record and remove returns no value. Vue push returns the new list; Dart push returns no value. cancel/dispose return no value. Load/write failures are also exposed in error. For unsupported operations Vue throws Error and Dart throws UnsupportedError. Loading after disposal fails.

`TxDataSource`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| config | `TxDataSourceConfig<T>` | `required` | Instance configuration. |

`TxDataSource.array`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| items | `List<T>` | `required` | Entries; replaced by dataSource when bound. |
| keyOf | `TxKeyOf<T>?` | `null` | Reads the stable record key. |
| paginate | `bool` | `false` | Enables paging; false loads the whole collection. |

| Member / type / return | Meaning |
| --- | --- |
| `TxStore<T> get store` | Data collection or custom store contract. |
| `List<T> get items` | Entries; replaced by dataSource when bound. |
| ` List<TxGroup<T>> groups = []` | Result group hierarchy. |
| ` int totalCount = 0` | Total filtered record count before paging. |
| ` int revision = 0` | Revision counter after a successful load. |
| `bool? containsKey(Object key)` | Returns false for known removals, a boolean for an array store, otherwise undefined/null. |
| ` int? groupCount` | Top-level group count before paging. |
| ` bool loading = false` | Shows the loading state. |
| ` bool loaded = false` | At least one load completed successfully. |
| ` Object? error` | Most recent load/write error. |
| ` List<TxSort<T>> sort` | Sort descriptors in priority order. |
| ` List<TxSort<T>> group` | Group descriptors or group name. |
| ` TxFilter<T>? filter` | Filter expression. |
| ` List<TxGetter<T>> searchExpr` | Search fields or getters. |
| ` String searchValue` | Search text; local search ignores case. |
| ` int pageSize` | Records per page. |
| ` int pageIndex` | Zero-based page index. |
| `Future<List<T>> load()` | Loads using the supplied options; DataSource uses current query state without arguments. Errors propagate. |
| `Future<List<T>> reload()` | Reloads the current query and returns visible records. |
| `Future<List<T>> configure({List<TxSort<T>>? sort, TxFilter<T>? filter, bool clearFilter = false, String? searchValue, List<TxGetter<T>>? searchExpr, List<TxSort<T>>? group, int? pageSize, int? pageIndex})` | Changes query options and reloads. Search, filter and page size reset the page unless explicitly supplied. |
| `void cancel()` | Set synchronously to true to cancel the action. |
| `Future<T?> byKey(Object key)` | Reads a record by key; missing keys return undefined (Vue) or null (Dart). |
| `Future<T> insert(T item)` | Inserts a record with a unique key and returns it. |
| `Future<T> update(Object key, T Function(T) change)` | Updates a notification or record. |
| `Future<void> remove(Object key)` | Removes the record or recursively removes a file/directory tree. |
| `Future<void> push(List<TxPush<T>> changes)` | Runs store writes sequentially and reloads once; not a transaction, partial success is possible on error. |
| `void dispose()` | Stops queries and listeners; do not use the instance afterward. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final source = TxDataSource.array(<Map<String, Object>>[{'id': 1, 'name': 'One'}], keyOf: (row) => row['id']!);
  void listener() => debugPrint('${source.loading}: ${source.error}');
  source.addListener(listener);
  await source.load();
  await source.configure(searchExpr: [(row) => row['name']], searchValue: 'One');
  await source.insert({'id': 2, 'name': 'Two'});
  await source.update(2, (row) => {...row, 'name': 'Updated'});
  await source.push([TxPush.update(2, (row) => {...row, 'name': 'Changed'})]);
  print(await source.byKey(1));
  print(source.containsKey(1));
  await source.remove(2);
  await source.reload();
  source.cancel();
  source.removeListener(listener);
  source.dispose();
}
```

<a id="en-txsourcestate"></a>
### TxSourceState

Lifecycle mixin for data-bound StatefulWidgets. Implement sourceInput; only owned sources are disposed.

| Member / type / return | Meaning |
| --- | --- |
| `Object? get sourceInput` | List/configuration/instance binding implemented by a custom State. |
| `List<T> get sourceFallback` | Fallback list without a bound source. |
| ` TxDataSource<T>? boundSource` | Currently bound source; borrowed instances remain owned by the caller. |
| `void sourceChanged()` | Hook after a bound source changes; override in custom states. |
| `List<T> get sourceItems` | Currently visible bound records. |
| `void dispose()` | Stops queries and listeners; do not use the instance afterward. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

class BoundLabel extends StatefulWidget {
  const BoundLabel({super.key, required this.source});
  final Object source;
  @override
  State<BoundLabel> createState() => _BoundLabelState();
}

class _BoundLabelState extends State<BoundLabel>
    with TxSourceState<BoundLabel, String> {
  @override
  Object get sourceInput => widget.source;
  @override
  Widget build(BuildContext context) => Text(sourceItems.join(', '));
}
```

<a id="en-txdatasourcebuilder"></a>
### TxDataSourceBuilder

Binds custom widgets to a List, configuration or DataSource and rebuilds on changes.

`TxDataSourceBuilder`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| dataSource | `Object` | `required` | List, configuration or DataSource instance; takes precedence over items. |
| builder | `Widget Function(BuildContext, List<T>, TxDataSource<T>?)` | `required` | Builds custom content; callback arguments and return type are given in the signature. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Widget example() {

  return TxDataSourceBuilder<String>(dataSource: const ['One'], builder: (context, items, source) => Text(items.join(', ')));
}
```

<a id="en-txthemedata"></a>
### TxThemeData

Semantic colors and dimensions as a ThemeExtension. copyWith replaces individual tokens; lerp interpolates between themes.

`TxThemeData`

| Parameter | Type | Default | Meaning |
| --- | --- | --- | --- |
| background | `Color` | `required` | Background color. |
| surface | `Color` | `required` | Primary surface color. |
| surfaceAlt | `Color` | `required` | Alternate surface color. |
| text | `Color` | `required` | Text to display. |
| muted | `Color` | `required` | Secondary text color. |
| border | `Color` | `required` | Border color. |
| accent | `Color` | `required` | Accent color. |
| onAccent | `Color` | `required` | Text color on accent surfaces. |
| hover | `Color` | `required` | Hover background. |
| selection | `Color` | `required` | Selection mode. |
| danger | `Color` | `required` | Error color. |
| success | `Color` | `required` | Success color. |
| focus | `Color` | `required` | Focus color. |
| radius | `double` | `8` | Corner radius in logical pixels. |
| spacing | `double` | `8` | Base spacing in logical pixels. |
| controlHeight | `double` | `40` | Base input height in logical pixels. |

| Member / type / return | Meaning |
| --- | --- |
| `static const TxThemeData light = TxThemeData(background: Color(0xfff3f5fa), surface: Colors.white, surfaceAlt: Color(0xfff7f9fc), text: Color(0xff172339), muted: Color(0xff53627a), border: Color(0xffc7d0df), accent: Color(0xff365bc6), onAccent: Colors.white, hover: Color(0xffe9eefb), selection: Color(0xffe1eaff), danger: Color(0xffb42338), success: Color(0xff137553), focus: Color(0xff315dd6))` | Default light tokens or light Material theme. |
| `static const TxThemeData dark = TxThemeData(background: Color(0xff101725), surface: Color(0xff182236), surfaceAlt: Color(0xff1d2a40), text: Color(0xffedf2fc), muted: Color(0xffb0bfd6), border: Color(0xff465974), accent: Color(0xffa9beff), onAccent: Color(0xff132348), hover: Color(0xff283c5c), selection: Color(0xff2b416b), danger: Color(0xffff9cad), success: Color(0xff7bdbb4), focus: Color(0xffb5c8ff))` | Default dark tokens or dark Material theme. |
| `TxThemeData copyWith({Color? background, Color? surface, Color? surfaceAlt, Color? text, Color? muted, Color? border, Color? accent, Color? onAccent, Color? hover, Color? selection, Color? danger, Color? success, Color? focus, double? radius, double? spacing, double? controlHeight})` | Creates a copy with the supplied changes; preserves other values. |
| `TxThemeData lerp(covariant TxThemeData? other, double t)` | Interpolates tokens toward another theme by factor t; null preserves this theme. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final tokens = TxThemeData.light.copyWith(accent: Colors.indigo, radius: 12);
  print(tokens.lerp(TxThemeData.dark, 0.5).accent);
}
```

<a id="en-txtheme"></a>
### TxTheme

Creates light or dark Material themes with tecexpress tokens.

| Member / type / return | Meaning |
| --- | --- |
| `static ThemeData light({TxThemeData tokens = TxThemeData.light})` | Default light tokens or light Material theme. |
| `static ThemeData dark({TxThemeData tokens = TxThemeData.dark})` | Default dark tokens or dark Material theme. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  final light = TxTheme.light();
  final dark = TxTheme.dark();
  print(MaterialApp(theme: light, darkTheme: dark));
}
```

<a id="en-txthemeof"></a>
### txThemeOf

Reads the context ThemeExtension; without an extension it returns matching light/dark default tokens.

Parameter context needs a Theme ancestor. Synchronously returns TxThemeData; without a custom extension, defaults matching brightness are returned.

```dart
TxThemeData txThemeOf(BuildContext context)
```

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  Color accent(BuildContext context) => txThemeOf(context).accent;
  print(accent);
}
```

<a id="en-txlocalizations"></a>
### TxLocalizations

Material localization delegates and supported German/English locales for MaterialApp.

| Member / type / return | Meaning |
| --- | --- |
| `static const List<LocalizationsDelegate<dynamic>> delegates = GlobalMaterialLocalizations.delegates` | Assign to MaterialApp.localizationsDelegates. |
| `static const List<Locale> supportedLocales = [Locale('de'), Locale('en')]` | Assign to MaterialApp.supportedLocales. |

```dart
import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> example() async {
  print(MaterialApp(localizationsDelegates: TxLocalizations.delegates, supportedLocales: TxLocalizations.supportedLocales));
}
```

<a id="en-development"></a>
### Development and further documentation

```sh
flutter pub get
flutter analyze
flutter test
dart doc
flutter pub publish --dry-run
```

Run commands from the respective package directory. A dry run does not publish anything.

[Publishing guide](https://github.com/tekocloud/tecexpress/blob/main/PUBLISHING.md) · [Showcase](https://github.com/tekocloud/tecexpress/blob/main/flutter/example/lib/showcase.dart) · [Changelog](https://github.com/tekocloud/tecexpress/blob/main/flutter/CHANGELOG.md) · [MIT](https://github.com/tekocloud/tecexpress/blob/main/flutter/LICENSE)
[Component mapping](https://github.com/tekocloud/tecexpress/blob/main/flutter/COMPONENTS.md) · [Extensions](https://github.com/tekocloud/tecexpress/blob/main/flutter/EXTENSIONS.md)
