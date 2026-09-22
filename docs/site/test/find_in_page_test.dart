import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_docs_site/src/find_in_page.dart';

void main() {
  final document = DocDocument.parse(
    'content/index.md',
    '# Hello\n\n${List.filled(24, 'Some introductory prose.').join('\n\n')}\n\n## First target\n\nA target in the first section.\n\n${List.filled(24, 'More prose between the results.').join('\n\n')}\n\n## Second target\n\nAnother target in the second section.',
  );

  testWidgets('Control-F finds and navigates text on the current page', (
    tester,
  ) async {
    await tester.pumpWidget(DocsApp(documents: [document]));
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    final input = find.descendant(
      of: find.byKey(DocsKeys.findInput),
      matching: find.byType(EditableText),
    );
    expect(input, findsOneWidget);
    expect(tester.widget<EditableText>(input).focusNode.hasFocus, isTrue);

    await tester.enterText(input, 'TARGET');
    await tester.pumpAndSettle();
    expect(find.text('1 of 4 sections'), findsOneWidget);
    expect(_highlightedText(tester), contains('target'));
    expect(
      tester
          .widget<SingleChildScrollView>(find.byKey(DocsKeys.documentScroll))
          .controller!
          .offset,
      greaterThan(0),
    );

    await tester.tap(find.byKey(DocsKeys.findNext));
    await tester.pumpAndSettle();
    expect(find.text('2 of 4 sections'), findsOneWidget);
    await tester.tap(find.byKey(DocsKeys.findPrevious));
    await tester.pumpAndSettle();
    expect(find.text('1 of 4 sections'), findsOneWidget);

    await tester.enterText(input, 'absent phrase');
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(DocsKeys.findInput), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(DocsKeys.findInput), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Command-F and the Find button reopen the search field', (
    tester,
  ) async {
    await tester.pumpWidget(DocsApp(documents: [document]));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(DocsKeys.findInput), findsOneWidget);

    await tester.tap(find.byKey(DocsKeys.findClose));
    await tester.pumpAndSettle();
    expect(find.byKey(DocsKeys.findInput), findsNothing);
    await tester.tap(find.byKey(DocsKeys.find));
    await tester.pumpAndSettle();
    expect(find.byKey(DocsKeys.findInput), findsOneWidget);
  });

  testWidgets('find remains usable in the narrow docs layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(DocsApp(documents: [document]));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DocsKeys.find));
    await tester.pumpAndSettle();
    final input = find.descendant(
      of: find.byKey(DocsKeys.findInput),
      matching: find.byType(EditableText),
    );
    await tester.enterText(input, 'target');
    await tester.pumpAndSettle();
    expect(find.text('1 of 4 sections'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('find shortcut works while the sidebar search is focused', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(DocsApp(documents: [document]));
    await tester.pumpAndSettle();
    final sidebarInput = find.descendant(
      of: find.byKey(DocsKeys.search),
      matching: find.byType(EditableText),
    );
    await tester.tap(sidebarInput);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(DocsKeys.findInput), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(DocsKeys.findInput),
              matching: find.byType(EditableText),
            ),
          )
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('a highlighted article link still navigates', (tester) async {
    final home = DocDocument.parse(
      'content/index.md',
      '# Home\n\nRead the [installation](/guide) instructions.',
    );
    final guide = DocDocument.parse(
      'content/guide.md',
      '# Guide\n\nDestination text.',
    );
    await tester.pumpWidget(DocsApp(documents: [home, guide]));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(DocsKeys.find));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byKey(DocsKeys.findInput),
        matching: find.byType(EditableText),
      ),
      'installation',
    );
    await tester.pumpAndSettle();
    expect(find.text('1 of 1 sections'), findsOneWidget);

    final paragraph = tester.renderObject<RenderParagraph>(
      find.textContaining('Read the installation', findRichText: true),
    );
    final start = paragraph.text.toPlainText().indexOf('installation');
    final rect = paragraph
        .getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: start + 12),
        )
        .first
        .toRect();
    await tester.tapAt(paragraph.localToGlobal(rect.center));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Destination text.', findRichText: true),
      findsOneWidget,
    );
  });

  test('marking a rich link preserves its text and tap recognizer', () {
    final recognizer = TapGestureRecognizer();
    addTearDown(recognizer.dispose);
    final source = TextSpan(
      children: [
        const TextSpan(text: 'Before '),
        TextSpan(
          style: const TextStyle(decoration: TextDecoration.underline),
          children: [TextSpan(text: 'target link', recognizer: recognizer)],
        ),
        const TextSpan(text: ' after'),
      ],
    );
    final marked = markTextMatches(source, 'target');

    expect(marked.toPlainText(), source.toPlainText());
    final link = (marked.children![1] as TextSpan).children!.first as TextSpan;
    expect((link.children!.first as TextSpan).recognizer, same(recognizer));
    expect(
      (link.children!.first as TextSpan).style?.backgroundColor,
      isNotNull,
    );
  });
}

String _highlightedText(WidgetTester tester) {
  final text = <String>[];

  void visit(InlineSpan span) {
    if (span is! TextSpan) return;
    if (span.style?.backgroundColor != null && span.text != null) {
      text.add(span.text!);
    }
    span.children?.forEach(visit);
  }

  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    visit(richText.text);
  }
  return text.join(' ').toLowerCase();
}
