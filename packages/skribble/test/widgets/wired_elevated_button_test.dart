import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredElevatedButton', () {
    testWidgets('renders its child label', (tester) async {
      await pumpWired(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
      expectRenders(tester, findWired<WiredElevatedButton>());
      expectPaints(findWired<WiredElevatedButton>());
      expectRepaintIsolation(findWired<WiredElevatedButton>());
    });

    testWidgets('renders a rough icon child', (tester) async {
      final addIcon = roughIconFor('add');

      await pumpWired(
        tester,
        WiredElevatedButton(
          onPressed: () {},
          child: WiredIcon(icon: addIcon),
        ),
      );

      expect(
        findWiredIn<WiredIcon>(findWired<WiredElevatedButton>()),
        findsOneWidget,
      );
      expectRenders(tester, findWired<WiredElevatedButton>());
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpWired(
        tester,
        WiredElevatedButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      );

      await tapWired(tester, findWired<WiredElevatedButton>());

      expect(pressed, isTrue);
    });

    testWidgets('tracks rapid repeated taps', (tester) async {
      var tapCount = 0;

      await pumpWired(
        tester,
        WiredElevatedButton(
          onPressed: () => tapCount++,
          child: const Text('Multi'),
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tapWired(tester, findWired<WiredElevatedButton>());
      }

      expect(tapCount, 3);
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        WiredElevatedButton(
          onPressed: () {},
          semanticLabel: 'Save changes',
          child: const Text('Save'),
        ),
      );

      expect(findWiredBySemanticsLabel('Save changes'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredElevatedButton>(),
        label: 'Save changes',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled button ignores taps and reports disabled', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredElevatedButton(
          onPressed: null,
          semanticLabel: 'Disabled',
          child: const Text('Disabled'),
        ),
      );

      await tapWired(tester, findWired<WiredElevatedButton>());

      expect(tester.takeException(), isNull);
      expectSemantics(
        tester,
        findWired<WiredElevatedButton>(),
        isButton: true,
        isEnabled: false,
        hasTapAction: false,
      );
      expectPaints(findWired<WiredElevatedButton>());
    });

    testWidgets('onPressed defaults to null', (tester) async {
      const button = WiredElevatedButton(child: Text('Default'));

      expect(button.onPressed, isNull);
    });

    testWidgets('keeps layout in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('RTL')),
      );

      expect(find.text('RTL'), findsOneWidget);
      expectRenders(tester, findWired<WiredElevatedButton>());
      expectPaints(findWired<WiredElevatedButton>());
    });

    testWidgets('survives doubled text and small constraints', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Scaled')),
        surfaceSize: const Size(120, 80),
      );

      expectRenders(tester, findWired<WiredElevatedButton>());
      expectPaints(findWired<WiredElevatedButton>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without throwing under zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredElevatedButton(onPressed: () {}, child: const Text('Zero')),
        surfaceSize: Size.zero,
      );

      expect(tester.takeException(), isNull);
    });
  });
}
