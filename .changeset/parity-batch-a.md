---
skribble: minor
---

# Add the Material long-tail parity widgets

The final Material parity audit batches add hand-drawn widgets mirroring the M3 APIs: `WiredCarouselView` (itemExtent/height/children/shrinkWrap with optional hachure fill), `WiredSearchAnchor` and `WiredSearchController` pairing a collapsible `WiredSearchBar` (with `onTap` and `autoFocus`) with an in-place suggestions view, `WiredDateRangePickerDialog` plus `showWiredDateRangePicker` reusing the calendar's month-grid language, `WiredLicensePage` plus `showWiredLicensePage` rendered from `LicenseRegistry`, `WiredGridTile` and `WiredGridTileBar` with rough borders and the publicly exported `WiredInkSplashFactory`, `WiredMergeableMaterial` with its slice/gap API family and animated merging, `WiredCheckboxMenuButton` and `WiredRadioMenuButton` wired into menu anchoring with tristate and toggleable semantics, `WiredAboutListTile`, and the top-level `showWiredTimePicker` dialog helper. Storybook showcases, widget catalog entries, and widget tests cover every widget.
