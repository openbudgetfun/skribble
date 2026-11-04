/// A style rule in a stylesheet, with the at-rule preludes around it.
typedef CssRule = ({
  String selector,
  Map<String, String> declarations,
  List<String> atRules,
});

/// Splits [css] into its style rules, ignoring comments.
///
/// Handles the flat and nested-once structure of `skribbleCss`: plain rules
/// and rules inside `@media` or `@keyframes`.
List<CssRule> cssRules(String css) {
  final source = css.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  final rules = <CssRule>[];
  final atRules = <String>[];
  var start = 0;

  for (var i = 0; i < source.length; i++) {
    if (source[i] == '}') {
      atRules.removeLast();
      start = i + 1;
      continue;
    }

    if (source[i] != '{') continue;

    final prelude = source.substring(start, i).trim();
    final close = source.indexOf('}', i);
    final open = source.indexOf('{', i + 1);

    if (open != -1 && open < close) {
      atRules.add(prelude);
      start = i + 1;
      continue;
    }

    rules.add((
      selector: prelude,
      declarations: _declarations(source.substring(i + 1, close)),
      atRules: List.unmodifiable(atRules),
    ));
    i = close;
    start = close + 1;
  }

  return rules;
}

/// The declarations of the top-level rule whose selector is [selector].
Map<String, String> ruleFor(String css, String selector) =>
    cssRules(
          css,
        )
        .singleWhere(
          (rule) => rule.selector == selector && rule.atRules.isEmpty,
        )
        .declarations;

/// Converts a CSS length in `px`, `rem`, or `em` to pixels.
double cssPixels(String length, {required double em, double rem = 16}) {
  final match = RegExp(r'^(-?[\d.]+)(px|rem|em)$').firstMatch(length.trim());

  if (match == null) throw FormatException('Unsupported length', length);

  final value = double.parse(match[1]!);

  return switch (match[2]) {
    'px' => value,
    'rem' => value * rem,
    _ => value * em,
  };
}

Map<String, String> _declarations(String body) => {
  for (final declaration in body.split(';'))
    if (declaration.contains(':'))
      declaration.substring(0, declaration.indexOf(':')).trim(): declaration
          .substring(declaration.indexOf(':') + 1)
          .trim(),
};
