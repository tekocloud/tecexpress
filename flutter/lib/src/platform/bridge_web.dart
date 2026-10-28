import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'file_backend.dart';

@JS('document')
external _Document get _document;
@JS('window')
external _Window get _window;
@JS('URL.createObjectURL')
external String _createObjectURL(JSObject blob);
@JS('URL.revokeObjectURL')
external void _revokeObjectURL(String url);

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny?> parts);
  external num get size;
  external JSPromise<JSArrayBuffer> arrayBuffer();
  external _Blob slice(int start, int end);
}

extension type _File(JSObject _) implements _Blob {
  external String get name;
  external String get type;
}

extension type _FileList(JSObject _) implements JSObject {
  external int get length;
  external _File? item(int index);
}

extension type _Document(JSObject _) implements JSObject {
  external _Element createElement(String tag);
  external _Element? get body;
}

extension type _Element(JSObject _) implements JSObject {
  external _Rect getBoundingClientRect();
  external set type(String value);
  external set accept(String value);
  external set multiple(bool value);
  external set href(String value);
  external set download(String value);
  external set hidden(bool value);
  external _FileList? get files;
  external void click();
  external void appendChild(_Element child);
  external void remove();
  external void addEventListener(String type, JSFunction callback);
  external void removeEventListener(String type, JSFunction callback);
}

extension type _Rect(JSObject _) implements JSObject {
  external double get left;
  external double get top;
  external double get width;
  external double get height;
}

extension type _Window(JSObject _) implements JSObject {
  external void addEventListener(String type, JSFunction callback);
}

extension type _Event(JSObject _) implements JSObject {
  external void preventDefault();
  external double get clientX;
  external double get clientY;
  external _Transfer? get dataTransfer;
}

extension type _Transfer(JSObject _) implements JSObject {
  external _FileList get files;
  external _Items get items;
}

extension type _Items(JSObject _) implements JSObject {
  external int get length;
  external _Item operator [](int index);
}

extension type _Item(JSObject _) implements JSObject {
  external String get kind;
  external _Entry? webkitGetAsEntry();
}

extension type _Entry(JSObject _) implements JSObject {
  external bool get isDirectory;
}

class _WebFile implements FileBackend {
  _WebFile(_File file)
    : _file = file,
      name = file.name,
      mimeType = file.type.isEmpty ? null : file.type;
  _File? _file;
  @override
  final String name;
  @override
  final String? mimeType;
  @override
  String? get path => null;
  @override
  Future<int> length() async => _file!.size.toInt();
  @override
  Stream<List<int>> openRead(int start, int? end) async* {
    final file = _file!;
    final limit = end ?? file.size.toInt();
    for (var offset = start; offset < limit; offset += 65536) {
      final buffer = await file
          .slice(offset, (offset + 65536).clamp(0, limit))
          .arrayBuffer()
          .toDart;
      yield buffer.toDart.asUint8List();
    }
  }

  @override
  Future<void> dispose() async {
    _file = null;
  }
}

FileBackend fileFromPath(String path, String? name, String? mimeType) =>
    throw UnsupportedError('Browser files have no native filesystem paths.');

// Reuse browser-backed slices instead of copying a large file into Dart memory.
Object? browserUploadBody(
  FileBackend file,
  List<int> head,
  List<int> tail,
  int start,
  int end,
) {
  if (file is! _WebFile) return null;
  return _Blob(
    <JSAny?>[
      Uint8List.fromList(head).toJS,
      file._file!.slice(start, end),
      Uint8List.fromList(tail).toJS,
    ].toJS,
  );
}

Future<List<FileBackend>> pickFiles(
  bool multiple,
  List<String> extensions,
) async {
  final result = Completer<List<FileBackend>>();
  final input = _document.createElement('input')
    ..type = 'file'
    ..multiple = multiple
    ..hidden = true
    ..accept = extensions.map((e) => '.$e').join(',');
  void complete(List<FileBackend> files) {
    if (!result.isCompleted) result.complete(files);
  }

  final change = ((JSAny? _) {
    final files = input.files;
    complete([
      if (files != null)
        for (var i = 0; i < files.length; i++) _WebFile(files.item(i)!),
    ]);
  }).toJS;
  final cancel = ((JSAny? _) {
    complete([]);
  }).toJS;
  input.addEventListener('change', change);
  input.addEventListener('cancel', cancel);
  _document.body!.appendChild(input);
  try {
    input.click();
    return await result.future;
  } finally {
    input.removeEventListener('change', change);
    input.removeEventListener('cancel', cancel);
    input.remove();
  }
}

Future<bool> saveFile(FileBackend file, String name) async {
  final parts = <JSAny?>[];
  if (file is _WebFile) {
    parts.add(file._file!);
  } else {
    await for (final bytes in file.openRead(0, null)) {
      parts.add(Uint8List.fromList(bytes).toJS);
    }
  }
  final url = _createObjectURL(_Blob(parts.toJS));
  final link = _document.createElement('a')
    ..href = url
    ..download = name
    ..hidden = true;
  _document.body!.appendChild(link);
  link.click();
  link.remove();
  // The browser must have time to consume the download URL.
  Timer(const Duration(minutes: 1), () => _revokeObjectURL(url));
  return true;
}

List<Map<String, Object>> _targets = [];
bool _configured = false;
void Function(List<FileBackend>, double, double, int)? _onDrop;
Map<String, Object>? _target(double x, double y) {
  for (final t in _targets.reversed) {
    final origin = _viewOrigin(t['viewId'] as int);
    if (x - origin.$1 >= (t['left'] as num) &&
        y - origin.$2 >= (t['top'] as num) &&
        x - origin.$1 < (t['right'] as num) &&
        y - origin.$2 < (t['bottom'] as num)) {
      return t;
    }
  }
  return null;
}

(double, double) _viewOrigin(int id) {
  final host = ui_web.views.getHostElement(id);
  if (host == null) return (0, 0);
  final rect = _Element(host as JSObject).getBoundingClientRect();
  return (rect.left, rect.top);
}

void configureDrops(
  void Function(List<FileBackend>, double, double, int) callback,
) {
  _onDrop = callback;
  if (_configured) return;
  _configured = true;
  _window.addEventListener(
    'dragover',
    ((_Event e) {
      if (_target(e.clientX, e.clientY) != null) {
        e.preventDefault();
      }
    }).toJS,
  );
  _window.addEventListener(
    'drop',
    ((_Event e) {
      final t = _target(e.clientX, e.clientY), transfer = e.dataTransfer;
      if (t == null || transfer == null) return;
      e.preventDefault();
      // Reject directories instead of treating a directory entry as a zero-byte file.
      for (var i = 0; i < transfer.items.length; i++) {
        if (transfer.items[i].kind == 'file' &&
            transfer.items[i].webkitGetAsEntry()?.isDirectory == true) {
          return;
        }
      }
      final origin = _viewOrigin(t['viewId'] as int);
      _onDrop?.call(
        [
          for (var i = 0; i < transfer.files.length; i++)
            _WebFile(transfer.files.item(i)!),
        ],
        e.clientX - origin.$1,
        e.clientY - origin.$2,
        t['viewId'] as int,
      );
    }).toJS,
  );
}

Future<void> updateDropTargets(List<Map<String, Object>> targets) async {
  _targets = targets;
}
