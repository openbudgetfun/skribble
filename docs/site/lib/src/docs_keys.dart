import 'package:flutter/widgets.dart';

/// Stable targets for the documentation's browser journeys.
abstract final class DocsKeys {
  /// The opt-in online map, mounted only after the visitor requests it.
  static const ValueKey<String> map = ValueKey('docs-online-map');

  /// Opens or closes the optional online basemap.
  static const ValueKey<String> mapOnlineToggle = ValueKey(
    'docs-map-online-toggle',
  );

  /// One of the network-independent sample pins.
  static ValueKey<String> mapPin(String icon) => ValueKey('docs-map-pin-$icon');

  /// Visible feedback from the sample pin selection.
  static const ValueKey<String> mapSelection = ValueKey('docs-map-selection');

  /// The financial chart's copyable example widget.
  static const ValueKey<String> chart = ValueKey('docs-financial-chart');

  /// Copies one code block; scope this key to the desired example.
  static const ValueKey<String> copyCode = ValueKey('docs-copy-code');

  /// The article scroll view surrounding live examples and source blocks.
  static const ValueKey<String> documentScroll = ValueKey('document-scroll');

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

  /// Replaces the shared specimen with a short code sample.
  static const ValueKey<String> fontCodeSample = ValueKey('font-code-sample');

  /// A rendered font specimen identified by family and roughness.
  static ValueKey<String> fontSpecimen(String font, String level) =>
      ValueKey('font-$font-$level');

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
