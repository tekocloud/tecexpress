import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress_example/showcase.dart';

void main() {
  testWidgets('showcase opens and changes theme', (tester) async {
    await tester.pumpWidget(const TecexpressShowcase());
    await tester.pumpAndSettle();
    expect(find.text('tecexpress · Flutter 0.7.1'), findsOneWidget);
    await tester.tap(find.byTooltip('Theme wechseln'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
