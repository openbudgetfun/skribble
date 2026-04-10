/// Hand-drawn emoji for Skribble.
///
/// This is a scaffold package -- the emoji maps are intentionally empty and
/// will be populated once emoji SVG sources are added to the `emoji/` directory
/// and processed through the rough icon pipeline.
///
/// Provides [kSkribbleEmoji], a compile-time map from codepoint to
/// `WiredSvgIconData`, and [lookupSkribbleEmojiByName] /
/// [lookupSkribbleEmojiByUnicode] for convenient access.
library;

import 'package:skribble_emoji/src/wired_svg_icon_data.dart';

export 'package:skribble_emoji/src/wired_emoji.dart' show WiredEmoji;
export 'package:skribble_emoji/src/wired_svg_icon_data.dart'
    show
        WiredSvgCirclePrimitive,
        WiredSvgEllipsePrimitive,
        WiredSvgFillRule,
        WiredSvgIconData,
        WiredSvgPathPrimitive,
        WiredSvgPrimitive;

// ---------------------------------------------------------------------------
// Emoji catalog (scaffold -- empty until emoji SVGs are generated)
// ---------------------------------------------------------------------------

/// Maps each emoji Unicode codepoint to its `WiredSvgIconData`.
///
/// Currently empty. Populate by running the rough icon generator against the
/// emoji manifest.
const Map<int, WiredSvgIconData> kSkribbleEmoji = <int, WiredSvgIconData>{};

/// Maps each emoji identifier string to its Unicode codepoint in
/// [kSkribbleEmoji].
///
/// Currently empty. Add entries alongside generated emoji data.
const Map<String, int> kSkribbleEmojiCodePoints = <String, int>{};

// ---------------------------------------------------------------------------
// Lookup helpers
// ---------------------------------------------------------------------------

/// Returns the `WiredSvgIconData` for the emoji [name], or `null` if not
/// found.
///
/// ```dart
/// final data = lookupSkribbleEmojiByName('grinning_face');
/// ```
WiredSvgIconData? lookupSkribbleEmojiByName(String name) {
  final codePoint = kSkribbleEmojiCodePoints[name];
  if (codePoint == null) return null;
  return kSkribbleEmoji[codePoint];
}

/// Returns the `WiredSvgIconData` for the given Unicode [codePoint], or `null`
/// if not found.
///
/// ```dart
/// final data = lookupSkribbleEmojiByUnicode(0x1f600);
/// ```
WiredSvgIconData? lookupSkribbleEmojiByUnicode(int codePoint) {
  return kSkribbleEmoji[codePoint];
}
