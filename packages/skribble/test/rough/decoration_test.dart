import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
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
      testWidgets('Container with RoughBoxDecoration renders without error', (tester) async {
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
                    fillStyle: const RoughDrawingStyle(
                      color: Colors.yellow,
                    ),
                    filler: HachureFiller(),
                    drawConfig: DrawConfig.build(seed: 42),
                  ),
                  child: const Center(
                    child: Text('Hello Rough'),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Hello Rough'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('Container with default drawConfig renders without error', (tester) async {
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

      testWidgets('Container with gradient style renders without error', (tester) async {
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
  });
}
