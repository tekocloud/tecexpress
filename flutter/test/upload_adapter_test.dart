import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress/tecexpress.dart';

void main() {
  test('empty uploads and multipart names cannot inject headers', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    String? body;
    final subscription = server.listen((request) async {
      body = await utf8.decoder.bind(request).join();
      request.response.write('empty');
      await request.response.close();
    });
    final file = TxFile.fromData(Uint8List(0), name: 'a"\r\nInjected: yes.txt');
    try {
      final progress = <int>[];
      final upload = txHttpUpload(
        TxHttpUploadConfig(
          url: Uri.parse('http://127.0.0.1:${server.port}'),
          fields: {'a"\r\nb': 'ü'},
        ),
      );
      expect(
        await upload(
          file,
          TxUploadContext(
            cancellation: TxCancellation(),
            onProgress: (done, total) {
              progress.add(done);
              expect(total, 0);
            },
          ),
        ),
        'empty',
      );
      expect(body, contains('filename="a%22%0D%0AInjected: yes.txt"'));
      expect(body, contains('name="a%22%0D%0Ab"'));
      expect(body, contains('ü'));
      expect(progress, [0]);
    } finally {
      await file.dispose();
      await subscription.cancel();
      await server.close(force: true);
    }
  });

  test(
    'cancellation interrupts an active request and prevents subsequent chunks',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final arrived = Completer<void>();
      var requests = 0;
      final subscription = server.listen((request) async {
        requests++;
        await request.drain<void>();
        if (!arrived.isCompleted) arrived.complete();
        // Deliberately keep the response open until client cancellation.
      });
      final token = TxCancellation();
      final file = TxFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        name: 'cancel.bin',
      );
      try {
        final upload = txHttpUpload(
          TxHttpUploadConfig(
            url: Uri.parse('http://127.0.0.1:${server.port}'),
            chunkSize: 1,
          ),
        );
        final operation = upload(
          file,
          TxUploadContext(
            cancellation: token,
            onProgress: (_, _) =>
                fail('Cancelled chunk must not report success'),
          ),
        );
        final failure = expectLater(operation, throwsA(anything));
        await arrived.future.timeout(const Duration(seconds: 5));
        token.cancel();
        await failure.timeout(const Duration(seconds: 5));
        expect(requests, 1);
      } finally {
        await file.dispose();
        await subscription.cancel();
        await server.close(force: true);
      }
    },
  );

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
        TxFile.fromData(
          Uint8List.fromList(utf8.encode('hello')),
          name: 'hello.txt',
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
          file = TxFile.fromData(
            Uint8List.fromList([1, 2, 3, 4, 5]),
            name: 'hello.bin',
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
