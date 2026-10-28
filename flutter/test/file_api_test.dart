import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';
import 'package:tecexpress/src/file_drop.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tecexpress/files');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'memory files own their bytes, bound ranges and reject use after disposal',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final file = TxFile.fromData(bytes, name: 'test.bin');
      bytes[0] = 9;
      expect(await file.readAsBytes(), [1, 2, 3, 4]);
      expect(await file.openRead(1, 3).expand((e) => e).toList(), [2, 3]);
      expect(await file.openRead(4, 4).toList(), isEmpty);
      await expectLater(file.openRead(-1).drain<void>(), throwsRangeError);
      await expectLater(file.openRead(0, 5).drain<void>(), throwsRangeError);
      await file.dispose();
      await file.dispose();
      await expectLater(file.length(), throwsA(isA<TxFileException>()));
    },
  );

  test('disposing native paths never deletes source files', () async {
    final dir = await Directory.systemTemp.createTemp('tx-file-test-');
    final source = File('${dir.path}/sample.txt');
    await source.writeAsBytes([3, 2, 1]);
    final file = TxFile.fromPath(source.path);
    try {
      expect(file.name, 'sample.txt');
      expect(await file.readAsBytes(), [3, 2, 1]);
      await file.dispose();
      expect(await source.exists(), isTrue);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('dialog cancellation, filters and owned resources', () async {
    final released = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'release') {
        released.add((call.arguments as Map)['path'] as String);
        return null;
      }
      if (call.method == 'beginSave') return null;
      return [
        {'name': 'readme.TXT', 'path': '/owned/one', 'owned': true},
        {'name': 'other.bin', 'path': '/owned/two', 'owned': true},
      ];
    });
    final files = await TxFileDialogs.pickFiles(extensions: ['.txt']);
    expect(files.map((f) => f.name), ['readme.TXT']);
    expect(released, ['/owned/two']);
    expect(await TxFileDialogs.saveFile(files.single), isFalse);
    await files.single.dispose();
    expect(released, ['/owned/two', '/owned/one']);
    messenger.setMockMethodCallHandler(channel, (_) async => []);
    expect(await TxFileDialogs.pickFiles(), isEmpty);
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'io'),
    );
    await expectLater(
      TxFileDialogs.pickFiles(),
      throwsA(isA<TxFileException>()),
    );
  });

  test(
    'saving uses bounded channel messages and releases a cancelled export',
    () async {
      final lengths = <int>[];
      var finished = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'beginSave':
            return 'save-token';
          case 'writeSave':
            lengths.add(((call.arguments as Map)['bytes'] as Uint8List).length);
          case 'finishSave':
            finished = true;
        }
        return null;
      });
      final file = TxFile.fromData(Uint8List(150000), name: 'large.bin');
      expect(await TxFileDialogs.saveFile(file), isTrue);
      expect(lengths.fold<int>(0, (a, b) => a + b), 150000);
      expect(lengths.every((n) => n <= 65536), isTrue);
      expect(finished, isTrue);
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'beginSave') return 'save-token';
        if (call.method == 'finishSave') {
          throw PlatformException(code: 'cancelled');
        }
        return null;
      });
      expect(await TxFileDialogs.saveFile(file), isFalse);
      await file.dispose();
    },
  );

  testWidgets('nested drops use the frontmost enabled Flutter target', (
    tester,
  ) async {
    final received = <String>[];
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: TxFileDropTarget(
            onDrop: (files) async {
              received.add('outer');
              for (final f in files) {
                await f.dispose();
              }
            },
            child: SizedBox(
              width: 300,
              height: 300,
              child: Center(
                child: TxFileDropTarget(
                  onDrop: (files) async {
                    received.add('inner');
                    for (final f in files) {
                      await f.dispose();
                    }
                  },
                  child: const SizedBox(width: 100, height: 100),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final point = tester.getCenter(find.byType(TxFileDropTarget).last);
    final data = channel.codec.encodeMethodCall(
      MethodCall('drop', {
        'x': point.dx,
        'y': point.dy,
        'viewId': tester.view.viewId,
        'files': [
          {'name': 'drop.txt', 'path': '/owned/drop', 'owned': true},
        ],
      }),
    );
    await messenger.handlePlatformMessage(channel.name, data, (_) {});
    await tester.pump();
    expect(received, ['inner']);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
