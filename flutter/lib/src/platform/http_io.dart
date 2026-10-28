import 'dart:convert';
import 'dart:io';

import '../source.dart';

Future<String> postMultipart(
  Uri url,
  Map<String, String> headers,
  String contentType,
  int length,
  Stream<List<int>> body,
  TxCancellation cancellation,
  Object? browserBody,
) async {
  final client = HttpClient();
  final unregister = cancellation.onCancel(() => client.close(force: true));
  try {
    cancellation.throwIfCancelled();
    final request = await client.postUrl(url);
    headers.forEach(request.headers.set);
    request.headers.set(HttpHeaders.contentTypeHeader, contentType);
    request.contentLength = length;
    await request.addStream(body);
    cancellation.throwIfCancelled();
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('HTTP ${response.statusCode}');
    }
    return text;
  } finally {
    unregister();
    client.close(force: true);
  }
}
