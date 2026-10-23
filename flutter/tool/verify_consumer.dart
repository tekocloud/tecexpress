import 'dart:convert';
import 'dart:io';

/// Compile the public API from a separate consumer, without relative imports.
Future<void> main() async {
  final packageRoot = File.fromUri(Platform.script).parent.parent;
  var sdk = File(Platform.resolvedExecutable).parent;
  File? executable;
  for (var index = 0; index < 12; index++) {
    final candidate = File(
      '${sdk.path}/bin/flutter${Platform.isWindows ? '.bat' : ''}',
    );
    if (candidate.existsSync()) {
      executable = candidate;
      break;
    }
    if (sdk.parent.path == sdk.path) break;
    sdk = sdk.parent;
  }
  if (executable == null) {
    throw StateError('Flutter SDK not found from Dart executable.');
  }
  final consumer = await Directory.systemTemp.createTemp(
    'tecexpress-flutter-consumer-',
  );
  await File('${consumer.path}/pubspec.yaml').writeAsString('''
name: tecexpress_consumer
publish_to: none
environment:
  sdk: '>=3.13.5 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  tecexpress:
    path: ${jsonEncode(packageRoot.path.replaceAll('\\', '/'))}
dev_dependencies:
  flutter_test:
    sdk: flutter
''');
  final tests = Directory('${consumer.path}/test');
  await tests.create();
  await File('${tests.path}/public_api_test.dart').writeAsString(r'''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

void main() {
  testWidgets('all 21 public entries compile and native widgets render', (tester) async {
    final user = TxChatUser(id: 'me', name: 'Consumer');
    final objects = <Object>[
      const TxButton(text: 'Button'), const TxTextBox(), const TxTextArea(),
      const TxNumberBox(), const TxCheckBox(), const TxSwitch(),
      const TxSelectBox<int>(items: [TxItem(value: 1, text: 'Eins')]), const TxDateBox(),
      const TxPopup(visible: false, child: Text('Popup')), const TxTabs(items: []),
      const TxToolbar(), const TxMenu(items: []), const TxTooltip(text: 'Hilfe', child: Text('Info')),
      const TxToast(visible: false, message: 'Toast'), const TxLoadIndicator(visible: false),
      TxDataGrid<int>(dataSource: const [1], keyOf: (row) => row, columns: [TxColumn(caption: 'ID', valueGetter: (row) => row)]),
      TxColumn<int>(caption: 'Column', valueGetter: (row) => row),
      TxScheduler(currentDate: DateTime(2026, 10, 23)), const TxCard(title: 'Card'),
      TxCardView<int>(dataSource: const [1], keyOf: (row) => row, titleOf: (row) => '$row'), TxChat(user: user)
    ];
    expect(objects.length, 21);
    await tester.pumpWidget(MaterialApp(theme: TxTheme.light(), darkTheme: TxTheme.dark(),
      locale: const Locale('de'), localizationsDelegates: TxLocalizations.delegates,
      supportedLocales: TxLocalizations.supportedLocales,
      home: Scaffold(body: TxCard(title: 'Consumer-Paketprobe', child: TxChat(user: user, height: 400)))));
    await tester.pumpAndSettle();
    expect(find.text('Consumer-Paketprobe'), findsOneWidget);
    expect(find.text('Noch keine Nachrichten. Starte die Unterhaltung.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
''');
  for (final arguments in [
    ['pub', 'get'],
    ['test', '--reporter', 'expanded'],
  ]) {
    final result = await Process.run(
      executable.path,
      arguments,
      workingDirectory: consumer.path,
      runInShell: Platform.isWindows,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) exit(result.exitCode);
  }
  stdout.writeln('Consumer successfully verified: ${consumer.path}');
}
