import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Future<Uint8List> pixels(WidgetTester tester, GlobalKey key) async =>
    (await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      return bytes;
    }))!;

void main() {
  for (final fill in [const Color(0xff241332), const Color(0xffffee99)]) {
    testWidgets('filled button is opaque and readable on $fill', (
      tester,
    ) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: WiredScaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 160,
                  child: WiredFilledButton(
                    fillColor: fill,
                    onPressed: () {},
                    child: const Text('Ink'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bytes = await pixels(tester, key);
      const offset = (20 * 160 + 18) * 4;
      expect(bytes.sublist(offset, offset + 4), [
        (fill.toARGB32() >> 16) & 255,
        (fill.toARGB32() >> 8) & 255,
        fill.toARGB32() & 255,
        255,
      ]);
      final foreground = DefaultTextStyle.of(tester.element(find.text('Ink')))
          .style
          .color!;
      final lighter = foreground.computeLuminance() > fill.computeLuminance()
          ? foreground
          : fill;
      final darker = lighter == fill ? foreground : fill;
      expect(
        (lighter.computeLuminance() + .05) / (darker.computeLuminance() + .05),
        greaterThanOrEqualTo(4.5),
      );
    });
  }

  testWidgets('switch thumb covers the track in both positions', (
    tester,
  ) async {
    final key = GlobalKey();
    for (final value in [false, true]) {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(fillColor: const Color(0xfffffbef)),
          home: WiredScaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: WiredSwitch(value: value, onChanged: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bytes = await pixels(tester, key);
      final center = (12 * 60 + (value ? 48 : 12)) * 4;
      expect(bytes.sublist(center, center + 4), [255, 251, 239, 255]);
    }
  });
}
