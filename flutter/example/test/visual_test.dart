import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tecexpress_example/showcase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Use the SDK's real fonts for visual QA instead of the test-only Ahem font.
    var directory = File(Platform.resolvedExecutable).parent;
    Directory? fonts;
    for (var i = 0; i < 12; i++) {
      final candidate = Directory(
        '${directory.path}/bin/cache/artifacts/material_fonts',
      );
      if (candidate.existsSync()) {
        fonts = candidate;
        break;
      }
      if (directory.parent.path == directory.path) break;
      directory = directory.parent;
    }
    if (fonts == null) {
      throw StateError('Flutter SDK material_fonts were not found.');
    }
    for (final entry in {
      'Roboto': 'roboto-regular.ttf',
      'MaterialIcons': 'materialicons-regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(
          File('${fonts.path}/${entry.value}')
              .readAsBytes()
              .then(ByteData.sublistView),
        );
      await loader.load();
    }
  });
  for (final dark in [false, true]) {
    for (final width in [1200.0, 390.0]) {
      testWidgets(
        'showcase ${dark ? 'dark' : 'light'} ${width.toInt()} layouts and screenshots',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundaryKey,
              child: const TecexpressShowcase(),
            ),
          );
          await tester.pumpAndSettle();
          if (dark) {
            await tester.tap(find.byTooltip('Theme wechseln'));
            await tester.pumpAndSettle();
          }
          const sections = [
            'Eingaben & Oberfläche',
            'DataGrid',
            'Scheduler',
            'Cards',
            'Chat',
          ];
          for (var index = 0; index < sections.length; index++) {
            if (width < 950) {
              await tester.tap(find.byType(DrawerButton));
              await tester.pumpAndSettle();
            }
            final target = width < 950
                ? find.descendant(
                    of: find.byType(Drawer),
                    matching: find.text(sections[index]),
                  )
                : find.text(sections[index]).first;
            await tester.tap(target);
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${sections[index]} at $width',
            );
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                'build/qa/${dark ? 'dark' : 'light'}-${width.toInt()}-$index.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
        },
      );
    }
  }
}
