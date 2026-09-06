import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Loads the Skribble font bytes from the package asset path
/// (`packages/skribble/assets/fonts/...`) and registers them under the
/// bare `'Skribble'` family name. This bridges the Flutter web issue
/// where package fonts get a package prefix in the FontManifest that
/// the bare const `skribbleFontFamily` cannot resolve.
Future<void> main() async {
  try {
    final data = await rootBundle.load(
      'packages/skribble/assets/fonts/Skribble-Regular.ttf',
    );
    final loader = FontLoader('Skribble');
    loader.addFont(Future.value(data));
    await loader.load();
    // Font loading is best-effort — any failure means "try fallback".
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    debugPrint('Skribble font load: $e');
  }

  runApp(const SkribbleStorybookApp());
}
