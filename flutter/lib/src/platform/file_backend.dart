import 'dart:typed_data';

/// Internal storage contract; platform files must remain readable until release.
abstract class FileBackend {
  String get name;
  String? get path;
  String? get mimeType;
  Future<int> length();
  Stream<List<int>> openRead(int start, int? end);
  Future<void> dispose();
}

class MemoryFileBackend implements FileBackend {
  MemoryFileBackend(Uint8List bytes, this.name, this.mimeType)
    : _bytes = Uint8List.fromList(bytes);
  Uint8List? _bytes;
  @override
  final String name;
  @override
  final String? mimeType;
  @override
  String? get path => null;
  @override
  Future<int> length() async => _bytes!.length;
  @override
  Stream<List<int>> openRead(int start, int? end) async* {
    final bytes = _bytes!;
    final limit = end ?? bytes.length;
    RangeError.checkValidRange(start, limit, bytes.length);
    for (var offset = start; offset < limit; offset += 65536) {
      yield bytes.sublist(offset, (offset + 65536).clamp(0, limit));
    }
  }

  @override
  Future<void> dispose() async {
    _bytes = null;
  }
}
