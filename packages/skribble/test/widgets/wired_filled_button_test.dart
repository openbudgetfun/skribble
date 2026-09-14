import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_material/skribble_icons_material.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredFilledButton', () {
    testWidgets('renders its child label', (tester) async {
      await pumpWired(
        tester,
        WiredFilledButton(onPressed: () {}, child: const Text('Filled')),
      );

      expect(find.text('Filled'), findsOneWidget);
      expectRenders(tester, findWired<WiredFilledButton>());
      expectPaints(findWired<WiredFilledButton>());
      expectRepaintIsolation(findWired<WiredFilledButton>());
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await pumpWired(
        tester,
        WiredFilledButton(
          onPressed: () => tapped = true,
          child: const Text('Tap me'),
        ),
      );

      await tapWired(tester, findWired<WiredFilledButton>());

      expect(tapped, isTrue);
    });

    testWidgets('renders with a custom fill color', (tester) async {
      await pumpWired(
        tester,
        WiredFilledButton(
          onPressed: () {},
          fillColor: const Color(0xFF1234FF),
          child: const Text('Blue'),
        ),
      );

      expect(find.text('Blue'), findsOneWidget);
      expectPaints(findWired<WiredFilledButton>());
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        WiredFilledButton(
          onPressed: () {},
          semanticLabel: 'Confirm order',
          child: const Text('Confirm'),
        ),
      );

      expect(findWiredBySemanticsLabel('Confirm order'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredFilledButton>(),
        label: 'Confirm order',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled button ignores taps and reports disabled', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredFilledButton(
          onPressed: null,
          semanticLabel: 'Disabled',
          child: const Text('Disabled'),
        ),
      );

      await tapWired(tester, findWired<WiredFilledButton>());

      expect(tester.takeException(), isNull);
      expectSemantics(
        tester,
        findWired<WiredFilledButton>(),
        isButton: true,
        isEnabled: false,
        hasTapAction: false,
      );
      expectPaints(findWired<WiredFilledButton>());
    });

    testWidgets('has a fixed button height', (tester) async {
      await pumpWired(
        tester,
        WiredFilledButton(onPressed: () {}, child: const Text('Check height')),
      );

      expect(
        tester.getSize(findWired<WiredFilledButton>()).height,
        kWiredButtonHeight,
      );
    });

    testWidgets('keeps layout in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredFilledButton(onPressed: () {}, child: const Text('RTL')),
      );

      expect(find.text('RTL'), findsOneWidget);
      expectRenders(tester, findWired<WiredFilledButton>());
      expectPaints(findWired<WiredFilledButton>());
    });

    testWidgets('survives doubled text and small constraints', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredFilledButton(onPressed: () {}, child: const Text('Scaled')),
        surfaceSize: const Size(120, 80),
      );

      expectRenders(tester, findWired<WiredFilledButton>());
      expectPaints(findWired<WiredFilledButton>());
      expect(tester.takeException(), isNull);
    });
  });

  for (final fill in [const Color(0xFF4A3470), const Color(0xFFFFFCF1)]) {
    testWidgets(
      'disabled content keeps contrast on ${fill.toARGB32()}',
      (tester) async {
        await pumpWired(
          tester,
          WiredFilledButton(
            fillColor: fill,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Resting ink'),
                WiredIcon(icon: _check),
              ],
            ),
          ),
        );

        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('Resting ink'),
        );
        final textColor = paragraph.text.style!.color!;
        final iconColor = IconTheme.of(
          tester.element(findWired<WiredIcon>()),
        ).color!;
        final effective = Color.alphaBlend(textColor, fill);
        final light = effective.computeLuminance();
        final background = fill.computeLuminance();
        final contrast = light > background
            ? (light + .05) / (background + .05)
            : (background + .05) / (light + .05);

        expect(contrast, greaterThan(3));
        expect(iconColor, textColor);
        expect(
          textColor.a,
          lessThan(1),
          reason: 'Disabled content remains visibly muted.',
        );
        expectSemantics(
          tester,
          findWired<WiredFilledButton>(),
          isButton: true,
          isEnabled: false,
        );
      },
    );
  }
}

final IconData _check = lookupMaterialRoughFontIcon('check')!;
