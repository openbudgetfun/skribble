import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

void main() {
  testWidgets('code typography uses Mono and follows inherited roughness', (
    tester,
  ) async {
    for (final level in WiredRoughness.values) {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(roughnessLevel: level),
          home: const CodeView(code: 'final ink = 42;'),
        ),
      );
      final text = tester
          .widgetList<Text>(find.byType(Text))
          .singleWhere(
            (text) => text.textSpan?.toPlainText() == 'final ink = 42;',
          );
      expect(
        text.style!.fontFamily,
        'packages/skribble/${WiredFont.mono.familyFor(level)}',
      );
    }
  });

  test('syntax colour preserves every source character', () {
    for (final language in ['dart', 'bash', 'yaml', 'html', 'unknown']) {
      const code = 'Widget build<T>() => Text("café & <hello> \$value");\n';
      final span = highlightCode(code, language);
      expect(span.toPlainText(), code);
    }
    final coloured = highlightCode('return "hello";', 'dart');
    expect(coloured.children, isNotEmpty);
    expect(
      coloured.children!.whereType<TextSpan>().any(
        (span) => span.style?.color != null,
      ),
      isTrue,
    );
  });

  test('parameter substitution escapes Dart interpolation and leaves source intact', () {
    final settings = ExampleSettings()
      ..label = 'A "quote", café, \$value\nnext line';
    final source = examples['filled-button']!.sourceFor(settings);
    expect(source, contains(r'\$value'));
    expect(source, contains(r'\"quote\"'));
    expect(source, contains(r'\nnext line'));
    expect(source, isNot(contains('settings.')));
    expect(source, contains('WiredInkInteraction.pressure'));
  });

  for (final entry in examples.entries) {
    testWidgets('${entry.key} fits a narrow page at each roughness', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final level in WiredRoughness.values) {
        await tester.pumpWidget(
          DocsApp(
            documents: [
              DocDocument.parse(
                'content/widgets/example.md',
                '# Example\n\n```dart\n// Live example: ${entry.key}\n```',
              ),
            ],
            initialLocation: '/widgets/example',
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey('docs-roughness-${level.name}')));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} / ${level.name}',
        );
      }
    });
  }

  testWidgets(
    'editing text and enum updates the actual widget and copied source',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(),
          home: WiredScaffold(
            body: SingleChildScrollView(
              child: LiveExample(
                id: 'filled-button',
                definition: examples['filled-button']!,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('filled-button-label')),
          matching: find.byType(EditableText),
        ),
        'A fresh idea',
      );
      await tester.tap(find.text('redraw'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('preview-filled-button')),
          matching: find.text('A fresh idea'),
        ),
        findsOneWidget,
      );
      final source = tester.widget<CodeView>(find.byType(CodeView)).code;
      expect(source, contains('WiredInkInteraction.redraw'));
      expect(source, contains('A fresh idea'));
      await tester.ensureVisible(find.text('Copy code'));
      await tester.tap(find.text('Copy code'));
      await tester.pumpAndSettle();
      expect(copied, source);
    },
  );

  testWidgets('roughness changes the theme and survives navigation', (
    tester,
  ) async {
    final documents = [
      DocDocument.parse('content/index.md', '# Home'),
      DocDocument.parse('content/widgets/buttons.md', '# Buttons'),
    ];
    await tester.pumpWidget(
      DocsApp(documents: documents, initialLocation: '/widgets/buttons'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('docs-roughness-expressive')));
    await tester.pumpAndSettle();
    expect(
      WiredTheme.of(tester.element(find.byType(DocsAction).first))
          .roughnessLevel,
      WiredRoughness.expressive,
    );
    await tester.tap(find.text('skribble'));
    await tester.pumpAndSettle();
    expect(
      WiredTheme.of(tester.element(find.byType(DocsAction).first))
          .roughnessLevel,
      WiredRoughness.expressive,
    );
  });
}
