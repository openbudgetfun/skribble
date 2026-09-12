import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('theme changes update labels without resetting selection', (
    tester,
  ) async {
    final picker = WiredCupertinoPicker(
      initialItem: 1,
      onSelectedItemChanged: (_) {},
      children: const [Text('One'), Text('Two'), Text('Three')],
    );
    for (final theme in [
      WiredThemeData(font: WiredFont.mono),
      WiredThemeData().copyWith(fontFamily: 'Notebook'),
    ]) {
      await tester.pumpWidget(_app(picker, theme: theme));
      final paragraph = tester.widget<RichText>(
        find.descendant(
          of: find.text('Two'),
          matching: find.byType(RichText),
        ),
      );
      expect(
        paragraph.text.style!.fontFamily,
        theme.fontPackage == null
            ? theme.fontFamily
            : 'packages/skribble/${theme.fontFamily}',
      );
      final wheel = tester.widget<ListWheelScrollView>(
        find.byType(ListWheelScrollView),
      );
      expect(
        (wheel.controller! as FixedExtentScrollController).selectedItem,
        1,
      );
    }
  });

  testWidgets('explicit child typography remains authoritative', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        WiredCupertinoPicker(
          onSelectedItemChanged: (_) {},
          children: const [
            Text(
              'Custom',
              style: TextStyle(
                fontFamily: 'CustomInk',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
    final paragraph = tester.widget<RichText>(
      find.descendant(
        of: find.text('Custom'),
        matching: find.byType(RichText),
      ),
    );
    expect(paragraph.text.style!.fontFamily, 'CustomInk');
    expect(paragraph.text.style!.fontWeight, FontWeight.w800);
  });

  for (final device in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
    testWidgets('${device.name} dragging changes the timer duration', (
      tester,
    ) async {
      Duration? selected;
      await tester.pumpWidget(
        _app(
          WiredCupertinoTimerPicker(
            initialTimerDuration: const Duration(hours: 1, minutes: 15),
            onTimerDurationChanged: (value) => selected = value,
          ),
        ),
      );
      final wheel = find.byType(WiredCupertinoPicker).first;
      final gesture = await tester.startGesture(
        tester.getCenter(wheel),
        kind: device,
      );
      await gesture.moveBy(const Offset(0, -80));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selected, isNotNull);
      expect(selected!.inHours, greaterThan(1));
      expect(selected!.inMinutes % 60, 15);
    });
  }

  for (final roughness in WiredRoughness.values) {
    testWidgets(
      '${roughness.name} wheel text uses the bundled hand-drawn family',
      (tester) async {
        final theme = WiredThemeData.cuddly(roughnessLevel: roughness);
        await tester.pumpWidget(
          _app(
            WiredCupertinoPicker(
              onSelectedItemChanged: (_) {},
              children: const [Text('One'), Text('Two')],
            ),
            theme: theme,
          ),
        );
        final paragraph = tester.widget<RichText>(
          find.descendant(
            of: find.text('One'),
            matching: find.byType(RichText),
          ),
        );
        expect(
          paragraph.text.style!.fontFamily,
          'packages/skribble/${theme.fontFamily}',
        );
      },
    );
  }
}

Widget _app(Widget child, {WiredThemeData? theme}) => WiredMaterialApp(
  wiredTheme: theme ?? WiredThemeData.cuddly(),
  home: WiredScaffold(
    body: Center(child: SizedBox(width: 400, child: child)),
  ),
);
