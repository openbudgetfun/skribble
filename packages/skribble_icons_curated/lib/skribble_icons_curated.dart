/// Curated hand-drawn simple icon set for Skribble.
///
/// Thirty app-level icons that cover the common interface vocabulary — home,
/// search, navigation arrows, editing, media, and status. Each one is authored
/// as a 24×24 SVG and warped through the shared rough pass at generation time,
/// so the geometry is already hand-drawn and rendering never runs the rough
/// engine.
///
/// ```dart
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_icons_curated/skribble_icons_curated.dart';
///
/// final data = lookupSkribbleCuratedIconByIdentifier('search');
/// if (data != null) WiredSvgIcon(data: data);
/// ```
library;

import 'package:skribble/skribble.dart';

import 'package:skribble_icons_curated/src/generated/skribble_curated_icons.g.dart';

export 'src/generated/skribble_curated_icons.g.dart'
    show kSkribbleCuratedIconCodePoints, kSkribbleCuratedIcons;

/// Returns hand-drawn geometry for a simple icon [identifier] such as
/// `'search'`, or `null` when this set does not ship it.
WiredSvgIconData? lookupSkribbleCuratedIconByIdentifier(String identifier) {
  final codePoint = kSkribbleCuratedIconCodePoints[identifier];
  if (codePoint == null) return null;
  return kSkribbleCuratedIcons[codePoint];
}

/// Number of icons in this set.
int get skribbleCuratedIconCount => kSkribbleCuratedIcons.length;

/// Identifiers in this set, sorted.
List<String> get skribbleCuratedIconIdentifiers =>
    kSkribbleCuratedIconCodePoints.keys.toList(growable: false);

/// Codepoints in this set, ascending.
List<int> get skribbleCuratedIconCodePoints =>
    kSkribbleCuratedIcons.keys.toList(growable: false);
