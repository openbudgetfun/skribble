import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredSwitch', () {
    testWidgets('has the documented track size and paints', (tester) async {
      await pumpWired(tester, WiredSwitch(value: false, onChanged: (_) {}));

      expectRenders(tester, findWired<WiredSwitch>(), size: const Size(60, 24));
      expectPaints(findWired<WiredSwitch>());
    });

    testWidgets('reports its toggled state to assistive technology', (
      tester,
    ) async {
      await pumpWired(tester, WiredSwitch(value: true, onChanged: (_) {}));
      expectSemantics(
        tester,
        findWired<WiredSwitch>(),
        isToggled: true,
        isEnabled: true,
        hasTapAction: true,
      );

      await pumpWired(tester, WiredSwitch(value: false, onChanged: (_) {}));
      expectSemantics(
        tester,
        findWired<WiredSwitch>(),
        isToggled: false,
        isEnabled: true,
      );
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredSwitch(
          value: false,
          onChanged: (_) {},
          semanticLabel: 'Enable notifications',
        ),
      );

      expect(findWiredBySemanticsLabel('Enable notifications'), findsOneWidget);
    });

    testWidgets('calls onChanged with the negated value when tapped', (
      tester,
    ) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredSwitch(value: false, onChanged: (value) => receivedValue = value),
      );

      await tapWired(tester, findWired<WiredSwitch>());

      expect(receivedValue, isTrue);
    });

    testWidgets('toggles back to false from the on state', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredSwitch(value: true, onChanged: (value) => receivedValue = value),
      );

      await tapWired(tester, findWired<WiredSwitch>());

      expect(receivedValue, isFalse);
    });

    testWidgets('activates through the semantics tap action', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredSwitch(value: false, onChanged: (value) => receivedValue = value),
      );

      await semanticTapWired(tester, findWired<WiredSwitch>());

      expect(receivedValue, isTrue);
    });

    testWidgets('disabled switch reports disabled and is not tappable', (
      tester,
    ) async {
      await pumpWired(tester, const WiredSwitch(value: false));

      expectSemantics(
        tester,
        findWired<WiredSwitch>(),
        isEnabled: false,
        isToggled: false,
        hasTapAction: false,
        reason: 'A disabled switch must not advertise a tap action.',
      );
      await tapWired(tester, findWired<WiredSwitch>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps custom colors on the public API', (tester) async {
      const active = Color(0xFF00FF00);
      const inactive = Color(0xFFFF0000);

      await pumpWired(
        tester,
        WiredSwitch(
          value: true,
          activeColor: active,
          inactiveColor: inactive,
          onChanged: (_) {},
        ),
      );

      final widget = tester.widget<WiredSwitch>(findWired<WiredSwitch>());
      expect(widget.activeColor, active);
      expect(widget.inactiveColor, inactive);
      expectPaints(findWired<WiredSwitch>());
    });

    testWidgets('follows external value changes', (tester) async {
      await pumpWired(tester, WiredSwitch(value: false, onChanged: (_) {}));
      expectSemantics(tester, findWired<WiredSwitch>(), isToggled: false);

      await pumpWired(tester, WiredSwitch(value: true, onChanged: (_) {}));
      await tester.pumpAndSettle();

      expectSemantics(tester, findWired<WiredSwitch>(), isToggled: true);
      expectPaints(findWired<WiredSwitch>());
    });

    testWidgets('mirrors the thumb travel in RTL', (tester) async {
      await pumpWired(tester, WiredSwitch(value: false, onChanged: (_) {}));
      await tester.pumpAndSettle();
      final ltrOff = _thumbCenterX(tester) - _switchCenterX(tester);

      await pumpWired(tester, WiredSwitch(value: true, onChanged: (_) {}));
      await tester.pumpAndSettle();
      final ltrOn = _thumbCenterX(tester) - _switchCenterX(tester);

      await pumpWiredRtl(tester, WiredSwitch(value: false, onChanged: (_) {}));
      await tester.pumpAndSettle();
      final rtlOff = _thumbCenterX(tester) - _switchCenterX(tester);

      await pumpWiredRtl(tester, WiredSwitch(value: true, onChanged: (_) {}));
      await tester.pumpAndSettle();
      final rtlOn = _thumbCenterX(tester) - _switchCenterX(tester);

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
        WiredSwitch(value: true, onChanged: (_) {}),
        surfaceSize: const Size(60, 24),
      );
      expectPaints(findWired<WiredSwitch>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredSwitch(value: true, onChanged: (_) {}),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredSwitch(value: true, onChanged: (_) {}),
      );

      expectRenders(tester, findWired<WiredSwitch>(), size: const Size(60, 24));
      expect(tester.takeException(), isNull);
    });
  });
}

/// Horizontal centre of the switch's thumb canvas, in global coordinates.
///
/// Identifies the thumb by shape (the only square canvas beneath the switch)
/// rather than by position in the tree or painter class, so it survives a
/// repaint or layer-order change.
double _thumbCenterX(WidgetTester tester) {
  final rects = findWiredIn<WiredCanvas>(findWired<WiredSwitch>())
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

/// Horizontal centre of the whole switch, in global coordinates.
double _switchCenterX(WidgetTester tester) =>
    tester.getRect(findWired<WiredSwitch>()).center.dx;
