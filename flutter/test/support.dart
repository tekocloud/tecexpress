import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

Future<void> pumpTx(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  double width = 1200,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      theme: dark ? TxTheme.dark() : TxTheme.light(),
      localizationsDelegates: TxLocalizations.delegates,
      supportedLocales: TxLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}
