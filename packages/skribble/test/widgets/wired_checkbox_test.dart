import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredCheckbox', () {
    testWidgets('renders without error', (tester) async {
      await pumpWired(
        tester,
        WiredCheckbox(value: false, onChanged: (_) {}),
      );

      expectRenders(tester, findWired<WiredCheckbox>());
      expectPaints(findWired<WiredCheckbox>());
      expectRepaintIsolation(findWired<WiredCheckbox>());
    });

    testWidgets('reports checked state to assistive technology', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredCheckbox(value: true, onChanged: (_) {}),
      );

      expectSemantics(
        tester,
        findWired<WiredCheckbox>(),
        isChecked: true,
        hasTapAction: true,
      );
    });

    testWidgets('reports unchecked state to assistive technology', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredCheckbox(value: false, onChanged: (_) {}),
      );

      expectSemantics(
        tester,
        findWired<WiredCheckbox>(),
        isChecked: false,
        hasTapAction: true,
      );
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredCheckbox(
          value: false,
          onChanged: (_) {},
          semanticLabel: 'Accept terms',
        ),
      );

      expect(findWiredBySemanticsLabel('Accept terms'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredCheckbox>(),
        label: 'Accept terms',
        isChecked: false,
      );
    });

    testWidgets('calls onChanged with the toggled value when tapped', (
      tester,
    ) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredCheckbox(
          value: false,
          onChanged: (value) => receivedValue = value,
        ),
      );

      await tapWired(tester, findWired<WiredCheckbox>());

      expect(receivedValue, isTrue);
    });

    testWidgets('toggles back to false from a checked state', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredCheckbox(value: true, onChanged: (value) => receivedValue = value),
      );

      await tapWired(tester, findWired<WiredCheckbox>());

      expect(receivedValue, isFalse);
    });

    testWidgets('activates through the semantics tap action', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredCheckbox(
          value: false,
          onChanged: (value) => receivedValue = value,
        ),
      );

      await semanticTapWired(tester, findWired<WiredCheckbox>());

      expect(receivedValue, isTrue);
      expectSemantics(
        tester,
        findWired<WiredCheckbox>(),
        isChecked: true,
        reason: 'The semantics tap must move the widget to checked.',
      );
    });

    testWidgets('follows an external value change', (tester) async {
      await pumpWired(
        tester,
        WiredCheckbox(value: false, onChanged: (_) {}),
      );
      expectSemantics(tester, findWired<WiredCheckbox>(), isChecked: false);

      await pumpWired(
        tester,
        WiredCheckbox(value: true, onChanged: (_) {}),
      );
      expectSemantics(tester, findWired<WiredCheckbox>(), isChecked: true);
    });

    testWidgets('lays out and paints in RTL', (tester) async {
      bool? receivedValue;

      await pumpWiredRtl(
        tester,
        WiredCheckbox(
          value: false,
          onChanged: (value) => receivedValue = value,
        ),
      );

      expectRenders(tester, findWired<WiredCheckbox>());
      expectPaints(findWired<WiredCheckbox>());
      await tapWired(tester, findWired<WiredCheckbox>());
      expect(receivedValue, isTrue);
    });

    testWidgets('keeps a tappable size under small and zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredCheckbox(value: false, onChanged: (_) {}),
        surfaceSize: const Size(27, 27),
      );
      expectRenders(tester, findWired<WiredCheckbox>());
      expectPaints(findWired<WiredCheckbox>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredCheckbox(value: false, onChanged: (_) {}),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredCheckbox(value: true, onChanged: (_) {}),
      );

      expectSemantics(tester, findWired<WiredCheckbox>(), isChecked: true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with a custom border radius', (tester) async {
      await pumpWired(
        tester,
        WiredCheckbox(
          value: false,
          onChanged: (_) {},
          borderRadius: BorderRadius.zero,
        ),
      );

      expectRenders(tester, findWired<WiredCheckbox>());
      expectPaints(findWired<WiredCheckbox>());
    });

    testWidgets('picks up the surrounding theme', (tester) async {
      await pumpWired(
        tester,
        WiredCheckbox(value: true, onChanged: (_) {}),
        theme: WiredThemeData(borderColor: const Color(0xFF00FF00)),
      );

      expectPaints(findWired<WiredCheckbox>());
      expectSemantics(tester, findWired<WiredCheckbox>(), isChecked: true);
    });
  });

  testWidgets('is disabled when onChanged is null', (tester) async {
    await pumpApp(tester, const WiredCheckbox(value: false));

    expectSemantics(tester, findWired<WiredCheckbox>(), isEnabled: false);
  });

  testWidgets('ignores taps when disabled', (tester) async {
    await pumpApp(tester, const WiredCheckbox(value: false));

    await tester.tap(findWired<WiredCheckbox>(), warnIfMissed: false);
    await tester.pump();

    // Still unchecked, and still announced as disabled.
    expectSemantics(tester, findWired<WiredCheckbox>(), isEnabled: false, isChecked: false);
  });
}
