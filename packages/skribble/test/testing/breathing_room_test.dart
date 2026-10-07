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
