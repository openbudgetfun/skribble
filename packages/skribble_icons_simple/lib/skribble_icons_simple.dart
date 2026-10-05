/// Simple Icons for skribble.
///
/// 3,472 brand and product marks from the [Simple Icons](https://simpleicons.org)
/// project — the logos an app needs for sign-in buttons, footer links, tech-stack
/// sections, and "works with" lists.
///
/// Artwork is CC0-1.0, gently bent through the shared skribble rough pass at
/// generation time. At render time `WiredSvgIcon` adds the theme's wavering and
/// honours `weight`.
///
/// Despite the name, this package holds logos, not interface icons. For home,
/// search, and the rest of the app vocabulary see
/// `SkribbleGlyphs` in the core [`skribble`](https://pub.dev/packages/skribble) package.
///
/// ```dart
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_icons_simple/skribble_icons_simple.dart';
///
/// final data = lookupSimpleIconByIdentifier('github');
/// if (data != null) WiredSvgIcon(data: data);
/// ```
library;

import 'package:skribble/skribble.dart';
import 'package:skribble_icons_simple/src/generated/simple_icons.g.dart';

export 'package:skribble_icons_simple/src/generated/simple_icons.g.dart'
    show kSimpleIconCodePoints, kSimpleIcons;

/// Returns hand-drawn geometry for a Simple Icons [identifier], or `null` when
/// this set does not ship it.
///
/// Identifiers use Simple Icons' own slug form, so it is `'github'`,
/// `'visual-studio-code'`, and `'flutter'` — the same strings the
/// [Simple Icons](https://simpleicons.org) site and its search box use.
WiredSvgIconData? lookupSimpleIconByIdentifier(String identifier) {
  final codePoint = kSimpleIconCodePoints[identifier];

  if (codePoint == null) return null;
  return kSimpleIcons[codePoint];
}

/// Number of names in this set, including aliases.
int get simpleIconCount => kSimpleIconCodePoints.length;

/// Identifiers in this set, sorted.
List<String> get simpleIconIdentifiers =>
    kSimpleIconCodePoints.keys.toList(growable: false);

/// Codepoints in this set, ascending.
List<int> get simpleIconCodePoints => kSimpleIcons.keys.toList(growable: false);
