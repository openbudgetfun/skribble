import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredButton', () {
    testWidgets('renders its child label', (tester) async {
      await pumpWired(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
      expectRenders(tester, findWired<WiredButton>());
      expectPaints(findWired<WiredButton>());
    });

    testWidgets('exposes a button role and the supplied label', (tester) async {
      await pumpWired(
        tester,
        WiredButton(
          onPressed: () {},
          semanticLabel: 'Submit form',
          child: const Text('Submit'),
        ),
      );

      expect(
        findWiredBySemanticsLabel('Submit form'),
        findsOneWidget,
      );
      expectSemantics(
        tester,
        findWired<WiredButton>(),
        label: 'Submit form',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpWired(
        tester,
        WiredButton(onPressed: () => pressed = true, child: const Text('Tap')),
      );

      await tapWired(tester, findWired<WiredButton>());

      expect(pressed, isTrue);
    });

    testWidgets('tracks rapid repeated taps', (tester) async {
      var tapCount = 0;

      await pumpWired(
        tester,
        WiredButton(onPressed: () => tapCount++, child: const Text('Multi')),
      );

      for (var i = 0; i < 3; i++) {
        await tapWired(tester, findWired<WiredButton>());
      }

      expect(tapCount, 3);
    });

    testWidgets('disabled button ignores taps and reports disabled', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredButton(
          onPressed: null,
          semanticLabel: 'Disabled',
          child: const Text('Disabled'),
        ),
        surfaceSize: const Size(200, 100),
      );

      await tapWired(tester, findWired<WiredButton>());

      expect(tester.takeException(), isNull);
      expectSemantics(
        tester,
        findWired<WiredButton>(),
        label: 'Disabled',
        isButton: true,
        isEnabled: false,
        hasTapAction: false,
      );
      expectRenders(tester, findWired<WiredButton>());
    });

    testWidgets('renders a disabled label in the theme disabled color', (
      tester,
    ) async {
      const disabledColor = Color(0xFF555555);

      await pumpWired(
        tester,
        WiredButton(
          onPressed: null,
          child: const Text('Disabled'),
        ),
        theme: WiredThemeData(disabledTextColor: disabledColor),
      );

      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('Disabled'),
      );

      expect(paragraph.text.style?.color, disabledColor);
    });

    testWidgets('does not stretch when placed in a large surface', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Sized')),
        surfaceSize: const Size(800, 600),
      );

      final size = tester.getSize(findWired<WiredButton>());

      expect(size.height, kWiredButtonHeight);
      expect(size.width, lessThan(800));
    });

    testWidgets('renders and paints in a small surface', (tester) async {
      await pumpWired(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Tiny')),
        surfaceSize: const Size(48, 42),
      );

      expectRenders(tester, findWired<WiredButton>());
      expectPaints(findWired<WiredButton>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without throwing under zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Zero')),
        surfaceSize: Size.zero,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps its label and hit area in RTL', (tester) async {
      var pressed = false;

      await pumpWiredRtl(
        tester,
        WiredButton(
          onPressed: () => pressed = true,
          child: const Text('Right to left'),
        ),
      );

      expect(find.text('Right to left'), findsOneWidget);
      expectRenders(tester, findWired<WiredButton>());
      expectPaints(findWired<WiredButton>());

      await tapWired(tester, findWired<WiredButton>());

      expect(pressed, isTrue);
    });

    testWidgets('grows its ink to fit doubled text without clipping', (
      tester,
    ) async {
      await pumpWiredScaled(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Scaled label')),
        surfaceSize: const Size(400, 200),
      );

      expectRenders(tester, findWired<WiredButton>());
      expectPaints(findWired<WiredButton>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('reads border color from the surrounding theme', (
      tester,
    ) async {
      const red = Color(0xFFFF0000);

      await pumpWired(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Themed')),
        theme: WiredThemeData(borderColor: red),
      );

      expectPaints(findWired<WiredButton>());
      expectRenders(tester, findWired<WiredButton>());
    });
  });
}
