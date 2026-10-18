import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

const _ink = Color(0xFF1A2B3C);
const _side = BorderSide(color: _ink, width: 2);

Widget _shaped(ShapeBorder shape, {Color? fill}) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: fill),
      child: const SizedBox(width: 120, height: 60),
    ),
  ),
);

void main() {
  group('RoughOutlinedBorder', () {
    testWidgets('inks the side as a rough outline', (tester) async {
      await tester.pumpWidget(
        _shaped(const RoughOutlinedBorder(side: _side, seed: 3)),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.renderObject(find.byType(DecoratedBox)),
        paints..path(color: _ink),
      );
    });

    testWidgets('paints nothing for a side with no style', (tester) async {
      await tester.pumpWidget(_shaped(const RoughOutlinedBorder()));

      expect(
        tester.renderObject(find.byType(DecoratedBox)),
        isNot(paints..path(color: _ink)),
      );
    });

    testWidgets('fills inside the outline', (tester) async {
      const fill = Color(0xFFFFE066);
      await tester.pumpWidget(
        _shaped(const RoughOutlinedBorder(side: _side), fill: fill),
      );

      expect(
        tester.renderObject(find.byType(DecoratedBox)),
        paints
          ..path(color: fill)
          ..path(color: _ink),
      );
    });

    test('draws the same wobble on every repaint', () {
      List<Rect> inkedBounds(ShapeBorder border) {
        final canvas = TestRecordingCanvas();
        border.paint(canvas, const Rect.fromLTWH(0, 0, 120, 60));
        return [
          for (final call in canvas.invocations)
            if (call.invocation.memberName == #drawPath)
              (call.invocation.positionalArguments.first as Path).getBounds(),
        ];
      }

      const border = RoughOutlinedBorder(side: _side, seed: 5);
      final first = inkedBounds(border);

      expect(first, isNotEmpty);
      expect(inkedBounds(border), first);
      expect(inkedBounds(border.copyWith()), first);
      expect(inkedBounds(border.copyWith(seed: 6)), isNot(first));
    });

    testWidgets('works as the shape of Material controls', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            cardTheme: const CardThemeData(
              shape: RoughOutlinedBorder(side: _side, seed: 7),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: const RoughOutlinedBorder(seed: 9),
                side: _side,
              ),
            ),
          ),
          home: Scaffold(
            body: Column(
              children: [
                const Card(child: SizedBox(width: 200, height: 80)),
                ElevatedButton(
                  onPressed: () => taps++,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });

    test('outer path stops at the centre of the pen line', () {
      const border = RoughOutlinedBorder(side: _side);
      const rect = Rect.fromLTWH(0, 0, 100, 60);
      final bounds = border.getOuterPath(rect).getBounds();
      final inset = const RoughBoxDecoration(
        borderStyle: RoughDrawingStyle(width: 2),
      ).inkInset;

      expect(bounds.left, closeTo(inset, 0.01));
      expect(bounds.right, closeTo(100 - inset, 0.01));
      expect(
        border.getInnerPath(rect).getBounds().left,
        greaterThan(bounds.left),
      );
    });

    test('a borderless side keeps the full box', () {
      const rect = Rect.fromLTWH(0, 0, 100, 60);
      expect(const RoughOutlinedBorder().getOuterPath(rect).getBounds(), rect);
    });

    test('never inverts a box smaller than the inset', () {
      const border = RoughOutlinedBorder(
        side: BorderSide(color: _ink, width: 8),
      );
      final bounds = border
          .getOuterPath(const Rect.fromLTWH(0, 0, 4, 4))
          .getBounds();
      expect(bounds.width, greaterThanOrEqualTo(0));
    });

    test('equal values are equal', () {
      const a = RoughOutlinedBorder(side: _side, seed: 2);
      const b = RoughOutlinedBorder(side: _side, seed: 2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const RoughOutlinedBorder(side: _side, seed: 3)));
      expect(
        a,
        isNot(
          const RoughOutlinedBorder(
            side: _side,
            seed: 2,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
      );
    });

    test('copyWith keeps unspecified values', () {
      const border = RoughOutlinedBorder(
        side: _side,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        seed: 4,
      );
      final copy = border.copyWith(side: BorderSide.none);
      expect(copy.side, BorderSide.none);
      expect(copy.borderRadius, border.borderRadius);
      expect(copy.seed, 4);
    });

    test('scale scales the pen and corners', () {
      const border = RoughOutlinedBorder(
        side: _side,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      );
      final scaled = border.scale(2) as RoughOutlinedBorder;
      expect(scaled.side.width, 4);
      expect(scaled.borderRadius, const BorderRadius.all(Radius.circular(20)));
    });

    test('lerps between rough borders and switches seed at the midpoint', () {
      const a = RoughOutlinedBorder(
        side: BorderSide(color: Color(0xFF000000), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        seed: 1,
      );
      const b = RoughOutlinedBorder(
        side: BorderSide(color: Color(0xFF000000), width: 4),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        seed: 2,
      );
      final early = ShapeBorder.lerp(a, b, 0.25)! as RoughOutlinedBorder;
      final mid = ShapeBorder.lerp(a, b, 0.5)! as RoughOutlinedBorder;
      expect(early.seed, 1);
      expect(mid.seed, 2);
      expect(mid.side.width, 3);
      expect(mid.borderRadius, const BorderRadius.all(Radius.circular(8)));
    });

    test('lerps with other borders without throwing', () {
      const rough = RoughOutlinedBorder(side: _side);
      const plain = RoundedRectangleBorder(side: _side);
      expect(ShapeBorder.lerp(rough, plain, 0.5), isNotNull);
      expect(ShapeBorder.lerp(plain, rough, 0.5), isNotNull);
    });
  });
}
