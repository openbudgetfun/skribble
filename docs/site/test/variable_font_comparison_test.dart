import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/variable_font_comparison.dart';

void main() {
  for (final width in [390.0, 1100.0]) {
    testWidgets(
      'variable sliders, static weights, styles and reset at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData(),
            home: const WiredScaffold(
              body: SingleChildScrollView(child: VariableFontComparison()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        Text variable() => tester.widget<Text>(
          find.byKey(const ValueKey('variable-specimen')),
        );
        Text fixed() =>
            tester.widget<Text>(find.byKey(const ValueKey('static-specimen')));
        expect(
          variable().style!.fontFamily,
          'packages/skribble/SkribbleVariablePlayful',
        );
        for (final weight in [300, 600, 800, 900]) {
          await tester.ensureVisible(find.text('$weight'));
          await tester.tap(find.text('$weight'));
          await tester.pumpAndSettle();
          expect(variable().style!.fontVariations!.first.value, weight);
          expect(
            fixed().style!.fontWeight,
            FontWeight.values[weight ~/ 100 - 1],
          );
        }
        final weightSlider = find.byKey(const ValueKey('variable-Weight'));
        await tester.ensureVisible(weightSlider);
        await tester.drag(weightSlider, const Offset(-137, 0));
        await tester.pumpAndSettle();
        final value = variable().style!.fontVariations!.first.value;
        expect(value, inExclusiveRange(300, 900));
        expect(value % 100, isNot(0));
        await tester.ensureVisible(find.text('Cursive'));
        await tester.tap(find.text('Cursive'));
        await tester.pumpAndSettle();
        expect(variable().style!.fontVariations!.last.value, 1);
        await tester.ensureVisible(find.text('Reset axes'));
        await tester.tap(find.text('Reset axes'));
        await tester.pumpAndSettle();
        expect(variable().style!.fontVariations!.first.value, 400);
        expect(variable().style!.fontVariations!.last.value, 0.5);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
