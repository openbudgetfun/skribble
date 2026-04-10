/// Hand-drawn emoji for Skribble.
///
/// Provides `kSkribbleEmoji`, a compile-time map from codepoint to
/// `WiredSvgIconData`, and [lookupSkribbleEmojiByName] /
/// [lookupSkribbleEmojiByUnicode] for convenient access.
///
/// Emoji SVG sources are from [OpenMoji](https://openmoji.org/) under
/// CC-BY-SA 4.0.
library;

import 'package:skribble_emoji/src/generated/skribble_emoji.g.dart' as gen;
import 'package:skribble_emoji/src/wired_svg_icon_data.dart';

export 'package:skribble_emoji/src/generated/skribble_emoji.g.dart'
    show kSkribbleEmoji;
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
// Emoji catalog
// ---------------------------------------------------------------------------

/// Maps each emoji identifier string to its Unicode codepoint in
/// `kSkribbleEmoji`.
const Map<String, int> kSkribbleEmojiCodePoints = <String, int>{
  // Smileys
  'grinning_face': 0x1f600,
  'face_with_tears_of_joy': 0x1f602,
  'smiling_face_with_heart_eyes': 0x1f60d,
  'thinking_face': 0x1f914,
  'crying_face': 0x1f622,
  'pouting_face': 0x1f621,
  'partying_face': 0x1f973,
  'sleeping_face': 0x1f634,
  'exploding_head': 0x1f92f,
  'smiling_face_with_sunglasses': 0x1f60e,
  // Hands/Gestures
  'thumbs_up': 0x1f44d,
  'thumbs_down': 0x1f44e,
  'waving_hand': 0x1f44b,
  'folded_hands': 0x1f64f,
  'clapping_hands': 0x1f44f,
  'victory_hand': 0x270c,
  'flexed_biceps': 0x1f4aa,
  'handshake': 0x1f91d,
  // Hearts/Symbols
  'red_heart': 0x2764,
  'hundred_points': 0x1f4af,
  'star': 0x2b50,
  'fire': 0x1f525,
  'check_mark': 0x2705,
  'cross_mark': 0x274c,
  'high_voltage': 0x26a1,
  // Objects
  'mobile_phone': 0x1f4f1,
  'laptop': 0x1f4bb,
  'camera': 0x1f4f7,
  'musical_note': 0x1f3b5,
  'email': 0x1f4e7,
  'key': 0x1f511,
  'house': 0x1f3e0,
  'calendar': 0x1f4c5,
  'alarm_clock': 0x23f0,
  'bell': 0x1f514,
  // Nature/Food
  'glowing_star': 0x1f31f,
  'rainbow': 0x1f308,
  'sun': 0x2600,
  'crescent_moon': 0x1f319,
  'pizza': 0x1f355,
  'party_popper': 0x1f389,
  'wrapped_present': 0x1f381,
  'trophy': 0x1f3c6,
  // People/Activities
  'rocket': 0x1f680,
  'light_bulb': 0x1f4a1,
  'direct_hit': 0x1f3af,
  'speech_balloon': 0x1f4ac,
  'memo': 0x1f4dd,
  'locked': 0x1f512,
  'unlocked': 0x1f513,
};

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
  return gen.kSkribbleEmoji[codePoint];
}

/// Returns the `WiredSvgIconData` for the given Unicode [codePoint], or `null`
/// if not found.
///
/// ```dart
/// final data = lookupSkribbleEmojiByUnicode(0x1f600);
/// ```
WiredSvgIconData? lookupSkribbleEmojiByUnicode(int codePoint) {
  return gen.kSkribbleEmoji[codePoint];
}
