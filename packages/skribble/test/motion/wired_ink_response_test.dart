import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/motion/wired_ink_response.dart';

void main() {
  Widget app({
    bool enabled = true,
    bool disabled = false,
    VoidCallback? onTap,
  }) => WiredMaterialApp(
    wiredTheme: WiredThemeData(motionEnabled: enabled),
    home: Center(
      child: WiredOutlinedButton(
        onPressed: disabled ? null : onTap ?? () {},
        child: const Text('Press me'),
      ),
    ),
  );
  double pressure(WidgetTester tester) =>
      tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<RoughBoxDecoration>()
          .first
          .pressure
          ?.value ??
      0;

  testWidgets('hover reinforces ink then relaxes without moving its label', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final rect = tester.getRect(find.text('Press me'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.text('Press me')));
    await tester.pumpAndSettle();
    expect(pressure(tester), .5);
    expect(tester.getRect(find.text('Press me')), rect);
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(pressure(tester), 0);
    await mouse.removePointer();
  });

  testWidgets('press and cancellation are reversible without firing callback', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        onTap: () {
          taps++;
        },
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Press me')),
    );
    await tester.pump(const Duration(milliseconds: 140));
    await tester.pump(const Duration(milliseconds: 140));
    expect(pressure(tester), 1);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(pressure(tester), 0);
    expect(taps, 0);
  });

  testWidgets('keyboard focus and activation use the same state controller', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        onTap: () {
          taps++;
        },
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(pressure(tester), .5);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(pressure(tester), .5);
  });

  testWidgets('restoring motion resumes the existing hover state', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.text('Press me')));
    await tester.pumpAndSettle();
    expect(pressure(tester), .5);
    await tester.pumpWidget(app(enabled: false));
    await tester.pumpAndSettle();
    expect(pressure(tester), 0);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(pressure(tester), .5);
    await mouse.removePointer();
  });

  testWidgets('disabled button remains idle and cannot be activated', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        disabled: true,
        onTap: () {
          taps++;
        },
      ),
    );
    await tester.tap(find.text('Press me'));
    await tester.pumpAndSettle();
    expect(pressure(tester), 0);
    expect(taps, 0);
  });

  testWidgets('motion off preserves activation without scheduling ink ticks', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        enabled: false,
        onTap: () {
          taps++;
        },
      ),
    );
    await tester.tap(find.text('Press me'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(pressure(tester), 0);
    expect(tester.hasRunningAnimations, false);
  });

  testWidgets('rapid pointer changes return to rest and survive removal', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    for (var i = 0; i < 8; i++) {
      await mouse.moveTo(tester.getCenter(find.text('Press me')));
      await tester.pump(const Duration(milliseconds: 16));
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(pressure(tester), 0);
    await tester.pumpWidget(const SizedBox());
    await mouse.removePointer();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'all six button variants provide ink feedback through Flutter states',
    (tester) async {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: Column(
            children: [
              WiredButton(onPressed: () {}, child: const Text('Basic')),
              WiredFilledButton(onPressed: () {}, child: const Text('Filled')),
              WiredOutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              WiredElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
              WiredTextButton(onPressed: () {}, child: const Text('Text')),
              WiredIconButton(
                onPressed: () {},
                icon: const IconData(0xe0b0, fontFamily: 'MaterialIcons'),
              ),
            ],
          ),
        ),
      );
      expect(find.byType(WiredInkResponse), findsNWidgets(6));
      final semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text('Basic')),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Basic',
        ),
      );
      semantics.dispose();
    },
  );
}
