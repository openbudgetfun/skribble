---
skribble: minor
---

Add "Material long tail" batch A widgets to close four M3 parity gaps:

- `WiredCarouselView`: hand-drawn horizontal carousel of rough-bordered cards
  mirroring M3 `CarouselView`'s `itemExtent` / `height` / `children` /
  `shrinkWrap` API, with optional hachure fill, tap callbacks, and item
  semantics.
- `WiredSearchAnchor` + `WiredSearchController`: search anchor pairing a
  collapsible `WiredSearchBar` with an in-place suggestions view
  (`builder` / `suggestionsBuilder` / `closeView(selection)` flow, analogous
  to Material's `SearchAnchor`). `WiredSearchBar` gains `onTap` and
  `autoFocus` parameters.
- `WiredDateRangePickerDialog` + `showWiredDateRangePicker`: hand-drawn range
  selection dialog reusing the calendar's month-grid visual language, with
  `firstDate`/`lastDate` clamping and month navigation.
- `WiredLicensePage` + `showWiredLicensePage`: license page rendered from
  `LicenseRegistry` data (alphabetical packages, rough-bordered headers,
  wired spinner while loading).

Storybook showcases were added to the Layout, Inputs, Data Display, and
Feedback pages; docs catalog entries to `widgets/layout.md`,
`widgets/inputs.md`, `widgets/selection.md`, `widgets/feedback.md`, and the
API overview; plus ~54 new widget tests.
