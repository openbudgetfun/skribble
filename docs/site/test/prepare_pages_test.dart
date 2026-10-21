import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/prepare_pages.dart' as pages;

void main() {
  test('release manifest keeps reading faces and defers comparison faces', () {
    final output = Directory.systemTemp.createTempSync('skribble-docs-fonts-');
    addTearDown(() => output.deleteSync(recursive: true));
    final assets = Directory('${output.path}/assets')..createSync();
    final manifest = File('${assets.path}/FontManifest.json');
    final deferred = File('${assets.path}/DeferredFontManifest.json');

    Map<String, Object> family(String name, {bool variable = false}) => {
      'family': name,
      'fonts': variable
          ? [
              {'asset': 'fonts/$name.ttf'},
            ]
          : [
              for (final weight in [300, 400, 500, 600, 700, 800, 900])
                for (final style in ['normal', 'italic'])
                  {
                    'weight': weight,
                    if (style == 'italic') 'style': style,
                    'asset': 'fonts/$name-$weight-$style.ttf',
                  },
            ],
    };

    manifest.writeAsStringSync(
      jsonEncode([
        family('MaterialIcons', variable: true),
        family('packages/skribble_font_recursive/SkribblePlayful'),
        family('packages/skribble_font_recursive/SkribbleMonoPlayful'),
        family('packages/skribble_font_recursive/SkribbleLinearPlayful'),
        family(
          'packages/skribble_font_recursive/SkribbleVariablePlayful',
          variable: true,
        ),
        family('RecursiveCasualOriginal'),
      ]),
    );

    pages.deferComparisonFonts(output);

    final startup = (jsonDecode(manifest.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    final comparison = (jsonDecode(deferred.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    expect(startup.map((family) => family['family']), [
      'MaterialIcons',
      'packages/skribble_font_recursive/SkribbleMonoPlayful',
    ]);
    expect(
      startup.skip(1).map((family) => (family['fonts'] as List).length),
      [4],
    );
    expect(comparison.map((family) => family['family']), [
      'packages/skribble_font_recursive/SkribblePlayful',
      'packages/skribble_font_recursive/SkribbleMonoPlayful',
      'packages/skribble_font_recursive/SkribbleLinearPlayful',
      'packages/skribble_font_recursive/SkribbleVariablePlayful',
      'RecursiveCasualOriginal',
    ]);
    expect(
      comparison.map((family) => (family['fonts'] as List).length),
      [14, 10, 14, 1, 14],
    );

    final before = deferred.readAsStringSync();
    pages.deferComparisonFonts(output);
    expect(deferred.readAsStringSync(), before);
  });

  test('each docs page previews as itself when shared', () {
    const bootstrap = '''
<head>
  <base href="/docs/">
  <meta name="description" content="Generic">
  <title>skribble — make something delightful</title>
</head>''';
    final frontmatter = pages.readFrontmatter('''
---
title: Maps & pins
description: Hand-drawn "pins" on a crisp basemap.
---

# Maps
''');
    expect(frontmatter, {
      'title': 'Maps & pins',
      'description': 'Hand-drawn "pins" on a crisp basemap.',
    });

    final html = pages.withShareMetadata(
      bootstrap,
      frontmatter: frontmatter,
      route: 'widgets/maps',
      siteUrl: 'https://skribble.dev',
    );
    expect(html, contains('<title>Maps &amp; pins · skribble docs</title>'));
    expect(
      html,
      contains(
        '<meta name="description" '
        'content="Hand-drawn &quot;pins&quot; on a crisp basemap.">',
      ),
    );
    expect(html, isNot(contains('Generic')));
    const page = 'https://skribble.dev/docs/widgets/maps';
    const image = 'https://skribble.dev/docs/share-card.png';
    for (final tag in [
      '<link rel="canonical" href="$page">',
      '<meta property="og:url" content="$page">',
      '<meta property="og:image" content="$image">',
      '<meta property="og:image:width" content="1200">',
      '<meta name="twitter:card" content="summary_large_image">',
      '<meta name="twitter:image" content="$image">',
    ]) {
      expect(html, contains(tag));
    }

    final project = pages.withShareMetadata(
      bootstrap.replaceFirst('/docs/', '/skribble/docs/'),
      frontmatter: const {'title': 'skribble'},
      route: '',
      siteUrl: 'https://openbudgetfun.github.io/skribble',
    );
    expect(project, contains('<title>skribble</title>'));
    expect(
      project,
      contains('content="https://openbudgetfun.github.io/skribble/docs/"'),
    );
  });
}
