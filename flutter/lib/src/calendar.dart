import 'models.dart';

DateTime txDay(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

DateTime txAddDays(DateTime date, int count) =>
    DateTime(date.year, date.month, date.day + count);
String txDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
String txDateInput(DateTime date, {bool allDay = false}) =>
    '${txDateKey(date)}${allDay ? '' : 'T${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'}';
DateTime txParseDate(String text) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2}))?$')
      .firstMatch(text);
  if (match == null) {
    throw const FormatException(
      'Datum als YYYY-MM-DD bzw. YYYY-MM-DDTHH:mm eingeben.',
    );
  }
  final parts = [for (var i = 1; i <= 5; i++) int.parse(match[i] ?? '0')];
  final date = DateTime(parts[0], parts[1], parts[2], parts[3], parts[4]);
  if (date.year != parts[0] ||
      date.month != parts[1] ||
      date.day != parts[2] ||
      date.hour != parts[3] ||
      date.minute != parts[4]) {
    throw const FormatException(
      'Ungültiges Datum oder nicht existierende lokale Uhrzeit.',
    );
  }
  return date;
}

DateTime txWeekStart(DateTime date, int firstDay) =>
    txAddDays(txDay(date), -((date.weekday % 7 - firstDay + 7) % 7));
List<DateTime> txCalendarDays(
  DateTime date,
  TxSchedulerView view,
  int firstDay,
) {
  if (view == TxSchedulerView.day) return [txDay(date)];
  final start = txWeekStart(
    view == TxSchedulerView.month ? DateTime(date.year, date.month) : date,
    firstDay,
  );
  return List.generate(
    view == TxSchedulerView.month ? 42 : 7,
    (i) => txAddDays(start, i),
  );
}

DateTime txNavigateDate(DateTime date, TxSchedulerView view, int direction) {
  if (view != TxSchedulerView.month) {
    return txAddDays(date, direction * (view == TxSchedulerView.week ? 7 : 1));
  }
  final first = DateTime(date.year, date.month + direction);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, date.day > last ? last : date.day);
}

List<TxAppointment> txAppointmentsOnDay(
  List<TxAppointment> appointments,
  DateTime day,
) {
  final next = txAddDays(day, 1);
  final result = appointments
      .where(
        (item) => item.startDate.isBefore(next) && item.endDate.isAfter(day),
      )
      .toList();
  result.sort((a, b) {
    final allDay = (b.allDay ? 1 : 0) - (a.allDay ? 1 : 0);
    return allDay != 0 ? allDay : a.startDate.compareTo(b.startDate);
  });
  return result;
}

class TxCalendarSegment {
  TxCalendarSegment(
    this.appointment,
    this.startMinute,
    this.endMinute,
    this.lane,
  );
  final TxAppointment appointment;
  final double startMinute, endMinute;
  final int lane;
  int laneCount = 1;
}

List<TxCalendarSegment> txLayoutAppointments(
  List<TxAppointment> appointments,
  DateTime day,
  int startHour,
  int endHour,
) {
  final intervals = <({TxAppointment item, double start, double end})>[];
  final next = txAddDays(day, 1);
  for (final item in txAppointmentsOnDay(
    appointments,
    day,
  ).where((item) => !item.allDay)) {
    final start = item.startDate.toLocal(), end = item.endDate.toLocal();
    final from = start.isBefore(day) ? 0.0 : start.hour * 60.0 + start.minute;
    var to = !end.isBefore(next) ? 1440.0 : end.hour * 60.0 + end.minute;
    if (to <= from) to = from + end.difference(start).inSeconds / 60;
    final clippedStart = from.clamp(startHour * 60.0, endHour * 60.0);
    final clippedEnd = to.clamp(startHour * 60.0, endHour * 60.0);
    if (clippedEnd > clippedStart) {
      intervals.add((item: item, start: clippedStart, end: clippedEnd));
    }
  }
  intervals.sort((a, b) {
    final start = a.start.compareTo(b.start);
    return start == 0 ? b.end.compareTo(a.end) : start;
  });
  final output = <TxCalendarSegment>[],
      cluster = <TxCalendarSegment>[],
      lanes = <double>[];
  var clusterEnd = -1.0;
  void flush() {
    for (final segment in cluster) {
      segment.laneCount = lanes.length;
    }
    cluster.clear();
    lanes.clear();
  }

  for (final interval in intervals) {
    if (interval.start >= clusterEnd) {
      flush();
      clusterEnd = -1;
    }
    var lane = lanes.indexWhere((end) => end <= interval.start);
    if (lane < 0) {
      lane = lanes.length;
      lanes.add(interval.end);
    } else {
      lanes[lane] = interval.end;
    }
    if (interval.end > clusterEnd) clusterEnd = interval.end;
    final segment = TxCalendarSegment(
      interval.item,
      interval.start,
      interval.end,
      lane,
    );
    cluster.add(segment);
    output.add(segment);
  }
  flush();
  return output;
}
