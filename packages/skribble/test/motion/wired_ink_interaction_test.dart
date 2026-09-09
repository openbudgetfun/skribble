import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget app({
    WiredInkInteraction style = WiredInkInteraction.redraw,
    WiredInkInteraction? override,
    bool enabled = true,
    Animation<double>? entrance,
    bool disabled = false,
  }) {
    final button = WiredOutlinedButton(
      inkInteraction: override,
      onPressed: disabled ? null : () {},
      child: const Text('Make a mark'),
    );
    return WiredMaterialApp(
      wiredTheme: WiredThemeData(inkInteraction: style, motionEnabled: enabled),
      home: Center(
        child: entrance == null
            ? button
            : WiredDrawTransition(progress: entrance, child: button),
      ),
    );
  }

  RoughBoxDecoration decoration(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .map((widget) => widget.decoration)
      .whereType<RoughBoxDecoration>()
      .first;

  testWidgets(
    'theme redraw traces ink on each press and settles without moving text',
    (tester) async {
      await tester.pumpWidget(app());
      final label = find.text('Make a mark');
      final bounds = tester.getRect(label);
      for (var count = 0; count < 3; count++) {
        final gesture = await tester.startGesture(tester.getCenter(label));
        await tester.pump();
        expect(decoration(tester).progress!.value, 0);
        await tester.pump(const Duration(milliseconds: 120));
        expect(decoration(tester).progress!.value, inExclusiveRange(0, 1));
        expect(tester.getRect(label), bounds);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(decoration(tester).progress!.value, 1);
        expect(tester.binding.transientCallbackCount, 0);
      }
    },
  );

  testWidgets('local none overrides a playful theme and retains activation', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(inkInteraction: WiredInkInteraction.redraw),
        home: Center(
          child: WiredFilledButton(
            inkInteraction: WiredInkInteraction.none,
            onPressed: () => taps++,
            child: const Text('Make a mark'),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Make a mark')),
    );
    await tester.pump(const Duration(milliseconds: 140));
    expect(decoration(tester).pressure!.value, 0);
    expect(decoration(tester).progress!.value, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets(
    'outer entrance limits interaction progress without being owned',
    (tester) async {
      final entrance = AnimationController(vsync: tester, value: .3);
      await tester.pumpWidget(app(entrance: entrance));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Make a mark')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(decoration(tester).progress!.value, .3);
      await gesture.up();
      await tester.pumpAndSettle();
      entrance.value = 1;
      await tester.pump();
      expect(decoration(tester).progress!.value, 1);
      await tester.pumpWidget(const SizedBox());
      entrance.value = .5;
      entrance.dispose();
    },
  );

  testWidgets('turning motion off settles an active redraw immediately', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Make a mark')),
    );
    await tester.pump();
    expect(decoration(tester).progress!.value, 0);
    await tester.pumpWidget(app(enabled: false));
    expect(decoration(tester).progress, isNull);
    expect(decoration(tester).pressure, isNull);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('platform reduced motion wins over a local redraw request', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(app(override: WiredInkInteraction.redraw));
    await tester.tap(find.text('Make a mark'));
    await tester.pumpAndSettle();
    expect(decoration(tester).progress, isNull);
    expect(decoration(tester).pressure, isNull);
  });

  testWidgets(
    'disabling a pressed control and removing it cancels owned tickers',
    (tester) async {
      await tester.pumpWidget(app());
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Make a mark')),
      );
      await tester.pump();
      await tester.pumpWidget(app(disabled: true));
      expect(decoration(tester).progress!.value, 1);
      await gesture.cancel();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
