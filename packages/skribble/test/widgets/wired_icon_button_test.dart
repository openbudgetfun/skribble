import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredIconButton', () {
    testWidgets('renders the requested rough icon', (tester) async {
      final addIcon = roughIconFor('add');

      await pumpWired(tester, WiredIconButton(icon: addIcon, onPressed: () {}));

      expect(
        findWiredIn<WiredIcon>(findWired<WiredIconButton>()),
        findsOneWidget,
      );
      expect(tester.widget<WiredIcon>(findWired<WiredIcon>()).icon, addIcon);
      expectRenders(tester, findWired<WiredIconButton>());
      expectPaints(findWired<WiredIconButton>());
      expectRepaintIsolation(findWired<WiredIconButton>());
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await pumpWired(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          onPressed: () => pressed = true,
        ),
      );

      await tapWired(tester, findWired<WiredIconButton>());

      expect(pressed, isTrue);
    });

    testWidgets('tracks rapid repeated taps', (tester) async {
      var tapCount = 0;

      await pumpWired(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          onPressed: () => tapCount++,
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tapWired(tester, findWired<WiredIconButton>());
      }

      expect(tapCount, 3);
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        WiredIconButton(
          icon: roughIconFor('settings'),
          onPressed: () {},
          semanticLabel: 'Open settings',
        ),
      );

      expect(findWiredBySemanticsLabel('Open settings'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredIconButton>(),
        label: 'Open settings',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled button ignores taps and reports disabled', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          onPressed: null,
          semanticLabel: 'Disabled',
        ),
      );

      await tapWired(tester, findWired<WiredIconButton>());

      expect(tester.takeException(), isNull);
      expectSemantics(
        tester,
        findWired<WiredIconButton>(),
        isButton: true,
        isEnabled: false,
        hasTapAction: false,
      );
      expectRenders(tester, findWired<WiredIconButton>());
      expectPaints(findWired<WiredIconButton>());
    });

    testWidgets('onPressed defaults to null', (tester) async {
      final addIcon = roughIconFor('add');
      final button = WiredIconButton(icon: addIcon);

      expect(button.onPressed, isNull);
      expect(button.size, 48.0);
      expect(button.iconColor, isNull);
    });

    testWidgets('renders at its default and custom sizes', (tester) async {
      final addIcon = roughIconFor('add');

      await pumpWired(tester, WiredIconButton(icon: addIcon, onPressed: () {}));
      expect(
        tester.getSize(findWired<WiredIconButton>()),
        const Size(48, 48),
      );

      await pumpWired(
        tester,
        WiredIconButton(icon: addIcon, onPressed: () {}, size: 64),
      );
      expect(
        tester.getSize(findWired<WiredIconButton>()),
        const Size(64, 64),
      );
      expectRenders(tester, findWired<WiredIconButton>());
    });

    testWidgets('passes a custom icon color through to the icon', (
      tester,
    ) async {
      const red = Color(0xFFFF0000);

      await pumpWired(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          onPressed: () {},
          iconColor: red,
        ),
      );

      expect(tester.widget<WiredIcon>(findWired<WiredIcon>()).color, red);
    });

    testWidgets('keeps its hit area in RTL', (tester) async {
      var pressed = false;

      await pumpWiredRtl(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          onPressed: () => pressed = true,
        ),
      );

      expectRenders(
        tester,
        findWired<WiredIconButton>(),
        size: const Size(48, 48),
      );
      expectPaints(findWired<WiredIconButton>());
      await tapWired(tester, findWired<WiredIconButton>());
      expect(pressed, isTrue);
    });

    testWidgets('renders and paints under small and zero constraints', (
      tester,
    ) async {
      final addIcon = roughIconFor('add');

      await pumpWired(
        tester,
        WiredIconButton(icon: addIcon, onPressed: () {}),
        surfaceSize: const Size(24, 24),
      );
      expectRenders(tester, findWired<WiredIconButton>());
      expectPaints(findWired<WiredIconButton>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredIconButton(icon: addIcon, onPressed: () {}),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          onPressed: () {},
        ),
      );

      expect(
        tester.getSize(findWired<WiredIconButton>()),
        const Size(48, 48),
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('mirrors Material iconSize and color names', (tester) async {
    await pumpApp(
      tester,
      WiredIconButton(
        icon: roughIconFor('settings'),
        onPressed: null,
        iconSize: 30,
        color: Color(0xFF123456),
      ),
    );

    final wiredIcon = tester.widget<WiredIcon>(find.byType(WiredIcon));
    expect(wiredIcon.size, 30);
    expect(wiredIcon.color, const Color(0xFF123456));
  });

  testWidgets('iconSize defaults to half of size', (tester) async {
    await pumpApp(
      tester,
      WiredIconButton(icon: roughIconFor('settings'), onPressed: null, size: 60),
    );

    expect(tester.widget<WiredIcon>(find.byType(WiredIcon)).size, 30);
  });

  testWidgets('iconColor is used when color is not set', (tester) async {
    await pumpApp(
      tester,
      WiredIconButton(
        icon: roughIconFor('settings'),
        onPressed: null,
        iconColor: Color(0xFF654321),
      ),
    );

    expect(
      tester.widget<WiredIcon>(find.byType(WiredIcon)).color,
      const Color(0xFF654321),
    );
  });
}
