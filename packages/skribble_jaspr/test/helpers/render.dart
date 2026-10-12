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
    expect(path.attributes['d'], matches(RegExp(r'^M[-\d. MLCZ]+$')));

    if (path.attributes['stroke'] != 'none') {
      expect(path.attributes['vector-effect'], 'non-scaling-stroke');
    }
  }
}
