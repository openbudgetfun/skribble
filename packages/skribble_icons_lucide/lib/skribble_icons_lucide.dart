/// Lucide icon set for Skribble.
///
/// Lucide contributes 1,837 icons plus 219 aliases, all drawn as open outlines
/// at a uniform 2px stroke. Because every path is a stroke rather than a
/// silhouette, the set reads as the lightest of the bundled catalogs.
///
/// Artwork comes from [Lucide](https://lucide.dev) under the ISC license,
/// warped through the shared Skribble rough pass at generation time. Every path
/// here is precomputed, so rendering never runs the rough engine.
///
/// ```dart
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_icons_lucide/skribble_icons_lucide.dart';
///
/// final data = lookupLucideIconByIdentifier('home');
/// if (data != null) WiredSvgIcon(data: data);
/// ```
library;

import 'package:skribble/skribble.dart';
import 'package:skribble_icons_lucide/src/generated/lucide_icons.g.dart';

export 'package:skribble_icons_lucide/src/generated/lucide_icons.g.dart'
    show kLucideIconCodePoints, kLucideIcons;

/// Returns hand-drawn geometry for a Lucide icon [identifier], or `null` when
/// this set does not ship it.
WiredSvgIconData? lookupLucideIconByIdentifier(String identifier) {
  final codePoint = kLucideIconCodePoints[identifier];
  if (codePoint == null) return null;
  return kLucideIcons[codePoint];
}

/// Number of names in this set, including aliases.
int get lucideIconCount => kLucideIconCodePoints.length;

/// Identifiers in this set, sorted.
List<String> get lucideIconIdentifiers =>
    kLucideIconCodePoints.keys.toList(growable: false);

/// Codepoints in this set, ascending.
List<int> get lucideIconCodePoints => kLucideIcons.keys.toList(growable: false);
