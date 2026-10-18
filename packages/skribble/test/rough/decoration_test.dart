import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/rough/decoration.dart';

void main() {
  group('RoughDrawingStyle', () {
    test('stores width and color', () {
      const style = RoughDrawingStyle(width: 3, color: Colors.red);
      expect(style.width, 3);
      expect(style.color, Colors.red);
      expect(style.gradient, isNull);
      expect(style.blendMode, isNull);
    });

    test('stores gradient', () {
      const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
      const style = RoughDrawingStyle(gradient: gradient);
      expect(style.gradient, isNotNull);
    });

    test('stores blendMode', () {
      const style = RoughDrawingStyle(blendMode: BlendMode.multiply);
      expect(style.blendMode, BlendMode.multiply);
    });

    test('defaults all properties to null', () {
      const style = RoughDrawingStyle();
      expect(style.width, isNull);
      expect(style.color, isNull);
      expect(style.gradient, isNull);
      expect(style.blendMode, isNull);
    });
  });

  group('RoughBoxShape', () {
    test('has exactly 4 values', () {
      expect(RoughBoxShape.values.length, 4);
    });

    test('contains all expected shapes', () {
      expect(RoughBoxShape.values, contains(RoughBoxShape.rectangle));
      expect(RoughBoxShape.values, contains(RoughBoxShape.roundedRectangle));
      expect(RoughBoxShape.values, contains(RoughBoxShape.circle));
      expect(RoughBoxShape.values, contains(RoughBoxShape.ellipse));
    });
  });

  group('RoughBoxDecoration', () {
    group('createBoxPainter()', () {
      test('creates RoughDecorationPainter', () {
        const RoughBoxDecoration decoration = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
        );

        final BoxPainter painter = decoration.createBoxPainter();

        expect(painter, isA<RoughDecorationPainter>());
      });

      test('creates painter with callback', () {
        const RoughBoxDecoration decoration = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 1, color: Colors.red),
        );

        var callbackInvoked = false;
        final BoxPainter painter = decoration.createBoxPainter(() {
          callbackInvoked = true;
        });

        expect(painter, isA<RoughDecorationPainter>());
        // Callback is stored but not invoked at creation time.
        expect(callbackInvoked, isFalse);
      });
    });

    group('padding', () {
      test('is derived from border width', () {
        const RoughBoxDecoration decoration = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 4, color: Colors.black),
        );

        final EdgeInsetsGeometry padding = decoration.padding;

        // padding = EdgeInsets.all(max(0.1, width / 2))
        // width = 4, so padding = EdgeInsets.all(2)
        expect(padding, equals(const EdgeInsets.all(2)));
      });

      test('defaults to 0.1 when border width is null', () {
        const RoughBoxDecoration decoration = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(color: Colors.black),
        );

        final EdgeInsetsGeometry padding = decoration.padding;

        // width is null => max(0.1, 0.1 / 2) = max(0.1, 0.05) = 0.1
        expect(padding, equals(const EdgeInsets.all(0.1)));
      });

      test('handles zero border width', () {
        const RoughBoxDecoration decoration = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 0, color: Colors.black),
        );

        final EdgeInsetsGeometry padding = decoration.padding;

        // max(0.1, 0 / 2) = max(0.1, 0) = 0.1
        expect(padding, equals(const EdgeInsets.all(0.1)));
      });

      test('handles no borderStyle at all', () {
        const RoughBoxDecoration decoration = RoughBoxDecoration();

        final EdgeInsetsGeometry padding = decoration.padding;

        // borderStyle is null => width defaults to null => 0.1
        expect(padding, equals(const EdgeInsets.all(0.1)));
      });
    });

    group('RoughBoxShape.rectangle', () {
      testWidgets('paints without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.rectangle,
                    borderStyle: const RoughDrawingStyle(
                      width: 2,
                      color: Colors.black,
                    ),
                    drawConfig: DrawConfig.build(seed: 1),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('RoughBoxShape.roundedRectangle', () {
      testWidgets('paints without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.roundedRectangle,
                    borderStyle: const RoughDrawingStyle(
                      width: 2,
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    drawConfig: DrawConfig.build(seed: 1),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('paints with asymmetric border radius', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.roundedRectangle,
                    borderStyle: const RoughDrawingStyle(
                      width: 2,
                      color: Colors.green,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                      bottomLeft: Radius.circular(12),
                    ),
                    drawConfig: DrawConfig.build(seed: 1),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });

    group('RoughBoxShape.circle', () {
      testWidgets('paints without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.circle,
                    borderStyle: const RoughDrawingStyle(
                      width: 2,
                      color: Colors.red,
                    ),
                    drawConfig: DrawConfig.build(seed: 1),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('RoughBoxShape.ellipse', () {
      testWidgets('paints without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.ellipse,
                    borderStyle: const RoughDrawingStyle(
                      width: 2,
                      color: Colors.purple,
                    ),
                    drawConfig: DrawConfig.build(seed: 1),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Container integration', () {
      testWidgets('Container with RoughBoxDecoration renders without error', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 150,
                  height: 80,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.rectangle,
                    borderStyle: const RoughDrawingStyle(
                      width: 3,
                      color: Colors.black,
                    ),
                    fillStyle: const RoughDrawingStyle(color: Colors.yellow),
                    filler: HachureFiller(),
                    drawConfig: DrawConfig.build(seed: 42),
                  ),
                  child: const Center(child: Text('Hello Rough')),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Hello Rough'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('Container with default drawConfig renders without error', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const RoughBoxDecoration(
                    shape: RoughBoxShape.circle,
                    borderStyle: RoughDrawingStyle(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('Container with gradient style renders without error', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: RoughBoxDecoration(
                    shape: RoughBoxShape.rectangle,
                    borderStyle: const RoughDrawingStyle(
                      width: 2,
                      color: Colors.black,
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.blue],
                      ),
                    ),
                    drawConfig: DrawConfig.build(seed: 1),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });

    group('level fill', () {
      testWidgets('paints color beneath the outline', (tester) async {
        const fill = Color(0xFFFFE066);
        await tester.pumpWidget(
          const Center(
            child: DecoratedBox(
              decoration: RoughBoxDecoration(
                shape: RoughBoxShape.roundedRectangle,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
                color: fill,
              ),
              child: SizedBox(width: 120, height: 60),
            ),
          ),
        );

        expect(
          tester.renderObject(find.byType(DecoratedBox)),
          paints..path(color: fill),
        );
      });

      testWidgets('paints nothing extra without a color', (tester) async {
        const fill = Color(0xFFFFE066);
        await tester.pumpWidget(
          const Center(
            child: DecoratedBox(
              decoration: RoughBoxDecoration(
                borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
              ),
              child: SizedBox(width: 120, height: 60),
            ),
          ),
        );

        expect(
          tester.renderObject(find.byType(DecoratedBox)),
          isNot(paints..path(color: fill)),
        );
      });

      test('stores color', () {
        const decoration = RoughBoxDecoration(color: Colors.amber);
        expect(decoration.color, Colors.amber);
        expect(const RoughBoxDecoration().color, isNull);
      });
    });

    group('inkInset', () {
      test('grows with the pen width', () {
        const thin = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 1),
        );
        const thick = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 4),
        );
        expect(thin.inkInset, greaterThan(1));
        expect(thick.inkInset, greaterThan(thin.inkInset));
      });

      test('follows the draw config roughness', () {
        final calm = RoughBoxDecoration(
          borderStyle: const RoughDrawingStyle(width: 2),
          drawConfig: DrawConfig.build(roughness: 0),
        );
        final rough = RoughBoxDecoration(
          borderStyle: const RoughDrawingStyle(width: 2),
          drawConfig: DrawConfig.build(roughness: 3),
        );
        expect(rough.inkInset, greaterThan(calm.inkInset));
      });
    });

    group('getClipPath()', () {
      const box = Rect.fromLTWH(0, 0, 100, 60);
      const pen = RoughDrawingStyle(width: 2);

      for (final shape in RoughBoxShape.values) {
        test('$shape stops at the centre of the pen line', () {
          final decoration = RoughBoxDecoration(
            shape: shape,
            borderStyle: pen,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          );
          final path = decoration.getClipPath(box, TextDirection.ltr);
          final inset = decoration.inkInset;

          expect(path.contains(box.center), isTrue);
          expect(path.contains(const Offset(0.5, 30)), isFalse);
          expect(path.getBounds().left, greaterThanOrEqualTo(inset - 0.01));
          expect(path.getBounds().top, greaterThanOrEqualTo(inset - 0.01));
        });
      }

      test('never inverts a box smaller than the inset', () {
        const decoration = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 8),
        );
        final path = decoration.getClipPath(
          const Rect.fromLTWH(0, 0, 4, 4),
          TextDirection.ltr,
        );
        expect(path.getBounds().width, greaterThanOrEqualTo(0));
      });

      testWidgets('lets a Container clip its child to the outline', (
        tester,
      ) async {
        await tester.pumpWidget(
          Center(
            child: Container(
              width: 120,
              height: 80,
              clipBehavior: Clip.antiAlias,
              decoration: const RoughBoxDecoration(
                shape: RoughBoxShape.roundedRectangle,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
                color: Colors.white,
              ),
              child: const ColoredBox(color: Colors.red),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(ClipPath), findsOneWidget);
      });
    });

    group('equality', () {
      test('equal values make equal decorations', () {
        const a = RoughBoxDecoration(
          shape: RoughBoxShape.roundedRectangle,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
          fillStyle: RoughDrawingStyle(color: Colors.blue),
          color: Colors.white,
          seed: 4,
        );
        const b = RoughBoxDecoration(
          shape: RoughBoxShape.roundedRectangle,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
          fillStyle: RoughDrawingStyle(color: Colors.blue),
          color: Colors.white,
          seed: 4,
        );
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('a different seed, color, or style is a different decoration', () {
        const base = RoughBoxDecoration(
          borderStyle: RoughDrawingStyle(width: 2),
        );
        expect(
          base,
          isNot(
            const RoughBoxDecoration(
              borderStyle: RoughDrawingStyle(width: 2),
              seed: 2,
            ),
          ),
        );
        expect(
          base,
          isNot(
            const RoughBoxDecoration(
              borderStyle: RoughDrawingStyle(width: 2),
              color: Colors.white,
            ),
          ),
        );
        expect(
          base,
          isNot(
            const RoughBoxDecoration(borderStyle: RoughDrawingStyle(width: 3)),
          ),
        );
      });

      test('draw configs compare by identity', () {
        final config = DrawConfig.build(seed: 3);
        expect(
          RoughBoxDecoration(drawConfig: config),
          RoughBoxDecoration(drawConfig: config),
        );
        expect(
          RoughBoxDecoration(drawConfig: DrawConfig.build(seed: 3)),
          isNot(RoughBoxDecoration(drawConfig: DrawConfig.build(seed: 3))),
        );
      });

      testWidgets('a rebuild with an equal decoration keeps the drawing', (
        tester,
      ) async {
        Widget build() => const Center(
          child: DecoratedBox(
            decoration: RoughBoxDecoration(
              borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
              seed: 9,
            ),
            child: SizedBox(width: 80, height: 40),
          ),
        );
        await tester.pumpWidget(build());
        final render = tester.renderObject<RenderDecoratedBox>(
          find.byType(DecoratedBox),
        );
        final first = render.decoration;

        // A new but equal instance, as a rebuilding parent would create.
        await tester.pumpWidget(
          Center(
            child: DecoratedBox(
              decoration: RoughBoxDecoration(
                borderStyle: const RoughDrawingStyle(
                  width: 2,
                  color: Colors.black,
                ),
                seed: 3 * 3,
              ),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        );

        expect(identical(render.decoration, first), isTrue);
      });
    });

    group('lerp', () {
      const from = RoughBoxDecoration(
        shape: RoughBoxShape.roundedRectangle,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderStyle: RoughDrawingStyle(width: 2, color: Color(0xFF000000)),
        color: Color(0xFF000000),
        seed: 1,
      );
      const to = RoughBoxDecoration(
        shape: RoughBoxShape.roundedRectangle,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderStyle: RoughDrawingStyle(width: 4, color: Color(0xFFFFFFFF)),
        color: Color(0xFFFFFFFF),
        seed: 2,
      );

      test('interpolates colours, pen width, and radius', () {
        final mid = RoughBoxDecoration.lerp(from, to, 0.5)!;
        expect(mid.color, Color.lerp(from.color, to.color, 0.5));
        expect(mid.borderStyle!.width, 3);
        expect(mid.borderRadius, const BorderRadius.all(Radius.circular(8)));
      });

      test('switches the seed at the midpoint', () {
        expect(RoughBoxDecoration.lerp(from, to, 0.4)!.seed, 1);
        expect(RoughBoxDecoration.lerp(from, to, 0.6)!.seed, 2);
      });

      test('returns null across shapes', () {
        const circle = RoughBoxDecoration(shape: RoughBoxShape.circle);
        expect(RoughBoxDecoration.lerp(from, circle, 0.5), isNull);
        expect(Decoration.lerp(from, circle, 0.25), from);
        expect(Decoration.lerp(from, circle, 0.75), circle);
      });

      test('Decoration.lerp uses it', () {
        final mid = Decoration.lerp(from, to, 0.5)! as RoughBoxDecoration;
        expect(mid.borderStyle!.width, 3);
      });

      test('RoughDrawingStyle.lerp handles a null end', () {
        final style = RoughDrawingStyle.lerp(
          null,
          const RoughDrawingStyle(width: 4, color: Color(0xFF000000)),
          0.5,
        )!;
        expect(style.width, 2);
        expect(style.color!.a, closeTo(0.5, 0.01));
      });

      testWidgets('animates inside an AnimatedContainer', (tester) async {
        Widget build(RoughBoxDecoration decoration) => Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 50,
            decoration: decoration,
          ),
        );
        await tester.pumpWidget(build(from));
        await tester.pumpWidget(build(to));
        await tester.pump(const Duration(milliseconds: 100));

        final mid =
            tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: find.byType(AnimatedContainer),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as RoughBoxDecoration;
        expect(mid.borderStyle!.width, closeTo(3, 0.5));

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('RoughDrawingStyle equality', () {
    test('equal values are equal', () {
      const a = RoughDrawingStyle(width: 2, color: Colors.black);
      const b = RoughDrawingStyle(width: 2, color: Colors.black);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const RoughDrawingStyle(width: 3, color: Colors.black)));
    });
  });
}
