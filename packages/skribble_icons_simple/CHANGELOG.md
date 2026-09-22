# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

### Fixes

#### Keep hand-drawn icons upright and rounded borders visibly irregular

Preserve authored icon endpoints while adding small bends along each stroke. Remove the shared displacement that made unrelated icon sets lean to the right, and regenerate the icon and emoji catalogs. Runtime icon drawing removes overall tilt, while wide rounded borders gain local variation with smooth corner joins.

Normalize insignificant floating-point drift so ARM and x64 generate identical icon and emoji coordinates.

The documentation and storybook activate the rough icon catalog at startup. The storybook bundles the current font package, exposes all six icon catalogs, and adds the missing loading, doodle, fill, typography, and table demonstrations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [26f116a](https://github.com/openbudgetfun/skribble/commit/26f116ae5da5dcdfc1b29b90c341b62ba1fb17f4)

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

### Changed

#### No package-specific changes were recorded; `skribble_icons_simple` was updated to 0.2.0 as part of group `main`.
