import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('slider follows right-to-left direction on first layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 300,
              child: WiredSlider(
                value: 10,
                min: 10,
                max: 100,
                onChanged: (_) => true,
              ),
            ),
          ),
        ),
      ),
    );
    final slider = tester.getRect(find.byType(WiredSlider));
    final thumb = tester.getRect(
      find.descendant(
        of: find.byType(Positioned),
        matching: find.byType(WiredCanvas),
      ),
    );
    expect(thumb.center.dx, closeTo(slider.right - 12, 0.01));
  });

  for (final value in [10.0, 55.0, 100.0]) {
    testWidgets('slider thumb is positioned on first layout at $value', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: WiredSlider(
                value: value,
                min: 10,
                max: 100,
                onChanged: (_) => true,
              ),
            ),
          ),
        ),
      );
      final slider = tester.getRect(find.byType(WiredSlider));
      final thumb = tester.getRect(
        find.descendant(
          of: find.byType(Positioned),
          matching: find.byType(WiredCanvas),
        ),
      );
      expect(
        thumb.center.dx,
        closeTo(slider.left + 12 + 276 * (value - 10) / 90, 0.01),
      );
      expect(thumb.left, greaterThanOrEqualTo(slider.left));
      expect(thumb.right, lessThanOrEqualTo(slider.right));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disabled slider has no input callback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WiredSlider(value: 0.5, onChanged: null),
        ),
      ),
    );
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('null checkbox is unchecked and toggles to true', (tester) async {
    bool? changed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WiredCheckbox(
            value: null,
            onChanged: (value) => changed = value,
          ),
        ),
      ),
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(changed, isTrue);
  });

  testWidgets('input hint follows the paper theme', (tester) async {
    final theme = WiredThemeData(disabledTextColor: const Color(0xffbdb0c8));
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: theme,
        home: const Scaffold(body: WiredInput(hintText: 'An idea')),
      ),
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField))
          .decoration!
          .hintStyle!
          .color,
      theme.disabledTextColor,
    );
  });

  for (final scale in [1.0, 1.5, 2.0, 3.0]) {
    testWidgets('input accommodates a long label at ${scale}x text', (
      tester,
    ) async {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: const SingleChildScrollView(
                child: SizedBox(
                  width: 280,
                  child: WiredInput(
                    labelText:
                        'A long label that needs room to wrap comfortably',
                    hintText: 'Your next idea',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Café £12.50');
      await tester.pumpAndSettle();
      expect(find.text('Café £12.50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('checkbox follows a parent update after local interaction', (
    tester,
  ) async {
    Future<void> pump(bool value) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WiredCheckbox(value: value, onChanged: (_) {}),
        ),
      ),
    );
    await pump(false);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await pump(true);
    await pump(false);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('slider settles and follows external value changes', (
    tester,
  ) async {
    Future<void> pump(double value) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WiredSlider(value: value, onChanged: (_) => true),
        ),
      ),
    );
    await pump(0.2);
    await tester.pumpAndSettle();
    await pump(0.8);
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0.8);
    expect(tester.takeException(), isNull);
  });
}
