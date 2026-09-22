import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<void>? _comparisonFonts;

/// Loads the font specimens omitted from the web startup manifest.
///
/// Development builds keep Flutter's complete manifest; the release build
/// writes this smaller deferred list in `tool/prepare_pages.dart`.
Future<void> loadComparisonFonts() =>
    _comparisonFonts ??= _loadComparisonFonts();

Future<void> _loadComparisonFonts() async {
  if (!kIsWeb || !const bool.fromEnvironment('DOCS_DEFER_FONTS')) return;

  final assets = rootBundle;
  final source = await assets.loadString('DeferredFontManifest.json');
  final families = (jsonDecode(source) as List).cast<Map<String, dynamic>>();

  await Future.wait(
    families.map((family) async {
      final loader = FontLoader(family['family'] as String);
      final fonts = (family['fonts'] as List).cast<Map<String, dynamic>>();

      for (final font in fonts) {
        loader.addFont(assets.load(font['asset'] as String));
      }

      await loader.load();
    }),
  );
}
