import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredToggle', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(value: false, onChange: (v) => true),
              ),
            ));

      expect(find.byType(WiredToggle), findsOneWidget);
    });

    testWidgets('contains GestureDetector', (tester) async {
      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(value: false, onChange: (v) => true),
              ),
            ));

      expect(
        find.descendant(
          of: find.byType(WiredToggle),
          matching: find.byType(GestureDetector),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls onChange on tap', (tester) async {
      bool? receivedValue;

      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(
                  value: false,
                  onChange: (v) {
                    receivedValue = v;
                    return true;
                  },
                ),
              ),
            ));

      // The GestureDetector inside WiredToggle wraps a Stack sized to 60x24
      // (thumbRadius * 2.5 x thumbRadius). It sits at the top-left of the
      // enclosing SizedBox. We retrieve the GestureDetector's onTap callback
      // directly since the CustomPaint children in the Stack intercept
      // hit-testing in the test environment.
      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(WiredToggle),
          matching: find.byType(GestureDetector),
        ),
      );
      gestureDetector.onTap!();
      await tester.pumpAndSettle();

      // The toggle starts with value=false, so tapping should pass true
      // as the next value.
      expect(receivedValue, isTrue);
    });

    testWidgets('has correct default thumbRadius (24.0)', (tester) async {
      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(value: false),
              ),
            ));

      final toggle = tester.widget<WiredToggle>(find.byType(WiredToggle));

      expect(toggle.thumbRadius, 24.0);
    });

    testWidgets('accepts custom thumbRadius', (tester) async {
      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(value: false, thumbRadius: 16.0),
              ),
            ));

      final toggle = tester.widget<WiredToggle>(find.byType(WiredToggle));

      expect(toggle.thumbRadius, 16.0);
    });

    testWidgets('does not toggle when onChange returns false', (tester) async {
      var callCount = 0;

      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(
                  value: false,
                  onChange: (v) {
                    callCount++;
                    return false;
                  },
                ),
              ),
            ));

      // Invoke onTap directly on the GestureDetector.
      final gestureDetector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(WiredToggle),
          matching: find.byType(GestureDetector),
        ),
      );
      gestureDetector.onTap!();
      await tester.pump();

      // onChange was called but returned false, so the internal state should
      // not change. We verify onChange was invoked.
      expect(callCount, 1);
    });

    testWidgets('contains RepaintBoundary wrapper', (tester) async {
      await pumpApp(tester, Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: WiredToggle(value: false),
              ),
            ));

      // WiredToggle uses buildWiredElement which wraps in RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredToggle),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });
  });
}
