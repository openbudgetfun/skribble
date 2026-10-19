import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:skribble_site/src/assets.dart';
import 'package:skribble_site/src/config.dart';
import 'package:skribble_site/src/page.dart';

/// Emoji shown on the landing page, by art file name.
const featuredEmoji = [
  'star-struck',
  'artist-palette',
  'smiling-face-with-hearts',
  'rocket',
  'cat-face',
  'sunflower',
  'party-popper',
  'pencil',
  'rainbow',
  'avocado',
  'partying-face',
  'butterfly',
  'hot-beverage',
  'ghost',
  'dog-face',
  'light-bulb',
  'doughnut',
  'winking-face-with-tongue',
  'cactus',
  'sparkles',
  'robot',
];

/// Lucide icons shown on the landing page.
const featuredIcons = [
  'pencil',
  'brush',
  'palette',
  'heart',
  'star',
  'sparkles',
  'cat',
  'coffee',
  'rocket',
  'cloud-sun',
  'music',
  'camera',
  'bell',
  'map-pin',
  'flower',
  'gift',
];

/// Emoji palette tokens, mirroring `EmojiPalette.standard` in
/// `packages/skribble_emoji/lib/src/emoji_palette.dart`. Person tokens use
/// the default (no skin tone) values.
const _emojiPalette = {
  'ink': '#34283f',
  'paper': '#fffaf0',
  'white': '#ffffff',
  'black': '#2e2733',
  'yellow': '#ffcc4d',
  'yellow-shade': '#f4a93a',
  'orange': '#ff9a47',
  'orange-shade': '#e5772e',
  'red': '#ee5a52',
  'red-shade': '#c9403b',
  'coral': '#e87960',
  'pink': '#f7a1c0',
  'pink-shade': '#e57aa0',
  'magenta': '#d65ba6',
  'purple': '#9c7bd4',
  'purple-shade': '#7b5db8',
  'lilac': '#d7ccf2',
  'blue': '#4e8fda',
  'blue-shade': '#356fb8',
  'sky': '#a6d8f2',
  'teal': '#3fb3a4',
  'green': '#72c25b',
  'green-shade': '#4f9e41',
  'leaf': '#3c8c49',
  'lime': '#c3e26a',
  'mint': '#c7ebcb',
  'brown': '#a86a40',
  'brown-shade': '#84502e',
  'tan': '#ddb07a',
  'cream': '#f6e3b4',
  'grey': '#a9a3ae',
  'grey-shade': '#827b88',
  'silver': '#d9d6dc',
  'cheek': '#f59c9c',
  'skin': '#ffcc4d',
  'skin-shade': '#f4a93a',
  'hair': '#5c3b28',
};

/// Finds the workspace root by walking up from [start] to the
/// `pubspec.yaml` named `skribble_workspace`.
Directory findWorkspaceRoot([Directory? start]) {
  var dir = (start ?? Directory.current).absolute;

  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().startsWith('name: skribble_workspace')) {
      return dir;
    }

    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Run the site build inside the skribble workspace.');
    }
    dir = parent;
  }
}

/// Reads the logo, emoji, icons, and fonts from the workspace at [root].
SiteAssets loadSiteAssets(Directory root) {
  final logo = File('${root.path}/assets/brand/skribble-light-transparent.svg')
      .readAsStringSync();

  return SiteAssets(
    logoSvg: inlineLogo(logo),
    emoji: [
      for (final name in featuredEmoji)
        EmojiArt(name: name, svg: resolveEmoji(root, name)),
    ],
    emojiCount: _emojiCount(root),
    icons: _lucideIcons(root, featuredIcons),
    iconCount: _lucideCount(root),
    // A family whose package is not in this checkout yet is left out, so
    // the page can ship before every font package lands.
    fonts: [
      for (final family in fontFamilies)
        if (Directory('${root.path}/packages/${family.package}').existsSync())
          family,
    ],
  );
}

/// Recolours the brand logo's plum ink to `currentColor` and its face to
/// `--logo-face` so it follows the theme, and drops its fixed size so CSS can set one.
String inlineLogo(String svg) => svg
    .replaceAll(RegExp('#34283F', caseSensitive: false), 'currentColor')
    .replaceAll(RegExp('#E5DDF4', caseSensitive: false), 'var(--logo-face)')
    .replaceFirst(RegExp(r'\swidth="\d+"'), '')
    .replaceFirst(RegExp(r'\sheight="\d+"'), '')
    .replaceFirst(
      '<svg ',
      '<svg class="brand-logo" aria-hidden="true" focusable="false" ',
    );

/// Returns a self-contained SVG for the emoji art file [name]: shared parts
/// inlined and palette tokens replaced with colours.
String resolveEmoji(Directory root, String name) {
  final art = Directory('${root.path}/packages/skribble_emoji/art');

  return _resolveTokens(
    _inlineIncludes(art, _artFile(art, name).readAsStringSync()),
  );
}

/// Finds the art file for [key] in any category, shared parts first.
File _artFile(Directory art, String key) {
  final shared = File('${art.path}/shared/$key.svg');
  if (shared.existsSync()) return shared;

  return art
      .listSync()
      .whereType<Directory>()
      .map((dir) => File('${dir.path}/$key.svg'))
      .firstWhere(
        (file) => file.existsSync(),
        orElse: () => throw StateError('No emoji art named $key.'),
      );
}

final _include = RegExp(r'<g([^>]*?)\sdata-include="([a-z0-9-]+)"([^>]*?)/>');
final _svgInner = RegExp(r'<svg[^>]*>([\s\S]*)</svg>');
final _token = RegExp('(fill|stroke)="([a-z-]+)"');

String _inlineIncludes(Directory art, String svg, [int depth = 0]) {
  if (depth > 4) throw StateError('Emoji includes nest too deeply.');

  return svg.replaceAllMapped(_include, (match) {
    final part = _artFile(art, match[2]!).readAsStringSync();
    final inner = _svgInner.firstMatch(part)![1]!;

    return '<g${match[1]}${match[3]}>'
        '${_inlineIncludes(art, inner, depth + 1)}</g>';
  });
}

String _resolveTokens(String svg) => svg.replaceAllMapped(_token, (match) {
  final value = match[2]!;
  if (value == 'none') return match[0]!;
  final colour = _emojiPalette[value];
  if (colour == null) throw StateError('Unknown emoji colour "$value".');

  return '${match[1]}="$colour"';
});

int _emojiCount(Directory root) {
  final readme = File('${root.path}/packages/skribble_emoji/README.md')
      .readAsStringSync();
  final match = RegExp(r'([\d,]+) emoji').firstMatch(readme);

  return int.parse(match![1]!.replaceAll(',', ''));
}

File _lucideSource(Directory root) => File(
  '${root.path}/packages/skribble_icons_lucide/lib/src/generated/'
  'lucide_icons.g.dart',
);

int _lucideCount(Directory root) {
  final header = _lucideSource(root).readAsStringSync();
  final match = RegExp(r'\((\d+) icons').firstMatch(header);

  return int.parse(match![1]!);
}

List<IconArt> _lucideIcons(Directory root, List<String> names) {
  final source = _lucideSource(root).readAsStringSync();

  return [
    for (final name in names) _lucideIcon(source, name),
  ];
}

IconArt _lucideIcon(String source, String name) {
  final codepoint = RegExp("  '${RegExp.escape(name)}': (0x[0-9a-f]+),")
      .firstMatch(source)?[1];
  if (codepoint == null) throw StateError('No Lucide icon named $name.');

  final start = source.indexOf('  $codepoint: WiredSvgIconData(');
  final end = source.indexOf('\n  ),', start);
  final entry = source.substring(start, end);
  final paths = [
    for (final match in RegExp("'(M[^']+)'").allMatches(entry)) match[1]!,
  ];

  return IconArt(name: name, paths: paths);
}

/// The characters the web fonts keep: Basic Latin, Latin-1, Latin
/// Extended-A, and common punctuation and symbols. Anything else falls back
/// to the next font in the stack.
const webFontUnicodes =
    'U+0000-017F,U+0192,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+2000-206F,'
    'U+2074,U+20AC,U+2122,U+2190-2199,U+2212,U+2215,U+FEFF,U+FFFD';

/// Writes [source] to [destination] as a WOFF web font that keeps only
/// [webFontUnicodes], using `pyftsubset` from fontTools (in `devenv shell`).
///
/// A subset WOFF is about a quarter of the TrueType file, so the page's
/// first paint is not held up by font downloads.
Future<void> writeWebFont(File source, File destination) async {
  final ProcessResult result;
  try {
    result = await Process.run('pyftsubset', [
      source.path,
      '--unicodes=$webFontUnicodes',
      '--layout-features=*',
      '--flavor=woff',
      '--output-file=${destination.path}',
    ]);
  } on ProcessException catch (error) {
    throw StateError(
      'pyftsubset is needed to build web fonts. Run the build inside '
      '`devenv shell`, or install fontTools (pip install fonttools). '
      '${error.message}',
    );
  }
  if (result.exitCode != 0) {
    throw StateError('pyftsubset failed for ${source.path}:\n${result.stderr}');
  }
}

/// Renders the site for [config] into [output], using the workspace at
/// [root] for assets.
Future<void> buildSite({
  required SiteConfig config,
  required Directory root,
  required Directory output,
}) async {
  Jaspr.initializeApp();

  final assets = loadSiteAssets(root);
  final site = Directory('${root.path}/apps/skribble_site');

  if (output.existsSync()) output.deleteSync(recursive: true);
  output.createSync(recursive: true);

  Future<void> page(String name, Component component) async {
    final response = await renderComponent(component);
    File('${output.path}/$name').writeAsBytesSync(response.body);
  }

  await page('index.html', LandingPage(config: config, assets: assets));
  await page('404.html', NotFoundPage(config: config, assets: assets));

  for (final file in Directory(
    '${site.path}/web',
  ).listSync().whereType<File>()) {
    file.copySync('${output.path}/${file.uri.pathSegments.last}');
  }

  File('${root.path}/docs/site/web/favicon.svg')
      .copySync('${output.path}/favicon.svg');

  final fonts = Directory('${output.path}/fonts')..createSync();
  await Future.wait([
    for (final family in assets.fonts)
      for (final face in family.faces)
        writeWebFont(
          File(
            '${root.path}/packages/${family.package}/assets/fonts/${face.file}',
          ),
          File('${fonts.path}/${face.webFile}'),
        ),
  ]);
  for (final package in {for (final family in assets.fonts) family.package}) {
    File(
      '${root.path}/packages/$package/assets/fonts/OFL.txt',
    ).copySync('${fonts.path}/${licenceFile(package)}');
  }

  final emoji = Directory('${output.path}/emoji')..createSync();
  for (final art in assets.emoji) {
    File('${emoji.path}/${art.name}.svg').writeAsStringSync(art.svg);
  }

  File('${output.path}/robots.txt').writeAsStringSync(
    'User-agent: *\nAllow: /\n',
  );
}
