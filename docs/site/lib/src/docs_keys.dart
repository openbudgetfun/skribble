import 'package:flutter/widgets.dart';

/// Stable targets for the documentation's browser journeys.
abstract final class DocsKeys {
  /// Copies one code block; scope this key to the desired example.
  static const ValueKey<String> copyCode = ValueKey('docs-copy-code');

  /// A roughness choice in the persistent toolbar.
  static ValueKey<String> roughness(String level) =>
      ValueKey('docs-roughness-$level');

  /// A rendered example's preview area.
  static ValueKey<String> preview(String id) => ValueKey('preview-$id');

  /// An editable parameter of a specific example.
  static ValueKey<String> parameter(String id, String parameter) =>
      ValueKey('$id-$parameter');

  /// A specific enum variant in an example's parameter editor.
  static ValueKey<String> choice(String id, String parameter, String value) =>
      ValueKey('$id-$parameter-$value');

  /// The source and copy action associated with a live example.
  static ValueKey<String> exampleCode(String id) => ValueKey('code-$id');

  /// Shared text used by all font specimens.
  static const ValueKey<String> fontSample = ValueKey('font-sample');

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
