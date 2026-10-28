import 'file_backend.dart';

Object? browserUploadBody(
  FileBackend file,
  List<int> head,
  List<int> tail,
  int start,
  int end,
) => null;

FileBackend fileFromPath(String path, String? name, String? mimeType) =>
    throw UnsupportedError(
      'Filesystem paths are unavailable on this platform.',
    );
Future<List<FileBackend>> pickFiles(
  bool multiple,
  List<String> extensions,
) async =>
    throw UnsupportedError('File dialogs are unavailable on this platform.');
Future<bool> saveFile(FileBackend file, String name) async =>
    throw UnsupportedError('Saving files is unavailable on this platform.');
void configureDrops(
  void Function(List<FileBackend>, double, double, int) callback,
) {}
Future<void> updateDropTargets(List<Map<String, Object>> targets) async {}
