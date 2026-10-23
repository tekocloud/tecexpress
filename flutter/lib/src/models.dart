import 'package:flutter/widgets.dart';

enum TxButtonType { normal, primary, danger, success }

enum TxSelectionMode { none, single, multiple }

enum TxSchedulerView { day, week, month }

enum TxMessageStatus { pending, sent, error }

enum TxCardVariant { outlined, elevated, filled }

/// Mutable cancellation flag for synchronous before-change callbacks.
class TxChange<T> {
  TxChange(this.data);
  final T data;
  bool cancel = false;
}

class TxValueChange<T> {
  const TxValueChange({required this.value, required this.previousValue});
  final T value, previousValue;
}

class TxItem<T> {
  const TxItem({
    required this.value,
    required this.text,
    this.disabled = false,
  });
  final T value;
  final String text;
  final bool disabled;
}

class TxMenuItem {
  const TxMenuItem(this.text, {this.disabled = false, this.icon});
  final String text;
  final bool disabled;
  final IconData? icon;
}

/// DataGrid configuration, not a standalone widget.
class TxColumn<T> {
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
  final String caption;
  final String? dataField;
  final Object? Function(T row) valueGetter;
  final double width;
  final bool allowSorting, allowFiltering, visible;
  final Alignment alignment;
  final Widget Function(BuildContext context, T row, Object? value)?
  cellBuilder;
}

class TxCardField<T> {
  const TxCardField({
    required this.caption,
    required this.valueGetter,
    this.builder,
  });
  final String caption;
  final Object? Function(T row) valueGetter;
  final Widget Function(BuildContext context, T row, Object? value)? builder;
}

class TxSelection<T> {
  TxSelection({required Iterable<Object> keys, required Iterable<T> data})
    : keys = Set.unmodifiable(keys),
      data = List.unmodifiable(data);
  final Set<Object> keys;
  final List<T> data;
}

class TxAppointment {
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
  final Object id;
  final String text, description;
  final DateTime startDate, endDate;
  final bool allDay;
  static bool _midnight(DateTime date) =>
      !date.isUtc &&
      date.hour == 0 &&
      date.minute == 0 &&
      date.second == 0 &&
      date.millisecond == 0 &&
      date.microsecond == 0;
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

class TxAppointmentUpdate {
  const TxAppointmentUpdate({required this.oldData, required this.newData});
  final TxAppointment oldData, newData;
}

class TxSchedulerEditing {
  const TxSchedulerEditing({
    this.allowAdding = true,
    this.allowUpdating = true,
    this.allowDeleting = true,
  });
  const TxSchedulerEditing.none()
    : allowAdding = false,
      allowUpdating = false,
      allowDeleting = false;
  final bool allowAdding, allowUpdating, allowDeleting;
}

class TxChatUser {
  TxChatUser({required this.id, required this.name, this.avatarUrl}) {
    txValidateKey(id);
    if (name.trim().isEmpty) {
      throw ArgumentError('Nutzer benötigen einen Namen.');
    }
  }
  final Object id;
  final String name;
  final String? avatarUrl;
}

class TxChatMessage {
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
  final Object id;
  final String text;
  final DateTime timestamp;
  final TxChatUser author;
  final TxMessageStatus status;
}

void txValidateKey(Object key) {
  if (key is! String && key is! int) {
    throw ArgumentError('Schlüssel müssen Strings oder Integer sein.');
  }
}

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
