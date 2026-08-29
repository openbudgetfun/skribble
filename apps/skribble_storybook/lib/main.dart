import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

Future<void> main() async {
  await _loadFont();
  runApp(const SkribbleStorybookApp());
}

/// Explicitly load the hand-drawn font to avoid the Flutter web package
/// prefix issue where fonts from packages are registered as
/// `packages/skribble/Skribble` — the bare `'Skribble'` lookup fails.
Future<void> _loadFont() async {
  const family = 'Skribble';
  const paths = [
    'assets/packages/skribble/assets/fonts/Skribble-Regular.ttf',
    'packages/skribble/assets/fonts/Skribble-Regular.ttf',
  ];
  for (final path in paths) {
    try {
      final data = await rootBundle.load(path);
      final loader = FontLoader(family);
      loader.addFont(Future.value(data));
      await loader.load();

      break;

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      debugPrint('SkribbleFont: failed to load from $path: $e');
    }
  }
}
