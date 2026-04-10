/// Hand-drawn icon set for Skribble.
///
/// Provides [kSkribbleIcons], a compile-time map from codepoint to
/// [WiredSvgIconData], and [lookupSkribbleIconByIdentifier] for
/// name-based access.
///
library;

import 'package:skribble_icons/src/generated/skribble_icons.g.dart';
import 'package:skribble_icons/src/wired_svg_icon_data.dart';

export 'package:skribble_icons/src/generated/skribble_icons.g.dart'
    show kSkribbleIcons;
export 'package:skribble_icons/src/wired_svg_icon_data.dart'
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

/// Maps each icon identifier string to its codepoint in [kSkribbleIcons].
const Map<String, int> kSkribbleIconsCodePoints = <String, int>{
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

/// Returns the [WiredSvgIconData] for [identifier], or `null` if not found.
///
/// ```dart
/// final data = lookupSkribbleIconByIdentifier('star');
/// ```
WiredSvgIconData? lookupSkribbleIconByIdentifier(String identifier) {
  final codePoint = kSkribbleIconsCodePoints[identifier];
  if (codePoint == null) return null;
  return kSkribbleIcons[codePoint];
}
