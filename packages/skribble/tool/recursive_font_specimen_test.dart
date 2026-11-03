// Run from packages/skribble with flutter test tool/recursive_font_specimen_test.dart
// --dart-define=FONT_SPECIMEN_OUT=../../.screenshots/fonts/before.
// Captures are generated from the bundled fonts and never committed.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _output = String.fromEnvironment('FONT_SPECIMEN_OUT');
const _fonts = String.fromEnvironment(
  'FONT_SPECIMEN_FONTS',
  defaultValue: '../skribble_font_recursive/assets/fonts',
);

String _family(String prefix, String level) =>
    prefix == 'Skribble' && level == 'Expressive' ? prefix : '$prefix$level';

void main() {
  testWidgets('capture Recursive lettering at reading sizes', (tester) async {
    if (_output.isEmpty) {
      markTestSkipped(
        'Set FONT_SPECIMEN_OUT to a gitignored output directory.',
      );
      return;
    }

    await tester.runAsync(() async {
      final noto = FontLoader('SpecimenNoto')
        ..addFont(
          File(
            '../skribble_font_noto_sketch/assets/fonts/SkribbleNotoSketch-Regular.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await noto.load();

      for (final prefix in ['Skribble', 'SkribbleLinear', 'SkribbleMono']) {
        for (final level in ['Gentle', 'Playful', 'Expressive']) {
          final family = _family(prefix, level);
          final loader = FontLoader(family);

          for (final style in ['Regular', 'Bold', 'Italic', 'BoldItalic']) {
            loader.addFont(
              File('$_fonts/$family-$style.ttf')
                  .readAsBytes()
                  .then(ByteData.sublistView),
            );
          }

          await loader.load();
        }
      }
    });

    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();

    for (final width in [360, 1280]) {
      tester.view.physicalSize = Size(width.toDouble(), 4096);

      for (final dark in [false, true]) {
        final foreground = dark
            ? const Color(0xfff4eee4)
            : const Color(0xff292d28);
        final background = dark
            ? const Color(0xff222622)
            : const Color(0xfffaf7ef);
        final columns = width < 768 ? 1 : 3;
        final cellWidth = (width - 48 - (columns - 1) * 28) / columns;

        Widget text(
          String value, {
          String? family,
          double size = 16,
          FontWeight weight = FontWeight.w400,
          FontStyle style = FontStyle.normal,
        }) => Text(
          value,
          style: TextStyle(
            fontFamily: family ?? 'SpecimenNoto',
            fontSize: size,
            fontWeight: weight,
            fontStyle: style,
          ),
        );

        final rows = <Widget>[
          text('skribble lettering', size: 28),
          const SizedBox(height: 8),
          text('Default · Noto Sketch'),
          const SizedBox(height: 4),
          text('Little plans, lovely days.', size: 24),
          const SizedBox(height: 28),
        ];

        for (final (prefix, label) in [
          ('Skribble', 'Casual'),
          ('SkribbleLinear', 'Linear'),
          ('SkribbleMono', 'Mono'),
        ]) {
          final cells = <Widget>[];

          for (final level in ['Gentle', 'Playful', 'Expressive']) {
            final family = _family(prefix, level);
            cells.add(
              SizedBox(
                width: cellWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text('$label · $level', size: 14),
                    const SizedBox(height: 10),
                    text('Little plans, big days.', family: family, size: 24),
                    const SizedBox(height: 10),
                    text(
                      'Keep a little room for lovely things. Coffee, books, and a quiet afternoon.',
                      family: family,
                    ),
                    const SizedBox(height: 10),
                    text(
                      'minimum illl · 0123456789\nCafé, piñata, naïve, über.',
                      family: family,
                      size: 14,
                    ),
                    const SizedBox(height: 10),
                    text(
                      'Bold decisions, gentle ink.',
                      family: family,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(height: 4),
                    text(
                      'A small handwritten note.',
                      family: family,
                      style: FontStyle.italic,
                    ),
                  ],
                ),
              ),
            );
          }

          rows.add(Wrap(spacing: 28, runSpacing: 24, children: cells));
          rows.add(const SizedBox(height: 32));
        }

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: TextStyle(color: foreground, height: 1.5),
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: key,
                  child: ColoredBox(
                    color: background,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rows,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        expect(boundary.size.width, width.toDouble());
        expect(boundary.size.height, lessThan(4096));
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          File('$_output/${dark ? 'dark' : 'light'}-$width.png')
            ..parent.createSync(recursive: true)
            ..writeAsBytesSync(png!.buffer.asUint8List());
        });
      }
    }
  });
}
