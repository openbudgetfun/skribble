import 'package:flutter/widgets.dart';

/// Stable targets for the documentation's browser journeys.
abstract final class DocsKeys {
  /// Copies the current page's Markdown.
  static const ValueKey<String> copyPage = ValueKey('docs-copy-page');

  /// Opens the compact navigation panel.
  static const ValueKey<String> menu = ValueKey('docs-menu');

  /// A navigation destination identified by its canonical route.
  static ValueKey<String> page(String path) => ValueKey('docs-page-$path');

  /// Replays the homepage illustration.
  static const ValueKey<String> replay = ValueKey('docs-replay');

  /// Saves the live example's small idea.
  static const ValueKey<String> saveIdea = ValueKey('docs-save-idea');

  /// Searches the canonical documentation catalog.
  static const ValueKey<String> search = ValueKey('docs-search');
}
