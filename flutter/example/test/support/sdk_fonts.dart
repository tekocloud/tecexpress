import 'dart:convert';
import 'dart:io';

/// Resolve the SDK used by this test's package configuration, including when
/// flutter_tester is launched through a symlink or outside the SDK directory.
Future<Directory> sdkFontsDirectory() async {
  var root = Directory.current;
  while (true) {
    final config = File('${root.path}/.dart_tool/package_config.json');
    if (config.existsSync()) {
      final data =
          jsonDecode(await config.readAsString()) as Map<String, dynamic>;
      final packages = data['packages'] as List<dynamic>;
      for (final package in packages.cast<Map<String, dynamic>>()) {
        if (package['name'] != 'flutter') continue;
        final flutter = Directory.fromUri(
          config.uri.resolve(package['rootUri'] as String),
        );
        final sdk = flutter.parent.parent;
        final directory = Directory(
          '${sdk.path}/bin/cache/artifacts/material_fonts',
        );
        if (!directory.existsSync()) {
          throw StateError(
            'Flutter SDK fonts were not found at ${directory.path}.',
          );
        }
        return directory;
      }
    }
    if (root.parent.path == root.path) break;
    root = root.parent;
  }
  throw StateError('Cannot resolve the Flutter SDK from package_config.json.');
}

/// SDK archives can differ in filename casing across platforms.
File sdkFontFile(Directory directory, String name) {
  for (final file in directory.listSync().whereType<File>()) {
    if (file.uri.pathSegments.last.toLowerCase() == name.toLowerCase()) {
      return file;
    }
  }
  throw StateError('SDK font $name was not found in ${directory.path}.');
}
