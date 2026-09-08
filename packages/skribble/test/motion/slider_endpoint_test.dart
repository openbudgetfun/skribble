import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  for (final value in [0.0, 1.0]) {
    testWidgets('the full thumb is visible at endpoint $value', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: WiredScaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: WiredSlider(value: value, onChanged: (_) => true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final pixels = await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
        return bytes;
      });
      var outerInk = 0;
      final start = value == 0 ? 0 : 190;
      for (var y = 12; y < 36; y++) {
        for (var x = start; x < start + 10; x++) {
          if (pixels![(y * 200 + x) * 4 + 3] > 0) outerInk++;
        }
      }
      expect(
        outerInk,
        greaterThan(0),
        reason: 'The outward half of the thumb must paint into the reserved padding.',
      );
    });
  }
}
