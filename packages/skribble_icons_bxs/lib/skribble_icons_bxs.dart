/// Boxicons Solid icon set for Skribble.
///
/// The solid weight of Boxicons: 665 filled silhouettes on a 24×24 grid. It
/// pairs with an outline set the way a filled Material icon pairs with its
/// outlined counterpart.
///
/// Artwork comes from [Boxicons](https://boxicons.com) under the MIT license,
/// warped through the shared Skribble rough pass at generation time. Every path
/// here is precomputed, so rendering never runs the rough engine.
///
/// ```dart
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_icons_bxs/skribble_icons_bxs.dart';
///
/// final data = lookupBxsIconByIdentifier('analyse');
/// if (data != null) WiredSvgIcon(data: data);
/// ```
library;

import 'package:skribble/skribble.dart';
import 'package:skribble_icons_bxs/src/generated/bxs_icons.g.dart';

export 'package:skribble_icons_bxs/src/generated/bxs_icons.g.dart'
    show kBxsIconCodePoints, kBxsIcons;

/// Returns hand-drawn geometry for a Boxicons Solid icon [identifier], or
/// `null` when this set does not ship it.
WiredSvgIconData? lookupBxsIconByIdentifier(String identifier) {
  final codePoint = kBxsIconCodePoints[identifier];
  if (codePoint == null) return null;
  return kBxsIcons[codePoint];
}

/// Number of names in this set, including aliases.
int get bxsIconCount => kBxsIconCodePoints.length;

/// Identifiers in this set, sorted.
List<String> get bxsIconIdentifiers =>
    kBxsIconCodePoints.keys.toList(growable: false);

/// Codepoints in this set, ascending.
List<int> get bxsIconCodePoints => kBxsIcons.keys.toList(growable: false);
