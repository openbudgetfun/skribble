import 'package:flutter/widgets.dart';

/// Shared targets for the map showcase's browser journey.
abstract final class MapDemoKeys {
  /// Opens the map showcase from the catalog.
  static const ValueKey<String> category = ValueKey('storybook-map-category');

  /// A city or ink option in the showcase.
  static ValueKey<String> choice(String name) => ValueKey('map-choice-$name');

  /// The real map and its Flutter overlays.
  static const ValueKey<String> map = ValueKey('storybook-map');

  /// A named pin, independent of the selected city.
  static ValueKey<String> pin(String label) => ValueKey('map-pin-$label');

  /// The surrounding page scroll view.
  static const ValueKey<String> scroll = ValueKey('maps-page-scroll');

  /// The visible selected destination.
  static const ValueKey<String> status = ValueKey('map-selected-place');
}
