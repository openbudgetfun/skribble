import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredRangeSlider', () {
    testWidgets('renders and paints', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(start: 0.2, end: 0.8),
      );

      expectRenders(tester, findWired<WiredRangeSlider>());
      expectPaints(findWired<WiredRangeSlider>());
    });

    testWidgets('exposes a slider role with the current range', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(
          start: 0.2,
          end: 0.8,
          onChanged: (start, end) => true,
        ),
      );

      expectSemantics(tester, findWired<WiredRangeSlider>(), isSlider: true);
      expect(
        semanticsOf(tester, findWired<WiredRangeSlider>()).value,
        '0.2 to 0.8',
      );
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(
          start: 0.2,
          end: 0.8,
          semanticLabel: 'Price range',
        ),
      );

      expect(findWiredBySemanticsLabel('Price range'), findsOneWidget);
      expectSemantics(
        tester,
        findWired<WiredRangeSlider>(),
        label: 'Price range',
      );
    });

    testWidgets('reports disabled when there is no callback', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(start: 0.2, end: 0.8),
      );

      expectSemantics(
        tester,
        findWired<WiredRangeSlider>(),
        isSlider: true,
        isEnabled: false,
      );
    });

    for (final accept in [true, false]) {
      testWidgets('drag reports endpoints and respects acceptance: $accept', (
        tester,
      ) async {
        (double, double)? reported;

        await pumpWired(
          tester,
          WiredRangeSlider.between(
            start: .2,
            end: .8,
            onChanged: (start, end) {
              reported = (start, end);
              return accept;
            },
          ),
        );

        await dragWired(
          tester,
          findWired<WiredRangeSlider>(),
          const Offset(80, 0),
        );

        expect(reported, isNotNull);

        final value = semanticsOf(
          tester,
          findWired<WiredRangeSlider>(),
        ).value;
        if (accept) {
          expect(
            value,
            '${reported!.$1.toStringAsFixed(1)} to '
            '${reported!.$2.toStringAsFixed(1)}',
            reason: 'An accepted drag must move the reported endpoints.',
          );
        } else {
          expect(
            value,
            '0.2 to 0.8',
            reason: 'A rejected drag must keep the previous endpoints.',
          );
        }
      });
    }

    testWidgets('follows external endpoint changes', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(start: .2, end: .8),
      );
      expect(
        semanticsOf(tester, findWired<WiredRangeSlider>()).value,
        '0.2 to 0.8',
      );

      await pumpWired(
        tester,
        WiredRangeSlider.between(start: .4, end: .6),
      );

      expect(
        semanticsOf(tester, findWired<WiredRangeSlider>()).value,
        '0.4 to 0.6',
      );
      expectPaints(findWired<WiredRangeSlider>());
    });

    testWidgets('honours custom min, max, and divisions', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(
          start: 20,
          end: 80,
          min: 10,
          max: 100,
          divisions: 5,
          onChanged: (start, end) => true,
        ),
      );

      expect(
        semanticsOf(tester, findWired<WiredRangeSlider>()).value,
        '20.0 to 80.0',
      );
      expectRenders(tester, findWired<WiredRangeSlider>());
      expectPaints(findWired<WiredRangeSlider>());
    });

    testWidgets('lays out and paints in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredRangeSlider.between(
          start: 0.2,
          end: 0.8,
          onChanged: (start, end) => true,
        ),
      );

      expectRenders(tester, findWired<WiredRangeSlider>());
      expectPaints(findWired<WiredRangeSlider>());
      expectSemantics(tester, findWired<WiredRangeSlider>(), isSlider: true);
    });

    testWidgets('renders under small and zero constraints', (tester) async {
      await pumpWired(
        tester,
        WiredRangeSlider.between(start: 0.2, end: 0.8),
        surfaceSize: const Size(60, 24),
      );
      expectRenders(tester, findWired<WiredRangeSlider>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredRangeSlider.between(start: 0.2, end: 0.8),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredRangeSlider.between(
          start: 0.2,
          end: 0.8,
          onChanged: (start, end) => true,
        ),
      );

      expectSemantics(tester, findWired<WiredRangeSlider>(), isSlider: true);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('can be disabled by omitting onChanged', (tester) async {
    await pumpApp(tester, WiredRangeSlider.between(start: 0.2, end: 0.8));

    expectSemantics(tester, findWired<WiredRangeSlider>(), isEnabled: false);
  });
}
