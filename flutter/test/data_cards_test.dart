import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

import 'support.dart';

typedef Row = ({int id, String name, String city, num amount});
const rows = [
  (id: 1, name: 'Anna', city: 'Berlin', amount: 30),
  (id: 2, name: 'Ben', city: 'Hamburg', amount: 10),
  (id: 3, name: 'Clara', city: 'Berlin', amount: 20),
  (id: 4, name: 'Dora', city: 'Berlin', amount: 40),
];
List<TxColumn<Row>> get columns => [
  TxColumn(caption: 'Name', valueGetter: (row) => row.name),
  TxColumn(caption: 'Stadt', valueGetter: (row) => row.city),
  TxColumn(caption: 'Betrag', valueGetter: (row) => row.amount),
];
void main() {
  testWidgets('grid filters, sorts numerically and preserves source order', (
    tester,
  ) async {
    await pumpTx(
      tester,
      TxDataGrid<Row>(
        dataSource: rows,
        keyOf: (row) => row.id,
        columns: columns,
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Stadt filtern'),
      'BERLIN',
    );
    await tester.pump();
    expect(find.text('Ben'), findsNothing);
    await tester.tap(find.text('Betrag'));
    await tester.pump();
    expect(
      tester.getTopLeft(find.text('Clara')).dy,
      lessThan(tester.getTopLeft(find.text('Anna')).dy),
    );
    expect(rows.first.name, 'Anna');
  });
  testWidgets('grid selection persists across pages and prunes removed rows', (
    tester,
  ) async {
    var data = rows.toList();
    Set<Object> keys = {};
    late StateSetter update;
    await pumpTx(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return TxDataGrid<Row>(
            dataSource: data,
            keyOf: (row) => row.id,
            columns: columns,
            pageSize: 2,
            selection: TxSelectionMode.multiple,
            selectedRowKeys: keys,
            onSelectedRowKeysChanged: (value) => setState(() => keys = value),
          );
        },
      ),
    );
    await tester.tap(find.bySemanticsLabel('Zeile 1 auswählen'));
    await tester.pump();
    expect(keys, {1});
    await tester.tap(find.byTooltip('Nächste Seite'));
    await tester.pump();
    expect(find.text('Clara'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Zeile 3 auswählen'));
    await tester.pump();
    expect(keys, {1, 3});
    update(() => data = [rows.first]);
    await tester.pumpAndSettle();
    expect(keys, {1});
    expect(find.text('Seite 1 / 1'), findsOneWidget);
  });
  testWidgets(
    'cards provide slots, search, pagination, selection and field builders',
    (tester) async {
      Set<Object>? selected;
      await pumpTx(
        tester,
        Column(
          children: [
            const TxCard(
              title: 'Einzelkarte',
              subtitle: 'Untertitel',
              media: Text('Medium'),
              footer: Text('Fußzeile'),
              child: Text('Inhalt'),
            ),
            TxCardView<Row>(
              dataSource: rows,
              keyOf: (row) => row.id,
              titleOf: (row) => row.name,
              columns: [
                TxCardField(caption: 'Ort', valueGetter: (row) => row.city),
              ],
              pageSize: 2,
              selection: TxSelectionMode.multiple,
              onSelectedCardKeysChanged: (keys) => selected = keys,
            ),
          ],
        ),
      );
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Fußzeile'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Karte Anna auswählen'));
      await tester.pump();
      expect(selected, {1});
      await tester.tap(find.byTooltip('Nächste Seite'));
      await tester.pump();
      expect(find.text('Clara'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Karten durchsuchen'),
        'Hamburg',
      );
      await tester.pump();
      expect(find.text('Ben'), findsOneWidget);
      expect(find.text('Clara'), findsNothing);
      expect(find.text('Seite 1 / 1'), findsOneWidget);
    },
  );
  testWidgets('grid and cards show empty and loading states', (tester) async {
    await pumpTx(
      tester,
      Column(
        children: [
          TxDataGrid<Row>(
            dataSource: const [],
            keyOf: (row) => row.id,
            columns: columns,
          ),
          TxCardView<Row>(
            dataSource: const [],
            keyOf: (row) => row.id,
            titleOf: (row) => row.name,
          ),
        ],
      ),
    );
    expect(find.text('Keine Daten vorhanden.'), findsOneWidget);
    expect(find.text('Keine Karten vorhanden.'), findsOneWidget);
    await pumpTx(
      tester,
      TxCardView<Row>(
        dataSource: rows,
        keyOf: (row) => row.id,
        titleOf: (row) => row.name,
        loading: true,
      ),
    );
    expect(find.text('Karten werden geladen …'), findsOneWidget);
  });
  test('models reject duplicate and invalid keys', () {
    expect(() => txValidateKeys(rows, (_) => 1), throwsArgumentError);
    expect(() => txValidateKey(1.5), throwsArgumentError);
  });
}
