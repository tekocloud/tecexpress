import '../source.dart';

Future<String> postMultipart(
  Uri url,
  Map<String, String> headers,
  String contentType,
  int length,
  Stream<List<int>> body,
  TxCancellation cancellation,
  Object? browserBody,
) => Future.error(UnsupportedError('HTTP is unavailable on this platform.'));
