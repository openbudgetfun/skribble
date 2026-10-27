import 'package:jaspr/dom.dart' show RawText;
import 'package:jaspr/server.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';
import 'package:skribble_site/src/assets.dart';
import 'package:skribble_site/src/config.dart';
import 'package:skribble_site/src/controls.dart';
import 'package:skribble_site/src/html.dart';
import 'package:skribble_site/src/ink.dart';
import 'package:skribble_site/src/sections/companions.dart';
import 'package:skribble_site/src/sections/craft.dart';
import 'package:skribble_site/src/sections/hero.dart';
import 'package:skribble_site/src/sections/showcase.dart';

const _description =
    'skribble is a hand-drawn design system for Flutter: more than a hundred '
    'Wired widgets, three pens, hand-lettered fonts, rough icons, and emoji.';

/// Describes the link-preview image for screen readers and when it fails
/// to load.
const shareImageAlt =
    'skribble: hand-drawn widgets for Flutter, lettered in Noto Sketch.';

/// The document every page shares: metadata, styles, header, and footer.
class SitePage extends StatelessComponent {
  /// Creates a page with [body] between the header and footer.
  const SitePage({
    required this.config,
    required this.assets,
    required this.title,
    required this.path,
    required this.body,
    this.description = _description,
    this.noIndex = false,
    this.headScript,
    super.key,
  });

  /// Where the site is served.
  final SiteConfig config;

  /// Logo and fonts.
  final SiteAssets assets;

  /// The `<title>`.
  final String title;

  /// This page's path relative to the site root, for the canonical link.
  final String path;

  /// The page summary for search results and link previews.
  final String description;

  /// Whether search engines should skip this page.
  final bool noIndex;

  /// The page's main content.
  final List<Component> body;

  /// Inline JavaScript run in `<head>` before the page paints.
  final String? headScript;

  @override
  Component build(BuildContext context) {
    final canonical = config.absolute(path);
    final shareImage = config.absolute(SiteLinks.shareImage);

    return Document(
      title: title,
      lang: 'en',
      base: config.basePath,
      meta: {
        'description': description,
        'theme-color': '#fffaf0',
        'color-scheme': 'light dark',
        if (noIndex) 'robots': 'noindex',
      },
      head: [
        el('link', const [], null, {'rel': 'canonical', 'href': canonical}),
        el('link', const [], null, {
          'rel': 'icon',
          'href': 'favicon.svg',
          'type': 'image/svg+xml',
        }),
        for (final (_, file, _) in criticalFaces)
          el('link', const [], null, {
            'rel': 'preload',
            'href': 'fonts/$file',
            'as': 'font',
            'type': 'font/woff',
            'crossorigin': '',
          }),
        for (final (property, content) in [
          ('og:type', 'website'),
          ('og:title', title),
          ('og:description', description),
          ('og:url', canonical),
          ('og:site_name', 'skribble'),
          ('og:image', shareImage),
          ('og:image:type', 'image/png'),
          ('og:image:width', '1200'),
          ('og:image:height', '630'),
          ('og:image:alt', shareImageAlt),
        ])
          el('meta', const [], null, {
            'property': property,
            'content': content,
          }),
        for (final (name, content) in [
          ('twitter:card', 'summary_large_image'),
          ('twitter:title', title),
          ('twitter:description', description),
          ('twitter:image', shareImage),
          ('twitter:image:alt', shareImageAlt),
        ])
          el('meta', const [], null, {'name': name, 'content': content}),
        el('script', const [RawText(_bootScript)]),
        if (headScript case final script?) el('script', [RawText(script)]),
        el('style', [RawText(fontFaceCss(assets.fonts))]),
        el('script', [RawText(_inkReadyScript)]),
        el('style', [const RawText(skribbleCss)]),
        el('style', [
          RawText(':root{--slider-thumb:${sliderThumbDataUri()}}'),
        ]),
        el('link', const [], null, {'rel': 'stylesheet', 'href': 'site.css'}),
        el('script', const [], null, {'src': 'site.js', 'defer': ''}),
      ],
      body: Component.fragment([
        const Document.body(attributes: {'class': 'skribble-page'}),
        // With a <base> element, a bare "#main" resolves against the site
        // root, which is only this document on the landing page.
        if (path.isEmpty)
          el('a', [t('Skip to content')], 'skip-link', {'href': '#main'}),
        SiteHeader(logoSvg: assets.logoSvg),
        el('main', body, null, {'id': 'main'}),
        const SiteFooter(),
        const RawText(_wobbleFilters),
      ]),
    );
  }
}

/// Holds the page back until the [criticalFaces] load, for at most 3
/// seconds, so it never paints in a fallback font and then reflows.
///
/// It runs after the `@font-face` rules so `document.fonts.load` can find
/// them. The stylesheet hides the page while the root has `inking`, and
/// `site.js` starts its reveals on the `skribble:inked` event. Without
/// JavaScript or the Font Loading API nothing is hidden.
final _inkReadyScript =
    '''
(function (root) {
  if (!document.fonts || !document.fonts.load) return;
  root.classList.add("inking");
  var done = false;
  function show() {
    if (done) return;
    done = true;
    root.classList.remove("inking");
    document.dispatchEvent(new Event("skribble:inked"));
  }
  var faces = [${criticalFaces.map((face) => '"${face.$3} 1em ${face.$1}"').join(', ')}];
  Promise.all(faces.map(function (face) {
    return document.fonts.load(face);
  })).then(show, show);
  setTimeout(show, 3000);
})(document.documentElement);''';

/// SVG filters that make clean artwork wobble like a hand-drawn line.
///
/// Two seeds are swapped in steps for a "line boil"; the stylesheet turns
/// them off under reduced motion.
const _wobbleFilters = '''
<svg class="filters" aria-hidden="true" focusable="false" width="0" height="0">
  <filter id="wobble-a">
    <feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="2" seed="2"/>
    <feDisplacementMap in="SourceGraphic" scale="2.4"/>
  </filter>
  <filter id="wobble-b">
    <feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="2" seed="9"/>
    <feDisplacementMap in="SourceGraphic" scale="2.4"/>
  </filter>
</svg>''';

/// Marks the page as scripted and applies the saved theme before first
/// paint, so reveal animations only hide content when the script that shows
/// it is running, and dark paper never flashes light.
const _bootScript = '''
(function (root) {
  root.classList.add("js");
  try {
    var theme = localStorage.getItem("skribble-theme");
    if (theme) root.dataset.theme = theme;
  } catch (error) {}
})(document.documentElement);''';

/// The sticky header with the logo, section links, and theme toggle.
class SiteHeader extends StatelessComponent {
  /// Creates the header around [logoSvg].
  const SiteHeader({required this.logoSvg, super.key});

  /// The inline logo.
  final String logoSvg;

  @override
  Component build(BuildContext context) {
    return el('header', [
      el(
        'a',
        [
          RawText(logoSvg),
          el('span', [t('skribble')], 'brand-name'),
        ],
        'brand',
        {'href': './', 'aria-label': 'skribble home'},
      ),
      el(
        'nav',
        [
          el('ul', [
            for (final (href, label) in const [
              ('./#widgets', 'Widgets'),
              ('./#pens', 'Pens'),
              ('./#fonts', 'Fonts'),
              (SiteLinks.docs, 'Docs'),
            ])
              el('li', [
                anchor(href, [t(label)]),
              ]),
            el('li', [
              anchor(SiteLinks.github, [t('GitHub')]),
            ]),
          ]),
        ],
        'site-nav',
        {'aria-label': 'Main'},
      ),
      el(
        'button',
        [
          doodle(
            width: 28,
            height: 28,
            classes: 'theme-sun',
            marks: [
              Mark(
                roughOval(
                  Pen.playful.generator(700, fill: RoughFillStyle.solid),
                  28,
                  28,
                  inset: 8,
                ),
                fill: Tone.sun,
              ),
              for (var i = 0; i < 8; i++)
                Mark(
                  Pen.playful
                      .generator(701 + i)
                      .line(
                        14 + 8.5 * _cos(i),
                        14 + 8.5 * _sin(i),
                        14 + 12.5 * _cos(i),
                        14 + 12.5 * _sin(i),
                      ),
                  width: 1.8,
                ),
            ],
          ),
          doodle(
            width: 28,
            height: 28,
            classes: 'theme-moon',
            marks: [
              Mark(
                Pen.playful
                    .generator(710, fill: RoughFillStyle.solid)
                    .curvePath([
                      for (final (x, y) in const [
                        (18.0, 4.0),
                        (8.0, 7.0),
                        (6.0, 17.0),
                        (13.0, 24.0),
                        (23.0, 21.0),
                        (15.0, 16.0),
                        (18.0, 4.0),
                      ])
                        PointD(x, y),
                    ]),
                fill: Tone.lilac,
              ),
            ],
          ),
        ],
        'theme-toggle',
        {
          'type': 'button',
          'aria-label': 'Switch between light and dark paper',
          'hidden': '',
        },
      ),
    ], 'site-header');
  }
}

double _cos(int i) => _trig[i].$1;
double _sin(int i) => _trig[i].$2;

const _trig = [
  (1.0, 0.0),
  (0.7071, 0.7071),
  (0.0, 1.0),
  (-0.7071, 0.7071),
  (-1.0, 0.0),
  (-0.7071, -0.7071),
  (0.0, -1.0),
  (0.7071, -0.7071),
];

/// The footer: links, licences, and a sign-off doodle.
class SiteFooter extends StatelessComponent {
  /// Creates the footer.
  const SiteFooter({super.key});

  @override
  Component build(BuildContext context) {
    Component column(String title, List<(String, String)> links) => el('div', [
      el('h2', [t(title)]),
      el('ul', [
        for (final (href, label) in links)
          el('li', [
            anchor(href, [t(label)]),
          ]),
      ]),
    ]);

    return el('footer', [
      const WiredDivider(seed: 800),
      el('div', [
        column('Learn', const [
          (SiteLinks.install, 'Installation'),
          (SiteLinks.quickStart, 'Quick start'),
          (SiteLinks.widgets, 'Widget catalog'),
          (SiteLinks.storybook, 'Storybook'),
        ]),
        column('Build', const [
          (SiteLinks.theming, 'Theming'),
          (SiteLinks.roughEngine, 'Rough engine'),
          (SiteLinks.jaspr, 'skribble on Jaspr'),
          (SiteLinks.designKit, 'Design kit'),
        ]),
        column('Project', const [
          (SiteLinks.github, 'GitHub'),
          (SiteLinks.pub, 'pub.dev'),
          (SiteLinks.figma, 'Figma'),
          (SiteLinks.whatsNew, "What's new"),
          ('${SiteLinks.github}/issues', 'Report an issue'),
        ]),
        el('div', [
          para(
            'Code under the MIT licence. Fonts under the SIL Open Font '
            'License. Drawn on the server with skribble_jaspr.',
            classes: 'muted',
          ),
          doodle(
            width: 160,
            height: 60,
            classes: 'draw footer-doodle',
            marks: [
              Mark(
                roughHeart(
                  Pen.playful.generator(
                    810,
                    fill: RoughFillStyle.hachure,
                    gap: 4,
                  ),
                  4,
                  6,
                  50,
                ),
                stroke: Tone.coral,
                fill: Tone.pink,
              ),
              Mark(
                roughStar(
                  Pen.playful.generator(811, fill: RoughFillStyle.solid),
                  100,
                  30,
                  18,
                ),
                fill: Tone.sun,
              ),
            ],
          ),
        ], 'footer-note'),
      ], 'footer-grid'),
    ], 'site-footer');
  }
}

/// The landing page.
class LandingPage extends StatelessComponent {
  /// Creates the landing page.
  const LandingPage({required this.config, required this.assets, super.key});

  /// Where the site is served.
  final SiteConfig config;

  /// Artwork and fonts.
  final SiteAssets assets;

  @override
  Component build(BuildContext context) {
    return SitePage(
      config: config,
      assets: assets,
      title: 'skribble: a hand-drawn design system for Flutter',
      path: '',
      body: [
        const Hero(),
        const Marquee(),
        const FillGallery(),
        const PenComparison(),
        const Playground(),
        const ChartsAndMaps(),
        Lettering(fonts: assets.fonts),
        ArtWall(assets: assets),
        const CodeSample(),
        const BeyondFlutter(),
        const Closing(),
      ],
    );
  }
}

/// The page GitHub Pages serves for any missing path.
///
/// Before this site existed, the documentation lived at the site root, so
/// `site.js` first tries the same path under `docs/`. Paths from the old
/// skribble.dev font shop go to the lettering section.
class NotFoundPage extends StatelessComponent {
  /// Creates the not-found page.
  const NotFoundPage({required this.config, required this.assets, super.key});

  /// Where the site is served.
  final SiteConfig config;

  /// Logo and fonts.
  final SiteAssets assets;

  @override
  Component build(BuildContext context) {
    return SitePage(
      config: config,
      assets: assets,
      title: 'Page not found · skribble',
      path: '404.html',
      noIndex: true,
      headScript: notFoundRedirect,
      body: [
        el('section', [
          doodle(
            width: 240,
            height: 160,
            classes: 'draw lost-doodle',
            label: 'A torn sketchbook page',
            marks: [
              Mark(
                Pen.expressive.generator(900).polygon([
                  for (final (x, y) in const [
                    (20.0, 20.0),
                    (210.0, 14.0),
                    (200.0, 70.0),
                    (222.0, 96.0),
                    (196.0, 148.0),
                    (24.0, 142.0),
                  ])
                    PointD(x, y),
                ]),
                width: 2.4,
              ),
              Mark(
                roughCurve(Pen.expressive.generator(901), [
                  (80, 70),
                  (95, 60),
                  (110, 70),
                ]),
              ),
              Mark(
                roughCurve(Pen.expressive.generator(902), [
                  (130, 70),
                  (145, 60),
                  (160, 70),
                ]),
              ),
              Mark(
                roughCurve(Pen.expressive.generator(903), [
                  (90, 115),
                  (120, 100),
                  (150, 115),
                ]),
                stroke: Tone.coral,
              ),
            ],
          ),
          el('h1', [t('This page got erased')]),
          para(
            'The link may be from the old site. Looking for the docs? '
            'They moved under /docs.',
            classes: 'lede',
          ),
          el('div', [
            WiredButton(href: './', seed: 910, child: t('Go home')),
            WiredButton(
              href: SiteLinks.docs,
              seed: 911,
              variant: WiredButtonVariant.secondary,
              child: t('Open the docs'),
            ),
          ], 'hero-actions'),
        ], 'lost'),
      ],
    );
  }
}

/// Sends old links to their new home before the not-found page paints.
///
/// The documentation used to be served from the site root, so any path
/// outside `docs/` is retried there; a missing docs page lands back here
/// with the prefix and is left alone, so this can never loop. Paths from the
/// old skribble.dev font shop go to the lettering section.
const notFoundRedirect = r'''
(function () {
  var base = new URL(document.baseURI).pathname;
  var path = location.pathname;
  if (path.indexOf(base) !== 0) return;
  var rest = path.slice(base.length).replace(/^\/+/, '');
  var legacy = /^(monospace|downloads|eula|terms|license)(\/|$)/;
  var retired = /^(about|faq|playground|chat)(\/|$)/;
  if (legacy.test(rest)) {
    location.replace(base + '#fonts');
  } else if (retired.test(rest)) {
    location.replace(base);
  } else if (rest && rest.indexOf('docs/') !== 0 && rest !== 'docs') {
    location.replace(base + 'docs/' + rest + location.search + location.hash);
  }
})();
''';
