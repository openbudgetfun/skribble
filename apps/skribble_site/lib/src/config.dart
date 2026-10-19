/// Where the built site is served from.
///
/// GitHub Pages serves the repository's site from `/skribble/` until a custom
/// domain is attached, then from `/`. Every page writes [basePath] into its
/// `<base href>`, so the same relative links work in both places, including
/// in `404.html`, which Pages serves at whatever path was requested.
final class SiteConfig {
  /// Creates a configuration for one deployment.
  const SiteConfig({
    this.basePath = '/',
    this.siteUrl = 'https://skribble.dev',
  });

  /// Normalizes [basePath] and [siteUrl] the way GitHub Pages reports them.
  factory SiteConfig.normalized({String basePath = '/', String? siteUrl}) {
    var base = basePath.trim();
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';

    var url = (siteUrl ?? 'https://skribble.dev').trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return SiteConfig(basePath: base, siteUrl: url);
  }

  /// The path the site is served under, with leading and trailing slashes.
  final String basePath;

  /// The public origin and path of the site, without a trailing slash.
  ///
  /// Used for canonical and social-preview links, which must be absolute.
  final String siteUrl;

  /// The absolute URL of [path], relative to the site root.
  String absolute(String path) => '$siteUrl/$path';
}

/// Links the landing page points at, relative to the site's base path.
abstract final class SiteLinks {
  /// The Flutter documentation site.
  static const docs = 'docs/';

  /// Installation guide.
  static const install = 'docs/getting-started/installation';

  /// The minimal app walkthrough.
  static const quickStart = 'docs/getting-started/quick-start';

  /// The widget catalog.
  static const widgets = 'docs/widgets/buttons';

  /// The Jaspr guide.
  static const jaspr = 'docs/guides/jaspr';

  /// The design kit and Figma guide.
  static const designKit = 'docs/reference/design-kit';

  /// The rough engine explainer.
  static const roughEngine = 'docs/core/rough-engine';

  /// The theme guide.
  static const theming = 'docs/getting-started/theming';

  /// The live Flutter storybook.
  static const storybook = 'docs/storybook/';

  /// The source repository.
  static const github = 'https://github.com/openbudgetfun/skribble';

  /// The main package on pub.dev.
  static const pub = 'https://pub.dev/packages/skribble';

  /// The bundled fonts' source folder.
  static const fontSource =
      'https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_font_recursive/assets/fonts';

  /// The editable Figma design system.
  static const figma =
      'https://www.figma.com/design/pjRi0rh4NWkGRROPlWLLBo/Skribble-Design-System';
}
