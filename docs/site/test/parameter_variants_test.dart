import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

void main() {
  Future<void> show(WidgetTester tester, String id) => tester.pumpWidget(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: WiredScaffold(
        body: SingleChildScrollView(
          child: LiveExample(id: id, definition: examples[id]!),
        ),
      ),
    ),
  );

  testWidgets('every fill choice updates the canvas and copied expression', (
    tester,
  ) async {
    await show(tester, 'rounded-canvas');
    await tester.pumpAndSettle();
    for (final value in RoughFilter.values) {
      final choice = find.byKey(
        DocsKeys.choice('rounded-canvas', 'fill', value.name),
      );
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final canvas = tester.widget<WiredCanvas>(
        find.descendant(
          of: find.byKey(DocsKeys.preview('rounded-canvas')),
          matching: find.byType(WiredCanvas),
        ),
      );
      expect(canvas.fillerType, value);
      expect(
        tester.widget<CodeView>(find.byType(CodeView)).code,
        contains('RoughFilter.${value.name}'),
      );
    }
  });

  testWidgets('every icon fill choice updates the rendered icon', (
    tester,
  ) async {
    await show(tester, 'svg-icon');
    await tester.pumpAndSettle();
    for (final value in WiredIconFillStyle.values) {
      final choice = find.byKey(
        DocsKeys.choice('svg-icon', 'iconFill', value.name),
      );
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final icon = tester.widget<WiredSvgIcon>(
        find.descendant(
          of: find.byKey(DocsKeys.preview('svg-icon')),
          matching: find.byType(WiredSvgIcon),
        ),
      );
      expect(icon.fillStyle, value);
      expect(
        tester.widget<CodeView>(find.byType(CodeView)).code,
        contains('WiredIconFillStyle.${value.name}'),
      );
    }
  });

  testWidgets('amount validates bounds and enabled removes the callback', (
    tester,
  ) async {
    await show(tester, 'slider');
    await tester.pumpAndSettle();
    final input = find.descendant(
      of: find.byKey(DocsKeys.parameter('slider', 'amount')),
      matching: find.byType(EditableText),
    );
    for (final value in ['0', '1', '0.25']) {
      await tester.enterText(input, value);
      await tester.pumpAndSettle();
      expect(
        tester.widget<WiredSlider>(find.byType(WiredSlider)).value,
        double.parse(value),
      );
    }
    await tester.enterText(input, '2');
    await tester.pumpAndSettle();
    expect(tester.widget<WiredSlider>(find.byType(WiredSlider)).value, .25);
    await tester.tap(find.text('enabled: true'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<WiredSlider>(find.byType(WiredSlider)).onChanged,
      isNull,
    );
  });
}
