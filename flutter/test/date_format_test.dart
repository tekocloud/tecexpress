import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/src/date_format.dart';

void main() {
  test('German, regional English and fallback date labels', () {
    final date = DateTime(2026, 10, 28, 9, 5);
    expect(
      txFormatDate(date, 'EEEE, d. MMMM yyyy', 'de-DE'),
      'Mittwoch, 28. Oktober 2026',
    );
    expect(txFormatDate(date, 'EEE d. MMM', 'en_GB'), 'Wed 28. Oct');
    expect(txFormatDate(date, 'HH:mm', 'de_CH'), '09:05');
    expect(txFormatDate(date, 'yMMMMd', 'de'), '28. Oktober 2026');
    expect(txFormatDate(date, 'yMMMMd', 'fr'), 'October 28, 2026');
    expect(txFormatDate(date, 'yMMMMd', 'en-GB'), '28 October 2026');
  });
}
