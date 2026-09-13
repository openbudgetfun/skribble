import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredTooltip', () {
    testWidgets('renders its child content', (tester) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Tooltip text',
          child: const Text('Hover me'),
        ),
      );

      expect(find.text('Hover me'), findsOneWidget);
      expectRenders(tester, findWired<WiredTooltip>());
    });

    testWidgets('exposes the message as a semantics tooltip', (tester) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Accessible hint',
          child: const Text('Target'),
        ),
      );

      // find.byTooltip matches the framework's semanticsTooltip contract, so
      // this proves the message reaches assistive technology rather than just
      // being stored on a widget property.
      expect(find.byTooltip('Accessible hint'), findsOneWidget);
    });

    testWidgets('shows the message on long press', (tester) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Long press tooltip',
          child: const Text('Press me'),
        ),
      );

      await tester.longPress(findWired<WiredTooltip>());
      await tester.pumpAndSettle();

      expect(find.text('Long press tooltip'), findsOneWidget);
    });

    testWidgets('draws the revealed message with rough ink', (tester) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Decorated',
          child: const Text('Styled'),
        ),
      );

      await tester.longPress(findWired<WiredTooltip>());
      await tester.pumpAndSettle();

      final message = find.text('Decorated');
      expect(message, findsOneWidget);
      expect(
        find.ancestor(of: message, matching: findWiredRoughPaint()),
        findsWidgets,
        reason: 'The revealed tooltip must be hand-drawn, not a plain box.',
      );
    });

    testWidgets('shows the message on hover after the wait duration', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Hover tooltip',
          waitDuration: Duration.zero,
          child: const Text('Hover target'),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(findWired<WiredTooltip>()));
      await tester.pumpAndSettle();

      expect(find.text('Hover tooltip'), findsOneWidget);
    });

    testWidgets('keeps the message hidden until triggered', (tester) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Hidden message',
          showDuration: const Duration(seconds: 5),
          child: const Text('Quiet'),
        ),
      );

      expect(find.text('Hidden message'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts custom durations and a custom child', (tester) async {
      const wait = Duration(seconds: 2);
      const show = Duration(seconds: 5);

      await pumpWired(
        tester,
        const WiredTooltip(
          message: 'Custom durations',
          waitDuration: wait,
          showDuration: show,
          child: Text('Custom'),
        ),
      );

      final widget = tester.widget<WiredTooltip>(findWired<WiredTooltip>());
      expect(widget.waitDuration, wait);
      expect(widget.showDuration, show);
      expect(widget.message, 'Custom durations');
    });

    testWidgets('lays out and shows in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredTooltip(
          message: 'RTL tooltip',
          child: const Text('RTL target'),
        ),
      );

      expectRenders(tester, findWired<WiredTooltip>());
      await tester.longPress(findWired<WiredTooltip>());
      await tester.pumpAndSettle();
      expect(find.text('RTL tooltip'), findsOneWidget);
    });

    testWidgets('keeps its child usable under doubled text scale', (
      tester,
    ) async {
      await pumpWiredScaled(
        tester,
        WiredTooltip(
          message: 'Scaled tooltip',
          child: const Text('Scaled target'),
        ),
      );

      expectRenders(tester, findWired<WiredTooltip>());
      await tester.longPress(findWired<WiredTooltip>());
      await tester.pumpAndSettle();
      expect(find.text('Scaled tooltip'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders under narrow constraints', (tester) async {
      await pumpWired(
        tester,
        WiredTooltip(
          message: 'Narrow tooltip',
          child: const Text('Narrow'),
        ),
        surfaceSize: const Size(80, 40),
      );

      expectRenders(tester, findWired<WiredTooltip>());
      expect(tester.takeException(), isNull);
    });
  });
}
