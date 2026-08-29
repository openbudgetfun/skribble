---
skribble: minor
---

# Material long tail, batch B — new hand-drawn widgets

Adds the final Material parity widgets from the audit backlog (PLANNING.md
1.3), plus the missing top-level time picker dialog helper:

- `WiredGridTile` + `WiredGridTileBar` (`wired_grid_tile.dart`) — grid tiles
  with header/footer bars, rough borders and a hand-drawn ink splash via
  `WiredInkSplashFactory` (now exported publicly).
- `WiredMergeableMaterial` (`wired_mergeable_material.dart`) — animated
  expand/collapse slices on top of rough borders. Ships
  `WiredMergeableMaterialItem`, `WiredMaterialSlice` and `WiredMaterialGap`
  mirroring Material's `MergeableMaterialItem` API family; gap size changes
  animate and a zero-size gap merges neighboring slices into one card.
- `WiredCheckboxMenuButton` and `WiredRadioMenuButton` (`wired_menu_bar.dart`)
  — menu items with hand-drawn checkbox/radio leading icons wired into the
  Material menu anchoring system (`MenuItemButton`), matching Material's
  default `closeOnActivate` behavior and tristate/toggleable semantics.
- `WiredAboutListTile` (`wired_about_list_tile.dart`) — a `WiredListTile`
  that opens `WiredAboutDialog` on tap, mirroring Material's `AboutListTile`.
- `showWiredTimePicker` (in `wired_time_picker.dart`) — top-level dialog
  helper matching `showWiredDatePicker`, with a hand-drawn Cancel/OK dialog
  around `WiredTimePicker`.

Also removes a stale `unreachable_from_main` ignore comment in
`tool/generate_material_rough_icons.dart` (no longer needed under the current
analyzer), and documents all of the above in the widget catalog
(`layout.md`, `navigation.md`, `selection.md`) and the API overview.

Storybook coverage added for every new widget (data display, layout, and
navigation pages).
