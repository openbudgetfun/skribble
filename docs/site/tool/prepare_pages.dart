import 'dart:convert';
import 'dart:io';

/// Adds static entrypoints so GitHub Pages can reload extensionless routes.
void main(List<String> args) {
  final output = Directory('build/web');

  if (args.contains('--defer-fonts')) {
    deferComparisonFonts(output);
  }

  final bootstrap = File('${output.path}/index.html').readAsStringSync();
  final siteUrl =
      Platform.environment['DOCS_SITE_URL'] ?? 'https://skribble.dev';
  final pages = Directory('content')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'));

  for (final page in pages) {
    final route = page.path
        .substring('content/'.length)
        .replaceFirst(RegExp(r'\.md$'), '')
        .replaceFirst(RegExp(r'(^|/)index$'), '');
    final html = withShareMetadata(
      bootstrap,
      frontmatter: readFrontmatter(page.readAsStringSync()),
      route: route,
      siteUrl: siteUrl,
    );
    final target = File(
      route.isEmpty
          ? '${output.path}/index.html'
          : '${output.path}/$route/index.html',
    );
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(html);
  }

  File('${output.path}/404.html').writeAsStringSync(bootstrap);
}

/// The link-preview image the docs build renders next to `index.html`
/// (see `tool/share_card_test.dart`).
const shareImage = 'share-card.png';

/// The `title` and `description` from a page's frontmatter.
Map<String, String> readFrontmatter(String markdown) {
  final match = RegExp(r'^---\n([\s\S]*?)\n---').firstMatch(markdown);
  if (match == null) return const {};
  return {
    for (final line in match.group(1)!.split('\n'))
      if (RegExp(r'^(\w+):\s*(.+)$').firstMatch(line) case final field?)
        field.group(1)!: field
            .group(2)!
            .trim()
            .replaceAll(RegExp(r'^"|"$'), '')
            .replaceAll(RegExp(r"^'|'$"), ''),
  };
}

/// [bootstrap] with the page's own title, description, canonical link, and
/// Open Graph and Twitter card metadata, so a shared docs link previews as
/// that page. [siteUrl] is the public origin, such as `https://skribble.dev`;
/// the docs path comes from the bootstrap's `<base href>`.
String withShareMetadata(
  String bootstrap, {
  required Map<String, String> frontmatter,
  required String route,
  required String siteUrl,
}) {
  final base =
      RegExp('<base href="([^"]*)">').firstMatch(bootstrap)?.group(1) ?? '/';
  final docs = '${Uri.parse(siteUrl).origin}$base';
  final url = '$docs$route';
  final heading = frontmatter['title'];
  final title = heading == null || route.isEmpty
      ? (heading ?? 'skribble docs')
      : '$heading · skribble docs';
  final description =
      frontmatter['description'] ??
      'Hand-drawn Flutter widgets: guides and a live example for every one.';
  final image = '$docs$shareImage';
  const imageAlt =
      'skribble: hand-drawn widgets for Flutter, lettered in Noto Sketch.';

  String escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  String property(String name, String content) =>
      '  <meta property="$name" content="${escape(content)}">';
  String named(String name, String content) =>
      '  <meta name="$name" content="${escape(content)}">';

  final metadata = [
    '<title>${escape(title)}</title>',
    '  <link rel="canonical" href="${escape(url)}">',
    property('og:type', 'website'),
    property('og:site_name', 'skribble'),
    property('og:title', title),
    property('og:description', description),
    property('og:url', url),
    property('og:image', image),
    property('og:image:type', 'image/png'),
    property('og:image:width', '1200'),
    property('og:image:height', '630'),
    property('og:image:alt', imageAlt),
    named('twitter:card', 'summary_large_image'),
    named('twitter:title', title),
    named('twitter:description', description),
    named('twitter:image', image),
    named('twitter:image:alt', imageAlt),
  ].join('\n');

  return bootstrap
      .replaceFirst(
        RegExp('<meta name="description" content="[^"]*">'),
        '<meta name="description" content="${escape(description)}">',
      )
      .replaceFirst(RegExp('<title>[^<]*</title>'), metadata);
}

/// Keeps reading faces in the startup manifest and saves specimens for later.
void deferComparisonFonts(Directory output) {
  final assets = Directory('${output.path}/assets');
  final manifest = File('${assets.path}/FontManifest.json');
  final deferred = File('${assets.path}/DeferredFontManifest.json');
  final families = (jsonDecode(manifest.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final startup = <Map<String, dynamic>>[];
  final comparison = <Map<String, dynamic>>[];

  for (final family in families) {
    final name = family['family'] as String;
    final fonts = (family['fonts'] as List).cast<Map<String, dynamic>>();
    final isSkribble = name.startsWith('packages/skribble_font_recursive/');
    final isOriginal =
        name.startsWith('Recursive') && name.endsWith('Original');

    if (!isSkribble && !isOriginal) {
      startup.add(family);
      continue;
    }

    // Articles are lettered in Noto Sketch, which loads with the other
    // startup families. From Recursive they only need the Mono faces for
    // code; the comparison page loads everything else when it opens.
    final isReadingFamily =
        name.startsWith(
          'packages/skribble_font_recursive/SkribbleMono',
        ) &&
        !name.contains('Linear');

    if (isReadingFamily) {
      final readingFaces = fonts.where((font) {
        final weight = font['weight'];
        return weight == 400 || weight == 700;
      }).toList();
      startup.add({...family, 'fonts': readingFaces});
      final remainingFaces = fonts
          .where((font) => !readingFaces.contains(font))
          .toList();

      if (remainingFaces.isNotEmpty) {
        comparison.add({...family, 'fonts': remainingFaces});
      }
    } else {
      comparison.add(family);
    }
  }

  if (comparison.isEmpty && deferred.existsSync()) return;

  manifest.writeAsStringSync(jsonEncode(startup));
  deferred.writeAsStringSync(jsonEncode(comparison));
}
