import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:highlight/highlight_core.dart' as syntax;
import 'package:highlight/languages/bash.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/swift.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';
import 'package:skribble_docs_site/src/find_in_page.dart';

final _syntax = syntax.Highlight()
  ..registerLanguage('dart', dart)
  ..registerLanguage('bash', bash)
  ..registerLanguage('css', css)
  ..registerLanguage('javascript', javascript)
  ..registerLanguage('json', json)
  ..registerLanguage('swift', swift)
  ..registerLanguage('xml', xml)
  ..registerLanguage('yaml', yaml);

/// Highlights source without changing its selectable or copied text.
TextSpan highlightCode(String code, String language) {
  final canonical = switch (language) {
    'js' || 'jsx' => 'javascript',
    'html' => 'xml',
    'sh' || 'shell' => 'bash',
    _ => language,
  };
  if (!{
    'dart',
    'bash',
    'css',
    'javascript',
    'json',
    'swift',
    'xml',
    'yaml',
  }.contains(canonical)) {
    return TextSpan(text: code);
  }

  return TextSpan(
    children: _syntax
        .parse(code, language: canonical)
        .nodes!
        .map(_span)
        .toList(),
  );
}

TextSpan _span(syntax.Node node) => TextSpan(
  text: node.value,
  style: TextStyle(
    color: switch (node.className) {
      'keyword' || 'literal' => const Color(0xff784175),
      'string' || 'regexp' => const Color(0xff35634b),
      'number' => const Color(0xff9c482b),
      'comment' => const Color(0xff716275),
      'title' || 'built_in' || 'type' => const Color(0xff315c83),
      _ => null,
    },
  ),
  children: node.children?.map(_span).toList(),
);

/// Selectable source with syntax colour and an exact-source copy action.
class CodeView extends HookWidget {
  /// Displays code in its declared language; unknown languages remain readable.
  const CodeView({
    required this.code,
    this.language = 'dart',
    this.findQuery = '',
    this.margin = const EdgeInsets.only(top: 4, bottom: 24),
    super.key,
  });

  /// Space around the panel; live examples tighten it inside their frame.
  final EdgeInsetsGeometry margin;

  /// Complete source copied to the clipboard.
  final String code;

  /// Markdown fence language.
  final String language;

  /// Current page search term, highlighted without changing copied source.
  final String findQuery;

  @override
  Widget build(BuildContext context) {
    final copied = useState(false);
    // A fenced block's closing newline would render as an empty last line;
    // the copy action still copies [code] exactly.
    final spans = useMemoized(
      () => highlightCode(
        code.endsWith('\n') ? code.substring(0, code.length - 1) : code,
        language,
      ),
      [code, language],
    );
    useEffect(() {
      copied.value = false;
      return null;
    }, [code]);

    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 18),
      decoration: docsSurface(context, color: const Color(0xffeee9f0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectionContainer.disabled(
            child: Row(
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      language.isEmpty ? 'text' : language,
                      style: const TextStyle(
                        fontSize: 12,
                        color: docsQuietInk,
                      ),
                    ),
                  ),
                ),
                DocsAction(
                  key: DocsKeys.copyCode,
                  dense: true,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) copied.value = true;
                  },
                  child: Text(
                    copied.value ? 'Copied!' : 'Copy code',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            padding: const EdgeInsets.only(right: 10),
            scrollDirection: Axis.horizontal,
            child: Text.rich(
              markTextMatches(spans, findQuery),
              style: TextStyle(
                fontFamily: WiredFont.mono.familyFor(
                  WiredTheme.of(context).roughnessLevel,
                ),
                package: 'skribble_font_recursive',
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
