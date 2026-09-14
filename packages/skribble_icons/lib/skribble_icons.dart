/// Every skribble hand-drawn icon set behind one import.
///
/// The sets live in separate packages so an app only pays for the artwork it
/// ships. This package depends on all of them, re-exports their catalogs, and
/// adds a cross-set lookup that searches the curated set first.
///
/// | Set | Package | Names | Style |
/// | --- | --- | --- | --- |
/// | Curated | `skribble_icons_curated` | 30 | app vocabulary |
/// | Simple Icons | `skribble_icons_simple` | 3,472 | brand marks |
/// | Material | `skribble_icons_material` | 8,600+ | Flutter's `Icons` |
/// | Lucide | `skribble_icons_lucide` | 2,056 | 2px outline |
/// | Boxicons Solid | `skribble_icons_bxs` | 665 | filled |
/// | CoreUI Brands | `skribble_icons_cib` | 831 | brand marks |
///
/// ```dart
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_icons/skribble_icons.dart';
///
/// void main() {
///   registerSkribbleIcons();
///   runApp(const MyApp());
/// }
///
/// // Any set, by identifier:
/// final icon = lookupSkribbleIconByIdentifier('home');
/// ```
library;

import 'package:skribble/skribble.dart';
import 'package:skribble_icons_bxs/skribble_icons_bxs.dart';
import 'package:skribble_icons_cib/skribble_icons_cib.dart';
import 'package:skribble_icons_curated/skribble_icons_curated.dart';
import 'package:skribble_icons_lucide/skribble_icons_lucide.dart';
import 'package:skribble_icons_material/skribble_icons_material.dart';
import 'package:skribble_icons_simple/skribble_icons_simple.dart';

export 'package:skribble/skribble.dart' show SkribbleIcon, WiredIconFillStyle;
export 'package:skribble_icons_bxs/skribble_icons_bxs.dart';
export 'package:skribble_icons_cib/skribble_icons_cib.dart';
export 'package:skribble_icons_curated/skribble_icons_curated.dart';
export 'package:skribble_icons_lucide/skribble_icons_lucide.dart';
export 'package:skribble_icons_material/skribble_icons_material.dart';
export 'package:skribble_icons_simple/skribble_icons_simple.dart';

/// Activates the Material catalog so `WiredIcon(icon: Icons.search)` draws
/// hand-drawn geometry instead of falling back to the Material font glyph.
///
/// Call once during startup. Named catalogs are otherwise opt-in, which keeps
/// the core library free of any icon-set dependency.
void registerSkribbleIcons() => registerSkribbleMaterialIcons();

/// The set that supplied an icon, in the order [lookupSkribbleIconByIdentifier]
/// searches them.
enum SkribbleIconSet {
  /// Hand-authored app vocabulary from `skribble_icons_curated`.
  curated,

  /// Simple Icons brand marks from `skribble_icons_simple`.
  simple,

  /// Flutter's Material set from `skribble_icons_material`.
  material,

  /// Lucide outline set from `skribble_icons_lucide`.
  lucide,

  /// Boxicons solid set from `skribble_icons_bxs`.
  bxs,

  /// CoreUI brand marks from `skribble_icons_cib`.
  cib,
}

/// Returns hand-drawn geometry for [identifier], searching every bundled set.
///
/// The curated set wins ties, because those names are chosen to match the
/// component library's own vocabulary. Simple Icons brand slugs come next
/// because they are unambiguous — `'github'` always means the logo. Material
/// follows so existing Flutter identifiers keep resolving, then the remaining
/// Iconify sets.
///
/// ```dart
/// lookupSkribbleIconByIdentifier('home'); // curated set
/// lookupSkribbleIconByIdentifier('github'); // simple set
/// lookupSkribbleIconByIdentifier('a-arrow-down'); // lucide
/// ```
WiredSvgIconData? lookupSkribbleIconByIdentifier(String identifier) {
  return lookupSkribbleIcon(identifier)?.data;
}

/// Like [lookupSkribbleIconByIdentifier], but also reports which set matched.
SkribbleIconMatch? lookupSkribbleIcon(String identifier) {
  final curated = lookupSkribbleCuratedIconByIdentifier(identifier);
  if (curated != null) {
    return SkribbleIconMatch(SkribbleIconSet.curated, curated);
  }
  final simple = lookupSimpleIconByIdentifier(identifier);
  if (simple != null) {
    return SkribbleIconMatch(SkribbleIconSet.simple, simple);
  }
  // Read the Material maps directly rather than going through the registered
  // catalog, so a cross-set lookup works without a startup registration.
  final materialCodePoint = kMaterialRoughIconsCodePoints[identifier];
  if (materialCodePoint != null) {
    final data = kMaterialRoughIcons[materialCodePoint];
    if (data != null) {
      return SkribbleIconMatch(SkribbleIconSet.material, data);
    }
  }
  final lucide = lookupLucideIconByIdentifier(identifier);
  if (lucide != null) {
    return SkribbleIconMatch(SkribbleIconSet.lucide, lucide);
  }
  final bxs = lookupBxsIconByIdentifier(identifier);
  if (bxs != null) {
    return SkribbleIconMatch(SkribbleIconSet.bxs, bxs);
  }
  final cib = lookupCibIconByIdentifier(identifier);
  if (cib != null) {
    return SkribbleIconMatch(SkribbleIconSet.cib, cib);
  }
  return null;
}

/// A resolved icon together with the set it came from.
final class SkribbleIconMatch {
  /// Creates a match record.
  const SkribbleIconMatch(this.set, this.data);

  /// Which catalog supplied [data].
  final SkribbleIconSet set;

  /// The hand-drawn geometry.
  final WiredSvgIconData data;
}

/// Identifiers from every bundled set, excluding Material's 8,600+ names so
/// the result stays cheap to build. Use [materialRoughIconIdentifiers] for
/// those.
List<String> get skribbleIconIdentifiers => [
  ...skribbleCuratedIconIdentifiers,
  ...simpleIconIdentifiers,
  ...lucideIconIdentifiers,
  ...bxsIconIdentifiers,
  ...cibIconIdentifiers,
];

/// Total names across the bundled non-Material sets.
int get skribbleIconCount =>
    skribbleCuratedIconCount +
    simpleIconCount +
    lucideIconCount +
    bxsIconCount +
    cibIconCount;

/// Total names in the Material catalog.
int get skribbleMaterialIconCount => materialRoughIconCodePoints.length;
