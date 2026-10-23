import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';
import 'editors.dart';
import 'models.dart';
import 'overlays.dart';
import 'theme.dart';

class TxScheduler extends StatefulWidget {
  const TxScheduler({
    super.key,
    this.dataSource,
    this.onDataSourceChanged,
    this.currentDate,
    this.onCurrentDateChanged,
    this.currentView,
    this.onCurrentViewChanged,
    this.views = const [
      TxSchedulerView.day,
      TxSchedulerView.week,
      TxSchedulerView.month,
    ],
    this.firstDayOfWeek = 1,
    this.startDayHour = 8,
    this.endDayHour = 18,
    this.cellDuration = 30,
    this.editing = const TxSchedulerEditing(),
    this.readOnly = false,
    this.disabled = false,
    this.loading = false,
    this.locale = 'de',
    this.label = 'Terminplaner',
    this.appointmentBuilder,
    this.onAppointmentClick,
    this.onCellClick,
    this.onAppointmentAdding,
    this.onAppointmentUpdating,
    this.onAppointmentDeleting,
    this.onAppointmentAdded,
    this.onAppointmentUpdated,
    this.onAppointmentDeleted,
  });
  final List<TxAppointment>? dataSource;
  final ValueChanged<List<TxAppointment>>? onDataSourceChanged;
  final DateTime? currentDate;
  final ValueChanged<DateTime>? onCurrentDateChanged;
  final TxSchedulerView? currentView;
  final ValueChanged<TxSchedulerView>? onCurrentViewChanged;
  final List<TxSchedulerView> views;
  final int firstDayOfWeek, startDayHour, endDayHour, cellDuration;
  final TxSchedulerEditing editing;
  final bool readOnly, disabled, loading;
  final String locale, label;
  final Widget Function(
    BuildContext context,
    TxAppointment item,
    TxSchedulerView view,
  )?
  appointmentBuilder;
  final ValueChanged<TxAppointment>? onAppointmentClick,
      onAppointmentAdded,
      onAppointmentDeleted;
  final ValueChanged<TxAppointmentUpdate>? onAppointmentUpdated;
  final void Function(DateTime start, DateTime end, bool allDay)? onCellClick;
  final ValueChanged<TxChange<TxAppointment>>? onAppointmentAdding,
      onAppointmentDeleting;
  final ValueChanged<TxChange<TxAppointmentUpdate>>? onAppointmentUpdating;
  @override
  State<TxScheduler> createState() => _TxSchedulerState();
}

class _TxSchedulerState extends State<TxScheduler> {
  DateTime _date = txDay(DateTime.now());
  TxSchedulerView? _view;
  List<TxAppointment> _data = [];
  int _counter = 0;
  final _cellNodes = <String, FocusNode>{};
  DateTime get _currentDate => txDay(widget.currentDate ?? _date);
  TxSchedulerView get _currentView =>
      widget.currentView ??
      (widget.views.contains(_view)
          ? _view!
          : widget.views.contains(TxSchedulerView.week)
          ? TxSchedulerView.week
          : widget.views.first);
  List<TxAppointment> get _appointments => widget.dataSource ?? _data;
  bool get _blocked => widget.disabled || widget.loading;
  bool get _canAdd =>
      !_blocked && !widget.readOnly && widget.editing.allowAdding;
  String _format(DateTime value, String pattern) =>
      DateFormat(pattern, widget.locale).format(value.toLocal());
  String _viewName(TxSchedulerView value) => switch (value) {
    TxSchedulerView.day => 'Tag',
    TxSchedulerView.week => 'Woche',
    TxSchedulerView.month => 'Monat',
  };
  void _setDate(DateTime value) {
    if (_blocked) return;
    setState(() => _date = txDay(value));
    widget.onCurrentDateChanged?.call(_date);
  }

  bool _same(TxAppointment a, TxAppointment b) =>
      a.id == b.id &&
      a.text == b.text &&
      a.description == b.description &&
      a.allDay == b.allDay &&
      a.startDate == b.startDate &&
      a.endDate == b.endDate;
  String? _commit(
    TxAppointment candidate,
    TxAppointment? original,
    bool delete,
  ) {
    if (!mounted) return 'Der Kalender ist nicht mehr verfügbar.';
    if (_blocked ||
        widget.readOnly ||
        (delete
            ? !widget.editing.allowDeleting
            : original == null
            ? !widget.editing.allowAdding
            : !widget.editing.allowUpdating)) {
      return 'Diese Aktion ist nicht erlaubt.';
    }
    final source = _appointments;
    if (original != null) {
      final current = source
          .where((item) => item.id == original.id)
          .firstOrNull;
      if (current == null || !_same(original, current)) {
        return 'Der Termin wurde zwischenzeitlich geändert oder entfernt. Bitte erneut öffnen.';
      }
    }
    try {
      if (delete) {
        final event = TxChange(original!);
        widget.onAppointmentDeleting?.call(event);
        if (event.cancel) {
          return 'Das Löschen wurde von der Anwendung abgebrochen.';
        }
      } else if (original == null) {
        final event = TxChange(candidate);
        widget.onAppointmentAdding?.call(event);
        if (event.cancel) {
          return 'Das Anlegen wurde von der Anwendung abgebrochen.';
        }
      } else {
        final event = TxChange(
          TxAppointmentUpdate(oldData: original, newData: candidate),
        );
        widget.onAppointmentUpdating?.call(event);
        if (event.cancel) {
          return 'Die Änderung wurde von der Anwendung abgebrochen.';
        }
      }
      final next = delete
          ? source.where((item) => item.id != original!.id).toList()
          : original == null
          ? [...source, candidate]
          : source
                .map((item) => item.id == original.id ? candidate : item)
                .toList();
      txValidateKeys(next, (item) => item.id);
      setState(() => _data = next);
      widget.onDataSourceChanged?.call(List.unmodifiable(next));
      if (delete) {
        widget.onAppointmentDeleted?.call(original!);
      } else if (original == null) {
        widget.onAppointmentAdded?.call(candidate);
      } else {
        widget.onAppointmentUpdated?.call(
          TxAppointmentUpdate(oldData: original, newData: candidate),
        );
      }
      return null;
    } catch (error) {
      return '$error';
    }
  }

  Future<void> _open({
    TxAppointment? item,
    DateTime? start,
    DateTime? end,
    bool allDay = false,
  }) async {
    if (_blocked || (item == null && !_canAdd)) return;
    Object key = item?.id ?? '';
    if (item == null) {
      do {
        key = 'tx-${identityHashCode(this)}-${++_counter}';
      } while (_appointments.any((item) => item.id == key));
    }
    final first =
        start ??
        DateTime(
          _currentDate.year,
          _currentDate.month,
          _currentDate.day,
          widget.startDayHour,
        );
    await showDialog<void>(
      context: context,
      builder: (context) => _AppointmentEditor(
        original: item,
        id: key,
        start: first,
        end: end ?? first.add(Duration(minutes: widget.cellDuration)),
        allDay: allDay,
        canSave:
            !widget.readOnly &&
            (item == null
                ? widget.editing.allowAdding
                : widget.editing.allowUpdating),
        canDelete:
            item != null && !widget.readOnly && widget.editing.allowDeleting,
        commit: (candidate, delete) => _commit(candidate, item, delete),
      ),
    );
  }

  void _cell(DateTime day, int minute, bool allDay) {
    if (_blocked) return;
    final start = allDay
        ? day
        : DateTime(day.year, day.month, day.day, 0, minute);
    final end = allDay
        ? txAddDays(day, 1)
        : DateTime(
            day.year,
            day.month,
            day.day,
            0,
            minute + widget.cellDuration,
          );
    if (!allDay &&
        (start.hour * 60 + start.minute != minute || !end.isAfter(start))) {
      return;
    }
    widget.onCellClick?.call(start, end, allDay);
    _open(start: start, end: end, allDay: allDay);
  }

  Widget _appointment(
    TxAppointment item, {
    bool compact = false,
    DateTime? day,
  }) {
    final tokens = txThemeOf(context);
    final localStart = item.startDate.toLocal(),
        localEnd = item.endDate.toLocal();
    final label = item.allDay
        ? 'Ganztägig'
        : '${day != null && localStart.isBefore(day) ? '↤' : _format(localStart, 'HH:mm')}–${day != null && !localEnd.isBefore(txAddDays(day, 1)) ? '↦' : _format(localEnd, 'HH:mm')}';
    return Tooltip(
      message:
          '${item.text} · ${_format(localStart, 'dd.MM.yyyy HH:mm')} – ${_format(localEnd, 'dd.MM.yyyy HH:mm')}',
      child: Semantics(
        label: '${item.text}, $label',
        button: true,
        child: Material(
          color: tokens.selection,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: tokens.accent),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _blocked
                ? null
                : () {
                    widget.onAppointmentClick?.call(item);
                    _open(item: item);
                  },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child:
                  widget.appointmentBuilder?.call(
                    context,
                    item,
                    _currentView,
                  ) ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 9, color: tokens.muted),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final node in _cellNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.views.isEmpty ||
        widget.currentView != null &&
            !widget.views.contains(widget.currentView) ||
        widget.firstDayOfWeek < 0 ||
        widget.firstDayOfWeek > 6 ||
        widget.startDayHour < 0 ||
        widget.endDayHour > 24 ||
        widget.startDayHour >= widget.endDayHour ||
        ![15, 30, 60].contains(widget.cellDuration)) {
      throw ArgumentError('Ungültige Scheduler-Konfiguration.');
    }
    txValidateKeys(_appointments, (item) => item.id);
    final tokens = txThemeOf(context),
        days = txCalendarDays(
          _currentDate,
          _currentView,
          widget.firstDayOfWeek,
        );
    final period = _currentView == TxSchedulerView.month
        ? _format(_currentDate, 'MMMM yyyy')
        : _currentView == TxSchedulerView.day
        ? _format(_currentDate, 'EEEE, d. MMMM yyyy')
        : '${_format(days.first, 'd. MMM')} – ${_format(days.last, 'd. MMM yyyy')}';
    return Semantics(
      label: widget.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Vorheriger Zeitraum',
                    onPressed: _blocked
                        ? null
                        : () => _setDate(
                            txNavigateDate(_currentDate, _currentView, -1),
                          ),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  TxButton(
                    text: 'Heute',
                    disabled: _blocked,
                    onPressed: () => _setDate(DateTime.now()),
                  ),
                  IconButton(
                    tooltip: 'Nächster Zeitraum',
                    onPressed: _blocked
                        ? null
                        : () => _setDate(
                            txNavigateDate(_currentDate, _currentView, 1),
                          ),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  SizedBox(
                    width: 175,
                    child: TxDateBox(
                      label: 'Kalenderdatum',
                      value: _currentDate,
                      disabled: _blocked,
                      onChanged: (value) {
                        if (value != null) _setDate(value);
                      },
                    ),
                  ),
                  for (final view in widget.views.toSet())
                    TxButton(
                      text: _viewName(view),
                      type: _currentView == view
                          ? TxButtonType.primary
                          : TxButtonType.normal,
                      disabled: _blocked,
                      onPressed: () {
                        setState(() => _view = view);
                        widget.onCurrentViewChanged?.call(view);
                      },
                    ),
                  if (_canAdd)
                    TxButton(
                      text: 'Neuer Termin',
                      icon: Icons.add,
                      type: TxButtonType.primary,
                      onPressed: () => _open(),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  period,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (widget.loading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: TxLoadIndicator(label: 'Termine werden geladen …'),
                  ),
                )
              else
                SizedBox(
                  height: 540,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = math.max(
                        constraints.maxWidth,
                        _currentView == TxSchedulerView.day ? 280.0 : 840.0,
                      );
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: width,
                          child: _currentView == TxSchedulerView.month
                              ? _month(days)
                              : _timeGrid(days, width),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${_appointments.where((item) => item.startDate.isBefore(txAddDays(days.last, 1)) && item.endDate.isAfter(days.first)).length} Termine im Zeitraum${widget.readOnly ? ' · Nur lesen' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _month(List<DateTime> days) {
    final tokens = txThemeOf(context);
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: tokens.border),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          TableRow(
            children: [
              for (final day in days.take(7))
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_format(day, 'EEE'), textAlign: TextAlign.center),
                ),
            ],
          ),
          for (var week = 0; week < 6; week++)
            TableRow(
              children: [
                for (final day in days.skip(week * 7).take(7))
                  Container(
                    constraints: const BoxConstraints(minHeight: 100),
                    padding: const EdgeInsets.all(6),
                    color: day.month != _currentDate.month
                        ? tokens.surfaceAlt
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _canAdd
                                ? () => _cell(day, 0, true)
                                : null,
                            child: Semantics(
                              label:
                                  'Ganztagstermin erstellen: ${_format(day, 'dd.MM.yyyy')}',
                              child: Text('${day.day}'),
                            ),
                          ),
                        ),
                        for (final item in txAppointmentsOnDay(
                          _appointments,
                          day,
                        ))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _appointment(item, compact: true, day: day),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _timeGrid(List<DateTime> days, double width) {
    const gutter = 60.0, rowHeight = 36.0;
    final dayWidth = (width - gutter) / days.length,
        count =
            (widget.endDayHour - widget.startDayHour) *
            60 ~/
            widget.cellDuration;
    final height = count * rowHeight, tokens = txThemeOf(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: gutter,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Zeit', style: TextStyle(fontSize: 10)),
                ),
              ),
              for (final day in days)
                SizedBox(
                  width: dayWidth,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _format(day, 'EEE d. MMM'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      for (final item in txAppointmentsOnDay(
                        _appointments,
                        day,
                      ).where((item) => item.allDay))
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: _appointment(item, compact: true),
                        ),
                      if (_canAdd)
                        IconButton(
                          tooltip:
                              'Ganztagstermin ${_format(day, 'dd.MM.yyyy')}',
                          onPressed: () => _cell(day, 0, true),
                          icon: const Icon(Icons.add, size: 14),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: gutter,
                child: Column(
                  children: List.generate(
                    count,
                    (slot) => SizedBox(
                      height: rowHeight,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            (slot * widget.cellDuration) % 60 == 0
                                ? '${(widget.startDayHour + slot * widget.cellDuration ~/ 60).toString().padLeft(2, '0')}:00'
                                : '',
                            style: TextStyle(fontSize: 10, color: tokens.muted),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              for (var dayIndex = 0; dayIndex < days.length; dayIndex++)
                SizedBox(
                  width: dayWidth,
                  height: height,
                  child: Stack(
                    children: [
                      Column(
                        children: List.generate(count, (slot) {
                          final day = days[dayIndex],
                              minute =
                                  widget.startDayHour * 60 +
                                  slot * widget.cellDuration;
                          final cellKey = '${txDateKey(day)}-$slot';
                          final node = _cellNodes.putIfAbsent(
                            cellKey,
                            FocusNode.new,
                          );
                          return SizedBox(
                            height: rowHeight,
                            child: Focus(
                              onKeyEvent: (_, event) {
                                if (_blocked || event is! KeyDownEvent) {
                                  return KeyEventResult.ignored;
                                }
                                var nextDay = dayIndex, nextSlot = slot;
                                if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowRight) {
                                  nextDay++;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowLeft) {
                                  nextDay--;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowDown) {
                                  nextSlot++;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.arrowUp) {
                                  nextSlot--;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.home) {
                                  nextSlot = 0;
                                } else if (event.logicalKey ==
                                    LogicalKeyboardKey.end) {
                                  nextSlot = count - 1;
                                } else {
                                  return KeyEventResult.ignored;
                                }
                                final target =
                                    '${txDateKey(days[nextDay.clamp(0, days.length - 1)])}-${nextSlot.clamp(0, count - 1)}';
                                _cellNodes[target]?.requestFocus();
                                return KeyEventResult.handled;
                              },
                              child: Semantics(
                                label:
                                    'Zeitfenster ${txDateKey(day)} ${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}',
                                button: true,
                                child: OutlinedButton(
                                  focusNode: node,
                                  onPressed: _blocked
                                      ? null
                                      : () => _cell(day, minute, false),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(dayWidth, rowHeight),
                                    shape: const RoundedRectangleBorder(),
                                    side: BorderSide(color: tokens.border),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      for (final segment in txLayoutAppointments(
                        _appointments,
                        days[dayIndex],
                        widget.startDayHour,
                        widget.endDayHour,
                      ))
                        Positioned(
                          top:
                              (segment.startMinute - widget.startDayHour * 60) /
                              widget.cellDuration *
                              rowHeight,
                          height:
                              (segment.endMinute - segment.startMinute) /
                              widget.cellDuration *
                              rowHeight,
                          left: segment.lane / segment.laneCount * dayWidth + 2,
                          width: math.max(1, dayWidth / segment.laneCount - 4),
                          child: _appointment(
                            segment.appointment,
                            day: days[dayIndex],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentEditor extends StatefulWidget {
  const _AppointmentEditor({
    required this.original,
    required this.id,
    required this.start,
    required this.end,
    required this.allDay,
    required this.canSave,
    required this.canDelete,
    required this.commit,
  });
  final TxAppointment? original;
  final Object id;
  final DateTime start, end;
  final bool allDay, canSave, canDelete;
  final String? Function(TxAppointment candidate, bool delete) commit;
  @override
  State<_AppointmentEditor> createState() => _AppointmentEditorState();
}

class _AppointmentEditorState extends State<_AppointmentEditor> {
  late final _title = TextEditingController(text: widget.original?.text ?? '');
  late final _description = TextEditingController(
    text: widget.original?.description ?? '',
  );
  late bool _allDay = widget.original?.allDay ?? widget.allDay;
  late final _start = TextEditingController(
    text: txDateInput(
      widget.original?.startDate.toLocal() ?? widget.start,
      allDay: _allDay,
    ),
  );
  late final _end = TextEditingController(
    text: txDateInput(
      widget.original?.endDate.toLocal() ?? widget.end,
      allDay: _allDay,
    ),
  );
  String? _error;
  bool _confirmDelete = false;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _save({bool delete = false}) {
    try {
      final candidate = delete
          ? widget.original!
          : TxAppointment(
              id: widget.id,
              text: _title.text.trim(),
              startDate: txParseDate(_start.text),
              endDate: txParseDate(_end.text),
              allDay: _allDay,
              description: _description.text,
            );
      final error = widget.commit(candidate, delete);
      if (error == null) {
        Navigator.of(context).pop();
      } else {
        setState(() => _error = error);
      }
    } catch (error) {
      setState(
        () => _error = error is FormatException ? error.message : '$error',
      );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.original == null
          ? 'Termin anlegen'
          : widget.canSave
          ? 'Termin bearbeiten'
          : 'Termindetails',
    ),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TxTextBox(
              controller: _title,
              label: 'Titel',
              readOnly: !widget.canSave,
            ),
            const SizedBox(height: 12),
            TxCheckBox(
              value: _allDay,
              label: 'Ganztägig',
              disabled: !widget.canSave,
              onChanged: (value) {
                try {
                  final start = txParseDate(_start.text),
                      end = txParseDate(_end.text);
                  if (value) {
                    _start.text = txDateInput(txDay(start), allDay: true);
                    _end.text = txDateInput(
                      txDay(end).isAfter(txDay(start))
                          ? txDay(end)
                          : txAddDays(txDay(start), 1),
                      allDay: true,
                    );
                  } else {
                    _start.text = txDateInput(
                      DateTime(start.year, start.month, start.day, 8),
                    );
                    final last = txAddDays(end, -1);
                    _end.text = txDateInput(
                      DateTime(last.year, last.month, last.day, 9),
                    );
                  }
                } catch (_) {
                  /* Retain invalid input for correction. */
                }
                setState(() => _allDay = value);
              },
            ),
            TxTextBox(
              controller: _start,
              label: 'Beginn',
              placeholder: _allDay ? 'YYYY-MM-DD' : 'YYYY-MM-DDTHH:mm',
              readOnly: !widget.canSave,
            ),
            const SizedBox(height: 12),
            TxTextBox(
              controller: _end,
              label: _allDay ? 'Ende (exklusiv)' : 'Ende',
              placeholder: _allDay ? 'YYYY-MM-DD' : 'YYYY-MM-DDTHH:mm',
              readOnly: !widget.canSave,
            ),
            const SizedBox(height: 12),
            TxTextArea(
              controller: _description,
              label: 'Beschreibung',
              readOnly: !widget.canSave,
            ),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: txThemeOf(context).danger),
                ),
              ),
            if (_confirmDelete) const Text('Diesen Termin endgültig löschen?'),
          ],
        ),
      ),
    ),
    actions: [
      if (widget.canDelete)
        TxButton(
          text: _confirmDelete ? 'Endgültig löschen' : 'Termin löschen',
          type: TxButtonType.danger,
          onPressed: () {
            if (_confirmDelete) {
              _save(delete: true);
            } else {
              setState(() => _confirmDelete = true);
            }
          },
        ),
      if (_confirmDelete)
        TxButton(
          text: 'Löschen abbrechen',
          onPressed: () => setState(() => _confirmDelete = false),
        )
      else
        TxButton(
          text: 'Schließen',
          onPressed: () => Navigator.of(context).pop(),
        ),
      if (widget.canSave && !_confirmDelete)
        TxButton(
          text: 'Speichern',
          type: TxButtonType.primary,
          onPressed: _save,
        ),
    ],
  );
}
