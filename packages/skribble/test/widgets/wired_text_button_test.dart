import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_material/skribble_icons_material.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredTextButton', () {
    testWidgets('renders its child label', (tester) async {
      await pumpWired(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
      expectRenders(tester, findWired<WiredTextButton>());
      expectPaints(findWired<WiredTextButton>());
      expectRepaintIsolation(findWired<WiredTextButton>());
    });

    testWidgets('renders a rough icon child', (tester) async {
      final starIcon = lookupMaterialRoughFontIcon('star');

      await pumpWired(
        tester,
        WiredTextButton(
          onPressed: () {},
          child: WiredIcon(icon: starIcon!),
        ),
      );

      expect(
        findWiredIn<WiredIcon>(findWired<WiredTextButton>()),
        findsOneWidget,
      );
      expectRenders(tester, findWired<WiredTextButton>());
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpWired(
        tester,
        WiredTextButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      );

      await tapWired(tester, findWired<WiredTextButton>());

      expect(pressed, isTrue);
    });

    testWidgets('tracks rapid repeated taps', (tester) async {
      var tapCount = 0;

      await pumpWired(
        tester,
        WiredTextButton(
          onPressed: () => tapCount++,
          child: const Text('Multi'),
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tapWired(tester, findWired<WiredTextButton>());
      }

      expect(tapCount, 3);
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        WiredTextButton(
          onPressed: () {},
          semanticLabel: 'Learn more',
          child: const Text('Details'),
        ),
      );

      expect(findWiredBySemanticsLabel('Learn more'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredTextButton>(),
        label: 'Learn more',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled button ignores taps and reports disabled', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredTextButton(
          onPressed: null,
          semanticLabel: 'Disabled',
          child: const Text('Disabled'),
        ),
      );

      await tapWired(tester, findWired<WiredTextButton>());

      expect(tester.takeException(), isNull);
      expectSemantics(
        tester,
        findWired<WiredTextButton>(),
        isButton: true,
        isEnabled: false,
        hasTapAction: false,
      );
      expectPaints(findWired<WiredTextButton>());
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const button = WiredTextButton(child: Text('Default'));

      expect(button.onPressed, isNull);
    });

    testWidgets('sizes to its content rather than the surface', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Intrinsic')),
        surfaceSize: const Size(600, 200),
      );

      expect(tester.getSize(findWired<WiredTextButton>()).width, lessThan(600));
    });

    testWidgets('keeps layout in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('RTL')),
      );

      expect(find.text('RTL'), findsOneWidget);
      expectRenders(tester, findWired<WiredTextButton>());
      expectPaints(findWired<WiredTextButton>());
    });

    testWidgets('scales its label inside the button bounds', (tester) async {
      await pumpWired(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Scaled')),
        surfaceSize: const Size(400, 300),
      );
      final normalTextHeight = tester.getSize(find.text('Scaled')).height;

      await pumpWiredScaled(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Scaled')),
        surfaceSize: const Size(400, 300),
      );

      final textRect = tester.getRect(find.text('Scaled'));
      final buttonRect = tester.getRect(findWired<WiredTextButton>());

      expect(
        textRect.height,
        greaterThan(normalTextHeight),
        reason: 'The 2x text scale must reach the label.',
      );
      expect(
        textRect.bottom,
        lessThanOrEqualTo(buttonRect.bottom),
        reason:
            'The scaled label must stay inside the painted control so the '
            'hand-drawn underline does not detach or clip.',
      );
      expectPaints(findWired<WiredTextButton>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders and paints under small constraints', (tester) async {
      await pumpWired(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Scaled')),
        surfaceSize: const Size(120, 80),
      );

      expectRenders(tester, findWired<WiredTextButton>());
      expectPaints(findWired<WiredTextButton>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without throwing under zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredTextButton(onPressed: () {}, child: const Text('Zero')),
        surfaceSize: Size.zero,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
