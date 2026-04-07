/// Hand-drawn custom icon set for Skribble.
///
/// Provides [kCustomRoughIcons], a compile-time map from codepoint to
/// [WiredSvgIconData], and [lookupCustomRoughIconByIdentifier] for
/// name-based access.
///
library;

import 'package:skribble_icons_custom/src/generated/custom_rough_icons.g.dart';
import 'package:skribble_icons_custom/src/wired_svg_icon_data.dart';

export 'package:skribble_icons_custom/src/generated/custom_rough_icons.g.dart'
    show kCustomRoughIcons;
export 'package:skribble_icons_custom/src/wired_svg_icon_data.dart'
    show
        WiredSvgCirclePrimitive,
        WiredSvgEllipsePrimitive,
        WiredSvgFillRule,
        WiredSvgIconData,
        WiredSvgPathPrimitive,
        WiredSvgPrimitive;

// ---------------------------------------------------------------------------
// Lookup helpers
// ---------------------------------------------------------------------------

/// Maps each icon identifier string to its codepoint in [kCustomRoughIcons].
const Map<String, int> kCustomRoughIconsCodePoints = <String, int>{
  'home': 0xe901,
  'search': 0xe902,
  'settings': 0xe903,
  'star': 0xe904,
  'favorite': 0xe905,
};

/// Returns the [WiredSvgIconData] for [identifier], or `null` if not found.
///
/// ```dart
/// final data = lookupCustomRoughIconByIdentifier('star');
/// ```
WiredSvgIconData? lookupCustomRoughIconByIdentifier(String identifier) {
  final codePoint = kCustomRoughIconsCodePoints[identifier];
  if (codePoint == null) return null;
  return kCustomRoughIcons[codePoint];
}
