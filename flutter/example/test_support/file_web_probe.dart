// Browser integration probe built as a real release application, without the
// Flutter test server. Run with tool/verify_web_release.mjs from the repository.
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:tecexpress/tecexpress.dart';
import 'package:flutter/material.dart';

@JS('window')
external _Window get _window;

extension type _Window(JSObject _) implements JSObject {
  external void dispatchEvent(JSObject event);
}

@JS('DragEvent')
extension type _DragEvent._(JSObject _) implements JSObject {
  external factory _DragEvent(String type, _DragInit options);
}

@JS()
extension type _DragInit._(JSObject _) implements JSObject {
  external factory _DragInit({
    double clientX,
    double clientY,
    _Transfer dataTransfer,
    bool cancelable,
  });
}

@JS('txFileProbeResult')
external set _result(JSString value);
@JS('document')
external _Document get _document;

extension type _Document(JSObject _) implements JSObject {
  external _Input? querySelector(String selector);
}

extension type _Input(JSObject _) implements JSObject {
  external set files(_Files value);
  external void dispatchEvent(_Event event);
}

@JS('File')
extension type _File._(JSObject _) implements JSObject {
  external factory _File(JSArray<JSAny?> contents, String name);
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

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Future<void> main() async {
  final passed = <String>[];
  try {
    final picking = TxFileDialogs.pickFiles(
      multiple: true,
      extensions: ['txt'],
    );
    final input = _document.querySelector('input[type="file"]')!;
    final transfer = _Transfer();
    transfer.items.add(_File(<JSAny?>['hello'.toJS].toJS, 'browser.txt'));
    transfer.items.add(_File(<JSAny?>['no'.toJS].toJS, 'rejected.bin'));
    input.files = transfer.files;
    input.dispatchEvent(_Event('change'));
    final files = await picking;
    check(
      files.length == 1 && files.single.name == 'browser.txt',
      'File type filter',
    );
    check(
      utf8.decode(await files.single.readAsBytes()) == 'hello',
      'Browser file lifetime',
    );
    check(
      (await files.single.openRead(1, 4).expand((e) => e).toList()).join(',') ==
          '101,108,108',
      'Byte range',
    );
    check(
      _document.querySelector('input[type="file"]') == null,
      'DOM input cleanup',
    );
    passed.add('picker, filter, lifetime, ranges, DOM cleanup');
    final cancelled = TxFileDialogs.pickFiles();
    _document
        .querySelector('input[type="file"]')!
        .dispatchEvent(_Event('cancel'));
    check((await cancelled).isEmpty, 'Picker cancellation');
    passed.add('picker cancellation');

    final progress = <int>[];
    final upload = txHttpUpload(
      TxHttpUploadConfig(
        url: Uri.base.resolve('/echo'),
        chunkSize: 2,
        fields: {'unicode': 'ü'},
        chunkFields: (_, i, count) => {'index': '$i', 'count': '$count'},
      ),
    );
    final response = await upload(
      files.single,
      TxUploadContext(
        cancellation: TxCancellation(),
        onProgress: (done, total) {
          check(total == 5, 'File size');
          progress.add(done);
        },
      ),
    );
    final json = jsonDecode(response as String) as Map<String, dynamic>;
    check(
      (json['body'] as String).contains('filename="browser.txt"') &&
          (json['body'] as String).contains('name="index"\r\n\r\n2'),
      'Multipart browser file',
    );
    check(progress.join(',') == '2,4,5', 'Chunk progress');
    passed.add('XHR multipart, browser Blob slices, chunking, progress');
    await files.single.dispose();
    var disposed = false;
    try {
      await files.single.length();
    } on TxFileException {
      disposed = true;
    }
    check(disposed, 'Disposed file rejected');
    passed.add('file disposal');

    final memory = TxFile.fromData(Uint8List(0), name: 'empty.txt');
    final empty =
        await txHttpUpload(TxHttpUploadConfig(url: Uri.base.resolve('/echo')))(
          memory,
          TxUploadContext(
            cancellation: TxCancellation(),
            onProgress: (a, b) => check(a == 0 && b == 0, 'Empty progress'),
          ),
        );
    check(empty is String, 'Empty file request');
    passed.add('empty upload');
    final token = TxCancellation();
    final held =
        txHttpUpload(TxHttpUploadConfig(url: Uri.base.resolve('/hold')))(
          memory,
          TxUploadContext(
            cancellation: token,
            onProgress: (_, _) =>
                throw StateError('Cancelled request succeeded'),
          ),
        );
    var aborted = false;
    final observed = held.then(
      (_) {},
      onError: (Object _) {
        aborted = true;
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    token.cancel();
    await observed.timeout(const Duration(seconds: 5));
    check(aborted, 'XHR abort');
    await memory.dispose();
    passed.add('XHR cancellation');

    final key = GlobalKey();
    final dropped = Completer<List<TxFile>>();
    var changes = 0;
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              child: TxFileUploader(
                key: key,
                multiple: true,
                onChanged: (files) {
                  changes++;
                  if (!dropped.isCompleted) dropped.complete(files);
                },
              ),
            ),
          ),
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    final box = key.currentContext!.findRenderObject() as RenderBox;
    final point = box.localToGlobal(const Offset(20, 20));
    final dropTransfer = _Transfer();
    dropTransfer.items.add(
      _File(<JSAny?>['drop contents'.toJS].toJS, 'dropped.txt'),
    );
    _window.dispatchEvent(
      _DragEvent(
        'drop',
        _DragInit(
          clientX: point.dx,
          clientY: point.dy,
          dataTransfer: dropTransfer,
          cancelable: true,
        ),
      ),
    );
    final acquired = await dropped.future.timeout(const Duration(seconds: 5));
    check(
      utf8.decode(await acquired.single.readAsBytes()) == 'drop contents',
      'Drop target routing and lifetime',
    );
    check(changes == 1, 'One drop destination');
    runApp(const SizedBox.shrink());
    await WidgetsBinding.instance.endOfFrame;
    var released = false;
    try {
      await acquired.single.length();
    } on TxFileException {
      released = true;
    }
    check(released, 'Uploader disposes only its acquired files');
    passed.add('browser drop routing, retained file reads, uploader disposal');
    _result = jsonEncode({'passed': passed}).toJS;
  } catch (e, s) {
    _result = jsonEncode({'passed': passed, 'error': '$e', 'stack': '$s'}).toJS;
  }
}
