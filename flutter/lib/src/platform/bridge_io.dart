import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'file_backend.dart';

Object? browserUploadBody(
  FileBackend file,
  List<int> head,
  List<int> tail,
  int start,
  int end,
) => null;

const _channel = MethodChannel('tecexpress/files');

class _PathFile implements FileBackend {
  _PathFile(this.path, this.name, this.mimeType, {this.owned = false});
  @override
  final String path;
  @override
  final String name;
  @override
  final String? mimeType;
  final bool owned;
  @override
  Future<int> length() => File(path).length();
  @override
  Stream<List<int>> openRead(int start, int? end) =>
      File(path).openRead(start, end);
  @override
  Future<void> dispose() async {
    if (owned) await _channel.invokeMethod<void>('release', {'path': path});
  }
}

FileBackend fileFromPath(String path, String? name, String? mimeType) =>
    _PathFile(path, name ?? path.split(RegExp(r'[/\\]')).last, mimeType);

FileBackend _decode(dynamic value) {
  final map = Map<String, dynamic>.from(value as Map);
  return _PathFile(
    map['path'] as String,
    map['name'] as String,
    map['mimeType'] as String?,
    owned: map['owned'] == true,
  );
}

Future<List<FileBackend>> pickFiles(
  bool multiple,
  List<String> extensions,
) async =>
    (await _channel.invokeListMethod<dynamic>('pick', {
              'multiple': multiple,
              'extensions': extensions,
            }) ??
            [])
        .map(_decode)
        .toList();

Future<bool> saveFile(FileBackend file, String name) async {
  final token = await _channel.invokeMethod<String>('beginSave', {
    'name': name,
  });
  if (token == null) return false;
  try {
    await for (final bytes in file.openRead(0, null)) {
      // Native handles/URIs never travel through dart:io, and channel messages
      // are bounded even when a backend produces larger chunks.
      for (var start = 0; start < bytes.length; start += 65536) {
        await _channel.invokeMethod<void>('writeSave', {
          'token': token,
          'bytes': Uint8List.fromList(
            bytes.sublist(start, (start + 65536).clamp(0, bytes.length)),
          ),
        });
      }
    }
    await _channel.invokeMethod<void>('finishSave', {'token': token});
    return true;
  } on PlatformException catch (e) {
    await _channel.invokeMethod<void>('abortSave', {'token': token});
    if (e.code == 'cancelled') return false;
    rethrow;
  } catch (_) {
    await _channel.invokeMethod<void>('abortSave', {'token': token});
    rethrow;
  }
}

void configureDrops(
  void Function(List<FileBackend>, double, double, int) callback,
) {
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'dropError') {
      final error = PlatformException(
        code: 'drop_error',
        message: (call.arguments as Map)['message'] as String?,
      );
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, library: 'tecexpress'),
      );
      return;
    }
    if (call.method != 'drop') return;
    final data = Map<String, dynamic>.from(call.arguments as Map);
    callback(
      (data['files'] as List).map(_decode).toList(),
      (data['x'] as num).toDouble(),
      (data['y'] as num).toDouble(),
      (data['viewId'] as num?)?.toInt() ?? 0,
    );
  });
}

Future<void> updateDropTargets(List<Map<String, Object>> targets) =>
    _channel.invokeMethod<void>('targets', targets);
