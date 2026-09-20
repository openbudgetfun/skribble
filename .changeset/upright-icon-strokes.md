---
skribble: fix
skribble_emoji: fix
skribble_emoji_gen: fix
skribble_icons_curated: fix
skribble_icons_simple: fix
skribble_icons_lucide: fix
skribble_icons_bxs: fix
skribble_icons_cib: fix
---

# Keep hand-drawn icons upright and rounded borders visibly irregular

Preserve authored icon endpoints while adding small bends along each stroke. Remove the shared displacement that made unrelated icon sets lean to the right, and regenerate the icon and emoji catalogs. Runtime icon drawing removes overall tilt, while wide rounded borders gain local variation with smooth corner joins.

Normalize insignificant floating-point drift so ARM and x64 generate identical icon and emoji coordinates.

The documentation and storybook activate the rough icon catalog at startup. The storybook bundles the current font package, exposes all six icon catalogs, and adds the missing loading, doodle, fill, typography, and table demonstrations.
