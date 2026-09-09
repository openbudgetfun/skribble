import 'package:flutter/widgets.dart';

/// A MapLibre style source with the small amount of chrome styling that
/// Skribble owns.
@immutable
class WiredMapStyle {
  /// Creates a MapLibre-backed map style.
  ///
  /// [styleString] accepts the same URL, asset path, file path, or raw JSON as
  /// MapLibre's `styleString` option.
  const WiredMapStyle({
    required this.styleString,
    this.attributionButtonColor,
  });

  /// A MapLibre style URL, asset path, file path, or raw style JSON.
  final String styleString;

  /// The native attribution button tint where the MapLibre platform supports
  /// it.
  final Color? attributionButtonColor;

  /// OpenFreeMap's quiet, high-contrast Positron style.
  ///
  /// The public OpenFreeMap service is keyless but has no availability
  /// guarantee. Supply a different [styleString] for production infrastructure
  /// with an explicit service agreement.
  static const positron = WiredMapStyle(
    styleString: 'https://tiles.openfreemap.org/styles/positron',
    attributionButtonColor: Color(0xFF34332F),
  );

  /// OpenFreeMap's fuller-colour Liberty style.
  static const liberty = WiredMapStyle(
    styleString: 'https://tiles.openfreemap.org/styles/liberty',
    attributionButtonColor: Color(0xFF34332F),
  );

  /// OpenFreeMap's dark style.
  static const dark = WiredMapStyle(
    styleString: 'https://tiles.openfreemap.org/styles/dark',
    attributionButtonColor: Color(0xFFF4F0E7),
  );

  /// The default quiet paper-like basemap.
  static const WiredMapStyle paper = positron;

  /// The default low-light basemap.
  static const WiredMapStyle night = dark;

  /// Returns a style with selected values replaced.
  WiredMapStyle copyWith({
    String? styleString,
    Color? attributionButtonColor,
  }) {
    return WiredMapStyle(
      styleString: styleString ?? this.styleString,
      attributionButtonColor:
          attributionButtonColor ?? this.attributionButtonColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WiredMapStyle &&
        other.styleString == styleString &&
        other.attributionButtonColor == attributionButtonColor;
  }

  @override
  int get hashCode => Object.hash(styleString, attributionButtonColor);
}
