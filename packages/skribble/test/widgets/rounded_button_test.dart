import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  for (final kind in ['basic', 'filled', 'elevated', 'outlined']) {
    testWidgets(
      '$kind supports rough rounded and square corners with working taps',
      (tester) async {
        var taps = 0;
        final boundary = GlobalKey();
        Future<List<int>> render(WiredRoughness level, double radius) async {
          final corners = BorderRadius.circular(radius);
          final child = switch (kind) {
            'basic' => WiredButton(
              borderRadius: corners,
              onPressed: () => taps++,
              child: const Text('Keep it'),
            ),
            'filled' => WiredFilledButton(
              borderRadius: corners,
              onPressed: () => taps++,
              fillColor: const Color(0xffe8957d),
              child: const Text('Keep it'),
            ),
            'elevated' => WiredElevatedButton(
              borderRadius: corners,
              onPressed: () => taps++,
              child: const Text('Keep it'),
            ),
            _ => WiredOutlinedButton(
              borderRadius: corners,
              onPressed: () => taps++,
              child: const Text('Keep it'),
            ),
          };
          await tester.pumpWidget(
            WiredMaterialApp(
              wiredTheme: WiredThemeData(
                roughnessLevel: level,
                motionEnabled: false,
              ),
              home: Center(
                child: RepaintBoundary(
                  key: boundary,
                  child: SizedBox(width: 180, child: child),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          return tester
              .runAsync(() async {
                final image =
                    await (boundary.currentContext!.findRenderObject()!
                            as RenderRepaintBoundary)
                        .toImage();
                try {
                  final data = await image.toByteData(
                    format: ui.ImageByteFormat.rawRgba,
                  );
                  return data!.buffer.asUint8List().toList();
                } finally {
                  image.dispose();
                }
              })
              .then((pixels) => pixels!);
        }

        final square = await render(WiredRoughness.playful, 0);
        final rounded = await render(WiredRoughness.playful, 12);
        expect(rounded, isNot(square));
        expect(
          await render(WiredRoughness.playful, 12),
          rounded,
          reason: 'Rebuilding should preserve the seeded contour',
        );
        expect(await render(WiredRoughness.expressive, 12), isNot(rounded));
        await tester.tap(find.text('Keep it'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final kind in ['chip', 'filter', 'input']) {
    testWidgets(
      '$kind chip keeps long labels and actions within a narrow width',
      (tester) async {
        const label = 'A long descriptive label that should remain accessible';
        var deleted = false;
        final chip = switch (kind) {
          'chip' => WiredChip(
            label: const Text(label),
            onDeleted: () => deleted = true,
          ),
          'input' => WiredInputChip(
            label: const Text(label),
            onDeleted: () => deleted = true,
          ),
          _ => WiredFilterChip(
            label: const Text(label),
            selected: true,
            onSelected: (_) => deleted = true,
          ),
        };
        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData(),
            home: Center(child: SizedBox(width: 180, child: chip)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text(label), findsOneWidget);
        if (kind == 'filter') {
          await tester.tap(find.byType(WiredFilterChip));
        } else {
          await tester.tap(find.byType(WiredIcon).last);
        }
        expect(deleted, isTrue);
      },
    );
  }
}
