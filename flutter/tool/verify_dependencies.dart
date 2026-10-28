import 'dart:io';

/// Enforce the SDK-only direct runtime dependency policy without a YAML package.
void main() {
  final root = File.fromUri(Platform.script).parent.parent;
  for (final relative in [
    'pubspec_overrides.yaml',
    'example/pubspec_overrides.yaml',
  ]) {
    if (File('${root.path}/$relative').existsSync()) {
      throw StateError(
        '$relative is not permitted by the SDK-only dependency policy',
      );
    }
  }
  for (final relative in ['pubspec.yaml', 'example/pubspec.yaml']) {
    final lines = File('${root.path}/$relative').readAsLinesSync();
    var inDependencies = false;
    String? dependency;
    final sources = <String, String>{};
    for (final line in lines) {
      if (line.trim().startsWith('#') || line.trim().isEmpty) continue;
      if (RegExp(r'^\S').hasMatch(line)) {
        inDependencies = line == 'dependencies:';
        if (RegExp(r'^dependency_overrides\s*:').hasMatch(line)) {
          throw StateError('$relative must not contain dependency_overrides');
        }
        continue;
      }
      if (!inDependencies) continue;
      final entry = RegExp(r'^  ([a-zA-Z0-9_]+):\s*(.*)$').firstMatch(line);
      if (entry != null) {
        dependency = entry[1]!;
        sources[dependency] = entry[2]!;
      } else if (dependency != null) {
        sources[dependency] = '${sources[dependency]} ${line.trim()}';
      }
    }
    for (final entry in sources.entries) {
      final allowed =
          entry.value.trim() == 'sdk: flutter' ||
          (relative.startsWith('example/') &&
              entry.key == 'tecexpress' &&
              entry.value.trim() == 'path: ../');
      if (!allowed) {
        throw StateError(
          '$relative: ${entry.key} must come from the Flutter SDK',
        );
      }
    }
    stdout.writeln('$relative: SDK-only direct runtime dependencies verified');
  }
}
