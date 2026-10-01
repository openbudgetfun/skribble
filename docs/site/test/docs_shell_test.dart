import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';
import 'package:skribble_docs_site/src/document.dart';

void main() {
  final home = DocDocument.parse('content/index.md', '# Home');
  final install = DocDocument.parse(
    'content/getting-started/installation.md',
    '---\ntitle: Installation\n---\n# Installation\n\nAdd it.',
  );
  final quickStart = DocDocument.parse(
    'content/getting-started/quick-start.md',
    '---\ntitle: Quick Start\n---\n# Quick Start\n\nBuild it.',
  );
  final buttons = DocDocument.parse(
    'content/widgets/buttons.md',
    '---\ntitle: Buttons\n---\n# Buttons\n\nPress it.',
  );
  final architecture = DocDocument.parse(
    'content/core/architecture.md',
    '---\ntitle: Architecture\n---\n# Architecture\n\nShape it.',
  );
  // Deliberately out of sidebar order, as the asset manifest may list them.
  final documents = [buttons, quickStart, home, architecture, install];

  void useViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  test('reading order follows the sidebar groups and keeps every page', () {
    expect(docsReadingOrder(documents), [
      home,
      quickStart,
      install,
      architecture,
      buttons,
    ]);
    expect(docsNavigationTitle(home), 'Hello, Skribble');
    expect(docsNavigationTitle(install), 'Installation');
  });

  group('pager', () {
    testWidgets('links to both neighbours and navigates on tap', (
      tester,
    ) async {
      useViewport(tester, const Size(1440, 900));
      await tester.pumpWidget(
        DocsApp(documents: documents, initialLocation: install.path),
      );
      await tester.pumpAndSettle();

      final previous = find.byKey(DocsKeys.previousPage);
      final next = find.byKey(DocsKeys.nextPage);
      expect(
        find.descendant(of: previous, matching: find.text('Quick Start')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: next, matching: find.text('Architecture')),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(next),
        matchesSemantics(
          isLink: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: 'Next →\nArchitecture',
        ),
      );

      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('Shape it.', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('omits the missing neighbour at either end', (tester) async {
      await tester.pumpWidget(
        DocsApp(documents: documents, initialLocation: home.path),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(DocsKeys.previousPage), findsNothing);
      expect(find.byKey(DocsKeys.nextPage), findsOneWidget);

      await tester.pumpWidget(
        DocsApp(
          key: const ValueKey('last'),
          documents: documents,
          initialLocation: buttons.path,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(DocsKeys.previousPage), findsOneWidget);
      expect(find.byKey(DocsKeys.nextPage), findsNothing);
    });
  });

  group('header', () {
    testWidgets('holds the pen picker and ends actions at the edge', (
      tester,
    ) async {
      useViewport(tester, const Size(1440, 900));
      await tester.pumpWidget(
        DocsApp(documents: documents, initialLocation: install.path),
      );
      await tester.pumpAndSettle();

      final playful = find.byKey(DocsKeys.roughness('playful'));
      expect(tester.getTopLeft(playful).dy, lessThan(72));
      expect(tester.getTopRight(find.text('GitHub')).dx, greaterThan(1380));
      expect(find.bySemanticsLabel('Pen roughness'), findsOneWidget);

      await tester.tap(find.byKey(DocsKeys.roughness('gentle')));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byKey(DocsKeys.roughness('gentle'))),
        matchesSemantics(
          label: 'Gentle',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('moves the pen picker below the header on phones', (
      tester,
    ) async {
      useViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        DocsApp(documents: documents, initialLocation: install.path),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.byKey(DocsKeys.roughness('playful'))).dy,
        greaterThanOrEqualTo(72),
      );
      expect(
        tester.getTopRight(find.byKey(DocsKeys.menu)).dx,
        greaterThan(360),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('contents', () {
    final article = DocDocument.parse(
      'content/core/example.md',
      [
        '# Example',
        for (final section in ['First', 'Second', 'Third']) ...[
          '## $section',
          ...List.filled(12, 'Prose in the $section section.'),
          '### $section detail',
          ...List.filled(12, 'More detail for $section.'),
        ],
      ].join('\n\n'),
    );

    testWidgets('indents subsections and marks the section being read', (
      tester,
    ) async {
      useViewport(tester, const Size(1440, 900));
      await tester.pumpWidget(
        DocsApp(documents: [home, article], initialLocation: article.path),
      );
      await tester.pumpAndSettle();

      final second = find.byKey(DocsKeys.contents('second'));
      final detail = find.byKey(DocsKeys.contents('second-detail'));
      expect(
        tester
            .getTopLeft(
              find.descendant(of: detail, matching: find.byType(Text)),
            )
            .dx,
        greaterThan(
          tester
              .getTopLeft(
                find.descendant(of: second, matching: find.byType(Text)),
              )
              .dx,
        ),
      );
      expect(_selected(tester, second), isFalse);
      expect(
        tester.getSemantics(
          find.descendant(of: second, matching: find.byType(Text)),
        ),
        matchesSemantics(
          label: 'Second',
          isLink: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      await tester.tap(
        find.descendant(of: second, matching: find.byType(Text)),
      );
      await tester.pumpAndSettle();
      expect(_selected(tester, second), isTrue);
      expect(
        _selected(tester, find.byKey(DocsKeys.contents('first'))),
        isFalse,
      );

      await tester.drag(
        find.byKey(DocsKeys.documentScroll),
        const Offset(0, -20000),
      );
      await tester.pumpAndSettle();
      expect(
        _selected(tester, find.byKey(DocsKeys.contents('third-detail'))),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('tables', () {
    final table = DocDocument.parse(
      'content/core/table.md',
      '# Table\n\n'
          '| Field | Type | Default | Description |\n'
          '| --- | --- | --- | --- |\n'
          '| disabledTextColor | WiredRoughness | Color(0xFFFEFEFE) | '
          'Resolved amplitude; an explicit constructor value overrides the '
          'preset for every painter below this scope. |\n',
    );

    testWidgets('fit the reading column without splitting identifiers', (
      tester,
    ) async {
      useViewport(tester, const Size(1440, 900));
      await tester.pumpWidget(
        DocsApp(documents: [home, table], initialLocation: table.path),
      );
      await tester.pumpAndSettle();

      final grid = find.byType(Table);
      expect(
        find.ancestor(of: grid, matching: find.byType(SingleChildScrollView)),
        findsOneWidget, // Only the document scroll view.
      );
      for (final identifier in [
        'disabledTextColor',
        'WiredRoughness',
        'Color(0xFFFEFEFE)',
      ]) {
        final cell = tester.renderObject<RenderParagraph>(
          find.text(identifier, findRichText: true),
        );
        expect(
          _lineCount(cell),
          equals(1),
          reason: '$identifier should stay on one line',
        );
      }
    });

    testWidgets('scroll sideways when columns cannot fit a phone', (
      tester,
    ) async {
      useViewport(tester, const Size(390, 844));
      await tester.pumpWidget(
        DocsApp(documents: [home, table], initialLocation: table.path),
      );
      await tester.pumpAndSettle();

      final scrollers = tester.widgetList<SingleChildScrollView>(
        find.ancestor(
          of: find.byType(Table),
          matching: find.byType(SingleChildScrollView),
        ),
      );
      expect(
        scrollers.map((scroller) => scroller.scrollDirection),
        contains(Axis.horizontal),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('code panels', () {
    testWidgets('label the language and copy the exact fenced source', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text']! as String;
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
          home: const WiredScaffold(
            body: CodeView(
              code: 'flutter pub add skribble\n',
              language: 'bash',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('bash'), findsOneWidget);
      final source = tester.renderObject<RenderParagraph>(
        find.textContaining('flutter pub add', findRichText: true),
      );
      expect(_lineCount(source), 1);

      await tester.tap(find.byKey(DocsKeys.copyCode));
      await tester.pump();
      expect(copied, 'flutter pub add skribble\n');
      expect(find.text('Copied!'), findsOneWidget);
    });
  });

  testWidgets('dense actions keep a 36-pixel target', (tester) async {
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: WiredScaffold(
          body: Center(
            child: DocsAction(
              dense: true,
              onPressed: () {},
              child: const Text('Compact'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(DocsAction)).height, 36);
  });
}

bool _selected(WidgetTester tester, Finder entry) =>
    tester
        .getSemantics(find.descendant(of: entry, matching: find.byType(Text)))
        .getSemanticsData()
        .flagsCollection
        .isSelected ==
    Tristate.isTrue;

/// Counts rendered lines by the distinct tops of the text's selection boxes.
int _lineCount(RenderParagraph paragraph) => paragraph
    .getBoxesForSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: paragraph.text.toPlainText().length,
      ),
    )
    .map((box) => box.top.round())
    .toSet()
    .length;
