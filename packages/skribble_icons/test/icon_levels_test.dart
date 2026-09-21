import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  testWidgets('all catalogs respond to levels at small and large sizes', (
    tester,
  ) async {
    registerSkribbleIcons();
    final samples = <String, WiredSvgIconData>{
      'Curated home': lookupSkribbleCuratedIconByIdentifier('home')!,
      'Material home': lookupMaterialRoughIconByIdentifier('home')!,
      'Lucide house': lookupLucideIconByIdentifier('house')!,
      'Simple github': lookupSimpleIconByIdentifier('github')!,
      'Boxicons home': lookupBxsIconByIdentifier('home')!,
      'CoreUI github': lookupCibIconByIdentifier('github')!,
    };
    final capture = Platform.environment.containsKey('ICON_LEVELS_PREVIEW');
    if (capture) {
      final font = FontLoader('Preview')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File(
                '../skribble_font_recursive/assets/fonts/SkribbleGentle-Regular.ttf',
              ).readAsBytesSync(),
            ),
          ),
        );
      await font.load();
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..drawColor(const Color(0xfffffaf0), BlendMode.src);
    void label(String text, double x, double y) {
      final paragraph =
          (ui.ParagraphBuilder(
                  ui.ParagraphStyle(fontSize: 16, fontFamily: 'Preview'),
                )
                ..pushStyle(ui.TextStyle(color: const Color(0xff35283f)))
                ..addText(text))
              .build()
            ..layout(const ui.ParagraphConstraints(width: 220));
      canvas.drawParagraph(paragraph, Offset(x, y));
      paragraph.dispose();
    }

    const key = ValueKey('icon');
    Future<ui.Image> render(
      WiredSvgIconData data,
      WiredRoughness level,
      double size, {
      bool source = false,
      bool shorthand = false,
    }) async {
      final config = source ? DrawConfig.build(roughness: 0) : null;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WiredThemeScope(
            data: WiredThemeData(roughnessLevel: level),
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: shorthand
                    ? SkribbleIcon(data: data, size: size, drawConfig: config)
                    : WiredSvgIcon(data: data, size: size, drawConfig: config),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(key)), Size.square(size));
      return (await tester.runAsync(
        () => tester
            .renderObject<RenderRepaintBoundary>(find.byKey(key))
            .toImage(pixelRatio: 2),
      ))!;
    }

    Future<Uint8List> bytes(ui.Image image) async => (await tester.runAsync(
      () async => (await image.toByteData())!.buffer.asUint8List(),
    ))!;

    var row = 0;
    for (final sample in samples.entries) {
      label(sample.key, 12, row * 166 + 8);
      for (final size in [24.0, 48.0, 96.0]) {
        final original = await render(
          sample.value,
          WiredRoughness.gentle,
          size,
          source: true,
        );
        final sourcePixels = await bytes(original);
        final differences = <int>[];
        var column = 1;
        for (final level in WiredRoughness.values) {
          final image = await render(sample.value, level, size);
          final pixels = await bytes(image);
          differences.add(_difference(sourcePixels, pixels));
          expect(
            differences.last,
            greaterThan(0),
            reason: '${sample.key} $level $size',
          );
          final rebuilt = await render(
            sample.value,
            level,
            size,
            shorthand: true,
          );
          expect(
            await bytes(rebuilt),
            pixels,
            reason: 'SkribbleIcon shares the treatment',
          );
          rebuilt.dispose();
          if (capture) {
            label(level.name, column * 220 + 12, row * 166 + 32);
            final x =
                column * 220 +
                switch (size) {
                  24 => 12,
                  48 => 48,
                  _ => 110,
                };
            canvas.drawImageRect(
              image,
              Rect.fromLTWH(
                0,
                0,
                image.width.toDouble(),
                image.height.toDouble(),
              ),
              Rect.fromLTWH(x.toDouble(), row * 166 + 58, size, size),
              Paint(),
            );
          }
          image.dispose();
          column++;
        }
        expect(
          differences[1],
          greaterThan(differences[0]),
          reason: '${sample.key} playful at $size',
        );
        expect(
          differences[2],
          greaterThan(differences[1]),
          reason: '${sample.key} expressive at $size',
        );
        if (capture) {
          label('Source', 12, row * 166 + 32);
          final x = switch (size) {
            24 => 12.0,
            48 => 48.0,
            _ => 110.0,
          };
          canvas.drawImageRect(
            original,
            Rect.fromLTWH(
              0,
              0,
              original.width.toDouble(),
              original.height.toDouble(),
            ),
            Rect.fromLTWH(x, row * 166 + 58, size, size),
            Paint(),
          );
        }
        original.dispose();
      }
      row++;
    }
    final picture = recorder.endRecording();
    if (capture) {
      await tester.runAsync(() async {
        final image = await picture.toImage(880, row * 166);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('../../.screenshots/icons/levels.png');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(png!.buffer.asUint8List());
        image.dispose();
      });
    }
    picture.dispose();
  });
}

int _difference(Uint8List a, Uint8List b) {
  var total = 0;
  for (var i = 3; i < a.length; i += 4) {
    total += (a[i] - b[i]).abs();
  }
  return total;
}
