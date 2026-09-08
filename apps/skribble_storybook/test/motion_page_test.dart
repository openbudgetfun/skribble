import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/pages/motion_page.dart';
import 'package:skribble_storybook/testing/motion_keys.dart';

void main() {
  for (final width in [390.0, 820.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('motion gallery fits width $width and text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData(),
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const WiredMotionPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(MotionKeys.enabled));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byKey(MotionKeys.title), findsOneWidget);
      });
    }
  }
  testWidgets('gallery replays, reverses, pauses, saves, and disables motion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: const WiredMotionPage(),
      ),
    );
    await tester.tap(find.byKey(MotionKeys.replay));
    await tester.pumpAndSettle();
    expect(find.text('Pen 100% · 0 ideas kept'), findsOneWidget);
    await tester.tap(find.byKey(MotionKeys.reverse));
    await tester.pumpAndSettle();
    expect(find.text('Pen 0% · 0 ideas kept'), findsOneWidget);
    await tester.tap(find.byKey(MotionKeys.half));
    await tester.pumpAndSettle();
    expect(find.text('Pen 50% · 0 ideas kept'), findsOneWidget);
    await tester.tap(find.byKey(MotionKeys.action));
    await tester.pumpAndSettle();
    expect(find.text('Pen 50% · 1 ideas kept'), findsOneWidget);
    await tester.tap(find.byKey(MotionKeys.enabled));
    await tester.pumpAndSettle();
    expect(find.text('Motion off · every line is complete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
