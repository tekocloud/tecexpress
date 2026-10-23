import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/sdk_fonts.dart';

void main() {
  test('SDK fonts resolve from the active Flutter package', () async {
    final directory = await sdkFontsDirectory();
    expect(sdkFontFile(directory, 'roboto-regular.ttf').existsSync(), isTrue);
    expect(
      sdkFontFile(directory, 'materialicons-regular.otf').existsSync(),
      isTrue,
    );
  });

  test(
    'font lookup accepts archive filename casing and reports missing fonts',
    () {
      final directory = Directory.systemTemp.createTempSync('tx-sdk-fonts-');
      addTearDown(() => directory.deleteSync(recursive: true));
      final font = File('${directory.path}/Roboto-Regular.ttf')
        ..writeAsBytesSync([]);
      expect(sdkFontFile(directory, 'roboto-regular.ttf').uri, font.uri);
      expect(() => sdkFontFile(directory, 'missing.ttf'), throwsStateError);
    },
  );
}
