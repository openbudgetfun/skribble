import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as parser;
import 'package:jaspr/server.dart';
import 'package:skribble_site/skribble_site.dart';
import 'package:test/test.dart';

final Directory _root = findWorkspaceRoot();
final SiteAssets _assets = loadSiteAssets(_root);

Future<html.Document> _render(Component page) async {
  final response = await renderComponent(page);

  return parser.parse(utf8.decode(response.body));
}

void main() {
  setUpAll(Jaspr.initializeApp);

  group('SiteConfig', () {
    test('normalizes base paths and site URLs', () {
      final config = SiteConfig.normalized(
        basePath: 'skribble',
        siteUrl: 'https://openbudgetfun.github.io/skribble/',
      );

      expect(config.basePath, '/skribble/');
      expect(config.siteUrl, 'https://openbudgetfun.github.io/skribble');
      expect(
        config.absolute('404.html'),
        'https://openbudgetfun.github.io/skribble/404.html',
      );
    });

    test('defaults to the skribble.dev root', () {
      final config = SiteConfig.normalized();

      expect(config.basePath, '/');
      expect(config.absolute(''), 'https://skribble.dev/');
    });
  });

  group('landing page', () {
    late html.Document page;

    setUpAll(() async {
      page = await _render(
        LandingPage(
          config: SiteConfig.normalized(basePath: '/skribble/'),
          assets: _assets,
        ),
      );
    });

    test('resolves every relative URL against the base path', () {
      expect(page.querySelector('base')?.attributes['href'], '/skribble/');
      expect(
        page.querySelector('link[rel="canonical"]')?.attributes['href'],
        'https://skribble.dev/',
      );
    });

    test('previews as a large card when the link is shared', () {
      String? meta(String key) =>
          (page.querySelector('meta[property="$key"]') ??
                  page.querySelector('meta[name="$key"]'))
              ?.attributes['content'];

      expect(meta('og:image'), 'https://skribble.dev/docs/share-card.png');
      expect(meta('og:image:width'), '1200');
      expect(meta('og:image:height'), '630');
      expect(meta('og:image:alt'), contains('Noto Sketch'));
      expect(meta('og:title'), page.querySelector('title')?.text);
      expect(meta('og:description'), meta('description'));
      expect(meta('twitter:card'), 'summary_large_image');
      expect(meta('twitter:image'), meta('og:image'));
      expect(meta('twitter:title'), meta('og:title'));
      expect(meta('twitter:description'), meta('og:description'));
      expect(meta('twitter:image:alt'), meta('og:image:alt'));
    });

    test('letters the page in Noto Sketch', () {
      final css = File('${_root.path}/apps/skribble_site/web/site.css')
          .readAsStringSync();

      expect(criticalFaces.first.$1, 'SkribbleNotoSketch');
      expect(css, contains('--font-body: "SkribbleNotoSketch"'));
      expect(css, contains('--font-display: var(--font-body);'));
    });

    test('letters headings in Noto Sketch without a faux bold', () {
      final css = File('${_root.path}/apps/skribble_site/web/site.css')
          .readAsStringSync();
      final headings = RegExp(r'h1,\s*h2,\s*h3\s*\{([^}]*)\}').firstMatch(css);

      expect(headings, isNotNull);
      expect(headings![1], contains('font-family: var(--font-display);'));
      expect(css, contains('font-synthesis: none;'));
    });

    test('shows what the chart and map packages draw', () {
      final section = page.getElementById('charts-maps')!;
      final widgets = section.querySelectorAll('h3 code').map((c) => c.text);
      final links = section
          .querySelectorAll('a')
          .map((a) => a.attributes['href']);
      final drawings = section.querySelectorAll('svg[role="img"]');

      expect(widgets, ['WiredFinancialChart', 'WiredMap']);
      expect(links, containsAll([SiteLinks.charts, SiteLinks.maps]));
      expect(drawings, hasLength(2));
      expect(
        drawings.map((svg) => svg.attributes['aria-label']),
        everyElement(isNotEmpty),
      );
      expect(section.text, contains('flutter pub add skribble_charts'));
      expect(section.text, contains('flutter pub add skribble_maps'));
      expect(section.querySelector('.chart-price--mark')?.text, '145.00');
    });

    test('has one h1 and labelled sections', () {
      expect(page.querySelectorAll('h1'), hasLength(1));

      for (final section in page.querySelectorAll('section')) {
        final labelledBy = section.attributes['aria-labelledby'];
        expect(
          labelledBy,
          isNotNull,
          reason: section.outerHtml.substring(0, 80),
        );
        expect(page.getElementById(labelledBy!), isNotNull, reason: labelledBy);
      }
    });

    test('renders every section the header links to', () {
      for (final id in ['widgets', 'pens', 'fonts', 'ink', 'art', 'code']) {
        expect(page.getElementById(id), isNotNull, reason: id);
      }
    });

    test('gives every image alternative text', () {
      for (final image in page.querySelectorAll('img')) {
        expect(image.attributes['alt'], isNotEmpty, reason: image.outerHtml);
      }
    });

    test('labels every form control', () {
      for (final input in page.querySelectorAll('input')) {
        final id = input.attributes['id'];
        final labelled =
            input.attributes.containsKey('aria-label') ||
            _hasAncestor(input, 'label') ||
            (id != null && page.querySelector('label[for="$id"]') != null);

        expect(labelled, isTrue, reason: input.outerHtml);
      }
    });

    test('hides decorative ink from assistive technology', () {
      final inks = page.querySelectorAll('svg.ink');
      expect(inks, isNotEmpty);

      for (final ink in inks) {
        final decorative = ink.attributes['aria-hidden'] == 'true';
        final labelled =
            ink.attributes['role'] == 'img' &&
            (ink.attributes['aria-label'] ?? '').isNotEmpty;

        expect(decorative || labelled, isTrue);
      }
    });

    test('lets every stroke draw itself on', () {
      final strokes = page.querySelectorAll('svg.ink path.ink-line');
      expect(strokes, isNotEmpty);

      for (final stroke in strokes) {
        expect(
          stroke.attributes['pathLength'] ?? stroke.attributes['pathlength'],
          '1',
        );
      }
    });

    test('draws each pen variant of the phone', () {
      final phone = page.querySelector('.phone')!;

      expect(phone.attributes['data-pen'], 'playful');
      for (final pen in ['gentle', 'playful', 'expressive']) {
        expect(phone.querySelectorAll('.pen--$pen'), isNotEmpty, reason: pen);
      }
    });

    test('only loads its own scripts and styles', () {
      final scripts = page
          .querySelectorAll('script[src]')
          .map((script) => script.attributes['src']);
      final styles = page
          .querySelectorAll('link[rel="stylesheet"]')
          .map((link) => link.attributes['href']);

      expect(scripts, ['site.js']);
      expect(styles, ['site.css']);
    });

    test('preloads the fonts it waits for before showing', () {
      final preloads = page
          .querySelectorAll('link[rel="preload"][as="font"]')
          .map((link) => link.attributes['href']);
      final inline = page
          .querySelectorAll('head script:not([src])')
          .map((script) => script.text)
          .join();

      expect(preloads, [
        for (final (_, file, _) in criticalFaces) 'fonts/$file',
      ]);
      for (final (family, _, weight) in criticalFaces) {
        expect(inline, contains('$weight 1em $family'), reason: family);
      }
      expect(inline, contains('inking'));
      expect(inline, contains('setTimeout(show, 3000)'));
    });

    test('serves every font face as a web font', () {
      final css = page
          .querySelectorAll('head style')
          .map((style) => style.text)
          .join();

      expect(css, isNot(contains('.ttf')));
      for (final family in _assets.fonts) {
        expect(css, contains('font-family:"${family.family}"'));
        for (final face in family.faces) {
          expect(css, contains('fonts/${face.webFile}'), reason: face.file);
        }
      }
    });

    test('offers every font family in the tester', () {
      final picks = page
          .querySelectorAll('input[name="font-family"]')
          .map((input) => input.attributes['value']);

      expect(picks, [for (final family in _assets.fonts) family.family]);
      expect(picks.first, 'SkribbleNotoSketch');
      expect(
        page
            .querySelector('input[name="font-family"][checked]')
            ?.attributes['value'],
        'SkribbleNotoSketch',
      );
      expect(
        page.querySelector('[data-font-install]')?.text,
        'flutter pub add skribble_font_noto_sketch',
      );
    });

    test('keeps internal links relative so the base path applies', () {
      for (final link in page.querySelectorAll('a[href]')) {
        final href = link.attributes['href']!;
        if (href.startsWith('https://')) continue;

        expect(href.startsWith('/'), isFalse, reason: href);
      }
    });

    test('links only to documentation pages that exist', () {
      final content = '${_root.path}/docs/site/content';
      final docsLinks = page
          .querySelectorAll('a[href^="docs/"]')
          .map((link) => Uri.parse(link.attributes['href']!).path)
          .toSet();

      expect(docsLinks, isNotEmpty);

      for (final href in docsLinks) {
        final route = href
            .substring('docs/'.length)
            .replaceFirst(RegExp(r'/$'), '');
        if (route.isEmpty || route == 'storybook') continue;

        expect(
          File('$content/$route.md').existsSync(),
          isTrue,
          reason: '$href has no docs/site/content/$route.md',
        );
      }
    });

    test('renders the same markup every build', () async {
      final again = await _render(
        LandingPage(
          config: SiteConfig.normalized(basePath: '/skribble/'),
          assets: _assets,
        ),
      );

      expect(again.outerHtml, page.outerHtml);
    });
  });

  group('not found page', () {
    late html.Document page;

    setUpAll(() async {
      page = await _render(
        NotFoundPage(config: SiteConfig.normalized(), assets: _assets),
      );
    });

    test('is kept out of search results', () {
      expect(
        page.querySelector('meta[name="robots"]')?.attributes['content'],
        'noindex',
      );
    });

    test('redirects old documentation links before painting', () {
      final inline = page
          .querySelectorAll('head script:not([src])')
          .map((script) => script.text)
          .join();

      expect(inline, contains("'docs/'"));
      expect(inline, contains('#fonts'));
    });

    test('offers a way home and to the docs', () {
      final hrefs = page
          .querySelectorAll('.lost a')
          .map((link) => link.attributes['href']);

      expect(hrefs, containsAll(['./', 'docs/']));
    });
  });

  group('workspace assets', () {
    test('resolves every emoji colour token', () {
      expect(_assets.emoji, hasLength(featuredEmoji.length));

      for (final art in _assets.emoji) {
        expect(art.svg, isNot(contains('data-include')), reason: art.name);
        expect(
          RegExp('(fill|stroke)="(?!none|#)[^"]*"').hasMatch(art.svg),
          isFalse,
          reason: art.name,
        );
      }
    });

    test('finds every featured icon', () {
      expect(_assets.icons.map((icon) => icon.name), featuredIcons);

      for (final icon in _assets.icons) {
        expect(icon.paths, isNotEmpty, reason: icon.name);
      }
    });

    test('ships font files that exist', () {
      for (final family in _assets.fonts) {
        final fonts = '${_root.path}/packages/${family.package}/assets/fonts';

        for (final face in family.faces) {
          expect(
            File('$fonts/${face.file}').existsSync(),
            isTrue,
            reason: face.file,
          );
        }
        expect(File('$fonts/OFL.txt').existsSync(), isTrue);
      }
    });

    test('shows the Recursive families and every Noto level it can find', () {
      final families = _assets.fonts.map((family) => family.family).toList();

      expect(
        families,
        containsAll([
          'SkribblePlayful',
          'SkribbleGentle',
          'Skribble',
          'SkribbleMonoPlayful',
        ]),
      );
      for (final family in fontFamilies) {
        final present = Directory(
          '${_root.path}/packages/${family.package}',
        ).existsSync();

        expect(
          families.contains(family.family),
          present,
          reason: family.family,
        );
      }
    });

    test('recolours the logo for both themes', () {
      expect(_assets.logoSvg, contains('currentColor'));
      expect(_assets.logoSvg, contains('var(--logo-face)'));
      expect(_assets.logoSvg, isNot(contains('width="100"')));
    });

    test('counts the shipped artwork', () {
      expect(_assets.emojiCount, greaterThan(1000));
      expect(_assets.iconCount, greaterThan(1000));
    });
  });

  test('builds a deployable folder', () async {
    final output = Directory.systemTemp.createTempSync('skribble_site_');
    addTearDown(() => output.deleteSync(recursive: true));

    await buildSite(
      config: SiteConfig.normalized(basePath: '/skribble/'),
      root: _root,
      output: output,
    );

    for (final file in [
      'index.html',
      '404.html',
      'site.css',
      'site.js',
      'favicon.svg',
      'robots.txt',
      'fonts/OFL.txt',
      'fonts/SkribblePlayful-Regular.woff',
      for (final (_, file, _) in criticalFaces) 'fonts/$file',
      'emoji/rocket.svg',
    ]) {
      expect(File('${output.path}/$file').existsSync(), isTrue, reason: file);
    }
  });
}

bool _hasAncestor(html.Element element, String tag) {
  for (var parent = element.parent; parent != null; parent = parent.parent) {
    if (parent.localName == tag) return true;
  }

  return false;
}
