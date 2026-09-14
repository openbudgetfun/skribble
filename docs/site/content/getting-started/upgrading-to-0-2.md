---
title: Upgrading to 0.2
description: How to migrate an app to skribble 0.2, where icon catalogs and typefaces moved into their own packages.
---

# Upgrading to 0.2

skribble 0.2 stops bundling icon data and fonts inside the core `skribble` package. Each set is now its own package, so an app only downloads the artwork it renders. That is what makes `skribble` 26 MB smaller, and it is also the reason for the breaking changes below.

Nothing about how icons or text _look_ changed. What changed is where the data lives and how it reaches the widgets.

If you are new to skribble, the [installation guide](/getting-started/installation) is the better starting point. This page is for apps already on 0.1.x.

## Do I have to migrate?

Yes, if you render hand-drawn icons or use the bundled typefaces. Both moved out of the core package.

Nothing throws if you skip a step. `WiredIcon` falls back to Flutter's ordinary `Icon` widget and missing fonts fall back to the platform face, so a partial migration degrades to plainer pixels rather than a crash. That is deliberate, but it does mean a missed step is quiet. Work through the checklist below.

## The three changes

| What                  | 0.1.x                                                | 0.2                               |
| --------------------- | ---------------------------------------------------- | --------------------------------- |
| Material icon catalog | Inside `skribble`                                    | `skribble_icons_material`         |
| The 30 curated icons  | `skribble_icons_simple`                              | `skribble_icons_curated`          |
| Bundled typefaces     | Inside `skribble`                                    | `skribble_font_recursive`         |
| Unified lookup        | `lookupSkribbleIconByIdentifier` on `skribble_icons` | unchanged, now searches more sets |

## Step 1: Add the packages you use

`skribble_icons` is now an umbrella: depending on it pulls in every icon set. That is convenient but large, so many apps will prefer a single set.

```yaml
dependencies:
  skribble: ^0.2.0

  # Option A: everything behind one import.
  skribble_icons: ^0.2.0

  # Option B: only what you render.
  # skribble_icons_material: ^0.2.0   # Flutter's Icons, 8,600+ glyphs
  # skribble_icons_lucide: ^0.2.0     # 2,056 open outlines
  # skribble_icons_bxs: ^0.2.0        # 665 filled silhouettes
  # skribble_icons_cib: ^0.2.0        # 831 brand marks
  # skribble_icons_simple: ^0.2.0     # 3,472 Simple Icons brand marks
  # skribble_icons_curated: ^0.2.0    # 30 hand-authored UI icons
```

Add the typefaces if the app renders text in the skribble faces:

```yaml
skribble_font_recursive: ^0.2.0
```

Run `dart pub get`.

## Step 2: Register the icon catalog

This is the step that bites, because skipping it is silent. `WiredIcon` resolves an `IconData` through a catalog the core package no longer owns, so you must install one at startup:

```dart
// Static example: api
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  registerSkribbleIcons();
  runApp(const MyApp());
}
```

If you depend on `skribble_icons_material` instead of the umbrella, call its registration function directly:

```dart
// Static example: api
import 'package:skribble_icons_material/skribble_icons_material.dart';

void main() {
  registerSkribbleMaterialIcons();
  runApp(const MyApp());
}
```

Both are idempotent and safe before `runApp`. The Iconify sets and the curated set need no registration — they are looked up by name, which the umbrella reads directly.

**How to tell it is missing:** `WiredIcon(icon: Icons.search)` renders the plain Material font glyph rather than a hand-drawn shape. If your icons look suddenly crisp and geometric, this is why.

## Step 3: Rename the curated icon set

`skribble_icons_simple` held 30 hand-authored UI icons. That name collided with [Simple Icons](https://simpleicons.org), the brand-mark project, so the curated set is now `skribble_icons_curated` and `skribble_icons_simple` means the real Simple Icons catalog.

```diff
-import 'package:skribble_icons_simple/skribble_icons_simple.dart';
+import 'package:skribble_icons_curated/skribble_icons_curated.dart';

-lookupSkribbleSimpleIconByIdentifier('home')
+lookupSkribbleCuratedIconByIdentifier('home')

-kSkribbleCustomIconsRough
+kSkribbleCuratedIcons

-skribbleSimpleIconCount
+skribbleCuratedIconCount
```

The `SkribbleIconSet.simple` enum value split in two. `SkribbleIconSet.curated` is the hand-authored set; `SkribbleIconSet.simple` is the Simple Icons brands.

If you were only using the umbrella's unified lookup, nothing changes — `lookupSkribbleIconByIdentifier` still works and now searches more sets.

## Step 4: Point pinned font families at the new package

The family _names_ are unchanged (`Skribble`, `SkribbleGentle`, `SkribbleVariablePlayful`, and so on). What changed is the package they resolve through, so any `TextStyle` that pinned them must be updated:

```diff
 TextStyle(
   fontFamily: 'SkribblePlayful',
-  package: 'skribble',
+  package: 'skribble_font_recursive',
 )
```

Most apps never wrote this by hand. If you used `WiredTheme`, `WiredFont`, or `WiredRoughness`, the theme already resolves the right package and you have nothing to do here. Search the codebase for `package: 'skribble'` to be sure.

## Step 5: Update moved icon accessors

These moved from `skribble` to `skribble_icons_material`, because the catalog they describe lives there now:

- `materialRoughFontFamily`
- `materialRoughFontCodePoints`
- `materialRoughIconIdentifiers`
- `materialRoughIconCodePoints`
- `lookupMaterialRoughFontIcon`

Import `package:skribble_icons_material/skribble_icons_material.dart` and the names resolve unchanged. `lookupMaterialRoughFontIcon` is also still available from core, resolving through whichever catalog is registered.

## Removed without replacement

- **`SkribbleIconFont` and `SkribbleIconFontIcons`.** They documented a `SkribbleIcons.ttf` asset that was never shipped, so they could not have worked. Use `WiredSvgIcon` with a catalog entry instead.
- **`WiredCupertinoIcon`.** It imported a path that no longer resolved. Use `WiredIcon` with a Cupertino `IconData`, or `WiredSvgIcon` with your own data.
- **`skribble_icons_custom`.** A five-icon example package with no dependents. If you used it, the 30-icon `skribble_icons_curated` set is the practical replacement.

## Verifying the migration

A quick check that the catalog is live, rather than silently falling back:

```dart
// Static example: test
final data = lookupSkribbleIconByIdentifier('search');
assert(data != null, 'Icon catalog is not registered.');
```

And that fonts resolve, by rendering text in a skribble family and confirming the glyphs are hand-drawn rather than the platform default.

## Why this was worth a breaking change

`skribble` shipped 26 MB compressed, and 25 of those megabytes were font files plus 8,600 icon codepoints that a given app might never render. After the split, `skribble` is 432 KB and you pay only for the sets you import — 0.25 MB for Lucide, 2.00 MB for the full Simple Icons catalog, or nothing at all if you bring your own icons.

The [releasing reference](/reference/releasing) covers the package list, and the [icons page](/widgets/icons) documents the lookup API in full.
