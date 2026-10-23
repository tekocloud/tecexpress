import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

import 'support.dart';

void main() {
  final user = TxChatUser(id: 'me', name: 'Stefan Bess'),
      other = TxChatUser(id: 'lena', name: 'Lena Fischer');
  testWidgets(
    'chat sorts messages, sends with Enter and clears a controlled controller',
    (tester) async {
      var messages = [
        TxChatMessage(
          id: 2,
          text: 'Zweite',
          timestamp: DateTime(2026, 10, 23, 10),
          author: user,
        ),
        TxChatMessage(
          id: 1,
          text: 'Erste',
          timestamp: DateTime(2026, 10, 23, 9),
          author: other,
        ),
      ];
      final controller = TextEditingController();
      await pumpTx(
        tester,
        StatefulBuilder(
          builder: (context, setState) => TxChat(
            user: user,
            items: messages,
            controller: controller,
            onItemsChanged: (value) => setState(() => messages = value),
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Erste')).dy,
        lessThan(tester.getTopLeft(find.text('Zweite')).dy),
      );
      await tester.enterText(find.byType(TextField), '  Hallo Team  ');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(messages.last.text, 'Hallo Team');
      expect(controller.text, '');
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Weiter benutzbar';
      controller.dispose();
    },
  );
  testWidgets(
    'chat supports Shift+Enter, IME and cancellation without discarding drafts',
    (tester) async {
      var calls = 0;
      final controller = TextEditingController();
      await pumpTx(
        tester,
        TxChat(
          user: user,
          controller: controller,
          onMessageEntered: (event) {
            calls++;
            event.cancel = true;
          },
        ),
      );
      await tester.enterText(find.byType(TextField), 'Entwurf');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(calls, 0);
      controller.value = const TextEditingValue(
        text: 'Komposition',
        selection: TextSelection.collapsed(offset: 5),
        composing: TextRange(start: 0, end: 5),
      );
      expect(controller.value.composing.isCollapsed, false);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 0);
      controller.value = const TextEditingValue(text: 'Entwurf');
      await tester.pump();
      await tester.tap(find.text('Senden ↑'));
      await tester.pump();
      expect(calls, 1);
      expect(controller.text, 'Entwurf');
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
  testWidgets('chat stops typing after inactivity and cleans up timers', (
    tester,
  ) async {
    var starts = 0, ends = 0;
    await pumpTx(
      tester,
      TxChat(
        user: user,
        onTypingStart: (_) => starts++,
        onTypingEnd: (_) => ends++,
        typingUsers: [user, other],
      ),
    );
    await tester.enterText(find.byType(TextField), 'H');
    await tester.enterText(find.byType(TextField), 'Hallo');
    expect(starts, 1);
    expect(find.text('Lena Fischer schreibt …'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(ends, 1);
    await tester.enterText(find.byType(TextField), 'Hallo!');
    expect(starts, 2);
    await tester.pumpWidget(const SizedBox());
    expect(ends, 2);
  });
  testWidgets('chat read-only and sending retain input and block sends', (
    tester,
  ) async {
    var calls = 0;
    final controller = TextEditingController(text: 'Entwurf');
    await pumpTx(
      tester,
      TxChat(
        user: user,
        controller: controller,
        sending: true,
        onMessageSent: (_) => calls++,
      ),
    );
    await tester.tap(find.text('Wird gesendet …'));
    expect(calls, 0);
    expect(controller.text, 'Entwurf');
    await pumpTx(
      tester,
      TxChat(user: user, controller: controller, readOnly: true),
    );
    expect(find.byType(TextField), findsNothing);
    await pumpTx(tester, TxChat(user: user, controller: controller));
    expect(controller.text, 'Entwurf');
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets(
    'incoming messages do not force a scrolled-up reader to the bottom',
    (tester) async {
      var messages = List.generate(
        25,
        (index) => TxChatMessage(
          id: index,
          text: 'Nachricht $index',
          timestamp: DateTime(2026, 10, 23, 9, index),
          author: other,
        ),
      );
      late StateSetter update;
      await pumpTx(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return TxChat(user: user, items: messages);
          },
        ),
      );
      await tester.pumpAndSettle();
      final list = tester.widget<ListView>(find.byType(ListView));
      list.controller!.jumpTo(0);
      await tester.pump();
      update(
        () => messages = [
          ...messages,
          TxChatMessage(
            id: 'new',
            text: 'Neu',
            timestamp: DateTime(2026, 10, 23, 12),
            author: other,
          ),
        ],
      );
      await tester.pump();
      expect(list.controller!.offset, 0);
      expect(find.text('1 neue Nachrichten ↓'), findsOneWidget);
      await tester.tap(find.text('1 neue Nachrichten ↓'));
      await tester.pumpAndSettle();
      expect(list.controller!.offset, greaterThan(0));
    },
  );
  testWidgets(
    'literal message text, errors and custom builders are supported',
    (tester) async {
      await pumpTx(
        tester,
        TxChat(
          user: user,
          items: [
            TxChatMessage(
              id: 1,
              text: '<script>alert(1)</script>',
              timestamp: DateTime(2026, 10, 23),
              author: user,
              status: TxMessageStatus.error,
            ),
          ],
        ),
      );
      expect(find.text('<script>alert(1)</script>'), findsOneWidget);
      expect(find.text('Senden fehlgeschlagen'), findsOneWidget);
      await pumpTx(
        tester,
        TxChat(
          user: user,
          items: [
            TxChatMessage(
              id: 1,
              text: 'Hallo',
              timestamp: DateTime(2026, 10, 23),
              author: user,
            ),
          ],
          messageBuilder: (_, message, own) =>
              Text('Vorlage ${message.text}: $own'),
        ),
      );
      expect(find.text('Vorlage Hallo: true'), findsOneWidget);
    },
  );
}
