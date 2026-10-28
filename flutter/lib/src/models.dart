import 'package:flutter/widgets.dart';

/// Darstellungsvarianten einer Schaltfläche.
///
/// Button appearance variants.
///
/// ```dart
/// print(TxButtonType.values);
/// ```
enum TxButtonType { normal, primary, danger, success }

/// Keine, einfache oder mehrfache Auswahl.
///
/// No, single or multiple selection.
///
/// ```dart
/// print(TxSelectionMode.values);
/// ```
enum TxSelectionMode { none, single, multiple }

/// Tages-, Wochen- oder Monatsansicht.
///
/// Day, week or month view.
///
/// ```dart
/// print(TxSchedulerView.values);
/// ```
enum TxSchedulerView { day, week, month }

/// Lokaler Anzeigestatus einer Nachricht; keine Zustellbestätigung.
///
/// Local message display status; not a delivery receipt.
///
/// ```dart
/// print(TxMessageStatus.values);
/// ```
enum TxMessageStatus { pending, sent, error }

/// Kartenvarianten mit Rahmen, Schatten oder Füllung.
///
/// Card variants using an outline, elevation or fill.
///
/// ```dart
/// print(TxCardVariant.values);
/// ```
enum TxCardVariant { outlined, elevated, filled }

/// Synchron veränderbares Vorereignis. cancel = true verhindert die vorgesehene Änderung.
///
/// Synchronously mutable before-event. cancel = true prevents the proposed change.
///
/// ```dart
/// final change = TxChange<int>(1);
/// change.cancel = true;
/// print(change.data);
/// ```
class TxChange<T> {
  /// Synchron veränderbares Vorereignis. cancel = true verhindert die vorgesehene Änderung.
  ///
  /// Synchronously mutable before-event. cancel = true prevents the proposed change.
  TxChange(this.data);

  /// Datensätze beziehungsweise Nutzdaten des Ereignisses.
  ///
  /// Records or event payload.
  final T data;

  /// Synchron auf true setzen, um die Aktion abzubrechen.
  ///
  /// Set synchronously to true to cancel the action.
  bool cancel = false;
}

/// Neuer und vorheriger Eingabewert.
///
/// New and previous input value.
///
/// ```dart
/// const change = TxValueChange(value: 2, previousValue: 1);
/// print(change.value);
/// ```
class TxValueChange<T> {
  /// Neuer und vorheriger Eingabewert.
  ///
  /// New and previous input value.
  const TxValueChange({required this.value, required this.previousValue});

  /// value: Aktueller Eingabe-/Optionswert.
  /// previousValue: Wert vor der Änderung.
  ///
  /// value: Current input/option value.
  /// previousValue: Value before the change.
  final T value, previousValue;
}

/// Typisierte Auswahloption mit Wert, Text und optionaler Gruppe oder Symbol.
///
/// Typed selection option with a value, text and optional group or icon.
///
/// ```dart
/// const option = TxItem(value: 1, text: 'One');
/// print(option.value);
/// ```
class TxItem<T> {
  /// Typisierte Auswahloption mit Wert, Text und optionaler Gruppe oder Symbol.
  ///
  /// Typed selection option with a value, text and optional group or icon.
  const TxItem({
    required this.value,
    required this.text,
    this.disabled = false,
    this.group,
    this.icon,
  });

  /// Aktueller Eingabe-/Optionswert.
  ///
  /// Current input/option value.
  final T value;

  /// Anzuzeigender Text.
  ///
  /// Text to display.
  final String text;

  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;

  /// Gruppierungsbeschreibungen beziehungsweise Gruppenname.
  ///
  /// Group descriptors or group name.
  final String? group;

  /// Symbol der Aktion.
  ///
  /// Action icon.
  final IconData? icon;
}

/// Reiter-/Menüeintrag mit Text, Symbol und Sperrzustand.
///
/// Tab/menu entry with text, an icon and a disabled state.
///
/// ```dart
/// const item = TxMenuItem('Home', icon: Icons.home);
/// print(item.text);
/// ```
class TxMenuItem {
  /// Reiter-/Menüeintrag mit Text, Symbol und Sperrzustand.
  ///
  /// Tab/menu entry with text, an icon and a disabled state.
  const TxMenuItem(this.text, {this.disabled = false, this.icon});

  /// Anzuzeigender Text.
  ///
  /// Text to display.
  final String text;

  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;

  /// Symbol der Aktion.
  ///
  /// Action icon.
  final IconData? icon;
}

/// Spaltenkonfiguration des DataGrid; keine eigenständige Oberfläche.
///
/// DataGrid column configuration; it has no standalone UI.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   final rows = <Map<String, Object>>[
///     {'id': 1, 'name': 'Alex'},
///   ];
///   return TxDataGrid<Map<String, Object>>(
///     dataSource: rows,
///     keyOf: (row) => row['id']!,
///     columns: [
///       TxColumn(
///         caption: 'Name',
///         valueGetter: (row) => row['name'],
///         cellBuilder: (context, row, value) => Text('$value'),
///       ),
///     ],
///   );
/// }
/// ```
class TxColumn<T> {
  /// Spaltenkonfiguration des DataGrid; keine eigenständige Oberfläche.
  ///
  /// DataGrid column configuration; it has no standalone UI.
  const TxColumn({
    required this.caption,
    required this.valueGetter,
    this.dataField,
    this.width = 160,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.visible = true,
    this.alignment = Alignment.centerLeft,
    this.cellBuilder,
  });

  /// Sichtbare Feld-/Spaltenüberschrift.
  ///
  /// Visible field/column caption.
  final String caption;

  /// Feldname; muss im Grid eindeutig sein.
  ///
  /// Field name; must be unique within a grid.
  final String? dataField;

  /// Liest den darzustellenden Feldwert.
  ///
  /// Reads the field value to display.
  final Object? Function(T row) valueGetter;

  /// Breite; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln.
  ///
  /// Width; Vue numbers use pixels, Flutter uses logical pixels.
  final double width;

  /// allowSorting: Erlaubt Sortierung dieser Spalte.
  /// allowFiltering: Erlaubt Filtern dieser Spalte.
  /// visible: Steuert die Sichtbarkeit.
  ///
  /// allowSorting: Allows sorting this column.
  /// allowFiltering: Allows filtering this column.
  /// visible: Controls visibility.
  final bool allowSorting, allowFiltering, visible;

  /// Ausrichtung des Inhalts.
  ///
  /// Content alignment.
  final Alignment alignment;

  /// Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  ///
  /// Builds custom content; callback arguments and return type are given in the signature.
  final Widget Function(BuildContext context, T row, Object? value)?
  cellBuilder;
}

/// Feld einer Karte mit Beschriftung, Getter und optionalem Builder.
///
/// Card field with a caption, getter and optional builder.
///
/// ```dart
/// final field = TxCardField<int>(caption: 'Number', valueGetter: (v) => v);
/// print(field.valueGetter(1));
/// ```
class TxCardField<T> {
  /// Feld einer Karte mit Beschriftung, Getter und optionalem Builder.
  ///
  /// Card field with a caption, getter and optional builder.
  const TxCardField({
    required this.caption,
    required this.valueGetter,
    this.builder,
  });

  /// Sichtbare Feld-/Spaltenüberschrift.
  ///
  /// Visible field/column caption.
  final String caption;

  /// Liest den darzustellenden Feldwert.
  ///
  /// Reads the field value to display.
  final Object? Function(T row) valueGetter;

  /// Erzeugt eigenen Inhalt; Callbackparameter und Rückgabetyp stehen in der Signatur.
  ///
  /// Builds custom content; callback arguments and return type are given in the signature.
  final Widget Function(BuildContext context, T row, Object? value)? builder;
}

/// Unveränderliche Auswahl mit Schlüsseln und zugehörigen Datensätzen.
///
/// Immutable selection containing keys and matching records.
///
/// ```dart
/// final selection = TxSelection<int>(keys: [1], data: [1]);
/// print(selection.keys);
/// ```
class TxSelection<T> {
  /// Unveränderliche Auswahl mit Schlüsseln und zugehörigen Datensätzen.
  ///
  /// Immutable selection containing keys and matching records.
  TxSelection({required Iterable<Object> keys, required Iterable<T> data})
    : keys = Set.unmodifiable(keys),
      data = List.unmodifiable(data);

  /// Stabile Schlüssel der Auswahl.
  ///
  /// Stable selection keys.
  final Set<Object> keys;

  /// Datensätze beziehungsweise Nutzdaten des Ereignisses.
  ///
  /// Records or event payload.
  final List<T> data;
}

/// Unveränderlicher Termin mit validiertem Schlüssel, Titel und Ende nach Beginn. Ganztagsgrenzen müssen lokale Mitternacht sein.
///
/// Immutable appointment with a validated key, title and end after start. All-day bounds must be local midnight.
///
/// ```dart
/// final meeting = TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10));
/// print(meeting.copyWith(text: 'Updated').text);
/// ```
class TxAppointment {
  /// Unveränderlicher Termin mit validiertem Schlüssel, Titel und Ende nach Beginn. Ganztagsgrenzen müssen lokale Mitternacht sein.
  ///
  /// Immutable appointment with a validated key, title and end after start. All-day bounds must be local midnight.
  TxAppointment({
    required this.id,
    required this.text,
    required this.startDate,
    required this.endDate,
    this.allDay = false,
    this.description = '',
  }) {
    txValidateKey(id);
    if (text.trim().isEmpty || !endDate.isAfter(startDate)) {
      throw ArgumentError('Termine benötigen Titel und Ende nach Beginn.');
    }
    if (allDay && (!_midnight(startDate) || !_midnight(endDate))) {
      throw ArgumentError('Ganztagstermine benötigen lokale Tagesgrenzen.');
    }
  }

  /// Eindeutige stabile ID.
  ///
  /// Unique stable ID.
  final Object id;

  /// text: Anzuzeigender Text.
  /// description: Optionale Terminbeschreibung.
  ///
  /// text: Text to display.
  /// description: Optional appointment description.
  final String text, description;

  /// startDate: Termin-/Zellenbeginn.
  /// endDate: Termin-/Zellenende, bei Ganztag exklusiv.
  ///
  /// startDate: Appointment/cell start.
  /// endDate: Appointment/cell end; exclusive for all-day entries.
  final DateTime startDate, endDate;

  /// Ganztagstermin mit lokalen Tagesgrenzen.
  ///
  /// All-day appointment with local day boundaries.
  final bool allDay;
  static bool _midnight(DateTime date) =>
      !date.isUtc &&
      date.hour == 0 &&
      date.minute == 0 &&
      date.second == 0 &&
      date.millisecond == 0 &&
      date.microsecond == 0;

  /// Erzeugt eine Kopie mit den angegebenen Änderungen; alle übrigen Werte bleiben erhalten.
  ///
  /// Creates a copy with the supplied changes; preserves other values.
  TxAppointment copyWith({
    String? text,
    DateTime? startDate,
    DateTime? endDate,
    bool? allDay,
    String? description,
  }) => TxAppointment(
    id: id,
    text: text ?? this.text,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    allDay: allDay ?? this.allDay,
    description: description ?? this.description,
  );
}

/// Alter und vorgeschlagener neuer Termin einer Aktualisierung.
///
/// Old and proposed new appointment for an update.
///
/// ```dart
/// final old = TxAppointment(id: 1, text: 'Meeting', startDate: DateTime(2026, 10, 28, 9), endDate: DateTime(2026, 10, 28, 10));
/// final update = TxAppointmentUpdate(oldData: old, newData: old.copyWith(text: 'Updated'));
/// print(update.newData.text);
/// ```
class TxAppointmentUpdate {
  /// Alter und vorgeschlagener neuer Termin einer Aktualisierung.
  ///
  /// Old and proposed new appointment for an update.
  const TxAppointmentUpdate({required this.oldData, required this.newData});

  /// oldData: Vorheriger Datensatz.
  /// newData: Neuer vorgeschlagener Datensatz.
  ///
  /// oldData: Previous record.
  /// newData: Proposed new record.
  final TxAppointment oldData, newData;
}

/// Berechtigungen zum Anlegen, Ändern und Löschen von Terminen; none sperrt alle drei Aktionen.
///
/// Permissions to create, update and delete appointments; none disables all three actions.
///
/// ```dart
/// const editing = TxSchedulerEditing(allowDeleting: false);
/// print(editing.allowAdding);
/// print(const TxSchedulerEditing.none().allowAdding);
/// ```
class TxSchedulerEditing {
  /// Berechtigungen zum Anlegen, Ändern und Löschen von Terminen; none sperrt alle drei Aktionen.
  ///
  /// Permissions to create, update and delete appointments; none disables all three actions.
  const TxSchedulerEditing({
    this.allowAdding = true,
    this.allowUpdating = true,
    this.allowDeleting = true,
  });

  /// Berechtigungen zum Anlegen, Ändern und Löschen von Terminen; none sperrt alle drei Aktionen.
  ///
  /// Permissions to create, update and delete appointments; none disables all three actions.
  const TxSchedulerEditing.none()
    : allowAdding = false,
      allowUpdating = false,
      allowDeleting = false;

  /// allowAdding: Erlaubt neue Termine.
  /// allowUpdating: Erlaubt Terminänderungen.
  /// allowDeleting: Zeigt Aktionen zum Löschen von Listeneinträgen.
  ///
  /// allowAdding: Allows creating appointments.
  /// allowUpdating: Allows updating appointments.
  /// allowDeleting: Shows list entry delete actions.
  final bool allowAdding, allowUpdating, allowDeleting;
}

/// Autor mit validiertem Schlüssel und nicht leerem Namen.
///
/// Author with a validated key and non-empty name.
///
/// ```dart
/// final user = TxChatUser(id: 'me', name: 'Alex');
/// print(user.name);
/// ```
class TxChatUser {
  /// Autor mit validiertem Schlüssel und nicht leerem Namen.
  ///
  /// Author with a validated key and non-empty name.
  TxChatUser({required this.id, required this.name, this.avatarUrl}) {
    txValidateKey(id);
    if (name.trim().isEmpty) {
      throw ArgumentError('Nutzer benötigen einen Namen.');
    }
  }

  /// Eindeutige stabile ID.
  ///
  /// Unique stable ID.
  final Object id;

  /// Name des Eingabefelds beziehungsweise Dateiname.
  ///
  /// Input field name or file name.
  final String name;

  /// Optionale Avatar-Bildadresse.
  ///
  /// Optional avatar image URL.
  final String? avatarUrl;
}

/// Unveränderliche Nachricht mit Autor, Zeitstempel und nicht leerem Text.
///
/// Immutable message with an author, timestamp and non-empty text.
///
/// ```dart
/// final message = TxChatMessage(id: 1, text: 'Hello', timestamp: DateTime.now(), author: TxChatUser(id: 'me', name: 'Alex'));
/// print(message.text);
/// ```
class TxChatMessage {
  /// Unveränderliche Nachricht mit Autor, Zeitstempel und nicht leerem Text.
  ///
  /// Immutable message with an author, timestamp and non-empty text.
  TxChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.author,
    this.status = TxMessageStatus.sent,
  }) {
    txValidateKey(id);
    if (text.trim().isEmpty) {
      throw ArgumentError('Nachrichten dürfen nicht leer sein.');
    }
  }

  /// Eindeutige stabile ID.
  ///
  /// Unique stable ID.
  final Object id;

  /// Anzuzeigender Text.
  ///
  /// Text to display.
  final String text;

  /// Zeitpunkt der Nachricht.
  ///
  /// Message timestamp.
  final DateTime timestamp;

  /// Autor der Nachricht.
  ///
  /// Message author.
  final TxChatUser author;

  /// Lokaler Nachrichtenstatus.
  ///
  /// Local message status.
  final TxMessageStatus status;
}

/// Prüft einen Schlüssel; andere Typen als String und int werfen ArgumentError.
///
/// Parameter key ist Object. Erfolgreiche Prüfung liefert void; andere Typen als String/int werfen ArgumentError.
///
/// Validates a key; types other than String and int throw ArgumentError.
///
/// Parameter key is Object. Success returns void; types other than String/int throw ArgumentError.
///
/// ```dart
/// txValidateKey('id-1'); // valid
/// ```
void txValidateKey(Object key) {
  if (key is! String && key is! int) {
    throw ArgumentError('Schlüssel müssen Strings oder Integer sein.');
  }
}

/// Prüft Schlüsseltypen und Eindeutigkeit einer Liste; ungültige oder doppelte Schlüssel werfen ArgumentError.
///
/// Parameter items ist die Liste, keyOf liest jeden Schlüssel. Erfolgreiche Prüfung liefert void; ungültige oder doppelte Schlüssel werfen ArgumentError.
///
/// Validates key types and uniqueness in a list; invalid or duplicate keys throw ArgumentError.
///
/// Parameter items is the list; keyOf reads each key. Success returns void; invalid or duplicate keys throw ArgumentError.
///
/// ```dart
/// txValidateKeys<Map<String, Object>>([{'id': 1}], (row) => row['id']!);
/// ```
void txValidateKeys<T>(List<T> items, Object Function(T) keyOf) {
  final keys = <Object>{};
  for (final item in items) {
    final key = keyOf(item);
    txValidateKey(key);
    if (!keys.add(key)) {
      throw ArgumentError('Doppelte Schlüssel sind nicht erlaubt: $key');
    }
  }
}
