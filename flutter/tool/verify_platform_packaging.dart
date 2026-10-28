import 'dart:io';

/// Checks published plugin metadata before CI builds or pub.dev publication.
void main() {
  final root = File.fromUri(Platform.script).parent.parent.path;
  String read(String relative) => File('$root/$relative').readAsStringSync();
  void require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  final version = RegExp(
    r'^version: (\S+)',
    multiLine: true,
  ).firstMatch(read('pubspec.yaml'))![1]!;
  for (final platform in ['ios', 'macos']) {
    final package = '$platform/tecexpress';
    final manifest = read('$package/Package.swift');
    require(
      File('$root/$package/Sources/tecexpress/TecexpressPlugin.swift')
          .existsSync(),
      '$platform: missing SwiftPM source',
    );
    require(
      manifest.contains('path: "../FlutterFramework"'),
      '$platform: missing local Flutter SDK package',
    );
    final podspec = read('$platform/tecexpress.podspec');
    require(
      podspec.contains(
        "s.source_files = 'tecexpress/Sources/tecexpress/**/*.swift'",
      ),
      '$platform: CocoaPods must use the same Swift sources',
    );
    require(
      podspec.contains("s.version = '$version'"),
      '$platform: stale podspec version',
    );
    final oldSources = Directory('$root/$platform/Classes');
    require(
      !oldSources.existsSync() ||
          !oldSources
              .listSync(recursive: true)
              .any((entry) => entry.path.endsWith('.swift')),
      '$platform: duplicate legacy Swift sources',
    );
  }

  final gradle = read('android/build.gradle');
  require(
    !RegExp(
      r'kotlin-android|org\.jetbrains\.kotlin\.android|kotlinOptions|kotlin-gradle-plugin',
    ).hasMatch(gradle),
    'Android: legacy Kotlin configuration detected',
  );
  require(
    gradle.contains('compilerOptions'),
    'Android: missing modern compiler options',
  );
  require(
    gradle.contains("version '$version'"),
    'Android: stale native version',
  );
  require(
    read('example/android/gradle.properties')
        .contains('android.builtInKotlin=true'),
    'Android example must exercise built-in Kotlin',
  );
  stdout.writeln(
    'SwiftPM/CocoaPods source layout, built-in Kotlin and native versions verified ($version).',
  );
}
