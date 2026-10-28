import 'dart:convert';
import 'dart:math';

import 'file_api.dart';
import 'source.dart';
import 'platform/http_stub.dart'
    if (dart.library.io) 'platform/http_io.dart'
    if (dart.library.js_interop) 'platform/http_web.dart'
    as transport;

String _quoted(String value) => value
    .replaceAll('%', '%25')
    .replaceAll('\r', '%0D')
    .replaceAll('\n', '%0A')
    .replaceAll('"', '%22');

Future<String> sendFileChunk({
  required Uri url,
  required Map<String, String> headers,
  required Map<String, String> fields,
  required String fieldName,
  required TxFile file,
  required int start,
  required int end,
  required TxCancellation cancellation,
}) async {
  final random = Random.secure();
  final boundary =
      'tecexpress-${List.generate(24, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
  final prefix = StringBuffer();
  for (final entry in fields.entries) {
    prefix.write(
      '--$boundary\r\nContent-Disposition: form-data; name="${_quoted(entry.key)}"\r\n\r\n${entry.value}\r\n',
    );
  }
  final mime = file.mimeType ?? 'application/octet-stream';
  if (mime.contains('\r') || mime.contains('\n')) {
    throw ArgumentError('Invalid MIME type');
  }
  prefix.write(
    '--$boundary\r\nContent-Disposition: form-data; name="${_quoted(fieldName)}"; filename="${_quoted(file.name)}"\r\nContent-Type: $mime\r\n\r\n',
  );
  final head = utf8.encode(prefix.toString()),
      tail = utf8.encode('\r\n--$boundary--\r\n');
  Stream<List<int>> body() async* {
    cancellation.throwIfCancelled();
    yield head;
    await for (final chunk in file.openRead(start, end)) {
      cancellation.throwIfCancelled();
      yield chunk;
    }
    yield tail;
  }

  return transport.postMultipart(
    url,
    headers,
    'multipart/form-data; boundary=$boundary',
    head.length + end - start + tail.length,
    body(),
    cancellation,
    browserFileUploadBody(file, head, tail, start, end),
  );
}
