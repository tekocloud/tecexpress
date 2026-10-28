import 'dart:typed_data';

import 'platform/file_backend.dart';
import 'platform/bridge_stub.dart'
    if (dart.library.io) 'platform/bridge_io.dart'
    if (dart.library.js_interop) 'platform/bridge_web.dart'
    as platform;

/// A file operation failed. Dialog cancellation is not an error.
class TxFileException implements Exception {
  /// Creates an error with its original platform cause.
  const TxFileException(this.message, [this.cause]);

  /// Human-readable description.
  final String message;

  /// Original platform error, when available.
  final Object? cause;

  /// Returns a readable description including the original cause.
  @override
  String toString() =>
      'TxFileException: $message${cause == null ? '' : ' ($cause)'}';
}

/// A portable readable file. Release owned resources with [dispose].
class TxFile {
  TxFile._(this._backend);

  /// Copies bytes into an independently owned in-memory file.
  factory TxFile.fromData(
    Uint8List bytes, {
    required String name,
    String? mimeType,
  }) => TxFile._(MemoryFileBackend(bytes, name, mimeType));

  /// Opens a native filesystem path. Disposal never deletes the original file.
  factory TxFile.fromPath(String path, {String? name, String? mimeType}) =>
      TxFile._(platform.fileFromPath(path, name, mimeType));
  final FileBackend _backend;
  bool _disposed = false;

  /// Display name, independent of a filesystem path.
  String get name => _backend.name;

  /// MIME type supplied by the source, if known.
  String? get mimeType => _backend.mimeType;

  /// Filesystem path when available. Browser files have no native path.
  String? get path => _backend.path;
  void _check() {
    if (_disposed) throw const TxFileException('File has been disposed.');
  }

  /// Returns the number of bytes.
  Future<int> length() async {
    _check();
    try {
      return await _backend.length();
    } catch (e) {
      throw TxFileException('Cannot read file length.', e);
    }
  }

  /// Reads the entire file. Prefer [openRead] for large files.
  Future<Uint8List> readAsBytes() async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in openRead()) {
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  /// Reads [start] inclusive to [end] exclusive, in bounded chunks.
  Stream<List<int>> openRead([int start = 0, int? end]) async* {
    _check();
    try {
      final size = await length();
      RangeError.checkValidRange(start, end, size);
      await for (final chunk in _backend.openRead(start, end)) {
        _check();
        yield chunk;
      }
    } catch (e) {
      if (e is RangeError || e is TxFileException) rethrow;
      throw TxFileException('Cannot read file.', e);
    }
  }

  /// Releases temporary resources; safe to call more than once.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await _backend.dispose();
    } catch (e) {
      throw TxFileException('Cannot release file.', e);
    }
  }
}

/// Built-in system dialogs, requiring no third-party Flutter plugins.
abstract final class TxFileDialogs {
  /// Picks files. Cancellation returns an empty list. Extensions omit dots.
  static Future<List<TxFile>> pickFiles({
    bool multiple = false,
    List<String> extensions = const [],
  }) async {
    final normalized = extensions
        .map((e) => e.replaceFirst(RegExp(r'^\.'), '').toLowerCase())
        .toList();
    if (normalized.any(
      (e) => !RegExp(r'^[a-z0-9][a-z0-9._+-]*$').hasMatch(e),
    )) {
      throw ArgumentError.value(extensions, 'extensions');
    }
    try {
      final files = (await platform.pickFiles(
        multiple,
        normalized,
      )).map(TxFile._).toList();
      final accepted = <TxFile>[];
      for (final file in files) {
        if ((multiple || accepted.isEmpty) &&
            (normalized.isEmpty ||
                normalized.any(
                  (e) => file.name.toLowerCase().endsWith('.$e'),
                ))) {
          accepted.add(file);
        } else {
          await file.dispose();
        }
      }
      return accepted;
    } catch (e) {
      throw TxFileException('Cannot select files.', e);
    }
  }

  /// Saves a file using a system dialog or browser download. False means cancel.
  static Future<bool> saveFile(TxFile file, {String? suggestedName}) async {
    file._check();
    final name = (suggestedName ?? file.name).split(RegExp(r'[/\\]')).last;
    if (name.isEmpty ||
        name == '.' ||
        name == '..' ||
        name.contains('\u0000')) {
      throw ArgumentError.value(name, 'suggestedName');
    }
    try {
      return await platform.saveFile(file._backend, name);
    } catch (e) {
      throw TxFileException('Cannot save file.', e);
    }
  }
}

// Package-internal bridge used by the drop widget.
void configureFileDrops(
  void Function(List<TxFile>, double, double, int) onDrop,
) => platform.configureDrops(
  (files, x, y, view) => onDrop(files.map(TxFile._).toList(), x, y, view),
);
Future<void> updateFileDropTargets(List<Map<String, Object>> targets) =>
    platform.updateDropTargets(targets);

Object? browserFileUploadBody(
  TxFile file,
  List<int> head,
  List<int> tail,
  int start,
  int end,
) {
  file._check();
  return platform.browserUploadBody(file._backend, head, tail, start, end);
}
