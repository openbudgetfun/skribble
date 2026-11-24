import 'package:html/dom.dart' as html;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';

/// Server-renders [component] and returns the parsed `<body>`.
///
/// Uses the same static rendering path as `jaspr build`, so assertions see
/// exactly the markup a zero-JavaScript site ships.
Future<html.Element> renderBody(
  ServerTester tester,
  Component component,
) async {
  tester.pumpComponent(component);
  final response = await tester.request('/');

  expect(response.statusCode, 200);

  return response.document!.body!;
}

/// Asserts that rendering [component] fails its build.
///
/// Jaspr catches the error, logs it to stderr, and answers with status 500,
/// so a static build reports it instead of shipping the bad markup.
Future<void> expectBuildError(ServerTester tester, Component component) async {
  tester.pumpComponent(component);
  final response = await tester.request('/');

  expect(response.statusCode, 500);
}

/// Server-renders [component] and returns the `<body>` markup.
Future<String> renderMarkup(ServerTester tester, Component component) async {
  final body = await renderBody(tester, component);

  return body.innerHtml;
}

/// The single element in [root] matching [selector].
html.Element single(html.Element root, String selector) {
  final matches = root.querySelectorAll(selector);

  expect(matches, hasLength(1), reason: selector);

  return matches.single;
}

/// Asserts that [svg] is a stretched, decorative ink overlay.
void expectInkOverlay(html.Element svg) {
  expect(svg.localName, 'svg');
  expect(svg.classes, contains('skribble-ink'));
  expect(svg.attributes['aria-hidden'], 'true');
  expect(svg.attributes['focusable'], 'false');
  expect(svg.attributes['preserveAspectRatio'], 'none');
  expect(svg.attributes['viewBox'], matches(RegExp(r'^0 0 \d+ \d+$')));

  for (final path in svg.querySelectorAll('path')) {
    expect(path.attributes['d'], matches(RegExp(r'^M[-\d. MLCZmlcz]+$')));

    if (path.attributes['stroke'] != 'none') {
      expect(path.attributes['vector-effect'], 'non-scaling-stroke');
    }
  }
}

/// Expands the compact path data the components write (relative commands,
/// implicit repeats, see `compactSvgPath`) into absolute `M`, `L`, `C`, and
/// `Z` commands with explicit separators, so tests can read coordinates.
String absolutePath(String data) {
  final tokens = RegExp(r'[MmLlCcZz]|-?(?:\d+\.?\d*|\.\d+)')
      .allMatches(data)
      .map((match) => match[0]!)
      .toList();
  const arity = {'M': 2, 'L': 2, 'C': 6, 'Z': 0};
  final out = StringBuffer();
  var x = 0.0;
  var y = 0.0;
  var startX = 0.0;
  var startY = 0.0;
  String? command;
  var i = 0;
  String n(double value) {
    final text = value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    return text == '-0' ? '0' : text;
  }

  while (i < tokens.length) {
    if (RegExp('[A-Za-z]').hasMatch(tokens[i])) command = tokens[i++];
    final kind = command!.toUpperCase();
    final relative = command != kind;
    if (kind == 'Z') {
      out.write('Z');
      x = startX;
      y = startY;
      continue;
    }
    final args = [
      for (var k = 0; k < arity[kind]!; k++) double.parse(tokens[i + k]),
    ];
    i += arity[kind]!;
    final points = <String>[];
    for (var k = 0; k < args.length; k += 2) {
      final px = relative ? x + args[k] : args[k];
      final py = relative ? y + args[k + 1] : args[k + 1];
      points.add('${n(px)} ${n(py)}');
      if (k == args.length - 2) {
        x = px;
        y = py;
      }
    }
    out.write('$kind${points.join(' ')}');
    if (kind == 'M') {
      startX = x;
      startY = y;
      command = relative ? 'l' : 'L';
    }
  }
  return out.toString();
}
