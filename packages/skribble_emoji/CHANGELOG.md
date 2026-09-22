# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

### Fixes

#### Keep hand-drawn icons upright and rounded borders visibly irregular

Preserve authored icon endpoints while adding small bends along each stroke. Remove the shared displacement that made unrelated icon sets lean to the right, and regenerate the icon and emoji catalogs. Runtime icon drawing removes overall tilt, while wide rounded borders gain local variation with smooth corner joins.

Normalize insignificant floating-point drift so ARM and x64 generate identical icon and emoji coordinates.

The documentation and storybook activate the rough icon catalog at startup. The storybook bundles the current font package, exposes all six icon catalogs, and adds the missing loading, doodle, fill, typography, and table demonstrations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [26f116a](https://github.com/openbudgetfun/skribble/commit/26f116ae5da5dcdfc1b29b90c341b62ba1fb17f4)

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

### Documentation

- **Lowercase the skribble brand word across documentation.** READMEs, docs site pages and titles, package descriptions, and source comments now write the brand word as lowercase skribble. Dart identifiers, bundled font families such as SkribbleGentle, asset names, and runtime strings keep their casing, so no API or behaviour changes. _Owner:_ Ifiok Jr. · _Introduced in:_ [5e3937c](https://github.com/openbudgetfun/skribble/commit/5e3937ccb6db77bc38e9ac95d273e018def98843) · _Last updated in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

## [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.1) (2026-09-13)

### Changed

- **No package-specific changes were recorded; `skribble_emoji` was updated to 0.1.1 as part of group `main`.**

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-11)

### Changed

#### No package-specific changes were recorded; `skribble_emoji` was updated to 0.1.0 as part of group `main`.
