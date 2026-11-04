// Renders a small hand-drawn page to static HTML and prints it.
//
// Run with `dart run example/main.dart > sketchbook.html`, then open the
// file in a browser. No client JavaScript is needed.
import 'dart:convert';
import 'dart:io';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

Future<void> main() async {
  Jaspr.initializeApp();

  final response = await renderComponent(
    const Document(
      title: 'Sketchbook',
      head: [
        Component.element(tag: 'style', children: [RawText(skribbleCss)]),
      ],
      body: Sketchbook(),
    ),
  );

  stdout.write(utf8.decode(response.body));
}

/// A page that shows each skribble_jaspr component once.
class Sketchbook extends StatelessComponent {
  /// Creates the example page.
  const Sketchbook({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const Document.body(attributes: {'class': 'skribble-page'}),
      Component.element(
        tag: 'main',
        children: [
          const Component.element(
            tag: 'h1',
            children: [
              Component.text('Draw it '),
              WiredHighlight(
                kind: WiredHighlightKind.circle,
                seed: 3,
                child: Component.text('differently'),
              ),
            ],
          ),
          const WiredCard(
            seed: 5,
            fillStyle: RoughFillStyle.hachure,
            fill: '#ffe08a',
            child: Component.text('A hatched card'),
          ),
          const WiredDivider(seed: 2),
          const WiredButton(
            href: '#start',
            child: Component.text('Start sketching'),
          ),
          const WiredButton(
            seed: 4,
            variant: WiredButtonVariant.secondary,
            child: Component.text('Read the docs'),
          ),
          WiredSketch.curve(
            width: 160,
            height: 80,
            points: const [(6, 70), (50, 20), (110, 60), (154, 14)],
            arrowhead: true,
            label: 'An arrow pointing at the buttons',
          ),
        ],
      ),
    ]);
  }
}
