// Renders the link-preview image for skribble.dev and its docs. The docs
// build runs it after `flutter build web`:
//
//   flutter test tool/share_card_test.dart --dart-define=SHARE_CARD_OUT=build/web/share-card.png
//
// The image is generated, never committed.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/share_card.dart';

import '../test/support/skribble_fonts.dart';

const String _out = String.fromEnvironment('SHARE_CARD_OUT');

void main() {
  testWidgets('render the share card', (tester) async {
    if (_out.isEmpty) {
      markTestSkipped('Set --dart-define=SHARE_CARD_OUT=<file> to render.');
      return;
    }
    await tester.runAsync(loadSkribbleFonts);
    tester.view
      ..physicalSize = ShareCard.size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData.cuddly(),
        home: const ShareCard(),
      ),
    );
    // Let the ink finish drawing on.
    await tester.pump(const Duration(seconds: 3));

    final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
    await tester.runAsync(() async {
      final image = await layer.toImage(Offset.zero & ShareCard.size);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File(_out)
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
  });
}
