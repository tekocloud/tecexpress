import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';
import 'package:tecexpress/src/calendar.dart';

import 'support.dart';

void main() {
  test('calendar navigation clamps months, starts weeks and rejects invalid wall-clock dates', () {
    expect(
      txNavigateDate(DateTime(2026, 1, 31), TxSchedulerView.month, 1),
      DateTime(2026, 2, 28),
    );
    expect(
      txNavigateDate(DateTime(2024, 1, 31), TxSchedulerView.month, 1),
      DateTime(2024, 2, 29),
    );
    expect(
      txNavigateDate(DateTime(2026, 12, 31), TxSchedulerView.day, 1),
      DateTime(2027),
    );
    expect(txWeekStart(DateTime(2026, 10, 23), 1), DateTime(2026, 10, 19));
    expect(txWeekStart(DateTime(2026, 10, 23), 0), DateTime(2026, 10, 18));
    expect(
      txCalendarDays(DateTime(2026, 2), TxSchedulerView.month, 1).length,
      42,
    );
    expect(() => txParseDate('2026-02-30T09:00'), throwsFormatException);
    expect(() => txParseDate('2026-03-29T25:00'), throwsFormatException);
    for (final start in [DateTime(2026, 3, 28), DateTime(2026, 10, 24)]) {
      expect(
        List.generate(
          4,
          (i) => txAddDays(start, i),
        ).every((day) => day.hour == 0),
        true,
      );
    }
  });
  test('exclusive all-day ends, overnight clipping and overlap lanes', () {
    final data = [
      TxAppointment(
        id: 1,
        text: 'Ganztag',
        startDate: DateTime(2026, 10, 23),
        endDate: DateTime(2026, 10, 24),
        allDay: true,
      ),
      TxAppointment(
        id: 2,
        text: 'Nacht',
        startDate: DateTime(2026, 10, 23, 17),
        endDate: DateTime(2026, 10, 24, 10),
      ),
    ];
    expect(
      txAppointmentsOnDay(data, DateTime(2026, 10, 24)).map((item) => item.id),
      [2],
    );
    final segment = txLayoutAppointments(
      data,
      DateTime(2026, 10, 24),
      8,
      18,
    ).single;
    expect(segment.startMinute, 480);
    expect(segment.endMinute, 600);
    final overlaps = [
      TxAppointment(
        id: 3,
        text: 'A',
        startDate: DateTime(2026, 10, 23, 9),
        endDate: DateTime(2026, 10, 23, 10, 30),
      ),
      TxAppointment(
        id: 4,
        text: 'B',
        startDate: DateTime(2026, 10, 23, 9, 30),
        endDate: DateTime(2026, 10, 23, 11),
      ),
      TxAppointment(
        id: 5,
        text: 'C',
        startDate: DateTime(2026, 10, 23, 11),
        endDate: DateTime(2026, 10, 23, 12),
      ),
    ];
    expect(
      txLayoutAppointments(
        overlaps,
        DateTime(2026, 10, 23),
        8,
        18,
      ).map((item) => (item.lane, item.laneCount)),
      [(0, 2), (1, 2), (0, 1)],
    );
  });
  testWidgets(
    'scheduler creates, validates, updates and confirms deletion in a controlled model',
    (tester) async {
      var appointments = <TxAppointment>[];
      await pumpTx(
        tester,
        StatefulBuilder(
          builder: (context, update) => TxScheduler(
            currentDate: DateTime(2026, 10, 23),
            currentView: TxSchedulerView.day,
            dataSource: appointments,
            onDataSourceChanged: (value) => update(() => appointments = value),
          ),
        ),
      );
      await tester.tap(find.text('Neuer Termin'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Titel'),
        'Workshop',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Beginn'),
        '2026-10-23T09:00',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Ende'),
        '2026-10-23T08:00',
      );
      await tester.tap(find.text('Speichern'));
      await tester.pump();
      expect(appointments, isEmpty);
      expect(find.textContaining('Ende nach Beginn'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Ende'),
        '2026-10-23T10:00',
      );
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();
      expect(appointments.single.text, 'Workshop');
      await tester.tap(find.text('Workshop'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Titel'),
        'Überarbeitet',
      );
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();
      expect(appointments.single.text, 'Überarbeitet');
      await tester.tap(find.text('Überarbeitet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Termin löschen'));
      await tester.pump();
      expect(appointments.length, 1);
      await tester.tap(find.text('Endgültig löschen'));
      await tester.pumpAndSettle();
      expect(appointments, isEmpty);
    },
  );
  testWidgets('scheduler cancellation, read-only and navigation models', (
    tester,
  ) async {
    TxSchedulerView? view;
    DateTime? date;
    await pumpTx(
      tester,
      TxScheduler(
        currentDate: DateTime(2026, 1, 31),
        currentView: TxSchedulerView.month,
        onCurrentViewChanged: (value) => view = value,
        onCurrentDateChanged: (value) => date = value,
        onAppointmentAdding: (event) => event.cancel = true,
      ),
    );
    await tester.tap(find.byTooltip('Nächster Zeitraum'));
    expect(date, DateTime(2026, 2, 28));
    await tester.tap(find.text('Tag'));
    expect(view, TxSchedulerView.day);
    await tester.tap(find.text('Neuer Termin'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Titel'),
      'Abbrechen',
    );
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    expect(
      find.text('Das Anlegen wurde von der Anwendung abgebrochen.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Schließen'));
    await tester.pumpAndSettle();
    await pumpTx(
      tester,
      TxScheduler(currentDate: DateTime(2026, 10, 23), readOnly: true),
    );
    expect(find.text('Neuer Termin'), findsNothing);
    expect(find.textContaining('Nur lesen'), findsOneWidget);
  });
  testWidgets(
    'scheduler rejects stale edits without resurrecting externally removed appointments',
    (tester) async {
      var data = [
        TxAppointment(
          id: 1,
          text: 'Original',
          startDate: DateTime(2026, 10, 23, 9),
          endDate: DateTime(2026, 10, 23, 10),
        ),
      ];
      late StateSetter update;
      await pumpTx(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return TxScheduler(
              currentDate: DateTime(2026, 10, 23),
              currentView: TxSchedulerView.day,
              dataSource: data,
              onDataSourceChanged: (value) => setState(() => data = value),
            );
          },
        ),
      );
      await tester.tap(find.text('Original'));
      await tester.pumpAndSettle();
      update(() => data = []);
      await tester.pump();
      await tester.tap(find.text('Speichern'));
      await tester.pump();
      expect(data, isEmpty);
      expect(find.textContaining('zwischenzeitlich'), findsOneWidget);
      await tester.tap(find.text('Schließen'));
      await tester.pumpAndSettle();
    },
  );
}
