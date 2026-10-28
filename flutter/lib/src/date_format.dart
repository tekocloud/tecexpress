/// Small formatter for the patterns used by tecexpress (German/English only).
String txFormatDate(DateTime date, String pattern, String locale) {
  final de = locale.toLowerCase().startsWith('de');
  const deMonths = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  const enMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  const deShort = [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Juni',
    'Juli',
    'Aug.',
    'Sept.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];
  const enShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const deDays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];
  const enDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const deDayShort = ['Mo.', 'Di.', 'Mi.', 'Do.', 'Fr.', 'Sa.', 'So.'];
  const enDayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String pad(int value) => value.toString().padLeft(2, '0');
  final tokens = <String, String>{
    'yyyy': date.year.toString().padLeft(4, '0'),
    'MMMM': (de ? deMonths : enMonths)[date.month - 1],
    'MMM': (de ? deShort : enShort)[date.month - 1],
    'MM': pad(date.month),
    'EEEE': (de ? deDays : enDays)[date.weekday - 1],
    'EEE': (de ? deDayShort : enDayShort)[date.weekday - 1],
    'dd': pad(date.day),
    'd': '${date.day}',
    'HH': pad(date.hour),
    'mm': pad(date.minute),
  };
  if (pattern == 'yMMMMd') {
    final region = locale
        .toLowerCase()
        .replaceAll('_', '-')
        .split('-')
        .skip(1)
        .firstOrNull;
    if (!de && ['gb', 'au', 'nz', 'ie', 'za', 'in', 'sg'].contains(region)) {
      return '${date.day} ${enMonths[date.month - 1]} ${date.year}';
    }
    return de
        ? '${date.day}. ${deMonths[date.month - 1]} ${date.year}'
        : '${enMonths[date.month - 1]} ${date.day}, ${date.year}';
  }
  return pattern.replaceAllMapped(
    RegExp(r'yyyy|MMMM|MMM|MM|EEEE|EEE|dd|d|HH|mm'),
    (m) => tokens[m[0]]!,
  );
}
