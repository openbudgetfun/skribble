import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';
import 'package:skribble_docs_site/src/share_card.dart';

import 'support/skribble_fonts.dart';

void main() {
  setUpAll(loadSkribbleFonts);

  testWidgets(
    'the share card fits its 1200 by 630 frame with room to breathe',
    (
      tester,
    ) async {
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
      await tester.pump(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(ShareCard)), ShareCard.size);
      expect(find.text('skribble'), findsOneWidget);
      expect(find.text('skribble.dev'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('skribble')))
            .style
            .fontFamily,
        'packages/skribble_font_noto_sketch/SkribbleNotoSketch',
      );
      final root = tester.binding.renderViews.first;
      expect(crampedText(root), isEmpty);
      expect(squeezedText(root), isEmpty);
    },
  );
}
