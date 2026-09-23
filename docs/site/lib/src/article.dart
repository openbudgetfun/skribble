import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart'
    deferred as catalog;
import 'package:skribble_docs_site/src/examples/example.dart';
import 'package:skribble_docs_site/src/find_in_page.dart';

/// Renders cached Markdown using Flutter's native text selection machinery.
class DocArticle extends HookWidget {
  /// Creates a document with explicit navigation and heading anchors.
  const DocArticle({
    required this.document,
    required this.onLink,
    required this.anchors,
    this.findQuery = '',
    this.blockKeys,
    super.key,
  });

  /// Parsed document to display.
  final DocDocument document;

  /// Resolves both local and external links in the surrounding router.
  final ValueChanged<String> onLink;

  /// Stable keys used for table-of-contents and URL fragment navigation.
  final Map<String, GlobalKey> anchors;

  /// Current page search term, highlighted in rendered prose and code.
  final String findQuery;

  /// Optional keys for scrolling to top-level search matches.
  final List<GlobalKey>? blockKeys;

  @override
  Widget build(BuildContext context) {
    final selection = useMemoized(_ArticleSelection.new);
    useEffect(() => selection.dispose, [selection]);
    return WiredSelectionArea(
      child: SelectionContainer(
        delegate: selection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < document.nodes.length; index++)
              RepaintBoundary(
                key: blockKeys?[index],
                child: _block(context, document.nodes[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _block(BuildContext context, md.Node node) {
    if (node is md.Text && node.textContent.trimLeft().startsWith('<!--')) {
      return const SizedBox.shrink();
    }
    if (node is! md.Element) {
      return _Paragraph(nodes: [node], onLink: onLink, findQuery: findQuery);
    }
    final children = node.children ?? const <md.Node>[];
    final heading = RegExp(r'^h([1-6])$').firstMatch(node.tag);

    if (heading != null) {
      final level = int.parse(heading.group(1)!);
      final sizes = [42.0, 29.0, 23.0, 20.0, 18.0, 18.0];

      return Padding(
        key: anchors[document.headingIds[node]],
        padding: EdgeInsets.only(top: level == 1 ? 8 : 32, bottom: 14),
        child: Semantics(
          header: true,
          headingLevel: level,
          child: _Paragraph(
            nodes: children,
            onLink: onLink,
            findQuery: findQuery,
            style: TextStyle(
              fontSize: sizes[level - 1],
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      );
    }

    return switch (node.tag) {
      'pre' => _code(node),
      'ul' || 'ol' => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(node.tag == 'ol' ? '${index + 1}.' : '•'),
                    ),
                    Expanded(child: _block(context, children[index])),
                  ],
                ),
              ),
          ],
        ),
      ),
      'li' => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (children.any(
            (child) =>
                child is md.Element && {'p', 'ul', 'ol'}.contains(child.tag),
          ))
            for (final child in children) _block(context, child)
          else
            _Paragraph(nodes: children, onLink: onLink, findQuery: findQuery),
        ],
      ),
      'blockquote' => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: docsSurface(context, color: const Color(0xffeef1df)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children.map((child) => _block(context, child)).toList(),
        ),
      ),
      'table' => _table(node),
      'hr' => const SizedBox(height: 24),
      'p' => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _Paragraph(
          nodes: children,
          onLink: onLink,
          findQuery: findQuery,
        ),
      ),
      // Generated MDT markers and old HTML embeds have no readable prose.
      'html' => const SizedBox.shrink(),
      _ => _Paragraph(nodes: children, onLink: onLink, findQuery: findQuery),
    };
  }

  Widget _code(md.Element node) {
    final id = RegExp(r'^// Live example: ([a-z0-9-]+)\n')
        .firstMatch(node.textContent)
        ?.group(1);
    if (id != null) {
      return _DeferredLiveExample(key: ValueKey(id), id: id);
    }

    return CodeView(
      code: node.textContent.replaceFirst(
        RegExp(r'^// Static example: [a-z-]+\n'),
        '',
      ),
      language:
          node.children
              ?.whereType<md.Element>()
              .firstOrNull
              ?.attributes['class']
              ?.replaceFirst('language-', '') ??
          '',
      findQuery: findQuery,
    );
  }

  Widget _table(md.Element table) {
    final rows = <md.Element>[];
    for (final section in table.children ?? <md.Node>[]) {
      if (section is md.Element) {
        rows.addAll((section.children ?? <md.Node>[]).whereType<md.Element>());
      }
    }

    final columns = rows.fold(
      0,
      (count, row) => math.max(count, row.children?.length ?? 0),
    );
    final weights = [
      for (var column = 0; column < columns; column++)
        _columnWeight(rows, column),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fits = columns * _minTableColumn <= constraints.maxWidth;
          final table = Table(
            columnWidths: {
              for (var column = 0; column < columns; column++)
                // Columns never break inside a word; prose columns carry more
                // flex, so they absorb most of the squeeze.
                column: fits
                    ? IntrinsicColumnWidth(flex: weights[column])
                    : const MinColumnWidth(
                        IntrinsicColumnWidth(),
                        FixedColumnWidth(240),
                      ),
            },
            border: const TableBorder(
              top: BorderSide(color: docsRule),
              bottom: BorderSide(color: docsRule),
              horizontalInside: BorderSide(color: docsRule),
            ),
            children: [
              for (final (index, row) in rows.indexed)
                TableRow(
                  decoration: index == 0
                      ? const BoxDecoration(color: Color(0xfff3ebe4))
                      : null,
                  children: [
                    for (final cell in row.children ?? <md.Node>[])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: _Paragraph(
                          nodes: cell is md.Element
                              ? cell.children ?? []
                              : [cell],
                          onLink: onLink,
                          findQuery: findQuery,
                          style: cell is md.Element && cell.tag == 'th'
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                )
                              : const TextStyle(fontSize: 15),
                        ),
                      ),
                  ],
                ),
            ],
          );

          return fits
              ? table
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: table,
                );
        },
      ),
    );
  }

  /// Narrowest readable column before a table scrolls instead of squeezing.
  static const double _minTableColumn = 150;

  /// Wider prose columns earn more of the reading width than short names.
  static double _columnWeight(List<md.Element> rows, int column) {
    final longest = rows
        .map(
          (row) =>
              row.children?.elementAtOrNull(column)?.textContent.length ?? 0,
        )
        .fold(0, math.max);
    return (longest / 14).clamp(1, 4).toDouble();
  }
}

class _DeferredLiveExample extends HookWidget {
  const _DeferredLiveExample({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final library = useMemoized(catalog.loadLibrary);
    final load = useFuture(library);

    if (load.hasError) {
      return Text('Could not load live example: ${load.error}');
    }

    if (load.connectionState != ConnectionState.done) {
      return const Text('Preparing live example…');
    }

    final definition = catalog.examples[id];
    if (definition == null) throw StateError('Unknown live example: $id');

    return LiveExample(id: id, definition: definition);
  }
}

class _Paragraph extends HookWidget {
  const _Paragraph({
    required this.nodes,
    required this.onLink,
    required this.findQuery,
    this.style,
  });
  final List<md.Node> nodes;
  final ValueChanged<String> onLink;
  final String findQuery;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final content = useMemoized(() => _InlineContent(nodes, onLink), [
      nodes,
      onLink,
    ]);
    useEffect(() => content.dispose, [content]);

    return Text.rich(
      markTextMatches(TextSpan(children: content.spans), findQuery),
      style: style,
    );
  }
}

// Keep copied blocks separate without putting blank lines into text layout.
class _ArticleSelection extends StaticSelectionContainerDelegate {
  @override
  SelectedContent? getSelectedContent() {
    final parts = [
      for (final selectable in selectables)
        if (selectable.getSelectedContent() case final SelectedContent content)
          content.plainText,
    ];
    return parts.isEmpty ? null : SelectedContent(plainText: parts.join('\n'));
  }
}

class _InlineContent {
  _InlineContent(List<md.Node> nodes, ValueChanged<String> onLink) {
    spans = nodes.map((node) => _span(node, onLink)).toList();
  }
  late final List<InlineSpan> spans;
  final _recognizers = <TapGestureRecognizer>[];

  InlineSpan _span(
    md.Node node,
    ValueChanged<String> onLink, [
    TapGestureRecognizer? link,
  ]) {
    if (node is! md.Element) {
      return TextSpan(text: node.textContent, recognizer: link);
    }
    if (node.tag == 'br') return const TextSpan(text: '\n');
    final style = switch (node.tag) {
      'strong' => const TextStyle(fontWeight: FontWeight.w700),
      'em' => const TextStyle(fontStyle: FontStyle.italic),
      'code' => const TextStyle(color: Color(0xff714265), fontSize: 15),
      'a' => const TextStyle(
        color: Color(0xff714265),
        decoration: TextDecoration.underline,
      ),
      'del' => const TextStyle(decoration: TextDecoration.lineThrough),
      _ => null,
    };
    var recognizer = link;

    if ((node.tag, node.attributes['href']) case ('a', final String href)) {
      recognizer = TapGestureRecognizer()..onTap = () => onLink(href);
      _recognizers.add(recognizer);
    }

    return TextSpan(
      style: style,
      recognizer: recognizer,
      text: node.tag == 'img' ? node.attributes['alt'] : null,
      children: node.children
          ?.map((child) => _span(child, onLink, recognizer))
          .toList(),
    );
  }

  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
  }
}
