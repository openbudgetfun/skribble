import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

const _ink = Color(0xFF1A2B3C);
const _side = BorderSide(color: _ink, width: 2);
const _fieldKey = Key('field');

Widget _field({
  InputBorder border = const RoughInputBorder(borderSide: _side, seed: 11),
  String? label,
  ValueChanged<String>? onChanged,
}) => MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        key: _fieldKey,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: border,
          enabledBorder: border,
        ),
      ),
    ),
  ),
);

void main() {
  group('RoughInputBorder', () {
    testWidgets('outlines a text field', (tester) async {
      await tester.pumpWidget(_field());

      expect(tester.takeException(), isNull);
      expect(
        tester.renderObject(find.byKey(_fieldKey)),
        paints..path(color: _ink),
      );
    });

    testWidgets('accepts typing and calls onChanged', (tester) async {
      String? value;
      await tester.pumpWidget(_field(onChanged: (text) => value = text));

      await tester.enterText(find.byKey(_fieldKey), 'hello');
      await tester.pump();
      expect(value, 'hello');
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('floats the label inside the field', (tester) async {
      await tester.pumpWidget(_field(label: 'Email'));
      await tester.tap(find.byKey(_fieldKey));
      await tester.pumpAndSettle();

      final field = tester.getRect(find.byKey(_fieldKey));
      final label = tester.getRect(find.text('Email'));
      expect(label.top, greaterThanOrEqualTo(field.top));
      expect(tester.takeException(), isNull);
    });

    testWidgets('works from an InputDecorationTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              border: RoughInputBorder(borderSide: _side),
              enabledBorder: RoughInputBorder(borderSide: _side),
              focusedBorder: RoughInputBorder(
                borderSide: BorderSide(color: _ink, width: 3),
              ),
            ),
          ),
          home: const Scaffold(body: TextField(key: _fieldKey)),
        ),
      );
      await tester.tap(find.byKey(_fieldKey));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.renderObject(find.byKey(_fieldKey)),
        paints..path(color: _ink),
      );
    });

    test('is not an outline border', () {
      expect(const RoughInputBorder().isOutline, isFalse);
    });

    test('outer path stops at the centre of the pen line', () {
      const border = RoughInputBorder(borderSide: _side);
      const rect = Rect.fromLTWH(0, 0, 200, 56);
      final bounds = border.getOuterPath(rect).getBounds();
      expect(bounds.left, greaterThan(1));
      expect(bounds.right, lessThan(199));
    });

    test('equality, copyWith, and scale', () {
      const a = RoughInputBorder(borderSide: _side, seed: 2);
      expect(a, const RoughInputBorder(borderSide: _side, seed: 2));
      expect(
        a.hashCode,
        const RoughInputBorder(borderSide: _side, seed: 2).hashCode,
      );
      expect(a, isNot(const RoughInputBorder(borderSide: _side, seed: 3)));

      final copy = a.copyWith(borderSide: BorderSide.none);
      expect(copy.borderSide, BorderSide.none);
      expect(copy.seed, 2);

      final scaled = a.scale(2) as RoughInputBorder;
      expect(scaled.borderSide.width, 4);
      expect(
        scaled.borderRadius,
        const BorderRadius.all(Radius.circular(32)),
      );
    });

    test('lerps between rough input borders', () {
      const a = RoughInputBorder(
        borderSide: BorderSide(color: _ink, width: 2),
        seed: 1,
      );
      const b = RoughInputBorder(
        borderSide: BorderSide(color: _ink, width: 4),
        seed: 2,
      );
      final mid = ShapeBorder.lerp(a, b, 0.5)! as RoughInputBorder;
      expect(mid.borderSide.width, 3);
      expect(mid.seed, 2);
      expect(
        (ShapeBorder.lerp(a, b, 0.25)! as RoughInputBorder).seed,
        1,
      );
    });
  });
}
