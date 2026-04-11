/// Dynamic hand-drawn icon library for Skribble.
///
/// Provides unified access to **all** roughened Flutter Material icons (8,600+)
/// plus 30 curated custom icons through a single API. Icons are roughened at
/// runtime for maximum flexibility.
///
/// ## Quick start
///
/// ```dart
/// import 'package:skribble_icons_dynamic/skribble_icons_dynamic.dart';
///
/// // Look up any icon by its identifier:
/// final searchIcon = lookupSkribbleDynamicIconByIdentifier('search');
///
/// // Or use the dynamic icon widget with custom fill styles:
/// SkribbleDynamicIcon(
///   data: kSkribbleDynamicIcons[0xf001]!,
///   fillStyle: WiredIconFillStyle.hachure,
/// )
/// ```
library;

import 'package:skribble/skribble.dart';
import 'package:skribble_icons_dynamic/src/generated/skribble_icons_dynamic.g.dart';

// Re-export core icon types and Material rough icon accessors from skribble.
export 'package:skribble/skribble.dart'
    show
        DrawConfig,
        WiredIconFillStyle,
        WiredSvgCirclePrimitive,
        WiredSvgEllipsePrimitive,
        WiredSvgFillRule,
        WiredSvgIcon,
        WiredSvgIconData,
        WiredSvgPathPrimitive,
        WiredSvgPrimitive,
        lookupMaterialRoughIcon,
        lookupMaterialRoughIconByIdentifier,
        materialRoughFontCodePoints,
        materialRoughFontFamily,
        materialRoughIconCodePoints,
        materialRoughIconIdentifiers;

// Export the clean custom icon set for runtime roughening.
export 'package:skribble_icons_dynamic/src/generated/skribble_icons_dynamic.g.dart'
    show kSkribbleDynamicIcons;

// Export the dynamic icon widget.
export 'package:skribble_icons_dynamic/src/skribble_dynamic_icon.dart'
    show SkribbleDynamicIcon;

// ---------------------------------------------------------------------------
// Custom icon codepoint map
// ---------------------------------------------------------------------------

/// Maps each curated custom icon identifier to its codepoint in
/// [kSkribbleDynamicIcons].
const Map<String, int> kSkribbleDynamicIconsCodePoints = <String, int>{
  'home': 0xf001,
  'search': 0xf002,
  'settings': 0xf003,
  'star': 0xf004,
  'heart': 0xf005,
  'user': 0xf006,
  'menu': 0xf007,
  'close': 0xf008,
  'check': 0xf009,
  'plus': 0xf00a,
  'minus': 0xf00b,
  'arrow_left': 0xf00c,
  'arrow_right': 0xf00d,
  'arrow_up': 0xf00e,
  'arrow_down': 0xf00f,
  'edit': 0xf010,
  'delete': 0xf011,
  'share': 0xf012,
  'copy': 0xf013,
  'mail': 0xf014,
  'phone': 0xf015,
  'camera': 0xf016,
  'image': 0xf017,
  'calendar': 0xf018,
  'clock': 0xf019,
  'lock': 0xf01a,
  'unlock': 0xf01b,
  'eye': 0xf01c,
  'eye_off': 0xf01d,
  'notification': 0xf01e,
};

// ---------------------------------------------------------------------------
// Unified lookup helpers
// ---------------------------------------------------------------------------

/// Returns [WiredSvgIconData] for [identifier], searching dynamic custom icons
/// first, then falling back to the full Material rough icon set.
///
/// This is the primary lookup function — it covers all 8,600+ Material icons
/// plus the 30 curated custom icons.
///
/// ```dart
/// // Custom icon:
/// lookupSkribbleDynamicIconByIdentifier('heart');
///
/// // Material icon (any Flutter Icons identifier):
/// lookupSkribbleDynamicIconByIdentifier('access_alarm');
/// ```
WiredSvgIconData? lookupSkribbleDynamicIconByIdentifier(String identifier) {
  // Try custom icons first (they take precedence for shared identifiers).
  final customCodePoint = kSkribbleDynamicIconsCodePoints[identifier];
  if (customCodePoint != null) {
    final data = kSkribbleDynamicIcons[customCodePoint];
    if (data != null) return data;
  }
  // Fall back to the full Material rough icon set.
  return lookupMaterialRoughIconByIdentifier(identifier);
}

/// Returns [WiredSvgIconData] for [identifier] from the curated dynamic custom
/// set only. Returns `null` if not found.
WiredSvgIconData? lookupSkribbleDynamicCustomIconByIdentifier(
  String identifier,
) {
  final codePoint = kSkribbleDynamicIconsCodePoints[identifier];
  if (codePoint == null) return null;
  return kSkribbleDynamicIcons[codePoint];
}

/// Total number of curated dynamic custom icons.
int get skribbleDynamicCustomIconCount => kSkribbleDynamicIcons.length;

/// Total number of Material rough icons available.
int get skribbleDynamicMaterialIconCount => materialRoughIconCodePoints.length;
