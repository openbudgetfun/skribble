import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredSlider', () {
    testWidgets('renders and paints', (tester) async {
      await pumpWired(tester, WiredSlider(value: 0.5, onChanged: (v) => true));

      expectRenders(tester, findWired<WiredSlider>());
      expectPaints(findWired<WiredSlider>());
    });

    testWidgets('exposes a slider role with its current value', (tester) async {
      await pumpWired(tester, WiredSlider(value: 0.5, onChanged: (v) => true));

      expectSemantics(
        tester,
        findWired<WiredSlider>(),
        isSlider: true,
        isEnabled: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      );
      expect(semanticsOf(tester, findWired<WiredSlider>()).value, '0.5');
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredSlider(
          value: 0.5,
          semanticLabel: 'Volume',
          onChanged: (v) => true,
        ),
      );

      expect(findWiredBySemanticsLabel('Volume'), findsOneWidget);
      expectSemantics(tester, findWired<WiredSlider>(), label: 'Volume');
    });

    testWidgets('reports disabled without a value-changing action', (
      tester,
    ) async {
      await pumpWired(tester, const WiredSlider(value: 0.5, onChanged: null));

      expectSemantics(
        tester,
        findWired<WiredSlider>(),
        isEnabled: false,
        hasIncreaseAction: false,
        hasDecreaseAction: false,
      );
    });

    testWidgets('reports new values when dragged', (tester) async {
      double? receivedValue;

      await pumpWired(
        tester,
        WiredSlider(
          value: 0.0,
          onChanged: (value) {
            receivedValue = value;
            return true;
          },
        ),
      );

      await dragWired(tester, findWired<WiredSlider>(), const Offset(100, 0));

      expect(receivedValue, isNotNull);
      expect(receivedValue, greaterThan(0.0));
    });

    testWidgets('respects a rejected change and keeps the painted value', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredSlider(value: 0.5, onChanged: (value) => false),
      );

      await dragWired(tester, findWired<WiredSlider>(), const Offset(100, 0));

      expect(semanticsOf(tester, findWired<WiredSlider>()).value, '0.5');
    });

    testWidgets('moves through the semantics increase action', (tester) async {
      final reported = <double>[];

      await pumpWired(
        tester,
        WiredSlider(
          value: 0.5,
          onChanged: (value) {
            reported.add(value);
            return true;
          },
        ),
      );

      final node = tester.getSemantics(findWired<WiredSlider>());
      node.owner!.performAction(node.id, SemanticsAction.increase);
      await tester.pump();

      expect(reported, isNotEmpty);
      expect(reported.single, greaterThan(0.5));
      expect(semanticsOf(tester, findWired<WiredSlider>()).value, '0.6');
    });

    testWidgets('honours custom min and max', (tester) async {
      await pumpWired(
        tester,
        WiredSlider(
          value: 50,
          min: 10,
          max: 100,
          onChanged: (value) => true,
        ),
      );

      expectSemantics(
        tester,
        findWired<WiredSlider>(),
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      );
      expect(semanticsOf(tester, findWired<WiredSlider>()).value, '50.0');
    });

    testWidgets('steps by divisions', (tester) async {
      final reported = <double>[];

      await pumpWired(
        tester,
        WiredSlider(
          value: 0.5,
          divisions: 5,
          onChanged: (value) {
            reported.add(value);
            return true;
          },
        ),
      );

      final node = tester.getSemantics(findWired<WiredSlider>());
      node.owner!.performAction(node.id, SemanticsAction.increase);
      await tester.pump();

      expect(reported.single, closeTo(0.7, 0.0001));
    });

    testWidgets('mirrors the thumb travel in RTL', (tester) async {
      await pumpWired(tester, WiredSlider(value: 1, onChanged: (v) => true));
      final ltrHigh = _thumbCenterX(tester) - _sliderCenterX(tester);

      await pumpWiredRtl(tester, WiredSlider(value: 1, onChanged: (v) => true));
      final rtlHigh = _thumbCenterX(tester) - _sliderCenterX(tester);

      expect(
        ltrHigh,
        greaterThan(0),
        reason: 'LTR high value sits at the end.',
      );
      expect(rtlHigh, lessThan(0), reason: 'RTL high value sits at the end.');

      await pumpWiredRtl(tester, WiredSlider(value: 0, onChanged: (v) => true));
      final rtlLow = _thumbCenterX(tester) - _sliderCenterX(tester);

      expect(
        rtlLow,
        greaterThan(0),
        reason: 'RTL low value sits at the start.',
      );
    });

    testWidgets('renders and paints under small and zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredSlider(value: 0.5, onChanged: (v) => true),
        surfaceSize: const Size(60, 24),
      );
      expectRenders(tester, findWired<WiredSlider>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredSlider(value: 0.5, onChanged: (v) => true),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredSlider(value: 0.5, onChanged: (v) => true),
      );

      expectSemantics(tester, findWired<WiredSlider>(), isSlider: true);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('can be disabled by omitting onChanged', (tester) async {
    await pumpApp(tester, const WiredSlider(value: 0.5));

    expectSemantics(
      tester,
      findWired<WiredSlider>(),
      isEnabled: false,
      hasIncreaseAction: false,
      hasDecreaseAction: false,
    );
  });
}

/// Horizontal centre of the square thumb canvas, in global coordinates.
double _thumbCenterX(WidgetTester tester) {
  final rects = findWiredIn<WiredCanvas>(findWired<WiredSlider>())
      .evaluate()
      .map((element) {
        final box = element.renderObject! as RenderBox;
        return box.localToGlobal(Offset.zero) & box.size;
      })
      .where((rect) => rect.width == rect.height)
      .toList();

  expect(rects, hasLength(1), reason: 'Expected exactly one square thumb.');
  return rects.single.center.dx;
}

/// Horizontal centre of the whole slider, in global coordinates.
double _sliderCenterX(WidgetTester tester) =>
    tester.getRect(findWired<WiredSlider>()).center.dx;
