/// CoreUI Brands icon set for Skribble.
///
/// 830 brand marks covering products, platforms, languages, and social
/// networks — the logos an app needs for sign-in buttons, footer links, and
/// tech-stack sections.
///
/// Artwork comes from [CoreUI Icons](https://github.com/coreui/coreui-icons)
/// under CC0-1.0, warped through the shared Skribble rough pass at generation
/// time. Every path here is precomputed, so rendering never runs the rough
/// engine.
///
/// ```dart
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_icons_cib/skribble_icons_cib.dart';
///
/// final data = lookupCibIconByIdentifier('github');
/// if (data != null) WiredSvgIcon(data: data);
/// ```
library;

import 'package:skribble/skribble.dart';
import 'package:skribble_icons_cib/src/generated/cib_icons.g.dart';

export 'package:skribble_icons_cib/src/generated/cib_icons.g.dart'
    show kCibIconCodePoints, kCibIcons;

/// Returns hand-drawn geometry for a CoreUI Brands icon [identifier], or `null`
/// when this set does not ship it.
WiredSvgIconData? lookupCibIconByIdentifier(String identifier) {
  final codePoint = kCibIconCodePoints[identifier];
  if (codePoint == null) return null;
  return kCibIcons[codePoint];
}

/// Number of names in this set, including aliases.
int get cibIconCount => kCibIconCodePoints.length;

/// Identifiers in this set, sorted.
List<String> get cibIconIdentifiers =>
    kCibIconCodePoints.keys.toList(growable: false);

/// Codepoints in this set, ascending.
List<int> get cibIconCodePoints => kCibIcons.keys.toList(growable: false);
