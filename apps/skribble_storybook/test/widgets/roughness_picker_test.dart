import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/widgets/roughness_picker.dart';

void main() {
  testWidgets('app toolbar stays named and themed alongside route semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byKey(const ValueKey('roughness-gentle'))),
        matchesSemantics(
          label: 'Gentle',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      expect(
        DefaultTextStyle.of(tester.element(find.text('Ink style')))
            .style
            .fontFamily,
        'packages/skribble/SkribbleGentle',
      );
      await tester.tap(find.text('Expressive'));
      await tester.pumpAndSettle();
      expect(
        DefaultTextStyle.of(tester.element(find.text('Ink style')))
            .style
            .fontFamily,
        'packages/skribble/Skribble',
      );
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });

  Future<void> pump(
    WidgetTester tester, {
    WiredRoughness value = WiredRoughness.expressive,
    ValueChanged<WiredRoughness>? onChanged,
  }) => tester.pumpWidget(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(roughnessLevel: value),
      home: Center(
        child: WiredRoughnessPicker(
          value: value,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    ),
  );
  testWidgets('shows the three level names', (tester) async {
    await pump(tester);
    for (final label in ['Gentle', 'Playful', 'Expressive']) {
      expect(find.text(label), findsOneWidget);
    }
  });
  testWidgets('reports the selected level', (tester) async {
    WiredRoughness? selected;
    await pump(tester, onChanged: (value) => selected = value);
    await tester.tap(find.text('Gentle'));
    expect(selected, WiredRoughness.gentle);
  });
  testWidgets('follows external selection changes', (tester) async {
    await pump(tester, value: WiredRoughness.gentle);
    expect(
      tester
          .widget<WiredChoiceChip>(
            find.byKey(const ValueKey('roughness-gentle')),
          )
          .selected,
      isTrue,
    );
    await pump(tester, value: WiredRoughness.playful);
    expect(
      tester
          .widget<WiredChoiceChip>(
            find.byKey(const ValueKey('roughness-gentle')),
          )
          .selected,
      isFalse,
    );
    expect(
      tester
          .widget<WiredChoiceChip>(
            find.byKey(const ValueKey('roughness-playful')),
          )
          .selected,
      isTrue,
    );
  });
  testWidgets('wraps at 320 pixels without overflowing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pump(tester);
    expect(tester.takeException(), isNull);
    for (final label in ['Gentle', 'Playful', 'Expressive']) {
      expect(tester.getRect(find.text(label)).right, lessThanOrEqualTo(320));
    }
  });
  testWidgets('keeps labels visible with larger text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Expressive'), findsOneWidget);
  });
  testWidgets('exposes the active choice to accessibility', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await pump(tester, value: WiredRoughness.gentle);
      expect(
        tester.getSemantics(find.byKey(const ValueKey('roughness-gentle'))),
        matchesSemantics(
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
          label: 'Gentle',
        ),
      );
    } finally {
      handle.dispose();
    }
  });
  testWidgets('rapid choices report each requested level', (tester) async {
    final values = <WiredRoughness>[];
    await pump(tester, onChanged: values.add);
    for (final label in ['Gentle', 'Playful', 'Expressive', 'Gentle']) {
      await tester.tap(find.text(label));
    }
    expect(values, [
      WiredRoughness.gentle,
      WiredRoughness.playful,
      WiredRoughness.expressive,
      WiredRoughness.gentle,
    ]);
  });
}
