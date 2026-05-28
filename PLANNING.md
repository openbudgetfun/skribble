# Skribble — Detailed Planning & Progress Tracker

Last updated: 2026-05-27

## Status Legend
- ⬜ Not started
- 🔄 In progress
- ✅ Done
- ⏸️ Blocked/deprioritized
- 🔀 Changed from original plan

---

## Phase 1: Core Widget Parity

### 1.1 Audit existing widgets against Material 3 catalog
- ✅ List all Material 3 widgets from Flutter docs
- ✅ Cross-reference with existing `Wired*` widgets
- ✅ Identify gaps (missing widgets)
- ✅ Prioritize gaps by usage frequency
- ✅ Check test coverage for widgets missing Semantics

#### Test Coverage Status

All 24 widgets identified as missing Semantics support DO have existing test files (86 total widget tests). This means accessibility tests can be added to existing test suites.

#### Material 3 Widget Audit Results

**Existing Wired widgets (82 total):**
- wired_about_dialog, wired_animated_icon, wired_app_bar, wired_autocomplete
- wired_avatar, wired_badge, wired_bottom_app_bar, wired_bottom_nav
- wired_bottom_sheet, wired_button, wired_calendar, wired_calendar_date_picker
- wired_card, wired_checkbox, wired_checkbox_list_tile, wired_chip
- wired_choice_chip, wired_circular_progress, wired_color_picker, wired_combo
- wired_context_menu, wired_data_table, wired_date_picker, wired_dialog
- wired_dismissible, wired_divider, wired_drawer, wired_drawer_header
- wired_elevated_button, wired_expansion_tile, wired_fab, wired_filled_button
- wired_filter_chip, wired_form, wired_icon, wired_icon_button
- wired_input, wired_input_chip, wired_list_tile, wired_material_app
- wired_material_banner, wired_menu_bar, wired_navigation_bar, wired_navigation_drawer
- wired_navigation_rail, wired_outlined_button, wired_popup_menu, wired_progress
- wired_radio, wired_radio_list_tile, wired_range_slider, wired_reorderable_list_view
- wired_scaffold, wired_scrollbar, wired_search_bar, wired_segmented_button
- wired_selectable_text, wired_slider, wired_sliver_app_bar, wired_snack_bar
- wired_stepper, wired_switch, wired_switch_list_tile, wired_tab_bar
- wired_text_area, wired_text_button, wired_theme, wired_time_picker
- wired_toggle, wired_toggle_buttons, wired_tooltip
- Plus: wired_base, wired_cupertino_* (13 widgets)

**Missing Material widgets (gaps):**
1. ~~`WiredDropdownButton`~~ — ✅ Already exists as `WiredCombo` (wraps DropdownButton)
2. ~~`WiredDropdownMenu`~~ — ✅ Already exists (added in earlier PR)
3. `WiredExpansionPanelList` — Multiple expansion panels (MEDIUM)
4. `WiredPaginatedDataTable` — Paginated table (MEDIUM)
5. `WiredRefreshIndicator` — Pull-to-refresh (HIGH priority - very common)
6. `WiredCarouselView` — M3 carousel (LOW - new M3 component)
7. `WiredDatePickerDialog` — Date picker dialog (already have calendar/date_picker)
8. `WiredDateRangePickerDialog` — Date range picker (LOW)
9. `WiredSearchAnchor` — M3 search with suggestions (MEDIUM)
10. `WiredLicensePage` — License display (LOW)
11. `WiredAboutListTile` — About dialog tile (LOW - have AboutDialog)
12. `WiredCheckboxMenuButton` — Checkbox in menu (LOW)
13. `WiredRadioMenuButton` — Radio in menu (LOW)
14. `WiredCircleAvatar` — User avatar circle (have wired_avatar)
15. `WiredGridTile` / `WiredGridTileBar` — Grid tiles (LOW)
16. `WiredMergeableMaterial` — Mergeable material slices (LOW)

**Priority ranking:**
- HIGH: RefreshIndicator (DropdownButton/DropdownMenu already exist as WiredCombo/WiredDropdownMenu)
- MEDIUM: ExpansionPanelList, PaginatedDataTable, SearchAnchor
- LOW: Everything else

### 1.2 Audit existing widgets against Cupertino catalog
- ✅ List all Cupertino widgets from Flutter docs
- ✅ Cross-reference with existing `WiredCupertino*` widgets
- ✅ Identify gaps
- ⬜ Prioritize gaps

#### Cupertino Widget Audit Results

**Existing WiredCupertino widgets (13 total):**
- wired_cupertino_action_sheet
- wired_cupertino_alert_dialog
- wired_cupertino_button
- wired_cupertino_date_picker
- wired_cupertino_navigation_bar
- wired_cupertino_picker
- wired_cupertino_scaffold
- wired_cupertino_segmented_control
- wired_cupertino_slider
- wired_cupertino_switch
- wired_cupertino_tab_bar
- wired_cupertino_text_field

**Missing Cupertino widgets (gaps):**
1. `WiredCupertinoActivityIndicator` — iOS-style spinner (MEDIUM)
2. `WiredCupertinoListSection` — iOS-style list section (MEDIUM)
3. `WiredCupertinoListTile` — iOS-style list tile (MEDIUM)
4. `WiredCupertinoNavigationBar` — already have this
5. `WiredCupertinoPageScaffold` — already have this
6. `WiredCupertinoScrollbar` — iOS scrollbar (LOW - can use WiredScrollbar)
7. `WiredCupertinoSearchTextField` — iOS search field (MEDIUM)
8. `WiredCupertinoSlidingSegmentedControl` — M3-style segmented control (LOW)
9. `WiredCupertinoTimerPicker` — Timer picker (LOW)
10. `WiredCupertinoFormSection` — Form section (LOW)

**Priority:** Most Cupertino widgets are lower priority since the focus is on Material parity. The existing 13 cover the most common use cases.

### 1.3 Fill Material widget gaps
- ⬜ `WiredPaginatedDataTable`
- ⬜ `WiredExpansionPanelList`
- ⬜ `WiredRefreshIndicator`
- ⬜ `WiredSnackBar` animation improvements
- ⬜ Other gaps TBD from audit

### 1.4 Fill Cupertino widget gaps
- ⬜ TBD from audit

### 1.5 Accessibility audit
- ✅ Review all Wired widgets for semantic labels
- 🔄 Add missing `Semantics` wrappers (13/24 done)
- ⬜ Test with screen reader (TalkBack/VoiceOver)
- ⬜ Document accessibility patterns

#### Accessibility Audit Results

**Widgets WITH Semantics support:**
- wired_button, wired_elevated_button, wired_filled_button
- wired_outlined_button, wired_text_button, wired_fab
- wired_icon_button, wired_icon
- wired_switch, wired_cupertino_switch
- wired_toggle

**Widgets MISSING Semantics support (need to add):**
- ✅ wired_checkbox — added checkbox semantics with semanticLabel
- ✅ wired_radio — added radio button semantics with semanticLabel
- ✅ wired_slider — added slider semantics with value/range
- ✅ wired_chip — added chip semantics with delete action
- ✅ wired_input — added textField semantics with semanticLabel
- ✅ wired_text_area — added textField semantics with semanticLabel
- ✅ wired_list_tile — added button semantics with tap action
- ✅ wired_date_picker — added button semantics with semanticLabel
- ✅ wired_time_picker — added button semantics with semanticLabel
- ✅ wired_bottom_sheet — added sheet semantics with semanticLabel
- ✅ wired_navigation_bar — added navigation bar semantics with semanticLabel
- ✅ wired_tab_bar — added tab bar semantics with semanticLabel
- ✅ wired_stepper — added stepper semantics with current step information
- wired_range_slider — needs range slider semantics
- wired_input / wired_text_area — needs text field semantics
- wired_chip / wired_choice_chip / wired_filter_chip / wired_input_chip — needs chip semantics
- wired_dialog — needs dialog semantics (label, barrier)
- wired_tooltip — needs tooltip semantics
- wired_snack_bar — needs snackbar semantics
- wired_date_picker — needs date picker semantics
- wired_time_picker — needs time picker semantics
- wired_bottom_sheet — needs bottom sheet semantics
- wired_drawer — needs drawer semantics
- wired_list_tile — needs list tile semantics
- wired_checkbox_list_tile — needs combined semantics
- wired_radio_list_tile — needs combined semantics
- wired_switch_list_tile — needs combined semantics
- wired_expansion_tile — needs expansion tile semantics
- wired_navigation_bar — needs navigation semantics
- wired_bottom_nav — needs navigation semantics
- wired_tab_bar — needs tab semantics
- wired_stepper — needs stepper semantics

**Priority:** HIGH — Accessibility is critical for production apps. Should be addressed alongside widget implementation.

### 1.6 Animation polish
- ⬜ Define hand-drawn animation style guide
- ⬜ Implement ripple/splash adapted for sketchy look
- ⬜ Loading states with hand-drawn spinners
- ⬜ Transition animations

---

## Phase 2: Font Roughening Pipeline

### 2.1 Research Dart font manipulation
- ✅ Evaluate `font` package on pub.dev for OpenType manipulation
- ✅ Evaluate `font_parser` package
- ✅ Determine if FontForge FFI is needed
- ✅ Document findings and chosen approach

#### Research Findings

**Available Dart packages for font manipulation:**

1. **`opentype_dart`** — OpenType.js rewrite in Dart
   - Read and write OpenType fonts
   - Table-level API (cmap, glyf, hmtx, kern, etc.)
   - Glyph outline access via BoundingBox
   - **Best candidate for our use case**

2. **`fontify_plus`** — SVG → OpenType font generation
   - Focused on icon font generation
   - Has font/glyph model classes
   - Less suitable for general font manipulation

3. **`pure_ui` / `TtfParser`** — Low-level TTF parser
   - Access to glyf table, glyph outlines
   - Read-only, no write support documented
   - TrueType only (not CFF/OTF)

**Chosen approach:**
- Use `opentype_dart` as primary library for reading/writing fonts
- If glyph outline manipulation is insufficient, fall back to FontForge FFI
- Build Dart CLI tool that reads font, applies jitter to on-curve points, writes output

**Risk:** Round-trip font modification (read → modify → write) may have edge cases. Need to test with real fonts early.

### 2.2 Build Dart CLI tool
- ⬜ Create `packages/skribble_font_roughen/` package
- ⬜ Implement TTF/OTF reading
- ⬜ Implement glyph outline extraction (on-curve points)
- ⬜ Implement deterministic jitter algorithm (port from Python)
- ⬜ Implement TTF/OTF output
- ⬜ Add configurable roughness parameter
- ⬜ Add CLI argument parsing
- ⬜ Write tests

### 2.3 Pre-roughen popular fonts
- ⬜ Inter (Regular, Bold, Italic, BoldItalic)
- ⬜ Roboto (Regular, Bold, Italic, BoldItalic)
- ⬜ Open Sans (Regular, Bold, Italic, BoldItalic)
- ⬜ Lato (Regular, Bold, Italic, BoldItalic)
- ⬜ Poppins (Regular, Bold, Italic, BoldItalic)
- ⬜ Source Sans Pro (Regular, Bold, Italic, BoldItalic)

### 2.4 Visual regression testing
- ⬜ Define golden test approach for font rendering
- ⬜ Create test fonts with known inputs
- ⬜ Implement visual diffing

### 2.5 Remove Python dependency
- ⬜ Delete `roughen_font.py` after Dart replacement is verified
- ⬜ Update documentation
- ⬜ Update CI scripts

---

## Phase 3: Icon Ecosystem

### 3.1 Expand skribble_emoji
- ⬜ Verify full OpenMoji set generation (1,800+ emoji)
- ⬜ Test emoji rendering performance
- ⬜ Add emoji search/lookup by name
- ⬜ Add emoji categories

### 3.2 Icon font generation (TTF)
- ✅ Research approach: SVG paths → FontForge → TTF
- ⬜ Generate test icon font with subset of icons
- ⬜ Evaluate visual quality
- ⬜ If quality is good: generate full icon font
- ⬜ Create `SkribbleIconFont` widget for font-based icon rendering

#### Research Findings

**Dart-native options for SVG → TTF:**
1. **`fontify_plus`** — SVG → OpenType font generation
   - Pure Dart, no external dependencies
   - Generates Flutter icon class
   - API and CLI support
   - **Best candidate for icon font generation**

2. **`svg_to_font_convertor`** — Similar to fontify_plus
   - Pure Dart, self-contained
   - Generates .otf files

3. **FontForge CLI** — Current approach for font roughening
   - Can also generate icon fonts from SVGs
   - Requires external dependency

**Chosen approach:**
- Use `fontify_plus` for SVG → TTF icon font generation
- Test with subset of roughened Material icons first
- If quality is insufficient, fall back to FontForge CLI

### 3.3 Cupertino icons
- ⬜ Extract Cupertino icon SVG paths
- ⬜ Run through rough engine
- ⬜ Add to `skribble_icons` package

### 3.4 Performance optimization
- ⬜ Benchmark current icon loading time
- ⬜ Optimize pre-computed icon map size
- ⬜ Consider lazy loading for large icon sets

---

## Phase 4: Developer Experience & Distribution

### 4.1 pub.dev publishing
- ✅ Check pubspec.yaml files for pub.dev requirements
- ⬜ Set up monochange versioning
- ⬜ Verify all packages meet pub.dev requirements
- ⬜ Publish initial versions

#### Pub.dev Readiness Status

**Packages checked:**
- `skribble` — v0.3.4, has homepage/repository/issue_tracker ✅
- `skribble_icons` — v0.1.0, has homepage/repository/issue_tracker ✅
- `skribble_icons_custom` — v0.1.0, has homepage/repository/issue_tracker ✅
- `skribble_emoji` — v0.1.0, has homepage/repository/issue_tracker ✅
- `skribble_lints` — v0.1.0, missing homepage/repository/issue_tracker ⚠️

**TODO:**
- Add homepage/repository/issue_tracker to `skribble_lints`
- ✅ Add LICENSE files to: `skribble_icons`, `skribble_icons_custom`, `skribble_emoji`
- ✅ Add CHANGELOG.md to: `skribble_icons`, `skribble_icons_custom`, `skribble_emoji`
- Verify all packages pass `dart pub publish --dry-run`

### 4.2 Documentation
- ⬜ Update getting started guide
- ⬜ Create migration guide (Material → Skribble)
- ⬜ Update widget catalog
- ⬜ Add code examples for common patterns

### 4.3 Web support
- ✅ Check for dart:io/Platform usage (none found)
- ✅ Check for web-specific code (none found)
- ⬜ Test all widgets on Flutter web
- ⬜ Fix any web-specific rendering issues
- ⬜ Document web support status

#### Web Compatibility Assessment

**Good news:** No `dart:io` or `Platform.` usage found in the main library. The library should be web-compatible out of the box.

**Potential concerns:**
- CustomPaint rendering may have different behavior on web (CanvasKit vs HTML renderer)
- Font loading may differ on web
- Performance characteristics may differ

**Recommendation:** Test with both `--web-renderer html` and `--web-renderer canvaskit`

### 4.4 Example apps
- ⬜ Update `skribble_example` app
- ⬜ Create showcase app demonstrating all widgets

---

## Phase 5: Beyond Flutter (Future)

- ⬜ Standalone font package
- ⬜ SVG library for web
- ⬜ Research React Native / SwiftUI / Jetpack Compose feasibility

---

## Change Log

### 2026-05-27
- Created planning document
- Set up 10-minute recurring reminder for 18 hours
- Started Phase 1.1 audit
- Completed Phase 1.1 Material 3 widget audit (82 existing, 16 gaps identified)
- Completed Phase 1.2 Cupertino widget audit (13 existing, ~8 gaps identified)
- Identified HIGH priority gaps: DropdownButton/DropdownMenu, RefreshIndicator
- Completed Phase 2.1 font manipulation research (opentype_dart is best candidate)
- Completed Phase 3.2 icon font generation research (fontify_plus is best candidate)
- Completed Phase 4.1 pub.dev readiness check (missing LICENSE/CHANGELOG in 3 packages)
- Completed Phase 4.3 web compatibility assessment (no dart:io usage, web-ready)
- Updated PLANNING.md: WiredCombo and WiredDropdownMenu already exist
- Added Semantics to WiredCheckbox, WiredRadio, WiredSlider (Phase 1.5)
- Added Semantics to WiredChip (Phase 1.5)
- Added LICENSE and CHANGELOG to skribble_icons, skribble_icons_custom, skribble_emoji (Phase 4.1)
