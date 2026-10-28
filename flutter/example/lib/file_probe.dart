import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tecexpress/tecexpress.dart';

/// Manual platform probe: flutter run -t lib/file_probe.dart.
void main() => runApp(const MaterialApp(home: _FileProbe()));

class _FileProbe extends StatefulWidget {
  const _FileProbe();
  @override
  State<_FileProbe> createState() => _FileProbeState();
}

class _FileProbeState extends State<_FileProbe> {
  String _status = 'Ready';
  Future<void> _run(Future<String> Function() action) async {
    try {
      final status = await action();
      if (mounted) setState(() => _status = status);
    } catch (e) {
      if (mounted) setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('tecexpress file probe')),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_status, key: const ValueKey('file-status')),
            ElevatedButton(
              onPressed: () => _run(() async {
                final files = await TxFileDialogs.pickFiles(
                  multiple: true,
                  extensions: ['txt'],
                );
                final labels = <String>[];
                for (final file in files) {
                  try {
                    labels.add(
                      '${file.name}: ${(await file.readAsBytes()).length} bytes',
                    );
                  } finally {
                    await file.dispose();
                  }
                }
                return files.isEmpty ? 'Pick cancelled' : labels.join(', ');
              }),
              child: const Text('Pick text files'),
            ),
            ElevatedButton(
              onPressed: () => _run(() async {
                final file = TxFile.fromData(
                  Uint8List.fromList([72, 105, 10]),
                  name: 'tecexpress-probe.txt',
                );
                try {
                  return await TxFileDialogs.saveFile(file)
                      ? 'Saved'
                      : 'Save cancelled';
                } finally {
                  await file.dispose();
                }
              }),
              child: const Text('Save sample'),
            ),
            TxFileUploader(
              multiple: true,
              onChanged: (files) => _run(() async {
                final labels = <String>[];
                for (final file in files) {
                  labels.add('${file.name}: ${await file.length()} bytes');
                }
                return labels.join(', ');
              }),
              adapter: (file, context) async {
                final size = await file.length();
                // A local adapter makes this probe usable offline on every platform.
                await file.openRead().drain<void>();
                context.cancellation.throwIfCancelled();
                context.onProgress(size, size);
                return file.name;
              },
            ),
          ],
        ),
      ),
    ),
  );
}
