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

/// A filled rectangle drawn through the shared default filler config.
Widget filledBox(Key key, double width) => RepaintBoundary(
  key: key,
  child: SizedBox(
    width: width,
    height: 80,
    child: WiredCanvas(
      painter: WiredRectangleBase(),
      fillerType: RoughFilter.hachureFiller,
    ),
  ),
);

void main() {
  testWidgets('fill geometry is identical across paints and rebuilds', (
    tester,
  ) async {
    final target = GlobalKey();

    Future<void> pumpPage({required bool withDecoy, double? width}) =>
        tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData(),
            home: WiredScaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A differently sized filled shape consumes a different
                    // number of random values before the target paints.
                    if (withDecoy) filledBox(GlobalKey(), 90),
                    filledBox(target, width ?? 160),
                  ],
                ),
              ),
            ),
          ),
        );

    await pumpPage(withDecoy: false);
    await tester.pumpAndSettle();
    final first = await pixels(tester, target);

    await pumpPage(withDecoy: true, width: 91);
    await tester.pumpAndSettle();

    await pumpPage(withDecoy: false);
    await tester.pumpAndSettle();
    final second = await pixels(tester, target);

    expect(second, equals(first));
  });
}
