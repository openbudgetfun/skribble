import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Widget host(
  Widget child, {
  bool reduced = false,
  TextDirection direction = TextDirection.ltr,
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduced),
  child: Directionality(
    textDirection: direction,
    child: Center(child: child),
  ),
);

const _box = SizedBox(width: 80, height: 40, child: Text('hi'));

/// The transform the entrance is painting the child with, or null at rest.
Matrix4? _transformOf(WidgetTester tester) {
  final transforms = find.descendant(
    of: find.byType(WiredEntrance),
    matching: find.byType(Transform),
  );
  if (transforms.evaluate().isEmpty) return null;
  return tester.widget<Transform>(transforms.first).transform;
}

double _opacityOf(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.descendant(
        of: find.byType(WiredEntrance),
        matching: find.byType(FadeTransition),
      ),
    )
    .opacity
    .value;

void main() {
  group('WiredSpringCurve', () {
    test('starts at zero and lands exactly on one', () {
      for (final curve in [
        WiredCurves.snappy,
        WiredCurves.springy,
        WiredCurves.bouncy,
        const WiredSpringCurve(bounce: 0),
      ]) {
        expect(curve.transform(0), 0);
        expect(curve.transform(1), 1);
        expect(curve.transform(0.98), closeTo(1, 0.01));
      }
    });

    test('overshoots more as the bounce grows', () {
      double peak(Curve curve) {
        var top = 0.0;
        for (var i = 0; i <= 1000; i++) {
          final value = curve.transform(i / 1000);
          if (value > top) top = value;
        }
        return top;
      }

      expect(peak(const WiredSpringCurve(bounce: 0)), lessThanOrEqualTo(1));
      expect(peak(WiredCurves.snappy), lessThan(1.02));
      expect(peak(WiredCurves.springy), inInclusiveRange(1.04, 1.1));
      expect(peak(WiredCurves.bouncy), inInclusiveRange(1.15, 1.25));
    });

    test('the pen curve rises monotonically', () {
      var last = 0.0;
      for (var i = 1; i <= 100; i++) {
        final value = WiredCurves.pen.transform(i / 100);
        expect(value, greaterThanOrEqualTo(last));
        last = value;
      }
      expect(WiredSpringCurve(bounce: 0.2).toString(), contains('0.2'));
    });
  });

  group('WiredEntrance', () {
    testWidgets('renders its child at full size from the first frame', (
      tester,
    ) async {
      await tester.pumpWidget(host(const WiredEntrance(child: _box)));
      expect(find.text('hi'), findsOneWidget);
      expect(tester.getSize(find.byWidget(_box)), const Size(80, 40));
      expect(_opacityOf(tester), 0);
      expect(_transformOf(tester), isNotNull);
      await tester.pumpAndSettle();
      expect(_opacityOf(tester), 1);
      expect(_transformOf(tester), isNull);
    });

    testWidgets('springs up from below and overshoots before settling', (
      tester,
    ) async {
      await tester.pumpWidget(host(const WiredEntrance(child: _box)));
      await tester.pump(const Duration(milliseconds: 60));
      final early = _transformOf(tester)!.getTranslation().y;
      expect(early, greaterThan(0));
      var overshot = false;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final transform = _transformOf(tester);
        if (transform != null && transform.getTranslation().y < -0.05) {
          overshot = true;
        }
      }
      expect(overshot, isTrue);
      await tester.pumpAndSettle();
      expect(_transformOf(tester), isNull);
    });

    testWidgets('waits for its delay before moving', (tester) async {
      await tester.pumpWidget(
        host(
          const WiredEntrance(
            delay: Duration(milliseconds: 300),
            child: _box,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(_opacityOf(tester), 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacityOf(tester), greaterThan(0));
      await tester.pumpAndSettle();
      expect(_opacityOf(tester), 1);
    });

    testWidgets('appears settled at once with reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const WiredEntrance(child: _box), reduced: true),
      );
      expect(_opacityOf(tester), 1);
      expect(_transformOf(tester), isNull);
      expect(tester.hasRunningAnimations, isFalse);

      await tester.pumpWidget(
        host(WiredMotion(enabled: false, child: WiredEntrance(child: _box))),
      );
      expect(_opacityOf(tester), 1);
    });

    testWidgets('draws descendant ink on with the pen', (tester) async {
      await tester.pumpWidget(
        host(
          const WiredEntrance(
            child: SizedBox(width: 120, height: 60, child: WiredCard()),
          ),
        ),
      );
      final drawTransition = find.descendant(
        of: find.byType(WiredEntrance),
        matching: find.byType(WiredDrawTransition),
      );
      expect(drawTransition, findsOneWidget);
      final ink = tester.widget<WiredDrawTransition>(drawTransition).progress;
      expect(ink.value, 0);
      await tester.pump(const Duration(milliseconds: 300));
      expect(ink.value, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(ink.value, 1);

      await tester.pumpWidget(
        host(const WiredEntrance(drawInk: false, child: _box)),
      );
      expect(drawTransition, findsNothing);
    });

    testWidgets('mirrors its sideways start in right-to-left text', (
      tester,
    ) async {
      const entrance = WiredEntrance(
        offset: Offset(20, 0),
        turns: 0,
        child: _box,
      );
      await tester.pumpWidget(host(entrance));
      await tester.pump(const Duration(milliseconds: 30));
      final ltr = _transformOf(tester)!.getTranslation().x;
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(host(entrance, direction: TextDirection.rtl));
      await tester.pump(const Duration(milliseconds: 30));
      final rtl = _transformOf(tester)!.getTranslation().x;
      expect(ltr, greaterThan(0));
      expect(rtl, closeTo(-ltr, 0.001));
    });

    testWidgets('staggered items start one after another, capped', (
      tester,
    ) async {
      final first = WiredEntrance.staggered(index: 0, child: _box);
      final third = WiredEntrance.staggered(index: 2, child: _box);
      final late = WiredEntrance.staggered(index: 50, child: _box);
      expect(first.delay, Duration.zero);
      expect(third.delay, const Duration(milliseconds: 140));
      expect(late.delay, const Duration(milliseconds: 700));
    });

    testWidgets('taps reach the child while it is still arriving', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          WiredEntrance(
            child: GestureDetector(onTap: () => taps++, child: _box),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('hi'));
      expect(taps, 1);
      await tester.pumpAndSettle();
    });
  });

  group('WiredCascade', () {
    testWidgets('lays children out in order with spacing', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 200,
            child: WiredCascade(
              spacing: 10,
              children: [
                SizedBox(height: 30, child: Text('one')),
                SizedBox(height: 30, child: Text('two')),
                SizedBox(height: 30, child: Text('three')),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(WiredEntrance), findsNWidgets(3));
      final one = tester.getTopLeft(find.text('one'));
      final two = tester.getTopLeft(find.text('two'));
      expect(two.dy - one.dy, 40);
      final delays = tester
          .widgetList<WiredEntrance>(find.byType(WiredEntrance))
          .map((entrance) => entrance.delay)
          .toList();
      expect(delays, [
        Duration.zero,
        const Duration(milliseconds: 70),
        const Duration(milliseconds: 140),
      ]);
      await tester.pumpAndSettle();
    });

    testWidgets('runs along a row and handles no children', (tester) async {
      await tester.pumpWidget(
        host(
          const WiredCascade(
            direction: Axis.horizontal,
            children: [Text('a'), Text('b')],
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('b')).dx,
        greaterThan(tester.getTopLeft(find.text('a')).dx),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(host(const WiredCascade(children: [])));
      expect(find.byType(WiredEntrance), findsNothing);
    });
  });
}
