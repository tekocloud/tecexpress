import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

Widget testApp(Widget child) => MaterialApp(
  theme: TxTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

class Row {
  const Row(this.id, this.text, this.group);
  final int id;
  final String text, group;
}

const rows = [Row(1, 'Alpha', 'A'), Row(2, 'Beta', 'B'), Row(3, 'Alpine', 'A')];
void main() {
  test('source filters, groups, pages and resets query state', () async {
    final source = TxDataSource<Row>(
      TxDataSourceConfig<Row>(
        store: TxArrayStore(rows, keyOf: (v) => v.id),
        pageSize: 1,
        pageIndex: 2,
      ),
    );
    await source.load();
    expect(source.items.single.id, 3);
    await source.configure(searchValue: 'al', searchExpr: [(v) => v.text]);
    expect(source.pageIndex, 0);
    expect(source.totalCount, 2);
    await source.configure(pageSize: 5, group: [TxSort((v) => v.group)]);
    expect(source.groups.single.count, 2);
    await source.configure(
      filter: TxFilter((v) => v.id, 1, operator: TxFilterOperator.greater),
    );
    expect(source.items.single.id, 3);
    source.dispose();
  });
  test(
    'custom remote source receives query and is not processed twice',
    () async {
      TxLoadOptions<Row>? options;
      final source = TxDataSource<Row>(
        TxDataSourceConfig<Row>(
          store: TxCustomStore<Row>(
            load: (o) {
              options = o;
              return const TxLoadResult(
                data: [Row(3, 'Server', 'S')],
                totalCount: 40,
              );
            },
          ),
          pageSize: 1,
          pageIndex: 3,
          filter: TxFilter((v) => v.id, 999),
        ),
      );
      await source.load();
      expect(options!.skip, 3);
      expect(options!.take, 1);
      expect(source.items.single.text, 'Server');
      expect(source.totalCount, 40);
      source.dispose();
    },
  );
  test('raw custom source supports local query', () async {
    final source = TxDataSource<Row>(
      TxDataSourceConfig<Row>(
        store: TxCustomStore<Row>(load: (_) => const TxLoadResult(data: rows)),
        remoteOperations: false,
        pageSize: 1,
        sort: [TxSort((v) => v.id, desc: true)],
      ),
    );
    await source.load();
    expect(source.items.single.id, 3);
    expect(source.totalCount, 3);
    source.dispose();
  });
  test('stale loads and failures cannot replace newer results', () async {
    final pending = <Completer<TxLoadResult<Row>>>[];
    final source = TxDataSource<Row>(
      TxDataSourceConfig<Row>(
        store: TxCustomStore<Row>(
          load: (_) {
            final result = Completer<TxLoadResult<Row>>();
            pending.add(result);
            return result.future;
          },
        ),
      ),
    );
    final first = source.load(), second = source.reload();
    pending[1].complete(const TxLoadResult(data: [Row(2, 'New', 'B')]));
    await second;
    pending[0].completeError(StateError('old'));
    await first;
    expect(source.items.single.text, 'New');
    expect(source.error, isNull);
    expect(source.loading, false);
    source.dispose();
  });
  test(
    'errors, cancellation and retry expose consistent loading state',
    () async {
      var fail = true, notifications = 0;
      final source = TxDataSource<Row>(
        TxDataSourceConfig<Row>(
          store: TxCustomStore<Row>(
            load: (_) {
              if (fail) throw StateError('offline');
              return const TxLoadResult(data: rows);
            },
          ),
        ),
      );
      source.addListener(() => notifications++);
      await expectLater(source.load(), throwsStateError);
      expect(source.error, isNotNull);
      expect(source.loading, false);
      fail = false;
      await source.reload();
      expect(source.error, isNull);
      expect(notifications, 4);
      source.cancel();
      source.dispose();
      await expectLater(source.load(), throwsStateError);
    },
  );
  test(
    'CRUD and pushes use typed transformations and immutable keys',
    () async {
      final source = TxDataSource.array(rows, keyOf: (v) => v.id);
      await source.load();
      await source.insert(const Row(4, 'Delta', 'D'));
      await source.update(4, (v) => Row(v.id, 'Updated', v.group));
      expect((await source.byKey(4))!.text, 'Updated');
      await expectLater(
        source.update(4, (v) => Row(5, v.text, v.group)),
        throwsArgumentError,
      );
      await source.push([const TxPush.remove(2), const TxPush.remove(4)]);
      expect(source.items.length, 2);
      source.dispose();
      expect(
        () => TxArrayStore([rows[0], rows[0]], keyOf: (v) => v.id),
        throwsArgumentError,
      );
    },
  );
  test('file provider prevents cycles and removes descendants', () async {
    final provider = TxMemoryFileProvider();
    final a = await provider.createDirectory(null, 'A'),
        b = await provider.createDirectory(a.id, 'B');
    await expectLater(provider.move(a.id, b.id), throwsArgumentError);
    await expectLater(provider.createDirectory(null, 'A'), throwsStateError);
    await provider.remove(a.id);
    expect(await provider.list(a.id), isEmpty);
  });
  test('Mercator round trips and clamps poles', () {
    const point = TxCoordinate(52.52, 13.405);
    final result = txUnproject(txProject(point, 8), 8);
    expect(result.lat, closeTo(point.lat, .00001));
    expect(result.lng, closeTo(point.lng, .00001));
    expect(txProject(const TxCoordinate(90, 0), 2).dy.isFinite, true);
  });
  testWidgets('radio and button groups prefer dataSource and share changes', (
    tester,
  ) async {
    final source = TxDataSource.array([
      const TxItem(value: 1, text: 'One'),
      const TxItem(value: 2, text: 'Two'),
    ], keyOf: (v) => v.value);
    int? value;
    await tester.pumpWidget(
      testApp(
        Column(
          children: [
            TxRadioGroup<int>(
              items: const [TxItem(value: 0, text: 'Ignored')],
              dataSource: source,
              onChanged: (v) => value = v,
            ),
            TxButtonGroup<int>(dataSource: source),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ignored'), findsNothing);
    expect(find.text('Two'), findsNWidgets(2));
    await tester.tap(find.byType(Radio<int>).first);
    expect(value, 1);
    await source.remove(2);
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await source.load();
    source.dispose();
  });
  testWidgets('grid renders remote page without paging twice', (tester) async {
    final source = TxDataSource<Row>(
      TxDataSourceConfig<Row>(
        store: TxArrayStore(rows, keyOf: (v) => v.id),
        pageSize: 1,
        pageIndex: 1,
      ),
    );
    await tester.pumpWidget(
      testApp(
        TxDataGrid<Row>(
          dataSource: source,
          keyOf: (v) => v.id,
          columns: [TxColumn(caption: 'Name', valueGetter: (v) => v.text)],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    source.dispose();
  });
  testWidgets('Lookup selects and TagBox confirms a draft', (tester) async {
    Set<int> result = {};
    await tester.pumpWidget(
      testApp(
        TxTagBox<int>(
          items: const [TxItem(value: 1, text: 'One')],
          applyOnConfirm: true,
          onChanged: (v) => result = v,
        ),
      ),
    );
    await tester.tap(find.text('Auswählen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(result, isEmpty);
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();
    expect(result, {1});
  });
  testWidgets('range controls report snapped changes and show a chart', (
    tester,
  ) async {
    RangeValues? next;
    await tester.pumpWidget(
      testApp(
        TxRangeSlider(
          value: const RangeValues(20, 60),
          step: 5,
          minRange: 10,
          onChanged: (v) => next = v,
        ),
      ),
    );
    final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
    slider.onChanged!(const RangeValues(59, 60));
    expect(next!.start, 50);
    await tester.pumpWidget(
      testApp(
        TxRangeSelector<int>(
          value: const RangeValues(0, 5),
          min: 0,
          max: 10,
          items: const [1, 2, 3],
          argumentOf: (v) => v.toDouble(),
          valueOf: (v) => v * 2.0,
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
  });
  testWidgets('LoadPanel follows a source and notify updates and closes', (
    tester,
  ) async {
    final pending = Completer<TxLoadResult<Row>>();
    final source = TxDataSource<Row>(
      TxDataSourceConfig<Row>(
        store: TxCustomStore<Row>(load: (_) => pending.future),
      ),
    );
    late BuildContext context;
    await tester.pumpWidget(
      testApp(
        Builder(
          builder: (c) {
            context = c;
            return SizedBox(
              height: 200,
              child: TxLoadPanel(
                dataSource: source,
                child: const Text('Content'),
              ),
            );
          },
        ),
      ),
    );
    final loading = source.load();
    await tester.pump();
    expect(find.text('Wird geladen …'), findsOneWidget);
    pending.complete(const TxLoadResult(data: []));
    await loading;
    await tester.pump();
    expect(find.text('Wird geladen …'), findsNothing);
    final handle = txNotify(
      context,
      message: 'Hello',
      displayTime: Duration.zero,
    );
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    handle.update(message: 'Updated');
    await tester.pump();
    expect(find.text('Updated'), findsOneWidget);
    handle.close();
    await tester.pump();
    expect(find.text('Updated'), findsNothing);
    source.dispose();
  });
}
