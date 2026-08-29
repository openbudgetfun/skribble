import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';

WiredMaterialSlice _slice(String label, {Color? color}) {
  return WiredMaterialSlice(
    color: color,
    key: ValueKey(label),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(label),
    ),
  );
}

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('WiredMergeableMaterial', () {
    testWidgets('renders without error', (tester) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(children: [_slice('One')]),
      );

      expect(find.byType(WiredMergeableMaterial), findsOneWidget);
    });

    testWidgets('renders slice content', (tester) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(
          children: [_slice('First'), _slice('Second')],
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('renders with no children', (tester) async {
      await pumpHost(tester, const WiredMergeableMaterial(children: []));

      expect(find.byType(WiredMergeableMaterial), findsOneWidget);
      expect(find.byType(WiredMaterialSlice), findsNothing);
    });

    testWidgets('draws hand-drawn borders around slices', (tester) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(children: [_slice('Only')]),
      );

      expect(findWiredCanvas, findsWidgets);
      expect(findRepaintBoundary, findsWidgets);
    });

    testWidgets('positive gaps separate slices into cards', (tester) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(
          children: [
            _slice('A'),
            const WiredMaterialGap(key: ValueKey('gap'), size: 16),
            _slice('B'),
          ],
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      // Two cards, each painted by its own WiredCanvas.
      expect(findWiredCanvas, findsNWidgets(2));
    });

    testWidgets('zero-size gaps merge neighboring slices into one card', (
      tester,
    ) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(
          hasDividers: true,
          children: [
            _slice('Left'),
            const WiredMaterialGap(key: ValueKey('gap'), size: 0),
            _slice('Right'),
          ],
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      // One card canvas + one divider canvas between the slices.
      expect(findWiredCanvas, findsNWidgets(2));
      final linePainters = tester
          .widgetList<WiredCanvas>(findWiredCanvas)
          .map((canvas) => canvas.painter)
          .whereType<WiredLineBase>()
          .toList();
      expect(linePainters, hasLength(1));
    });

    testWidgets(
      'hasDividers=false draws only the card border for merged slices',
      (tester) async {
        await pumpHost(
          tester,
          WiredMergeableMaterial(
            hasDividers: false,
            children: [
              _slice('Top'),
              const WiredMaterialGap(key: ValueKey('gap'), size: 0),
              _slice('Bottom'),
            ],
          ),
        );

        // Only the card border painter remains (no divider lines).
        expect(findWiredCanvas, findsOneWidget);
      },
    );

    testWidgets('dividerColor is applied to divider lines', (tester) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(
          hasDividers: true,
          dividerColor: Colors.lime,
          children: [
            _slice('Top'),
            const WiredMaterialGap(key: ValueKey('gap'), size: 0),
            _slice('Bottom'),
          ],
        ),
      );

      final linePainters = tester
          .widgetList<WiredCanvas>(findWiredCanvas)
          .map((canvas) => canvas.painter)
          .whereType<WiredLineBase>()
          .toList();
      expect(linePainters, hasLength(1));
      expect(linePainters.first.borderColor, Colors.lime);
    });

    testWidgets('slice color overrides card fill', (tester) async {
      await pumpHost(
        tester,
        WiredMergeableMaterial(
          children: [_slice('Tinted', color: Colors.teal)],
        ),
      );

      expect(find.text('Tinted'), findsOneWidget);
    });

    testWidgets('gap size changes are animated', (tester) async {
      WiredMergeableMaterial buildMaterial(double gapSize) {
        return WiredMergeableMaterial(
          animationDuration: const Duration(milliseconds: 300),
          children: [
            WiredMaterialSlice(
              key: const ValueKey('a'),
              child: const SizedBox(height: 100),
            ),
            WiredMaterialGap(
              key: const ValueKey('gap'),
              size: gapSize,
            ),
            WiredMaterialSlice(
              key: const ValueKey('b'),
              child: const SizedBox(height: 100),
            ),
          ],
        );
      }

      await pumpHost(tester, buildMaterial(16));
      await tester.pumpAndSettle();

      final initialHeight = tester
          .getSize(find.byType(WiredMergeableMaterial))
          .height;
      expect(initialHeight, moreOrLessEquals(216));

      // Rebuild with a larger gap; mid-animation the height is between the
      // old and new values (the growth animates).
      await pumpHost(tester, buildMaterial(80));
      await tester.pump(const Duration(milliseconds: 100));
      final midHeight = tester
          .getSize(find.byType(WiredMergeableMaterial))
          .height;
      expect(midHeight, inExclusiveRange(initialHeight, 280));

      await tester.pumpAndSettle();
      final expandedHeight = tester
          .getSize(find.byType(WiredMergeableMaterial))
          .height;
      expect(expandedHeight, moreOrLessEquals(280));

      // Collapsing the gap to 0 merges the slices into one card of exactly
      // the two slice rows (no gap left over).
      await pumpHost(tester, buildMaterial(0));
      await tester.pumpAndSettle();
      final collapsedHeight = tester
          .getSize(find.byType(WiredMergeableMaterial))
          .height;
      expect(collapsedHeight, moreOrLessEquals(200));
    });

    testWidgets('rapidly toggling gap changes does not throw', (tester) async {
      await pumpHost(
        tester,
        const WiredMergeableMaterial(
          children: [
            WiredMaterialSlice(
              key: ValueKey('s'),
              child: SizedBox(height: 50),
            ),
            WiredMaterialGap(key: ValueKey('gap'), size: 0),
            WiredMaterialSlice(
              key: ValueKey('s2'),
              child: SizedBox(height: 50),
            ),
          ],
        ),
      );

      // Toggle the gap size on every rebuild, never settling, to shake out
      // animation state bugs.
      for (var i = 1; i <= 6; i++) {
        await pumpHost(
          tester,
          WiredMergeableMaterial(
            children: [
              const WiredMaterialSlice(
                key: ValueKey('s'),
                child: SizedBox(height: 50),
              ),
              WiredMaterialGap(
                key: const ValueKey('gap'),
                size: i.isEven ? 32.0 : 0.0,
              ),
              const WiredMaterialSlice(
                key: ValueKey('s2'),
                child: SizedBox(height: 50),
              ),
            ],
          ),
        );
        await tester.pump(const Duration(milliseconds: 30));
      }
      await tester.pumpAndSettle();
    });
  });
}
