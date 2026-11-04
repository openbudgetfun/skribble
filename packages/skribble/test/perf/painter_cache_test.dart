import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';

import '../helpers/skribble_test_support.dart';

/// Performance regression gates for the rough geometry cache.
///
/// Every test counts how often the rough pipeline actually runs, through
/// [RoughGenerationCounter]. A rebuild that re-runs geometry generation for
/// unchanged, equal-valued inputs is a caching regression that turns every
/// parent rebuild into generator + filler + ink-sampling work.
void main() {
  group('WiredCanvas geometry caching', () {
    testWidgets(
      'an ancestor rebuild with an equal inline painter reuses geometry',
      (tester) async {
        RoughGenerationCounter.reset();
        await pumpWired(
          tester,
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: WiredCanvas(
                painter: WiredRectangleBase(fillColor: Colors.amber),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        );
        expect(RoughGenerationCounter.generations, 1);

        // A parent rebuilding with a fresh but equal-valued painter instance is
        // the common case: widgets construct painters inline in build.
        await pumpWired(
          tester,
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: WiredCanvas(
                painter: WiredRectangleBase(fillColor: Colors.amber),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        );
        expect(
          RoughGenerationCounter.generations,
          1,
          reason: 'an equal-valued painter must not regenerate geometry',
        );

        // A changed value really does redraw.
        await pumpWired(
          tester,
          Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: WiredCanvas(
                painter: WiredRectangleBase(fillColor: Colors.blue),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        );
        expect(RoughGenerationCounter.generations, 2);
      },
    );

    testWidgets('equal painters compare equal across every shape kind', (
      tester,
    ) async {
      const rectangle = WiredRectangleBase(leftIndent: 2, strokeWidth: 3);
      const rectangleAgain = WiredRectangleBase(leftIndent: 2, strokeWidth: 3);
      const line = WiredLineBase(x1: 0, y1: 0, x2: 10, y2: 10);
      const circle = WiredCircleBase(diameterRatio: 0.7);
      const rounded = WiredRoundedRectangleBase();
      const triangle = WiredInvertedTriangleBase();
      const roundedOther = WiredRoundedRectangleBase(
        borderRadius: BorderRadius.zero,
      );

      expect(rectangle, rectangleAgain);
      expect(rectangle.hashCode, rectangleAgain.hashCode);
      expect(rectangle, isNot(const WiredRectangleBase(leftIndent: 3)));

      expect(line, const WiredLineBase(x1: 0, y1: 0, x2: 10, y2: 10));
      expect(
        line.hashCode,
        const WiredLineBase(x1: 0, y1: 0, x2: 10, y2: 10).hashCode,
      );
      expect(line, isNot(const WiredLineBase(x1: 0, y1: 0, x2: 11, y2: 10)));

      expect(circle, const WiredCircleBase(diameterRatio: 0.7));
      expect(
        circle.hashCode,
        const WiredCircleBase(diameterRatio: 0.7).hashCode,
      );
      expect(circle, isNot(const WiredCircleBase(diameterRatio: 0.6)));

      expect(rounded, const WiredRoundedRectangleBase());
      expect(rounded.hashCode, const WiredRoundedRectangleBase().hashCode);
      expect(rounded, isNot(roundedOther));

      expect(triangle, const WiredInvertedTriangleBase());
      expect(triangle.hashCode, const WiredInvertedTriangleBase().hashCode);
      expect(triangle, isNot(const WiredInvertedTriangleBase(strokeWidth: 4)));

      // Different kinds never compare equal, whatever their fields.
      expect(rounded, isNot(const WiredRectangleBase()));
      expect(circle, isNot(rectangle));
    });

    testWidgets(
      'a stable seed redraws nothing on rebuild, and different seeds vary the hand',
      (tester) async {
        RoughGenerationCounter.reset();
        Widget card(int? seed) => Center(
          child: SizedBox(
            width: 200,
            height: 100,
            child: WiredCard(seed: seed, child: const SizedBox()),
          ),
        );

        await pumpWired(tester, card(7));
        final firstGeneration = RoughGenerationCounter.generations;
        expect(firstGeneration, greaterThan(0));

        await pumpWired(tester, card(7));
        expect(
          RoughGenerationCounter.generations,
          firstGeneration,
          reason: 'the same seed must keep its prepared geometry',
        );

        await pumpWired(tester, card(9));
        expect(
          RoughGenerationCounter.generations,
          greaterThan(firstGeneration),
          reason: 'a new seed must redraw the shape',
        );
      },
    );
  });

  group('doodles and the logo', () {
    testWidgets('an ancestor rebuild redraws no doodle or logo geometry', (
      tester,
    ) async {
      // Fresh, equal-valued widgets each pump, as a parent's build makes.
      // ignore: prefer_const_constructors
      Widget page() => Center(
        // ignore: prefer_const_constructors
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: prefer_const_constructors
            WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 3),
            // ignore: prefer_const_constructors
            WiredDoodle(
              kind: WiredDoodleKind.heart,
              fillColor: const Color(0xFFF6DFD5),
            ),
            // ignore: prefer_const_constructors
            WiredLogo(),
          ],
        ),
      );
      RoughGenerationCounter.reset();
      await pumpWired(tester, page());
      final settled = RoughGenerationCounter.generations;
      expect(settled, greaterThan(0));

      await pumpWired(tester, page());
      await pumpWired(tester, page());
      expect(
        RoughGenerationCounter.generations,
        settled,
        reason: 'an unchanged doodle must keep its prepared ink',
      );

      await pumpWired(
        tester,
        const Center(
          child: WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 4),
        ),
      );
      expect(
        RoughGenerationCounter.generations,
        greaterThan(settled),
        reason: 'a new seed must redraw the doodle',
      );
    });
  });

  group('WiredToggle animation', () {
    testWidgets('the thumb travel regenerates no rough geometry', (
      tester,
    ) async {
      RoughGenerationCounter.reset();
      await pumpWired(tester, WiredToggle(value: false, onChanged: (v) {}));

      // Track and thumb are each prepared once.
      final settled = RoughGenerationCounter.generations;
      expect(settled, 2);

      await tapWired(tester, findWired<WiredToggle>());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));
      await tester.pumpAndSettle();

      expect(
        RoughGenerationCounter.generations,
        settled,
        reason:
            'the 250 ms thumb travel must reposition painted geometry, '
            'not regenerate it every frame',
      );
    });
  });
}
