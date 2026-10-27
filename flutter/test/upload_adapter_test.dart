import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

void main() {
  test('HTTP adapter sends multipart chunks and protocol metadata', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
        bodies = <String>[];
    final subscription = server.listen((request) async {
      bodies.add(await utf8.decoder.bind(request).join());
      request.response.write('done');
      await request.response.close();
    });
    final progress = <int>[];
    try {
      final adapter = txHttpUpload(
        TxHttpUploadConfig(
          url: Uri.parse('http://127.0.0.1:${server.port}/upload'),
          chunkSize: 2,
          fields: const {'folder': 'docs'},
          chunkFields: (_, index, count) => {
            'index': '$index',
            'count': '$count',
          },
        ),
      );
      final result = await adapter(
        XFile.fromData(
          Uint8List.fromList(utf8.encode('hello')),
          name: 'hello.txt',
          path: 'hello.txt',
        ),
        TxUploadContext(
          cancellation: TxCancellation(),
          onProgress: (loaded, total) {
            expect(total, 5);
            progress.add(loaded);
          },
        ),
      );
      expect(result, 'done');
      expect(bodies.length, 3);
      expect(bodies.first, contains('filename="hello.txt"'));
      expect(bodies.first, contains('docs'));
      expect(bodies.last, contains('name="count"\r\n\r\n3'));
      expect(progress, [2, 4, 5]);
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  });
  test('HTTP failure stops chunks and retry begins from zero', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var requests = 0;
    final subscription = server.listen((request) async {
      await request.drain<void>();
      requests++;
      request.response.statusCode = requests == 1 ? 500 : 200;
      await request.response.close();
    });
    try {
      final adapter = txHttpUpload(
            TxHttpUploadConfig(
              url: Uri.parse('http://127.0.0.1:${server.port}/upload'),
              chunkSize: 2,
            ),
          ),
          file = XFile.fromData(
            Uint8List.fromList([1, 2, 3, 4, 5]),
            name: 'hello.bin',
            path: 'hello.bin',
          ),
          context = TxUploadContext(
            cancellation: TxCancellation(),
            onProgress: (_, _) {},
          );
      await expectLater(adapter(file, context), throwsStateError);
      expect(requests, 1);
      await adapter(file, context);
      expect(requests, 4);
      final cancelled = TxCancellation()..cancel();
      await expectLater(
        adapter(
          file,
          TxUploadContext(cancellation: cancelled, onProgress: (_, _) {}),
        ),
        throwsStateError,
      );
      expect(requests, 4);
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  });
}
