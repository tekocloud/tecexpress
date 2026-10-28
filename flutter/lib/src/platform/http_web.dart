import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import '../source.dart';

@JS('XMLHttpRequest')
extension type _Request._(JSObject _) implements JSObject {
  external factory _Request();
  external void open(String method, String url);
  external void setRequestHeader(String name, String value);
  external void send(JSAny body);
  external void abort();
  external int get status;
  external String get responseText;
  external set onload(JSFunction? listener);
  external set onerror(JSFunction? listener);
  external set onabort(JSFunction? listener);
}

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny?> parts);
}

Future<String> postMultipart(
  Uri url,
  Map<String, String> headers,
  String contentType,
  int length,
  Stream<List<int>> body,
  TxCancellation cancellation,
  Object? browserBody,
) async {
  final result = Completer<String>(), request = _Request();
  // Cancellation may happen while the request body is still being prepared.
  result.future.ignore();
  final unregister = cancellation.onCancel(() {
    request.abort();
    if (!result.isCompleted) {
      result.completeError(StateError('Upload cancelled'));
    }
  });
  try {
    cancellation.throwIfCancelled();
    final parts = <JSAny?>[];
    if (browserBody == null) {
      await for (final bytes in body) {
        cancellation.throwIfCancelled();
        parts.add(Uint8List.fromList(bytes).toJS);
      }
    }
    request.open('POST', url.toString());
    headers.forEach((name, value) => request.setRequestHeader(name, value));
    request.setRequestHeader('Content-Type', contentType);
    request.onload = ((JSAny? _) {
      if (result.isCompleted) return;
      if (request.status >= 200 && request.status < 300) {
        result.complete(request.responseText);
      } else {
        result.completeError(StateError('HTTP ${request.status}'));
      }
    }).toJS;
    request.onerror = ((JSAny? _) {
      if (!result.isCompleted) {
        result.completeError(StateError('Network error'));
      }
    }).toJS;
    request.onabort = ((JSAny? _) {
      if (!result.isCompleted) {
        result.completeError(StateError('Upload cancelled'));
      }
    }).toJS;
    cancellation.throwIfCancelled();
    request.send(
      browserBody == null ? _Blob(parts.toJS) : browserBody as JSObject,
    );
    return await result.future;
  } finally {
    unregister();
    request.onload = null;
    request.onerror = null;
    request.onabort = null;
  }
}
