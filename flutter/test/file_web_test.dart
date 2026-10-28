@TestOn('browser')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

@JS('document')
external _Document get _document;

extension type _Document(JSObject _) implements JSObject {
  external _Input? querySelector(String selector);
}

extension type _Input(JSObject _) implements JSObject {
  external set files(_Files value);
  external String get accept;
  external bool dispatchEvent(_Event event);
}

@JS('File')
extension type _File._(JSObject _) implements JSObject {
  external factory _File(JSArray<JSAny?> parts, String name);
}

@JS('DataTransfer')
extension type _Transfer._(JSObject _) implements JSObject {
  external factory _Transfer();
  external _Items get items;
  external _Files get files;
}

extension type _Items(JSObject _) implements JSObject {
  external void add(_File file);
}

extension type _Files(JSObject _) implements JSObject {}

@JS('Event')
extension type _Event._(JSObject _) implements JSObject {
  external factory _Event(String type);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'browser picker filters files, retains reads and removes its DOM input',
    () async {
      final picking = TxFileDialogs.pickFiles(
        multiple: true,
        extensions: ['txt'],
      );
      // pickFiles synchronously creates its input before waiting for user selection.
      final input = _document.querySelector('input[type="file"]')!;
      expect(input.accept, '.txt');
      final transfer = _Transfer();
      transfer.items.add(_File(<JSAny?>['Hello'.toJS].toJS, 'readme.txt'));
      transfer.items.add(_File(<JSAny?>['No'.toJS].toJS, 'other.bin'));
      input.files = transfer.files;
      input.dispatchEvent(_Event('change'));
      final files = await picking;
      expect(files.map((f) => f.name), ['readme.txt']);
      expect(_document.querySelector('input[type="file"]'), isNull);
      expect(await files.single.openRead(1, 4).expand((e) => e).toList(), [
        101,
        108,
        108,
      ]);
      expect(await files.single.readAsBytes(), utf8.encode('Hello'));
      await files.single.dispose();
      expect(files.single.name, 'readme.txt');
      await expectLater(
        files.single.readAsBytes(),
        throwsA(isA<TxFileException>()),
      );
      final cancelled = TxFileDialogs.pickFiles();
      _document
          .querySelector('input[type="file"]')!
          .dispatchEvent(_Event('cancel'));
      expect(await cancelled, isEmpty);
    },
  );

  const endpoint = String.fromEnvironment('TX_TEST_UPLOAD_URL');
  test(
    'browser XHR sends chunked multipart data and reports success',
    () async {
      final file = TxFile.fromData(
        Uint8List.fromList(utf8.encode('hello')),
        name: 'a".txt',
      );
      final progress = <int>[];
      try {
        final upload = txHttpUpload(
          TxHttpUploadConfig(
            url: Uri.parse('$endpoint/echo'),
            chunkSize: 2,
            fields: {'text': 'ü'},
            chunkFields: (_, index, count) => {
              'index': '$index',
              'count': '$count',
            },
          ),
        );
        final response = await upload(
          file,
          TxUploadContext(
            cancellation: TxCancellation(),
            onProgress: (done, total) {
              expect(total, 5);
              progress.add(done);
            },
          ),
        );
        final json = jsonDecode(response as String) as Map<String, dynamic>;
        expect(json['body'], contains('filename="a%22.txt"'));
        expect(json['body'], contains('name="index"\r\n\r\n2'));
        expect(json['body'], contains('ü'));
        expect(progress, [2, 4, 5]);
      } finally {
        await file.dispose();
      }
    },
    skip: endpoint.isEmpty
        ? 'Run node tool/verify_web.mjs for local HTTP fixtures'
        : false,
  );

  test(
    'browser XHR abort rejects a pending request',
    () async {
      final file = TxFile.fromData(Uint8List(0), name: 'empty.txt');
      final token = TxCancellation();
      try {
        final operation =
            txHttpUpload(TxHttpUploadConfig(url: Uri.parse('$endpoint/hold')))(
              file,
              TxUploadContext(
                cancellation: token,
                onProgress: (_, _) => fail('Aborted request succeeded'),
              ),
            );
        final failure = expectLater(operation, throwsA(anything));
        await Future<void>.delayed(const Duration(milliseconds: 300));
        token.cancel();
        await failure.timeout(const Duration(seconds: 5));
      } finally {
        await file.dispose();
      }
    },
    skip: endpoint.isEmpty
        ? 'Run node tool/verify_web.mjs for local HTTP fixtures'
        : false,
  );
}
