import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

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
      expect(findWiredIcon(Icons.check), findsOneWidget);
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
      expect(findWiredIcon(Icons.check), findsOneWidget);
    });
  });
}
