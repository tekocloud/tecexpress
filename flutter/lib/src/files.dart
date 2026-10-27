import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:http/http.dart' as http;

import 'source.dart';

export 'package:file_selector/file_selector.dart' show XFile;

class _DirectoryTree extends StatefulWidget {
  const _DirectoryTree({
    super.key,
    required this.provider,
    required this.disabled,
    required this.onSelected,
    this.path = const [],
  });
  final TxFileProvider provider;
  final bool disabled;
  final List<TxFileEntry> path;
  final ValueChanged<List<TxFileEntry>> onSelected;
  @override
  State<_DirectoryTree> createState() => _DirectoryTreeState();
}

class _DirectoryTreeState extends State<_DirectoryTree> {
  late final Future<List<TxFileEntry>> _folders = widget.provider.list(
    widget.path.lastOrNull?.id,
  );
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _folders,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Text('${snapshot.error}');
      if (!snapshot.hasData) return const SizedBox.shrink();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: snapshot.data!
            .where(
              (v) => v.isDirectory && !widget.path.any((p) => p.id == v.id),
            )
            .map(
              (folder) => ExpansionTile(
                key: ValueKey(folder.id),
                title: TextButton(
                  onPressed: widget.disabled
                      ? null
                      : () => widget.onSelected([...widget.path, folder]),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(folder.name),
                  ),
                ),
                children: [
                  _DirectoryTree(
                    provider: widget.provider,
                    disabled: widget.disabled,
                    onSelected: widget.onSelected,
                    path: [...widget.path, folder],
                  ),
                ],
              ),
            )
            .toList(),
      );
    },
  );
}

class TxFileEntry {
  const TxFileEntry({
    required this.id,
    required this.name,
    this.parentId,
    this.isDirectory = false,
    this.size = 0,
    this.modified,
    this.bytes,
  });
  final String id, name;
  final String? parentId;
  final bool isDirectory;
  final int size;
  final DateTime? modified;
  final Uint8List? bytes;
  TxFileEntry copyWith({
    String? id,
    String? name,
    String? parentId,
    bool root = false,
  }) => TxFileEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: root ? null : parentId ?? this.parentId,
    isDirectory: isDirectory,
    size: size,
    modified: modified,
    bytes: bytes,
  );
}

abstract class TxFileProvider {
  Set<String> get capabilities;
  Future<List<TxFileEntry>> list(
    String? parentId, {
    TxCancellation? cancellation,
  });
  Future<TxFileEntry> createDirectory(String? parentId, String name) =>
      throw UnsupportedError('createDirectory');
  Future<void> rename(String id, String name) =>
      throw UnsupportedError('rename');
  Future<void> copy(String id, String? target) =>
      throw UnsupportedError('copy');
  Future<void> move(String id, String? target) =>
      throw UnsupportedError('move');
  Future<void> remove(String id) => throw UnsupportedError('remove');
  Future<TxFileEntry> upload(
    String? parentId,
    XFile file, {
    TxCancellation? cancellation,
  }) => throw UnsupportedError('upload');
  Future<Uint8List> download(String id) => throw UnsupportedError('download');
}

class TxMemoryFileProvider extends TxFileProvider {
  TxMemoryFileProvider([List<TxFileEntry> entries = const []])
    : _entries = List.of(entries) {
    if (entries.map((v) => v.id).toSet().length != entries.length) {
      throw ArgumentError('Duplicate IDs');
    }
    for (final entry in _entries) {
      _validate(entry.parentId, entry.name, entry.id);
      final visited = <String>{entry.id};
      for (
        var parent = entry.parentId;
        parent != null;
        parent = _get(parent).parentId
      ) {
        if (!visited.add(parent)) throw ArgumentError('Cyclic directory tree');
      }
    }
  }
  final List<TxFileEntry> _entries;
  var _serial = 0;
  @override
  Set<String> get capabilities => {
    'createDirectory',
    'rename',
    'copy',
    'move',
    'remove',
    'upload',
    'download',
  };
  TxFileEntry _get(String id) => _entries.firstWhere(
    (v) => v.id == id,
    orElse: () => throw StateError('Datei nicht gefunden'),
  );
  String _id() {
    String id;
    do {
      id = 'tx-file-${++_serial}';
    } while (_entries.any((v) => v.id == id));
    return id;
  }

  void _validate(String? parentId, String name, [String? exclude]) {
    if (name.trim().isEmpty ||
        name.contains(RegExp(r'[/\\]')) ||
        name == '.' ||
        name == '..') {
      throw ArgumentError('Ungültiger Dateiname');
    }
    if (parentId != null && !_get(parentId).isDirectory) {
      throw ArgumentError('Kein Ordner');
    }
    if (_entries.any(
      (v) => v.parentId == parentId && v.name == name && v.id != exclude,
    )) {
      throw StateError('Name bereits vorhanden');
    }
  }

  void _target(String id, String? target) {
    for (
      var current = target;
      current != null;
      current = _get(current).parentId
    ) {
      if (current == id) {
        throw ArgumentError(
          'Ordner kann nicht in sich selbst verschoben/kopiert werden',
        );
      }
    }
  }

  @override
  Future<List<TxFileEntry>> list(
    String? parentId, {
    TxCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    return _entries.where((v) => v.parentId == parentId).toList();
  }

  @override
  Future<TxFileEntry> createDirectory(String? parentId, String name) async {
    _validate(parentId, name);
    final entry = TxFileEntry(
      id: _id(),
      name: name,
      parentId: parentId,
      isDirectory: true,
      modified: DateTime.now(),
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<void> rename(String id, String name) async {
    final item = _get(id);
    _validate(item.parentId, name, id);
    _entries[_entries.indexOf(item)] = item.copyWith(name: name);
  }

  @override
  Future<void> move(String id, String? target) async {
    final item = _get(id);
    _target(id, target);
    _validate(target, item.name, id);
    _entries[_entries.indexOf(item)] = item.copyWith(
      parentId: target,
      root: target == null,
    );
  }

  @override
  Future<void> copy(String id, String? target) async {
    final item = _get(id);
    _target(id, target);
    _validate(target, item.name);
    void clone(TxFileEntry item, String? parent) {
      final next = item.copyWith(
        id: _id(),
        parentId: parent,
        root: parent == null,
      );
      final children = _entries.where((v) => v.parentId == item.id).toList();
      _entries.add(next);
      for (final child in children) {
        clone(child, next.id);
      }
    }

    clone(item, target);
  }

  @override
  Future<void> remove(String id) async {
    _get(id);
    final ids = {id};
    var changed = true;
    while (changed) {
      changed = false;
      for (final item in _entries) {
        if (ids.contains(item.parentId) && ids.add(item.id)) changed = true;
      }
    }
    _entries.removeWhere((v) => ids.contains(v.id));
  }

  @override
  Future<TxFileEntry> upload(
    String? parentId,
    XFile file, {
    TxCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    final bytes = await file.readAsBytes();
    cancellation?.throwIfCancelled();
    _validate(parentId, file.name);
    final entry = TxFileEntry(
      id: _id(),
      name: file.name,
      parentId: parentId,
      size: bytes.length,
      bytes: bytes,
      modified: DateTime.now(),
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<Uint8List> download(String id) async {
    final item = _get(id);
    if (item.isDirectory) throw ArgumentError('Kein Download für Ordner');
    return item.bytes ?? Uint8List(0);
  }
}

TxStore<TxFileEntry> txFileStore(
  TxFileProvider provider,
  String? Function() parent,
) => TxCustomStore(
  load: (options) async => txQuery(
    await provider.list(parent(), cancellation: options.cancellation),
    options,
  ),
  remove: provider.capabilities.contains('remove')
      ? (key) => provider.remove('$key')
      : null,
);

class TxUploadContext {
  const TxUploadContext({required this.cancellation, required this.onProgress});
  final TxCancellation cancellation;
  final void Function(int loaded, int total) onProgress;
}

typedef TxUploadAdapter = Future<Object?> Function(
  XFile file,
  TxUploadContext context,
);

class TxHttpUploadConfig {
  const TxHttpUploadConfig({
    required this.url,
    this.fieldName = 'file',
    this.headers = const {},
    this.fields = const {},
    this.chunkSize,
    this.chunkFields,
  });
  final Uri url;
  final String fieldName;
  final Map<String, String> headers, fields;
  final int? chunkSize;
  final Map<String, String> Function(XFile, int, int)? chunkFields;
}

TxUploadAdapter txHttpUpload(TxHttpUploadConfig config) =>
    (file, context) async {
      final bytes = await file.readAsBytes(),
          size = config.chunkSize ?? (bytes.isEmpty ? 1 : bytes.length);
      if (size <= 0) throw ArgumentError('chunkSize must be positive');
      final count = (bytes.length / size).ceil().clamp(1, 1 << 30);
      Object? result;
      final client = http.Client(),
          unregister = context.cancellation.onCancel(client.close);
      try {
        for (var index = 0; index < count; index++) {
          context.cancellation.throwIfCancelled();
          final start = index * size,
              end = (start + size).clamp(0, bytes.length),
              chunk = bytes.sublist(start, end),
              request = http.MultipartRequest('POST', config.url)
                ..headers.addAll(config.headers)
                ..fields.addAll({
                  ...config.fields,
                  ...?config.chunkFields?.call(file, index, count),
                })
                ..files.add(
                  http.MultipartFile.fromBytes(
                    config.fieldName,
                    chunk,
                    filename: file.name,
                  ),
                );
          final response = await client.send(request);
          result = await response.stream.bytesToString();
          if (response.statusCode < 200 || response.statusCode >= 300) {
            throw StateError('HTTP ${response.statusCode}');
          }
          context.onProgress(end, bytes.length);
        }
        return result;
      } finally {
        unregister();
        client.close();
      }
    };

class TxFileUploader extends StatefulWidget {
  const TxFileUploader({
    super.key,
    this.adapter,
    this.dataSource,
    this.multiple = false,
    this.maxFileSize,
    this.minFileSize = 0,
    this.extensions = const [],
    this.instantly = false,
    this.disabled = false,
    this.onUploaded,
    this.onError,
    this.onChanged,
  });
  final TxUploadAdapter? adapter;
  final Object? dataSource;
  final bool multiple, instantly, disabled;
  final int? maxFileSize;
  final int minFileSize;
  final List<String> extensions;
  final void Function(XFile, Object?)? onUploaded;
  final void Function(XFile, Object)? onError;
  final ValueChanged<List<XFile>>? onChanged;
  @override
  State<TxFileUploader> createState() => _TxFileUploaderState();
}

class _Upload {
  _Upload(this.file);
  final XFile file;
  TxCancellation? cancellation;
  String status = 'ready';
  Object? error;
  double progress = 0;
  bool valid = true;
}

class _TxFileUploaderState extends State<TxFileUploader>
    with TxSourceState<TxFileUploader, XFile> {
  @override
  Object? get sourceInput => widget.dataSource;
  final _known = <XFile>{};
  @override
  void initState() {
    super.initState();
    unawaited(Future.microtask(_syncSource));
  }

  @override
  void didUpdateWidget(covariant TxFileUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(Future.microtask(_syncSource));
  }

  @override
  void sourceChanged() {
    unawaited(_syncSource());
  }

  Future<void> _syncSource() async {
    if (!mounted || widget.dataSource == null) return;
    final next = sourceItems;
    for (final item
        in _queue
            .where(
              (item) => _known.contains(item.file) && !next.contains(item.file),
            )
            .toList()) {
      item.cancellation?.cancel();
      _queue.remove(item);
      _known.remove(item.file);
    }
    final incoming = next.where((file) => !_known.contains(file)).toList();
    _known.addAll(incoming);
    if (incoming.isNotEmpty) await _add(incoming);
  }

  final _queue = <_Upload>[];
  Future<void> _add(List<XFile> files) async {
    if (widget.disabled) return;
    if (!widget.multiple) {
      for (final item in _queue) {
        item.cancellation?.cancel();
      }
      _queue.clear();
    }
    for (final file in widget.multiple ? files : files.take(1)) {
      final item = _Upload(file), size = await file.length();
      if (size < widget.minFileSize ||
          widget.maxFileSize != null && size > widget.maxFileSize!) {
        item.error = 'Dateigröße nicht erlaubt';
        item.valid = false;
      }
      if (widget.extensions.isNotEmpty &&
          !widget.extensions.any(
            (v) => file.name.toLowerCase().endsWith('.${v.toLowerCase()}'),
          )) {
        item.error = 'Dateityp nicht erlaubt';
        item.valid = false;
      }
      if (!item.valid) item.status = 'error';
      if (!mounted) return;
      setState(() => _queue.add(item));
      if (widget.instantly && item.valid) unawaited(_upload(item));
    }
    widget.onChanged?.call(_queue.map((v) => v.file).toList());
  }

  Future<void> _upload(_Upload item) async {
    if (widget.disabled ||
        !item.valid ||
        widget.adapter == null ||
        item.status == 'uploading' ||
        item.status == 'done') {
      return;
    }
    final cancellation = item.cancellation = TxCancellation();
    setState(() {
      item.status = 'uploading';
      item.error = null;
    });
    try {
      final result = await widget.adapter!(
        item.file,
        TxUploadContext(
          cancellation: cancellation,
          onProgress: (loaded, total) {
            if (mounted && !cancellation.isCancelled) {
              setState(() => item.progress = total == 0 ? 0 : loaded / total);
            }
          },
        ),
      );
      cancellation.throwIfCancelled();
      if (mounted) {
        setState(() {
          item.status = 'done';
          item.progress = 1;
        });
      }
      widget.onUploaded?.call(item.file, result);
    } catch (e) {
      if (mounted) {
        setState(() {
          item.status = cancellation.isCancelled ? 'cancelled' : 'error';
          item.error = e;
        });
      }
      if (!cancellation.isCancelled) widget.onError?.call(item.file, e);
    }
  }

  @override
  void dispose() {
    for (final item in _queue) {
      item.cancellation?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DropTarget(
    onDragDone: (details) => _add(details.files),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: widget.disabled
                  ? null
                  : () async {
                      final groups = widget.extensions.isEmpty
                          ? <XTypeGroup>[]
                          : [
                              XTypeGroup(
                                label: 'Dateien',
                                extensions: widget.extensions,
                              ),
                            ];
                      final files = widget.multiple
                          ? await openFiles(acceptedTypeGroups: groups)
                          : [?await openFile(acceptedTypeGroups: groups)];
                      if (mounted) await _add(files);
                    },
              icon: const Icon(Icons.upload_file),
              label: const Text('Dateien auswählen oder hier ablegen'),
            ),
            ..._queue.map(
              (item) => ListTile(
                title: Text(item.file.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.status),
                    LinearProgressIndicator(value: item.progress),
                    if (item.error != null) Text('${item.error}'),
                  ],
                ),
                trailing: item.status == 'uploading'
                    ? IconButton(
                        tooltip: 'Abbrechen',
                        onPressed: () => item.cancellation?.cancel(),
                        icon: const Icon(Icons.cancel),
                      )
                    : IconButton(
                        tooltip: 'Hochladen / Wiederholen',
                        onPressed:
                            widget.disabled ||
                                !item.valid ||
                                widget.adapter == null ||
                                item.status == 'done'
                            ? null
                            : () => _upload(item),
                        icon: const Icon(Icons.upload),
                      ),
              ),
            ),
            if (!widget.instantly)
              TextButton(
                onPressed: widget.disabled || widget.adapter == null
                    ? null
                    : () {
                        for (final item in _queue.where(
                          (v) => v.status == 'ready',
                        )) {
                          unawaited(_upload(item));
                        }
                      },
                child: const Text('Alle hochladen'),
              ),
          ],
        ),
      ),
    ),
  );
}

class TxFileManager extends StatefulWidget {
  const TxFileManager({
    super.key,
    required this.provider,
    this.dataSource,
    this.disabled = false,
    this.height = 360,
    this.onSelectionChanged,
    this.onFileOpened,
    this.onDownload,
  });
  final TxFileProvider provider;
  final Object? dataSource;
  final bool disabled;
  final double height;
  final ValueChanged<List<TxFileEntry>>? onSelectionChanged;
  final ValueChanged<TxFileEntry>? onFileOpened;
  final void Function(TxFileEntry, Uint8List)? onDownload;
  @override
  State<TxFileManager> createState() => _TxFileManagerState();
}

class _TxFileManagerState extends State<TxFileManager> {
  String? _parent;
  final _crumbs = <TxFileEntry>[];
  final _selected = <String>{};
  final _name = TextEditingController(), _target = TextEditingController();
  late TxDataSource<TxFileEntry> _source = _create();
  bool _tiles = false;
  Object? _error;
  TxDataSource<TxFileEntry> _create() => TxDataSource(
    TxDataSourceConfig(
      store: txFileStore(widget.provider, () => _parent),
      keyOf: (v) => v.id,
      paginate: false,
      sort: [TxSort((v) => v.name)],
    ),
  );
  @override
  void didUpdateWidget(covariant TxFileManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _source.dispose();
      _source = _create();
      _parent = null;
      _crumbs.clear();
      _selected.clear();
    }
  }

  Future<void> _action(Future<void> Function() fn) async {
    try {
      await fn();
      if (!mounted) return;
      _selected.clear();
      widget.onSelectionChanged?.call([]);
      await _source.reload();
      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _navigate(TxFileEntry? folder) {
    if (widget.disabled) return;
    setState(() {
      _parent = folder?.id;
      _selected.clear();
      if (folder == null) {
        _crumbs.clear();
      } else {
        final i = _crumbs.indexWhere((v) => v.id == folder.id);
        if (i >= 0) {
          _crumbs.removeRange(i + 1, _crumbs.length);
        } else {
          _crumbs.add(folder);
        }
      }
    });
    unawaited(_source.reload().catchError((_) => <TxFileEntry>[]));
  }

  @override
  void dispose() {
    _source.dispose();
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TxDataSourceBuilder<TxFileEntry>(
    dataSource: widget.dataSource ?? _source,
    builder: (context, rows, source) {
      final selected = rows.where((v) => _selected.contains(v.id)).toList(),
          caps = widget.provider.capabilities;
      Widget entry(TxFileEntry item) => ListTile(
        leading: Checkbox(
          value: _selected.contains(item.id),
          onChanged: widget.disabled
              ? null
              : (checked) {
                  setState(() {
                    if (checked == true) {
                      _selected.add(item.id);
                    } else {
                      _selected.remove(item.id);
                    }
                  });
                  widget.onSelectionChanged?.call(
                    rows.where((v) => _selected.contains(v.id)).toList(),
                  );
                },
        ),
        title: Text('${item.isDirectory ? '📁' : '📄'} ${item.name}'),
        subtitle: item.isDirectory ? null : Text('${item.size} Bytes'),
        onTap: widget.disabled
            ? null
            : () => item.isDirectory
                  ? _navigate(item)
                  : widget.onFileOpened?.call(item),
        trailing: !item.isDirectory && caps.contains('download')
            ? IconButton(
                tooltip: 'Download',
                onPressed: widget.disabled
                    ? null
                    : () => _action(() async {
                        final bytes = await widget.provider.download(item.id);
                        if (widget.onDownload != null) {
                          widget.onDownload!(item, bytes);
                        } else {
                          final target = await getSaveLocation(
                            suggestedName: item.name,
                          );
                          if (target != null) {
                            await XFile.fromData(
                              bytes,
                              name: item.name,
                            ).saveTo(target.path);
                          }
                        }
                      }),
                icon: const Icon(Icons.download),
              )
            : null,
      );
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DirectoryTree(
                key: ValueKey((_source, _source.revision)),
                provider: widget.provider,
                disabled: widget.disabled,
                onSelected: (path) {
                  _crumbs.clear();
                  _crumbs.addAll(path.take(path.length - 1));
                  _navigate(path.last);
                },
              ),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () => _navigate(null),
                    child: const Text('Dateien'),
                  ),
                  ..._crumbs.map(
                    (v) => TextButton(
                      onPressed: () => _navigate(v),
                      child: Text(v.name),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              Wrap(
                children: [
                  if (caps.contains('createDirectory'))
                    TextButton(
                      onPressed: widget.disabled
                          ? null
                          : () => _action(() async {
                              await widget.provider.createDirectory(
                                _parent,
                                _name.text,
                              );
                            }),
                      child: const Text('Neuer Ordner'),
                    ),
                  if (caps.contains('rename'))
                    TextButton(
                      onPressed: widget.disabled || selected.length != 1
                          ? null
                          : () => _action(
                              () => widget.provider.rename(
                                selected.first.id,
                                _name.text,
                              ),
                            ),
                      child: const Text('Umbenennen'),
                    ),
                  if (caps.contains('remove'))
                    TextButton(
                      onPressed: widget.disabled || selected.isEmpty
                          ? null
                          : () => _action(() async {
                              for (final item in selected) {
                                await widget.provider.remove(item.id);
                              }
                            }),
                      child: const Text('Löschen'),
                    ),
                  TextButton(
                    onPressed: () => setState(() => _tiles = !_tiles),
                    child: Text(_tiles ? 'Details' : 'Kacheln'),
                  ),
                ],
              ),
              TextField(
                controller: _target,
                decoration: const InputDecoration(
                  labelText: 'Zielordner-ID (leer für Stammordner)',
                ),
              ),
              Wrap(
                children: [
                  for (final op in ['copy', 'move'])
                    if (caps.contains(op))
                      TextButton(
                        onPressed: widget.disabled || selected.isEmpty
                            ? null
                            : () => _action(() async {
                                for (final item in selected) {
                                  final target = _target.text.isEmpty
                                      ? null
                                      : _target.text;
                                  if (op == 'copy') {
                                    await widget.provider.copy(item.id, target);
                                  } else {
                                    await widget.provider.move(item.id, target);
                                  }
                                }
                              }),
                        child: Text(op == 'copy' ? 'Kopieren' : 'Verschieben'),
                      ),
                ],
              ),
              if (_error != null || _source.error != null)
                Text('${_error ?? _source.error}'),
              if (_source.loading) const LinearProgressIndicator(),
              SizedBox(
                height: widget.height,
                child: _tiles
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 280,
                              mainAxisExtent: 100,
                            ),
                        itemCount: rows.length,
                        itemBuilder: (context, i) => entry(rows[i]),
                      )
                    : ListView(children: rows.map(entry).toList()),
              ),
              if (rows.isEmpty && !_source.loading)
                const Text('Ordner ist leer'),
              if (caps.contains('upload'))
                TxFileUploader(
                  multiple: true,
                  disabled: widget.disabled,
                  adapter: (file, context) async {
                    final result = await widget.provider.upload(
                      _parent,
                      file,
                      cancellation: context.cancellation,
                    );
                    await _source.reload();
                    return result;
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
