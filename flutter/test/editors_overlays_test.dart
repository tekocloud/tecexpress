import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

import 'support.dart';

void main() {
  testWidgets('number step controls emit numeric bounded values', (
    tester,
  ) async {
    num? value;
    await pumpTx(
      tester,
      TxNumberBox(
        value: 5,
        step: 2,
        min: 0,
        max: 6,
        onChanged: (next) => value = next,
      ),
    );
    await tester.tap(find.byTooltip('Wert erhöhen'));
    await tester.pump();
    expect(value, 6);
    await tester.tap(find.byTooltip('Wert verringern'));
    await tester.pump();
    expect(value, 4);
  });
  testWidgets(
    'text fields synchronize callbacks and preserve external controller ownership',
    (tester) async {
      final controller = TextEditingController(text: 'Alt');
      String? value;
      TxValueChange<String>? event;
      await pumpTx(
        tester,
        Column(
          children: [
            TxTextBox(
              controller: controller,
              label: 'Name',
              onChanged: (next) => value = next,
              onValueChanged: (next) => event = next,
            ),
            const TxTextArea(initialValue: 'Notiz', label: 'Notiz', rows: 4),
          ],
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'Neu');
      expect(value, 'Neu');
      expect(event?.previousValue, 'Alt');
      expect(controller.text, 'Neu');
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Nach Unmount';
      expect(controller.text, 'Nach Unmount');
      controller.dispose();
    },
  );
  testWidgets(
    'number values remain numeric and clear to null; disabled controls block callbacks',
    (tester) async {
      num? value = 1;
      await pumpTx(
        tester,
        TxNumberBox(
          value: value,
          label: 'Menge',
          onChanged: (next) => value = next,
        ),
      );
      await tester.enterText(find.byType(TextField), '12,5');
      expect(value, 12.5);
      await tester.enterText(find.byType(TextField), '');
      expect(value, isNull);
      var calls = 0;
      await pumpTx(
        tester,
        Column(
          children: [
            TxTextBox(disabled: true, onChanged: (_) => calls++),
            TxButton(
              text: 'Gesperrt',
              disabled: true,
              onPressed: () => calls++,
            ),
            TxSwitch(label: 'Aktiv', disabled: true, onChanged: (_) => calls++),
          ],
        ),
      );
      await tester.tap(find.text('Gesperrt'));
      await tester.tap(find.text('Aktiv'));
      expect(calls, 0);
    },
  );
  testWidgets('boolean, selection and date controls update values', (
    tester,
  ) async {
    bool checked = false, enabled = false;
    int? category;
    DateTime? date;
    await pumpTx(
      tester,
      Column(
        children: [
          TxCheckBox(
            label: 'Akzeptiert',
            onChanged: (value) => checked = value,
          ),
          TxSwitch(label: 'Aktiv', onChanged: (value) => enabled = value),
          TxSelectBox<int>(
            label: 'Kategorie',
            items: const [
              TxItem(value: 0, text: 'Null'),
              TxItem(value: 7, text: 'Sieben', disabled: true),
            ],
            onChanged: (value) => category = value,
          ),
          TxDateBox(
            label: 'Datum',
            value: DateTime(2026, 10, 23),
            onChanged: (value) => date = value,
          ),
        ],
      ),
    );
    await tester.tap(find.text('Akzeptiert'));
    await tester.pump();
    expect(checked, true);
    await tester.tap(find.text('Aktiv'));
    await tester.pump();
    expect(enabled, true);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Null').last);
    await tester.pumpAndSettle();
    expect(category, 0);
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('24').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(date, DateTime(2026, 10, 24));
  });
  testWidgets('navigation skips disabled tabs and invokes menu callbacks', (
    tester,
  ) async {
    int? tab, item;
    await pumpTx(
      tester,
      Column(
        children: [
          TxTabs(
            items: const [
              TxMenuItem('Eins'),
              TxMenuItem('Gesperrt', disabled: true),
              TxMenuItem('Drei'),
            ],
            onChanged: (value) => tab = value,
            builder: (_, index) => Text('Panel $index'),
          ),
          TxToolbar(
            after: const [Text('Rechts')],
            children: const [Text('Links')],
          ),
          TxMenu(
            items: const [
              TxMenuItem('Datei'),
              TxMenuItem('Export', disabled: true),
            ],
            onItemClick: (_, index) => item = index,
          ),
        ],
      ),
    );
    final first = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Eins'),
    );
    first.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(tab, 2);
    expect(find.text('Panel 2'), findsOneWidget);
    await tester.tap(find.text('Datei'));
    expect(item, 0);
    await tester.tap(find.text('Export'));
    expect(item, 0);
    expect(find.text('Links'), findsOneWidget);
    expect(find.text('Rechts'), findsOneWidget);
  });
  testWidgets(
    'popup shows content, closes with Escape and calls visibility callback',
    (tester) async {
      var visible = false;
      await pumpTx(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              TxButton(
                text: 'Öffnen',
                onPressed: () => setState(() => visible = true),
              ),
              TxPopup(
                visible: visible,
                title: 'Testdialog',
                onVisibleChanged: (next) => setState(() => visible = next),
                child: const TxTextBox(label: 'Dialogfeld'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Öffnen'));
      await tester.pumpAndSettle();
      expect(find.text('Testdialog'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(visible, false);
      expect(find.text('Testdialog'), findsNothing);
    },
  );
  testWidgets(
    'toast dismisses after duration and tooltip and loading labels are accessible',
    (tester) async {
      var hidden = false;
      await pumpTx(
        tester,
        Column(
          children: [
            TxToast(
              visible: true,
              message: 'Gespeichert',
              displayTime: const Duration(milliseconds: 100),
              onVisibleChanged: (value) => hidden = !value,
            ),
            const TxTooltip(text: 'Hilfe', child: Icon(Icons.info)),
            const TxLoadIndicator(label: 'Lädt'),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      expect(hidden, true);
      expect(find.byTooltip('Hilfe'), findsOneWidget);
      expect(find.text('Lädt'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
  testWidgets('error messages and both themes are present', (tester) async {
    await pumpTx(
      tester,
      const TxTextBox(
        label: 'E-Mail',
        isValid: false,
        validationMessage: 'Ungültig',
      ),
      dark: true,
    );
    expect(find.text('Ungültig'), findsOneWidget);
    final context = tester.element(find.byType(TxTextBox));
    expect(txThemeOf(context).background, TxThemeData.dark.background);
    expect(TxThemeData.light.copyWith(radius: 12).radius, 12);
    expect(
      TxThemeData.light.lerp(TxThemeData.dark, .5).surface,
      isNot(TxThemeData.light.surface),
    );
  });
}
