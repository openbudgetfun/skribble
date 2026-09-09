import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/article.dart';
import 'package:skribble_docs_site/src/document.dart';

void main() {
  test(
    'Flutter text receives literal code and punctuation, not HTML escapes',
    () {
      final document = DocDocument.parse(
        'content/index.md',
        '# Types & values\n\nUse `Animation<double>`.\n\n```dart\nList<String> names = [];\n```',
      );
      final text = document.nodes.map((node) => node.textContent).join('\n');
      expect(text, contains('Types & values'));
      expect(text, contains('Animation<double>'));
      expect(text, contains('List<String> names = [];'));
      expect(text, isNot(contains('&lt;')));
    },
  );
  test('duplicate headings have stable distinct fragments', () {
    final document = DocDocument.parse(
      'content/index.md',
      '# Page\n\n## Example\n\nOne.\n\n## Example\n\nTwo.',
    );
    expect(document.headingIds.values, ['page', 'example', 'example-1']);
  });

  testWidgets('MDT comments stay hidden while code comments remain copyable', (
    tester,
  ) async {
    final document = DocDocument.parse(
      'content/core/example.md',
      '# Example\n\n<!-- hidden marker -->\n\nReadable prose.\n\n```html\n<!-- useful code comment -->\n```',
    );
    await tester.pumpWidget(
      DocsApp(documents: [document], initialLocation: document.path),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('hidden marker', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('useful code comment', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a rich inline link navigates when its visible text is tapped', (
    tester,
  ) async {
    String? destination;
    final document = DocDocument.parse(
      'content/index.md',
      'Read the [**installation** guide](/getting-started/installation) to begin.',
    );
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: WiredScaffold(
          body: DocArticle(
            document: document,
            anchors: const {},
            onLink: (value) => destination = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byType(RichText).first,
    );
    final text = paragraph.text.toPlainText();
    final start = text.indexOf('installation');
    final box = paragraph
        .getBoxesForSelection(
          TextSelection(
            baseOffset: start,
            extentOffset: start + 'installation'.length,
          ),
        )
        .first
        .toRect();
    await tester.tapAt(paragraph.localToGlobal(box.center));
    await tester.pump();
    expect(destination, '/getting-started/installation');
  });

  testWidgets('an unknown route offers a working path home', (tester) async {
    final home = DocDocument.parse(
      'content/index.md',
      '# Welcome back\n\nA small beginning.',
    );
    await tester.pumpWidget(
      DocsApp(documents: [home], initialLocation: '/wandered-off'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Skribble'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Welcome back', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('brand and contents links activate from the keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final home = DocDocument.parse('content/index.md', '# Home');
    final article = DocDocument.parse(
      'content/core/example.md',
      '# Example\n\n${List.filled(15, 'Some introductory prose.').join('\n\n')}\n\n## Details\n\nThe destination.',
    );
    await tester.pumpWidget(
      DocsApp(documents: [home, article], initialLocation: article.path),
    );
    await tester.pumpAndSettle();
    final contentsLink = find.text('Details').last;
    Focus.of(tester.element(contentsLink)).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      tester
          .getTopLeft(
            find.textContaining('The destination.', findRichText: true),
          )
          .dy,
      lessThan(1000),
    );
    Focus.of(tester.element(find.text('skribble'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Keep this little idea'), findsOneWidget);
  });

  testWidgets('inline links expose working assistive activation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    String? destination;
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: WiredScaffold(
          body: DocArticle(
            document: DocDocument.parse(
              'content/index.md',
              'Read [**installation**](/install) now.',
            ),
            anchors: const {},
            onLink: (href) => destination = href,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    SemanticsNode? link;
    bool findLink(SemanticsNode node) {
      if (node.label == 'installation') link = node;
      node.visitChildren(findLink);
      return true;
    }

    final owner = tester.binding.renderViews.single.owner!.semanticsOwner!;
    findLink(owner.rootSemanticsNode!);
    expect(link, isNotNull);
    expect(link!.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    owner.performAction(
      link!.id,
      SemanticsAction.tap,
    );
    await tester.pump();
    expect(destination, '/install');
    semantics.dispose();
  });

  testWidgets('motion checkbox has a label and keyboard activation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final document = DocDocument.parse('content/core/motion.md', '# Motion');
    await tester.pumpWidget(
      DocsApp(documents: [document], initialLocation: document.path),
    );
    await tester.pumpAndSettle();
    final checkbox = find.byType(WiredCheckbox);
    expect(
      tester.getSemantics(checkbox),
      matchesSemantics(
        label: 'Allow decorative motion',
        hasCheckedState: true,
        isChecked: true,
        hasTapAction: true,
      ),
    );
    final focusable = find
        .descendant(of: checkbox, matching: find.byType(Focus))
        .first;
    Focus.of(
      tester.element(find.byWidget(tester.widget<Focus>(focusable).child)),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(tester.widget<WiredCheckbox>(checkbox).value, isFalse);
    semantics.dispose();
  });
}
