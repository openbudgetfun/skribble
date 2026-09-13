import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredToggle', () {
    testWidgets('renders and paints', (tester) async {
      await pumpWired(
        tester,
        Center(
          child: SizedBox(
            width: 120,
            height: 100,
            child: WiredToggle(value: false, onChange: (v) => true),
          ),
        ),
      );

      expectRenders(tester, findWired<WiredToggle>());
      expectPaints(findWired<WiredToggle>());
    });

    testWidgets('reports its toggled state to assistive technology', (
      tester,
    ) async {
      await pumpWired(tester, WiredToggle(value: true, onChange: (v) => true));

      expectSemantics(
        tester,
        findWired<WiredToggle>(),
        isToggled: true,
        isEnabled: true,
        hasTapAction: true,
      );

      await pumpWired(tester, WiredToggle(value: false, onChange: (v) => true));

      expectSemantics(
        tester,
        findWired<WiredToggle>(),
        isToggled: false,
        isEnabled: true,
      );
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredToggle(
          value: true,
          onChange: (v) => true,
          semanticLabel: 'Dark mode',
        ),
      );

      expect(findWiredBySemanticsLabel('Dark mode'), findsOneWidget);
    });

    testWidgets('calls onChange with the next value when tapped', (
      tester,
    ) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredToggle(value: false, onChange: (v) => receivedValue = v),
      );

      await tapWired(tester, findWired<WiredToggle>());

      expect(receivedValue, isTrue);
    });

    testWidgets('activates through the semantics tap action', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredToggle(value: false, onChange: (v) => receivedValue = v),
      );

      await semanticTapWired(tester, findWired<WiredToggle>());

      expect(receivedValue, isTrue);
    });

    testWidgets('does not change state when onChange rejects the toggle', (
      tester,
    ) async {
      var callCount = 0;

      await pumpWired(
        tester,
        WiredToggle(
          value: false,
          onChange: (v) {
            callCount++;
            return false;
          },
        ),
      );

      await tapWired(tester, findWired<WiredToggle>());

      expect(callCount, 1);
      expectSemantics(
        tester,
        findWired<WiredToggle>(),
        isToggled: false,
        reason: 'A rejected toggle must stay off.',
      );
    });

    testWidgets('disabled toggle reports disabled and is not tappable', (
      tester,
    ) async {
      await pumpWired(tester, const WiredToggle(value: true));

      expectSemantics(
        tester,
        findWired<WiredToggle>(),
        isEnabled: false,
        isToggled: true,
        hasTapAction: false,
        reason: 'A disabled toggle must not advertise a tap action.',
      );
      await tapWired(tester, findWired<WiredToggle>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('has documented thumb radius defaults', (tester) async {
      const toggle = WiredToggle(value: false);
      expect(toggle.thumbRadius, 24.0);
      expect(toggle.onChange, isNull);
      expect(toggle.semanticLabel, isNull);

      await pumpWired(
        tester,
        const WiredToggle(value: false, thumbRadius: 16),
      );

      expect(
        tester.widget<WiredToggle>(findWired<WiredToggle>()).thumbRadius,
        16.0,
      );
      expectRenders(tester, findWired<WiredToggle>());
    });

    testWidgets('mirrors the thumb travel in RTL', (tester) async {
      await pumpWired(tester, WiredToggle(value: false, onChange: (v) => true));
      await tester.pumpAndSettle();
      final ltrOff = _thumbCenterX(tester) - _toggleCenterX(tester);

      await pumpWired(tester, WiredToggle(value: true, onChange: (v) => true));
      await tester.pumpAndSettle();
      final ltrOn = _thumbCenterX(tester) - _toggleCenterX(tester);

      await pumpWiredRtl(
        tester,
        WiredToggle(value: false, onChange: (v) => true),
      );
      await tester.pumpAndSettle();
      final rtlOff = _thumbCenterX(tester) - _toggleCenterX(tester);

      await pumpWiredRtl(
        tester,
        WiredToggle(value: true, onChange: (v) => true),
      );
      await tester.pumpAndSettle();
      final rtlOn = _thumbCenterX(tester) - _toggleCenterX(tester);

      expect(ltrOff, lessThan(0), reason: 'LTR off rests at the start edge.');
      expect(ltrOn, greaterThan(0), reason: 'LTR on rests at the end edge.');
      expect(
        rtlOff,
        greaterThan(0),
        reason: 'RTL off rests at the start edge.',
      );
      expect(rtlOn, lessThan(0), reason: 'RTL on rests at the end edge.');
    });

    testWidgets('renders and paints under small and zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredToggle(value: true, onChange: (v) => true),
        surfaceSize: const Size(60, 24),
      );
      expectRenders(tester, findWired<WiredToggle>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredToggle(value: true, onChange: (v) => true),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredToggle(value: true, onChange: (v) => true),
      );

      expectSemantics(tester, findWired<WiredToggle>(), isToggled: true);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Horizontal centre of the square thumb canvas, in global coordinates.
double _thumbCenterX(WidgetTester tester) {
  final rects = findWiredIn<WiredCanvas>(findWired<WiredToggle>())
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

/// Horizontal centre of the whole toggle, in global coordinates.
double _toggleCenterX(WidgetTester tester) =>
    tester.getRect(findWired<WiredToggle>()).center.dx;
