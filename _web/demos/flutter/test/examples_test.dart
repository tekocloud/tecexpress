import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';
import '../lib/generated/registry.dart';

void main() {
  for (final entry in examples.entries) {
    testWidgets('${entry.key} mounts as an actual library example', (tester) async {
      tester.view.physicalSize = const Size(1600, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(theme: TxTheme.light(), localizationsDelegates: TxLocalizations.delegates, supportedLocales: TxLocalizations.supportedLocales, home: Scaffold(body: SingleChildScrollView(child: entry.value()))));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets('button and text input accept interaction', (tester) async {
    var clicked = false;
    await tester.pumpWidget(MaterialApp(theme: TxTheme.light(), home: Scaffold(body: TxButton(text: 'Run', onPressed: () => clicked = true))));
    await tester.tap(find.text('Run'));
    expect(clicked, isTrue);
    await tester.pumpWidget(MaterialApp(theme: TxTheme.light(), home: Scaffold(body: examples['txtextbox']!())));
    await tester.enterText(find.byType(TextField).first, 'Interactive demo');
    expect(find.text('Interactive demo'), findsOneWidget);
  });
}
