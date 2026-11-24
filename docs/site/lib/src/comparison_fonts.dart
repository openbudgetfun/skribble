import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:skribble/skribble.dart';

Future<void>? _comparisonFonts;
final Map<String, Future<void>> _families = {};

/// Loads the font specimens omitted from the web startup manifest.
///
/// Development builds keep Flutter's complete manifest; the release build
/// writes this smaller deferred list in `tool/prepare_pages.dart`.
Future<void> loadComparisonFonts() =>
    _comparisonFonts ??= _loadComparisonFonts();

Future<void> _loadComparisonFonts() => _loadDeferred((_) => true);

/// Loads the deferred faces of the Recursive Mono family for [roughness], so
/// code blocks keep their hand when the reader switches pens.
///
/// The release build starts with only the playful Mono's upright faces.
Future<void> loadMonoFontsFor(WiredRoughness roughness) => _loadDeferred(
  (family) =>
      family ==
      'packages/skribble_font_recursive/'
          '${WiredFont.mono.familyFor(roughness)}',
);

Future<List<Map<String, dynamic>>>? _manifest;

Future<void> _loadDeferred(bool Function(String family) wanted) async {
  if (!kIsWeb || !const bool.fromEnvironment('DOCS_DEFER_FONTS')) return;

  final assets = rootBundle;
  final families = await (_manifest ??= assets
      .loadString('DeferredFontManifest.json')
      .then(
        (source) => (jsonDecode(source) as List).cast<Map<String, dynamic>>(),
      ));

  await Future.wait([
    for (final family in families)
      if (wanted(family['family'] as String))
        _families.putIfAbsent(family['family'] as String, () {
          final loader = FontLoader(family['family'] as String);
          final fonts = (family['fonts'] as List).cast<Map<String, dynamic>>();

          for (final font in fonts) {
            loader.addFont(assets.load(font['asset'] as String));
          }

          return loader.load();
        }),
  ]);
}
