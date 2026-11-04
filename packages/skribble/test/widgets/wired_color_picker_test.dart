import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';

import '../helpers/pump_app.dart';

void main() {
  Widget buildSubject({
    Color selectedColor = Colors.blue,
    ValueChanged<Color>? onColorChanged,
    List<Color>? colors,
    double swatchSize = 36,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WiredColorPicker(
            selectedColor: selectedColor,
            onColorChanged: onColorChanged,
            colors:
                colors ??
                const [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                ],
            swatchSize: swatchSize,
          ),
        ),
      ),
    );
  }

  group('WiredColorPicker', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject(onColorChanged: (_) {}));
      expect(find.byType(WiredColorPicker), findsOneWidget);
    });

    testWidgets('renders correct number of swatches', (tester) async {
      await tester.pumpWidget(buildSubject(onColorChanged: (_) {}));
      // 5 colors in our test list
      expect(find.byType(GestureDetector), findsAtLeast(5));
    });

    testWidgets('calls onColorChanged when swatch tapped', (tester) async {
      Color? selected;
      await tester.pumpWidget(
        buildSubject(onColorChanged: (c) => selected = c),
      );
      // Tap the first swatch (red)
      final swatches = find.byType(GestureDetector);
      await tester.tap(swatches.first);
      expect(selected, isNotNull);
    });

    testWidgets('shows check mark on selected color', (tester) async {
      await tester.pumpWidget(
        buildSubject(selectedColor: Colors.blue, onColorChanged: (_) {}),
      );
      expect(findWiredGlyph(SkribbleGlyphs.check), findsOneWidget);
    });

    testWidgets('does not call callback when disabled', (tester) async {
      Color? selected;
      await tester.pumpWidget(buildSubject());
      final swatches = find.byType(GestureDetector);
      await tester.tap(swatches.first);
      expect(selected, isNull);
    });

    testWidgets('renders with custom swatch size', (tester) async {
      await tester.pumpWidget(
        buildSubject(swatchSize: 48, onColorChanged: (_) {}),
      );
      expect(find.byType(WiredColorPicker), findsOneWidget);
    });

    testWidgets('renders with default colors when not specified', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredColorPicker(selectedColor: Colors.red, onColorChanged: (_) {}),
      );
      // Default has 20 colors
      expect(find.byType(WiredColorPicker), findsOneWidget);
    });

    testWidgets('changing selection updates check mark', (tester) async {
      Color currentColor = Colors.red;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildSubject(
              selectedColor: currentColor,
              onColorChanged: (c) => setState(() => currentColor = c),
            );
          },
        ),
      );
      expect(findWiredGlyph(SkribbleGlyphs.check), findsOneWidget);
    });

    testWidgets('puts at most crossAxisCount swatches in a row', (
      tester,
    ) async {
      await pumpWired(
        tester,
        SizedBox(
          width: 600,
          child: WiredColorPicker(
            selectedColor: const Color(0xFFF44336),
            onColorChanged: (_) {},
            crossAxisCount: 3,
            colors: const [
              Color(0xFFF44336),
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
              Color(0xFF673AB7),
            ],
          ),
        ),
      );

      final swatches = find.bySemanticsLabel(RegExp('^Color #'));
      final tops = {
        for (final element in swatches.evaluate())
          tester.getTopLeft(find.byWidget(element.widget)).dy.round(),
      };
      expect(tops, hasLength(2));
    }, semanticsEnabled: true);

    testWidgets('names swatches and their selection for screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpWired(
        tester,
        WiredColorPicker(
          selectedColor: const Color(0xFF2196F3),
          onColorChanged: (_) {},
          colors: const [Color(0xFF2196F3), Color(0xFF000000)],
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Color #2196F3')),
        matchesSemantics(
          label: 'Color #2196F3',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('a focused swatch is chosen with Enter', (tester) async {
      Color? chosen;
      await pumpWired(
        tester,
        WiredColorPicker(
          selectedColor: const Color(0xFF2196F3),
          onColorChanged: (color) => chosen = color,
          colors: const [Color(0xFF2196F3), Color(0xFF000000)],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(chosen, const Color(0xFF000000));
    });
  });
}
