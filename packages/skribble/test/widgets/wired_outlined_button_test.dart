import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_material/skribble_icons_material.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredOutlinedButton', () {
    testWidgets('renders its child label', (tester) async {
      await pumpWired(
        tester,
        WiredOutlinedButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
      expectRenders(tester, findWired<WiredOutlinedButton>());
      expectPaints(findWired<WiredOutlinedButton>());
      expectRepaintIsolation(findWired<WiredOutlinedButton>());
    });

    testWidgets('renders a rough icon child', (tester) async {
      final checkIcon = lookupMaterialRoughFontIcon('check');

      await pumpWired(
        tester,
        WiredOutlinedButton(
          onPressed: () {},
          child: WiredIcon(icon: checkIcon!),
        ),
      );

      expect(
        findWiredIn<WiredIcon>(findWired<WiredOutlinedButton>()),
        findsOneWidget,
      );
      expectRenders(tester, findWired<WiredOutlinedButton>());
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpWired(
        tester,
        WiredOutlinedButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      );

      await tapWired(tester, findWired<WiredOutlinedButton>());

      expect(pressed, isTrue);
    });

    testWidgets('tracks rapid repeated taps', (tester) async {
      var tapCount = 0;

      await pumpWired(
        tester,
        WiredOutlinedButton(
          onPressed: () => tapCount++,
          child: const Text('Multi'),
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tapWired(tester, findWired<WiredOutlinedButton>());
      }

      expect(tapCount, 3);
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        WiredOutlinedButton(
          onPressed: () {},
          semanticLabel: 'Cancel action',
          child: const Text('Cancel'),
        ),
      );

      expect(findWiredBySemanticsLabel('Cancel action'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredOutlinedButton>(),
        label: 'Cancel action',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled button ignores taps and reports disabled', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredOutlinedButton(
          onPressed: null,
          semanticLabel: 'Disabled',
          child: const Text('Disabled'),
        ),
      );

      await tapWired(tester, findWired<WiredOutlinedButton>());

      expect(tester.takeException(), isNull);
      expectSemantics(
        tester,
        findWired<WiredOutlinedButton>(),
        isButton: true,
        isEnabled: false,
        hasTapAction: false,
      );
      expectPaints(findWired<WiredOutlinedButton>());
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const button = WiredOutlinedButton(child: Text('Default'));

      expect(button.onPressed, isNull);
    });

    testWidgets('renders at the standard button height', (tester) async {
      await pumpWired(
        tester,
        WiredOutlinedButton(onPressed: () {}, child: const Text('Height test')),
      );

      expect(
        tester.getSize(findWired<WiredOutlinedButton>()).height,
        kWiredButtonHeight,
      );
    });

    testWidgets('keeps layout in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredOutlinedButton(onPressed: () {}, child: const Text('RTL')),
      );

      expect(find.text('RTL'), findsOneWidget);
      expectRenders(tester, findWired<WiredOutlinedButton>());
      expectPaints(findWired<WiredOutlinedButton>());
    });

    testWidgets('survives doubled text and small constraints', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredOutlinedButton(onPressed: () {}, child: const Text('Scaled')),
        surfaceSize: const Size(120, 80),
      );

      expectRenders(tester, findWired<WiredOutlinedButton>());
      expectPaints(findWired<WiredOutlinedButton>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without throwing under zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredOutlinedButton(onPressed: () {}, child: const Text('Zero')),
        surfaceSize: Size.zero,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
