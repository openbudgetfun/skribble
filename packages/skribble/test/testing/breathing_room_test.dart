import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';

import '../helpers/pump_app.dart';

RenderObject _root(WidgetTester tester) => tester.binding.renderViews.first;

/// A rough box exactly [height] tall around [text].
Widget _box(String text, {required double height, double fontSize = 14}) =>
    Builder(
      builder: (context) => Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: RoughBoxDecoration(
          drawConfig: WiredTheme.of(context).drawConfig,
          borderStyle: const RoughDrawingStyle(width: 2),
        ),
        child: Text(text, style: TextStyle(fontSize: fontSize)),
      ),
    );

void main() {
  group('crampedText', () {
    testWidgets('passes a control that keeps the ink padding', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredButton(onPressed: () {}, child: const Text('Go')),
        ),
      );
      expect(crampedText(_root(tester)), isEmpty);
    });

    testWidgets('measures a face against itself, not the shadow under it', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Center(
          child: WiredElevatedButton(
            onPressed: () {},
            child: const Text('Elevated'),
          ),
        ),
      );
      // An impossible minimum reports every gap; the face centres its label,
      // while the shadow, drawn 2 pixels down and right, would not.
      final gaps = crampedText(_root(tester), vertical: 100).single.gaps;
      expect(gaps.top, closeTo(gaps.bottom, 1));
      expect(gaps.left, closeTo(gaps.right, 1));
    });

    testWidgets('finds text that crowds its line', (tester) async {
      await pumpApp(
        tester,
        Center(child: _box('Hi', height: 30, fontSize: 22)),
      );
      final cramped = crampedText(_root(tester));
      expect(cramped, hasLength(1));
      expect(cramped.single.text, 'Hi');
      expect(cramped.single.gaps.top, lessThan(kWiredInkPadding.top));
      expect(cramped.single.toString(), contains('"Hi"'));
    });

    testWidgets('accepts looser or stricter minimums', (tester) async {
      await pumpApp(
        tester,
        Center(child: _box('Hi', height: 30, fontSize: 22)),
      );
      expect(crampedText(_root(tester), vertical: 0), isEmpty);
      expect(crampedText(_root(tester), horizontal: 40), isNotEmpty);
    });

    testWidgets('measures text inside drawn rectangles, pills, and circles', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WiredCard(
                height: null,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('A roomy card'),
                ),
              ),
              WiredChoiceChip(label: Text('A chip')),
              WiredAvatar(radius: 28, child: Text('AB')),
            ],
          ),
        ),
      );
      expect(crampedText(_root(tester)), isEmpty);

      await pumpApp(
        tester,
        const Center(
          // A card keeps its padding and grows to fit, so take the padding
          // away to put the text against the ink.
          child: WiredCard(
            height: null,
            padding: EdgeInsets.zero,
            child: Text('Squeezed', style: TextStyle(fontSize: 24)),
          ),
        ),
      );
      expect(
        crampedText(_root(tester)).map((cramped) => cramped.text),
        ['Squeezed'],
      );
    });

    testWidgets('measures text against the nearest shape around it', (
      tester,
    ) async {
      // A roomy chip inside a card: the chip's own ink is what counts.
      await pumpApp(
        tester,
        const Center(
          child: WiredCard(
            height: null,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: WiredChoiceChip(label: Text('Nested')),
            ),
          ),
        ),
      );
      expect(crampedText(_root(tester)), isEmpty);
    });

    testWidgets('ignores text scrolled out of view', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: SizedBox(
            height: 60,
            child: ListView(
              children: [
                _box('Shown', height: 50),
                // Laid out in the cache below the viewport, never seen.
                _box('Hidden', height: 20, fontSize: 18),
              ],
            ),
          ),
        ),
      );
      expect(
        crampedText(_root(tester)).map((cramped) => cramped.text),
        isNot(contains('Hidden')),
      );
    });

    testWidgets('judges scaled-down content by its proportions', (
      tester,
    ) async {
      await pumpApp(
        tester,
        Center(
          child: Transform.scale(
            scale: .5,
            child: WiredButton(onPressed: () {}, child: const Text('Go')),
          ),
        ),
      );
      expect(crampedText(_root(tester)), isEmpty);
    });
  });

  group('crampedText lines', () {
    Widget struck({required double y}) => Center(
      child: SizedBox(
        width: 160,
        height: 40,
        child: Stack(
          children: [
            const Positioned(
              left: 20,
              top: 10,
              child: Text('Struck', style: TextStyle(fontSize: 16)),
            ),
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredLineBase(x1: 0, y1: y, x2: 160, y2: y),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ],
        ),
      ),
    );

    testWidgets('reports a line through text only when asked', (
      tester,
    ) async {
      await pumpApp(tester, struck(y: 20));
      expect(crampedText(_root(tester)), isEmpty);

      final hits = crampedText(_root(tester), lines: true);
      expect(hits, hasLength(1));
      expect(hits.single.ink, CrampedInk.line);
      expect(hits.single.text, 'Struck');
      expect(hits.single.toString(), contains('a line crosses "Struck"'));
    });

    testWidgets('passes a line that clears the text', (tester) async {
      await pumpApp(tester, struck(y: 39));
      expect(crampedText(_root(tester), lines: true), isEmpty);
    });
  });

  group('crampedText icons', () {
    Widget button(double iconSize) => Center(
      child: WiredIconButton(
        icon: Icons.home,
        iconSize: iconSize,
        onPressed: () {},
      ),
    );

    testWidgets('passes an icon with room inside its circle', (tester) async {
      await pumpApp(tester, button(24));
      expect(crampedText(_root(tester), icons: true), isEmpty);
    });

    testWidgets('reports an icon crowding its circle only when asked', (
      tester,
    ) async {
      await pumpApp(tester, button(44));
      expect(crampedText(_root(tester)), isEmpty);

      final hits = crampedText(_root(tester), icons: true);
      expect(hits, hasLength(1));
      expect(hits.single.ink, CrampedInk.icon);
      expect(hits.single.gaps.top, lessThan(4));
      expect(hits.single.toString(), contains('icon in 48×48'));
    });
  });

  group('crampedText clipped icons', () {
    testWidgets('ignores the side of a shape scrolled out of view', (
      tester,
    ) async {
      final controller = ScrollController(initialScrollOffset: 30);
      addTearDown(controller.dispose);
      await pumpApp(
        tester,
        Center(
          child: SizedBox(
            height: 120,
            child: ListView(
              controller: controller,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: WiredButton(
                    onPressed: () {},
                    child: const WiredIcon(icon: Icons.home),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      );

      // The button's top 20 pixels are scrolled above the viewport, so its
      // icon pokes past the visible edge of the outline. That side is cut,
      // not crowded.
      expect(crampedText(_root(tester), icons: true), isEmpty);
    });
  });

  group('squeezedText', () {
    testWidgets('finds a paragraph squeezed into a narrow column', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const Center(
          child: SizedBox(
            width: 80,
            child: Text('Your account is about to expire very soon.'),
          ),
        ),
      );
      expect(squeezedText(_root(tester)), hasLength(1));
    });

    testWidgets('passes a paragraph with room to read', (tester) async {
      await pumpApp(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: Text('Your account is about to expire very soon.'),
          ),
        ),
      );
      expect(squeezedText(_root(tester)), isEmpty);
    });
  });
}
