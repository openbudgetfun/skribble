import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

/// Adds static entrypoints so GitHub Pages can reload extensionless routes.
Future<void> main(List<String> args) async {
  final output = Directory('build/web');

  if (args.contains('--defer-fonts')) {
    deferComparisonFonts(output);
  }

  if (args.contains('--subset-fonts')) {
    await subsetFonts(output);
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
    // startup families. From Recursive they only need upright Mono for code
    // in the default playful pen (about 300 KB); the pen picker loads the
    // gentle and expressive Mono when chosen, and the comparison page loads
    // everything else when it opens.
    final isReadingFamily =
        name == 'packages/skribble_font_recursive/SkribbleMonoPlayful';

    if (isReadingFamily) {
      final readingFaces = fonts.where((font) {
        final weight = font['weight'];
        return (weight == null || weight == 400 || weight == 700) &&
            font['style'] != 'italic';
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

/// The characters the docs' font files keep: Latin, IPA, Greek, and
/// Cyrillic, punctuation, currency, letterlike symbols, arrows, maths
/// operators, box drawing, and geometric shapes. Anything else falls back to
/// Flutter's Noto fonts.
const docsFontUnicodes =
    'U+0000-052F,U+1E00-1EFF,U+2000-206F,U+20A0-20CF,U+2100-214F,'
    'U+2190-21FF,U+2200-22FF,U+2500-25FF,U+FB00-FB06,U+FEFF,U+FFFD';

/// Rewrites every skribble and Recursive font in [output] with only
/// [docsFontUnicodes] and the OpenType features Flutter applies by default,
/// using `pyftsubset` from fontTools (in `devenv shell`).
///
/// The docs never show other scripts or ask for stylistic sets, so this cuts
/// Noto Sketch, which letters every article, from 550 KB to 240 KB over the
/// wire, and the Mono code faces by about half.
Future<void> subsetFonts(Directory output) async {
  final assets = Directory('${output.path}/assets');
  final fonts = [
    for (final entity in assets.listSync(recursive: true))
      if (entity is File &&
          entity.path.endsWith('.ttf') &&
          (entity.path.contains('/packages/skribble_font_') ||
              entity.path.contains('/assets/fonts/Recursive')))
        entity,
  ];
  final queue = fonts.iterator;

  Future<void> worker() async {
    while (queue.moveNext()) {
      final font = queue.current;
      final subset = File('${font.path}.subset');
      final ProcessResult result;
      try {
        result = await Process.run('pyftsubset', [
          font.path,
          '--unicodes=$docsFontUnicodes',
          '--output-file=${subset.path}',
        ]);
      } on ProcessException catch (error) {
        throw StateError(
          'pyftsubset is needed to subset the docs fonts. Run the build '
          'inside `devenv shell`, or install fontTools (pip install '
          'fonttools). ${error.message}',
        );
      }
      if (result.exitCode != 0) {
        throw StateError(
          'pyftsubset failed for ${font.path}:\n${result.stderr}',
        );
      }
      subset.renameSync(font.path);
    }
  }

  await Future.wait([
    for (var i = 0; i < math.max(1, Platform.numberOfProcessors); i++) worker(),
  ]);
}
