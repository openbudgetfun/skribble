import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:skribble/skribble.dart';

import 'package:skribble_docs_site/src/document.dart';

/// Renders cached Markdown using Flutter's native text selection machinery.
class DocArticle extends HookWidget {
  /// Creates a document with explicit navigation and heading anchors.
  const DocArticle({
    required this.document,
    required this.onLink,
    required this.anchors,
    super.key,
  });

  /// Parsed document to display.
  final DocDocument document;

  /// Resolves both local and external links in the surrounding router.
  final ValueChanged<String> onLink;

  /// Stable keys used for table-of-contents and URL fragment navigation.
  final Map<String, GlobalKey> anchors;

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
            for (final node in document.nodes)
              RepaintBoundary(child: _block(node)),
          ],
        ),
      ),
    );
  }

  Widget _block(md.Node node) {
    if (node is md.Text && node.textContent.trimLeft().startsWith('<!--')) {
      return const SizedBox.shrink();
    }
    if (node is! md.Element) return _Paragraph(nodes: [node], onLink: onLink);
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
      'pre' => _CodeBlock(code: node.textContent),
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
                    Expanded(child: _block(children[index])),
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
            for (final child in children) _block(child)
          else
            _Paragraph(nodes: children, onLink: onLink),
        ],
      ),
      'blockquote' => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xffeef1df),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children.map(_block).toList(),
        ),
      ),
      'table' => _table(node),
      'hr' => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: WiredDivider(),
      ),
      'p' => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _Paragraph(nodes: children, onLink: onLink),
      ),
      // Generated MDT markers and old HTML embeds have no readable prose.
      'html' => const SizedBox.shrink(),
      _ => _Paragraph(nodes: children, onLink: onLink),
    };
  }

  Widget _table(md.Element table) {
    final rows = <md.Element>[];
    for (final section in table.children ?? <md.Node>[]) {
      if (section is md.Element) {
        rows.addAll((section.children ?? <md.Node>[]).whereType<md.Element>());
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(240),
          border: TableBorder.all(color: const Color(0xffdfd6ce)),
          children: [
            for (final row in rows)
              TableRow(
                children: [
                  for (final cell in row.children ?? <md.Node>[])
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: _Paragraph(
                        nodes: cell is md.Element
                            ? cell.children ?? []
                            : [cell],
                        onLink: onLink,
                        style: cell is md.Element && cell.tag == 'th'
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : null,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Paragraph extends HookWidget {
  const _Paragraph({required this.nodes, required this.onLink, this.style});
  final List<md.Node> nodes;
  final ValueChanged<String> onLink;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final content = useMemoized(() => _InlineContent(nodes, onLink), [
      nodes,
      onLink,
    ]);
    useEffect(() => content.dispose, [content]);

    return Text.rich(
      TextSpan(children: content.spans),
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
      'code' => const TextStyle(
        backgroundColor: Color(0xffeee7f0),
        fontSize: 15,
      ),
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

class _CodeBlock extends HookWidget {
  const _CodeBlock({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final copied = useState(false);

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xffeee9f0),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SelectionContainer.disabled(
              child: WiredTextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) copied.value = true;
                },
                child: Text(copied.value ? 'Copied!' : 'Copy code'),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              code,
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
