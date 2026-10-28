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

/// Datei-/Ordnermetadaten mit stabiler ID; parentId null bezeichnet das Wurzelverzeichnis.
///
/// Dart copyWith behält nicht angegebene Felder bei; root: true setzt parentId ausdrücklich auf null. parentId: null allein behält den bisherigen Elternordner.
///
/// File/directory metadata with a stable ID; a null parentId denotes the root directory.
///
/// Dart copyWith preserves omitted fields; root: true explicitly sets parentId to null. Passing parentId: null alone preserves the existing parent.
///
/// ```dart
/// const entry = TxFileEntry(id: '1', name: 'hello.txt');
/// print(entry.copyWith(name: 'renamed.txt').name);
/// ```
class TxFileEntry {
  /// Datei-/Ordnermetadaten mit stabiler ID; parentId null bezeichnet das Wurzelverzeichnis.
  ///
  /// File/directory metadata with a stable ID; a null parentId denotes the root directory.
  const TxFileEntry({
    required this.id,
    required this.name,
    this.parentId,
    this.isDirectory = false,
    this.size = 0,
    this.modified,
    this.bytes,
  });
  /// id: Eindeutige stabile ID.
  /// name: Name des Eingabefelds beziehungsweise Dateiname.
  ///
  /// id: Unique stable ID.
  /// name: Input field name or file name.
  final String id, name;
  /// Elternordner-ID; null bezeichnet die Wurzel.
  ///
  /// Parent directory ID; null denotes the root.
  final String? parentId;
  /// Kennzeichnet einen Ordner.
  ///
  /// Identifies a directory.
  final bool isDirectory;
  /// Dateigröße in Bytes.
  ///
  /// File size in bytes.
  final int size;
  /// Letzter Änderungszeitpunkt.
  ///
  /// Last modification time.
  final DateTime? modified;
  /// Dateiinhalt im Speicher.
  ///
  /// File contents in memory.
  final Uint8List? bytes;
  /// Erzeugt eine Kopie mit den angegebenen Änderungen; alle übrigen Werte bleiben erhalten.
  ///
  /// Creates a copy with the supplied changes; preserves other values.
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

/// Asynchroner Vertrag für Verzeichnislisten und Dateioperationen.
///
/// list ist erforderlich. Vue bietet optionale Methoden; Dart-Implementierungen deklarieren Fähigkeiten in capabilities und überschreiben die entsprechenden Methoden. Nicht implementierte Dart-Operationen werfen UnsupportedError. list/upload berücksichtigen kooperativen Abbruch. createDirectory/upload liefern einen Eintrag; rename/copy/move/remove keinen Wert; download liefert Blob (Vue) oder Uint8List (Dart).
///
/// Asynchronous contract for directory listings and file operations.
///
/// list is required. Vue offers optional methods; Dart implementations declare capabilities and override matching methods. Unimplemented Dart operations throw UnsupportedError. list/upload support cooperative cancellation. createDirectory/upload return an entry; rename/copy/move/remove return no value; download returns Blob (Vue) or Uint8List (Dart).
///
/// ```dart
/// TxFileProvider provider = TxMemoryFileProvider();
/// print(provider.capabilities);
/// print(await provider.list(null));
/// ```
abstract class TxFileProvider {
  /// Unterstützte Dateiaufgaben; steuert sichtbare Aktionen.
  ///
  /// Supported file operations; controls visible actions.
  Set<String> get capabilities;
  /// Liefert Einträge des angegebenen Elternordners; null liest die Wurzel.
  ///
  /// Returns entries in the parent directory; null reads the root.
  Future<List<TxFileEntry>> list(
    String? parentId, {
    TxCancellation? cancellation,
  });
  /// Legt einen Ordner mit gültigem, im Elternordner eindeutigem Namen an.
  ///
  /// Creates a directory with a valid name unique within its parent.
  Future<TxFileEntry> createDirectory(String? parentId, String name) =>
      throw UnsupportedError('createDirectory');
  /// Benennt eine Datei oder einen Ordner um; ID und Elternordner bleiben erhalten.
  ///
  /// Renames a file or directory; preserves its ID and parent.
  Future<void> rename(String id, String name) =>
      throw UnsupportedError('rename');
  /// Kopiert einen Eintrag rekursiv in den Zielordner; neue IDs werden vergeben.
  ///
  /// Recursively copies an entry to the target directory, assigning new IDs.
  Future<void> copy(String id, String? target) =>
      throw UnsupportedError('copy');
  /// Verschiebt einen Eintrag in den Zielordner; Zyklen werden abgelehnt.
  ///
  /// Moves an entry to the target directory; cycles are rejected.
  Future<void> move(String id, String? target) =>
      throw UnsupportedError('move');
  /// Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand.
  ///
  /// Removes the record or recursively removes a file/directory tree.
  Future<void> remove(String id) => throw UnsupportedError('remove');
  /// Lädt eine Datei in den angegebenen Ordner; liefert den neuen Dateieintrag.
  ///
  /// Uploads a file to the specified directory and returns its new entry.
  Future<TxFileEntry> upload(
    String? parentId,
    XFile file, {
    TxCancellation? cancellation,
  }) => throw UnsupportedError('upload');
  /// Liefert Dateiinhalt; Ordnerdownloads schlagen fehl.
  ///
  /// Returns file contents; downloading a directory fails.
  Future<Uint8List> download(String id) => throw UnsupportedError('download');
}

/// Flüchtiger Datei-Provider mit rekursivem Kopieren/Löschen, Namensprüfung und Zyklusschutz; Daten überleben keinen Neustart.
///
/// Alle Dateioperationen sind asynchron. Ordner-IDs und Datei-IDs sind Strings, null als Eltern-/Ziel-ID bezeichnet die Wurzel. Ungültige Namen, Namenskollisionen, unbekannte IDs, doppelte IDs und Zyklen schlagen fehl. Kopieren erhält Inhalte, vergibt neue IDs und kopiert Unterordner. Entfernen löscht rekursiv. Ohne gespeicherten Inhalt ist der Download leer; Ordnerdownloads sind nicht möglich.
///
/// Volatile file provider with recursive copy/delete, name validation and cycle protection; data does not survive a restart.
///
/// All file operations are asynchronous. Directory and file IDs are strings; null as parent/target denotes the root. Invalid names, name collisions, unknown IDs, duplicate IDs and cycles fail. Copy preserves contents, assigns new IDs and includes descendants. Remove deletes recursively. Without stored contents, download is empty; directory downloads are unavailable.
///
/// ```dart
/// final provider = TxMemoryFileProvider();
/// final folder = await provider.createDirectory(null, 'Documents');
/// final file = await provider.upload(folder.id, XFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt'));
/// await provider.rename(file.id, 'renamed.txt');
/// await provider.copy(file.id, null);
/// await provider.rename(file.id, 'moved.txt');
/// await provider.move(file.id, null);
/// print(await provider.list(null));
/// print(await provider.download(file.id));
/// await provider.remove(folder.id);
/// ```
class TxMemoryFileProvider extends TxFileProvider {
  /// Flüchtiger Datei-Provider mit rekursivem Kopieren/Löschen, Namensprüfung und Zyklusschutz; Daten überleben keinen Neustart.
  ///
  /// Volatile file provider with recursive copy/delete, name validation and cycle protection; data does not survive a restart.
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
  /// Unterstützte Dateiaufgaben; steuert sichtbare Aktionen.
  ///
  /// Supported file operations; controls visible actions.
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

  /// Liefert Einträge des angegebenen Elternordners; null liest die Wurzel.
  ///
  /// Returns entries in the parent directory; null reads the root.
  @override
  Future<List<TxFileEntry>> list(
    String? parentId, {
    TxCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    return _entries.where((v) => v.parentId == parentId).toList();
  }

  /// Legt einen Ordner mit gültigem, im Elternordner eindeutigem Namen an.
  ///
  /// Creates a directory with a valid name unique within its parent.
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

  /// Benennt eine Datei oder einen Ordner um; ID und Elternordner bleiben erhalten.
  ///
  /// Renames a file or directory; preserves its ID and parent.
  @override
  Future<void> rename(String id, String name) async {
    final item = _get(id);
    _validate(item.parentId, name, id);
    _entries[_entries.indexOf(item)] = item.copyWith(name: name);
  }

  /// Verschiebt einen Eintrag in den Zielordner; Zyklen werden abgelehnt.
  ///
  /// Moves an entry to the target directory; cycles are rejected.
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

  /// Kopiert einen Eintrag rekursiv in den Zielordner; neue IDs werden vergeben.
  ///
  /// Recursively copies an entry to the target directory, assigning new IDs.
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

  /// Löscht den Datensatz beziehungsweise rekursiv den Datei-/Ordnerbestand.
  ///
  /// Removes the record or recursively removes a file/directory tree.
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

  /// Lädt eine Datei in den angegebenen Ordner; liefert den neuen Dateieintrag.
  ///
  /// Uploads a file to the specified directory and returns its new entry.
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

  /// Liefert Dateiinhalt; Ordnerdownloads schlagen fehl.
  ///
  /// Returns file contents; downloading a directory fails.
  @override
  Future<Uint8List> download(String id) async {
    final item = _get(id);
    if (item.isDirectory) throw ArgumentError('Kein Download für Ordner');
    return item.bytes ?? Uint8List(0);
  }
}

/// Verbindet einen Provider und einen Getter des aktuellen Ordners mit einem abfragbaren Store.
///
/// Parameter: provider und parent als Getter der aktuellen Ordner-ID (null = Wurzel). Rückgabe: TxStore&lt;TxFileEntry&gt;. load liefert Promise/Future&lt;TxLoadResult&lt;TxFileEntry&gt;&gt;. Providerfehler werden weitergegeben. Nach einem Ordnerwechsel erneut laden.
///
/// Connects a provider and a current-directory getter to a queryable store.
///
/// Parameters: provider and parent, a getter for the current directory ID (null = root). Returns TxStore&lt;TxFileEntry&gt;. load returns Promise/Future&lt;TxLoadResult&lt;TxFileEntry&gt;&gt;. Provider failures propagate. Reload after changing directories.
///
/// ```dart
/// final store = txFileStore(TxMemoryFileProvider(), () => null);
/// print(await store.load(const TxLoadOptions()));
/// ```
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

/// Abbruch und Fortschrittsmeldung einer einzelnen Uploadoperation; Fortschritt wird in Bytes gemeldet.
///
/// Cancellation and progress reporting for one upload operation; progress is reported in bytes.
///
/// ```dart
/// final context = TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) => print(loaded));
/// context.onProgress(10, 20);
/// ```
class TxUploadContext {
  /// Abbruch und Fortschrittsmeldung einer einzelnen Uploadoperation; Fortschritt wird in Bytes gemeldet.
  ///
  /// Cancellation and progress reporting for one upload operation; progress is reported in bytes.
  const TxUploadContext({required this.cancellation, required this.onProgress});
  /// Token für kooperativen Abbruch.
  ///
  /// Cooperative cancellation token.
  final TxCancellation cancellation;
  /// Meldet abgeschlossene Bytes und Gesamtgröße.
  ///
  /// Reports completed bytes and total size.
  final void Function(int loaded, int total) onProgress;
}

/// Asynchroner Callback für den Upload einer Datei; Ergebnis geht an den Erfolgs-Callback, Fehler an die Fehlerbehandlung.
///
/// Asynchronous callback uploading one file; its result reaches the success callback and errors reach error handling.
///
/// ```dart
/// TxUploadAdapter adapter = (file, context) async {
///   context.cancellation.throwIfCancelled();
///   final size = await file.length();
///   context.onProgress(size, size);
///   return file.name;
/// };
/// print(await adapter(XFile.fromData(Uint8List(0), name: 'empty.txt'), TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) {})));
/// ```
typedef TxUploadAdapter = Future<Object?> Function(
  XFile file,
  TxUploadContext context,
);

/// Multipart-HTTP-Konfiguration mit Zieladresse, Feldern, Headern und optionalen Chunks.
///
/// Multipart HTTP configuration with a destination, fields, headers and optional chunks.
///
/// ```dart
/// final config = TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload'), fieldName: 'file', chunkSize: 1024 * 1024);
/// final adapter = txHttpUpload(config);
/// print(adapter);
/// ```
class TxHttpUploadConfig {
  /// Multipart-HTTP-Konfiguration mit Zieladresse, Feldern, Headern und optionalen Chunks.
  ///
  /// Multipart HTTP configuration with a destination, fields, headers and optional chunks.
  const TxHttpUploadConfig({
    required this.url,
    this.fieldName = 'file',
    this.headers = const {},
    this.fields = const {},
    this.chunkSize,
    this.chunkFields,
  });
  /// Zieladresse des Uploadservers.
  ///
  /// Upload server destination.
  final Uri url;
  /// Multipart-Feldname der Datei.
  ///
  /// Multipart file field name.
  final String fieldName;
  /// headers: Zusätzliche HTTP-Header.
  /// fields: Zusätzliche Multipart-Textfelder.
  ///
  /// headers: Additional HTTP headers.
  /// fields: Additional multipart text fields.
  final Map<String, String> headers, fields;
  /// Chunkgröße in Bytes; muss positiv sein.
  ///
  /// Chunk size in bytes; must be positive.
  final int? chunkSize;
  /// Felder je Chunk; Index ist nullbasiert.
  ///
  /// Fields per chunk; index is zero-based.
  final Map<String, String> Function(XFile, int, int)? chunkFields;
}

/// Erzeugt einen Multipart-POST-Adapter. Der Server muss Chunks zusammensetzen. Nicht erfolgreiche HTTP-Antworten und Netzwerkfehler schlagen fehl.
///
/// Parameter: config mit erforderlicher URL; Rückgabe TxUploadAdapter. Der Adapter erhält file und context und liefert asynchron den letzten HTTP-Antworttext. fieldName = file; zusätzliche Felder/Header standardmäßig leer. chunkSize muss positiv sein; chunkFields erhält file, nullbasierten index und count. Abbruch und HTTP-/Netzwerkfehler lehnen die Operation ab. Kein automatisches JSON-Parsing und keine automatische serverseitige Chunk-Zusammenführung.
///
/// Creates a multipart POST adapter. The server must assemble chunks. Non-success HTTP responses and network errors fail the upload.
///
/// Parameter: config with a required URL; returns TxUploadAdapter. The adapter receives file and context and asynchronously returns the final HTTP response text. fieldName = file; extra fields/headers default to empty. chunkSize must be positive; chunkFields receives file, zero-based index and count. Cancellation and HTTP/network failures reject the operation. No automatic JSON parsing or server-side chunk assembly.
///
/// ```dart
/// // Requires your own multipart server with matching chunk assembly.
/// final upload = txHttpUpload(TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload')));
/// await upload(XFile.fromData(Uint8List.fromList([72, 105]), name: 'hello.txt'), TxUploadContext(cancellation: TxCancellation(), onProgress: (loaded, total) => print('$loaded/$total')));
/// ```
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

/// Dateiauswahl und Uploadwarteschlange mit Größen-/Typprüfung, Fortschritt und Wiederholung ab Dateianfang.
///
/// File picker and upload queue with size/type checks, progress and retry from the beginning.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   // Replace with your server's multipart endpoint.
///   final upload = txHttpUpload(
///     TxHttpUploadConfig(url: Uri.parse('https://example.com/api/upload')),
///   );
///   return TxFileUploader(adapter: upload, extensions: const ['txt']);
/// }
/// ```
class TxFileUploader extends StatefulWidget {
  /// Dateiauswahl und Uploadwarteschlange mit Größen-/Typprüfung, Fortschritt und Wiederholung ab Dateianfang.
  ///
  /// File picker and upload queue with size/type checks, progress and retry from the beginning.
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
  /// Uploadfunktion für eine Datei.
  ///
  /// Upload function for one file.
  final TxUploadAdapter? adapter;
  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object? dataSource;
  /// multiple: Erlaubt mehrere Dateien.
  /// instantly: Startet gültige Dateien unmittelbar nach Auswahl.
  /// disabled: Sperrt die Interaktion.
  ///
  /// multiple: Allows multiple files.
  /// instantly: Starts valid files immediately after selection.
  /// disabled: Disables interaction.
  final bool multiple, instantly, disabled;
  /// Maximale Dateigröße in Bytes.
  ///
  /// Maximum file size in bytes.
  final int? maxFileSize;
  /// Minimale Dateigröße in Bytes.
  ///
  /// Minimum file size in bytes.
  final int minFileSize;
  /// Erlaubte Dateiendungen ohne Punkt.
  ///
  /// Allowed file extensions without a dot.
  final List<String> extensions;
  /// Liefert die hochgeladene XFile und das Adapterergebnis.
  ///
  /// Provides the uploaded XFile and adapter result.
  final void Function(XFile, Object?)? onUploaded;
  /// Meldet Datei und Fehler einer fehlgeschlagenen Uploadoperation.
  ///
  /// Reports the file and error of a failed upload operation.
  final void Function(XFile, Object)? onError;
  /// Callback für changed; Argumente und Rückgabetyp siehe Signatur.
  ///
  /// Callback for changed; see the signature for arguments and return type.
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

/// Ordnernavigation und Dateiaktionen. Der Provider bestimmt die verfügbaren Operationen; kein Dateiserver enthalten.
///
/// Directory navigation and file actions. Provider capabilities determine available operations; no file server is included.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:tecexpress/tecexpress.dart';
///
/// Widget example() {
///   final provider = TxMemoryFileProvider([
///     const TxFileEntry(id: '1', name: 'Documents', isDirectory: true),
///   ]);
///   return TxFileManager(provider: provider);
/// }
/// ```
class TxFileManager extends StatefulWidget {
  /// Ordnernavigation und Dateiaktionen. Der Provider bestimmt die verfügbaren Operationen; kein Dateiserver enthalten.
  ///
  /// Directory navigation and file actions. Provider capabilities determine available operations; no file server is included.
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
  /// Datei-Provider mit unterstützten Operationen.
  ///
  /// File provider with supported operations.
  final TxFileProvider provider;
  /// Liste, Konfiguration oder DataSource-Instanz; hat Vorrang vor items.
  ///
  /// List, configuration or DataSource instance; takes precedence over items.
  final Object? dataSource;
  /// Sperrt die Interaktion.
  ///
  /// Disables interaction.
  final bool disabled;
  /// Höhe; Vue-Zahlen in Pixeln, Flutter in logischen Pixeln.
  ///
  /// Height; Vue numbers use pixels, Flutter uses logical pixels.
  final double height;
  /// Meldet selection; kontrollierten Zustand im Callback aktualisieren.
  ///
  /// Reports selection; update controlled state in the callback.
  final ValueChanged<List<TxFileEntry>>? onSelectionChanged;
  /// Meldet den aktivierten Dateieintrag.
  ///
  /// Reports the activated file entry.
  final ValueChanged<TxFileEntry>? onFileOpened;
  /// Liefert Dateieintrag und Bytes für eine eigene Speicherintegration.
  ///
  /// Provides a file entry and bytes for custom saving.
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
