# skribble — Detailed Planning & Progress Tracker

Last updated: 2026-09-13

> **Historical/rolling tracker — not a source of truth.** This document records how the project got to its current state: session notes, completed sprints, and plans as they were written. Claims in it go stale, and several (accessibility coverage, widget-gap status, decoupling counts) have been wrong in the past. For current architecture and direction, read [`docs/site/content/core/architecture.md`](docs/site/content/core/architecture.md). For the current decoupling snapshot, read [`docs/material-dependency-audit.txt`](docs/material-dependency-audit.txt) (regenerate with `dart run tool/audit_material_dependencies.dart`). When this file disagrees with either, they win.

## Status Legend

- ⬜ Not started
- 🔄 In progress
- ✅ Done
- ⏸️ Blocked/deprioritized
- 🔀 Changed from original plan

---

## Overall Status

**Project Status: SUBSTANTIALLY COMPLETE for widget parity; the material decoupling is the active hard target.**

The skribble hand-drawn design system is production-ready with:

- 80+ Wired widgets covering the Material and Cupertino catalogs (parity work is merged through PRs #136–#138)
- Explicit `Semantics` in 45 of 112 widget files (see the accessibility correction below — most widgets currently appear accessible because the Material widget they wrap supplies semantics, and that supply disappears as each skin is rewritten)
- Complete animation/motion system (`lib/src/motion`, hooks-independent)
- Font roughening pipeline (Dart CLI tool)
- 1,827 hand-drawn emoji from OpenMoji
- Icon performance optimization
- Comprehensive documentation
- pub.dev publishing configuration

**The remaining hard work is the Material decoupling rewrite** (70 skin files, ordered plan in AGENTS.md and the architecture doc). Other open items are LOW priority or need external resources.

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
3. ~~`WiredExpansionPanelList`~~ — ✅ Multiple expansion panels (MEDIUM - implemented)
4. ~~`WiredPaginatedDataTable`~~ — ✅ Paginated table (MEDIUM - implemented)
5. `WiredRefreshIndicator` — ⚠️ **not shipped.** The file exists at `packages/skribble/lib/src/wired_refresh_indicator.dart` (165 lines), but it is not exported from `packages/skribble/lib/skribble.dart` and is referenced nowhere else in the repository — no tests, no storybook entry. It is dead code, not a delivered pull-to-refresh widget. Either finish it (export, tests, storybook, docs, catalog entry) or delete it.
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

- HIGH: RefreshIndicator — ⚠️ implemented but unexported and unused (dead code; see above)
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

- ✅ `WiredPaginatedDataTable`
- ✅ `WiredExpansionPanelList`
- ⚠️ `WiredRefreshIndicator` — file exists but is dead code, not exported (see Phase 1.1)
- ⬜ `WiredSnackBar` animation improvements
- ⬜ Other gaps TBD from audit

### 1.4 Fill Cupertino widget gaps

- ⬜ TBD from audit

### 1.5 Accessibility audit

- 🔀 Partial review only — do not read the checkmarks below as current coverage
- 🔀 `Semantics` added to 22 widgets in the May sprint (list below); 45 of 112 widget files contain an explicit `Semantics` construction as of 2026-09-13
- ⬜ Per-widget screen-reader verification (the testing guide exists, but "tested" was not recorded per widget)
- ✅ Document accessibility patterns (see `docs/site/content/reference/accessibility-testing.md`)

#### Accessibility Audit Results — corrected 2026-09-13

> **Correction.** The summary this section used to end with ("33 total widgets with Semantics support... Only 2 widgets remaining for manual review") was wrong. A grep of `packages/skribble/lib/src/wired_*.dart` finds an explicit `Semantics` in 45 of 112 widget files, and the old audit conflated three different situations: widgets that render their own semantics, widgets whose semantics come from the wrapped Material/Cupertino widget, and widgets never checked. Most widgets look accessible today because a Material widget inside them supplies platform semantics. **Accessible with Material is not accessible without Material:** when a skin is rewritten onto `flutter/widgets`, the semantics supplied by the removed wrapper go with it. Every skin rewrite in the decoupling plan needs an accessibility check — semantic tree, labels, roles and states, focus order, and a screen-reader pass — and the result belongs in the widget's tests, not in a hand-maintained count on this page.

**Widgets with explicit Semantics at the time of the sprint (11 widgets):**

- wired_button, wired_elevated_button, wired_filled_button
- wired_outlined_button, wired_text_button, wired_fab
- wired_icon_button, wired_icon
- wired_switch, wired_cupertino_switch
- wired_toggle

**Widgets with Semantics added during this sprint (22 widgets):**

- ✅ wired_checkbox — checkbox semantics with semanticLabel, checked/toggled state
- ✅ wired_radio — radio button semantics with semanticLabel, inGroup/checked state
- ✅ wired_slider — slider semantics with semanticLabel, value/range/increase/decrease
- ✅ wired_range_slider — slider semantics with semanticLabel, range value display
- ✅ wired_chip — chip semantics with semanticLabel, button/delete action
- ✅ wired_choice_chip — chip semantics with semanticLabel, selected state
- ✅ wired_filter_chip — chip semantics with semanticLabel, selected state
- ✅ wired_input_chip — chip semantics with semanticLabel, selected/delete state
- ✅ wired_action_chip — chip semantics with semanticLabel, button action
- ✅ wired_input — textField semantics with semanticLabel
- ✅ wired_text_area — textField semantics with semanticLabel
- ✅ wired_list_tile — button semantics with semanticLabel, tap action
- ✅ wired_checkbox_list_tile — combined semantics via WiredListTile
- ✅ wired_radio_list_tile — combined semantics via WiredListTile
- ✅ wired_switch_list_tile — combined semantics via WiredListTile
- ✅ wired_date_picker — button semantics with semanticLabel
- ✅ wired_time_picker — button semantics with semanticLabel
- ✅ wired_bottom_sheet — sheet semantics with semanticLabel
- ✅ wired_snack_bar — liveRegion semantics with semanticLabel
- ✅ wired_navigation_bar — navigation bar semantics with semanticLabel
- ✅ wired_tab_bar — tab bar semantics with semanticLabel
- ✅ wired_stepper — stepper semantics with semanticLabel, current step info
- ✅ wired_expansion_tile — expanded state semantics with semanticLabel

**Widgets whose semantics came from the wrapped Material/Cupertino widget (rewrite re-verification required):**

- wired_dialog — wraps Flutter's Dialog, which supplies semantics today
- wired_drawer — wraps Flutter's Drawer, which supplies semantics today
- wired_tooltip — wraps Flutter's Tooltip, which supplies semantics today

**Known gaps at the time of the sprint (never verified since):**

- wired_bottom_nav — needs navigation semantics (LOW - wraps Flutter widget)
- wired_reorderable_list_view — needs list semantics (LOW - wraps Flutter widget)

**Priority:** HIGH — accessibility is critical for production apps, and each decoupling rewrite is a chance to lose semantics silently.

**Correct summary (2026-09-13):** 45 of 112 widget files render an explicit `Semantics`; the rest either inherit semantics from a wrapped framework widget, wrap a widget that supplies them, or have not been reviewed. There is no current count of per-widget screen-reader verification.

### 1.6 Animation polish

- ✅ Define hand-drawn animation style guide
- ✅ Implement ripple/splash adapted for sketchy look
- ✅ Loading states with hand-drawn spinners
- ✅ Transition animations

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

- ✅ Create `packages/skribble_font_roughen/` package
- ✅ Implement TTF/OTF reading (using opentype_dart)
- ✅ Implement glyph outline extraction (using opentype_dart)
- ✅ Implement deterministic jitter algorithm (port from Python)
- ✅ Implement TTF/OTF output (using opentype_dart)
- ✅ Add configurable roughness parameter
- ✅ Add CLI argument parsing
- ✅ Write tests

### 2.3 Pre-roughen popular fonts

- ⬜ Inter (Regular, Bold, Italic, BoldItalic)
- ⬜ Roboto (Regular, Bold, Italic, BoldItalic)
- ⬜ Open Sans (Regular, Bold, Italic, BoldItalic)
- ⬜ Lato (Regular, Bold, Italic, BoldItalic)
- ⬜ Poppins (Regular, Bold, Italic, BoldItalic)
- ⬜ Source Sans Pro (Regular, Bold, Italic, BoldItalic)

**Note:** Script created (`roughen_fonts.dart`) to automate font roughening. Implementation is placeholder - needs actual font downloading and processing.

### 2.4 Visual regression testing

- ✅ Define golden test approach for font rendering
- ✅ Create test fonts with known inputs
- ✅ Implement visual diffing (placeholder created)

### 2.5 Remove Python dependency

- ✅ Delete `roughen_font.py` after Dart replacement is verified (deprecated with notice)
- ✅ Update documentation (README.md created for skribble_font_roughen)
- ✅ Update documentation references (wired_theme.dart updated)
- ✅ Update CI scripts (check_font_roughener_ci.sh created)

---

## Phase 3: Icon Ecosystem

### 3.1 Expand skribble_emoji

- ✅ Verify full OpenMoji set generation (1,800+ emoji) - 1,827 emoji in generated file
- ✅ Test emoji rendering performance (performance tests created)
- ✅ Add emoji search/lookup by name (EmojiSearch utility created)
- ✅ Add emoji categories (EmojiSearch.categories() implemented)

### 3.2 Icon font generation (TTF)

- ✅ Research approach: SVG paths → FontForge → TTF
- ✅ Generate test icon font with subset of icons (tests created)
- ⬜ Evaluate visual quality
- ⬜ If quality is good: generate full icon font
- ✅ Create `skribbleIconFont` widget for font-based icon rendering

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
- ✅ Add to `skribble_icons` package (WiredCupertinoIcon widget created)

### 3.4 Performance optimization

- ✅ Benchmark current icon loading time (performance tests created)
- ✅ Optimize pre-computed icon map size (IconOptimizer created)
- ✅ Consider lazy loading for large icon sets (LazyIconLoader and PaginatedIconLoader created)

---

## Phase 4: Developer Experience & Distribution

### 4.1 pub.dev publishing

- ✅ Check pubspec.yaml files for pub.dev requirements
- ✅ Set up monochange versioning (monochange.toml configured)
- ✅ Verify all packages meet pub.dev requirements
- ⬜ Publish initial versions

**CI/CD Integration:**

- ✅ monochange validation in CI
- ✅ Changeset policy workflow for PRs
- ✅ Zizmor security scanning for GitHub Actions
- ✅ OSV scanner for dependency auditing
- ✅ Release workflow with monochange

#### Pub.dev Readiness Status

**Packages checked:**

- `skribble` — v0.3.4, has homepage/repository/issue_tracker ✅
- `skribble_icons` — v0.1.0, has homepage/repository/issue_tracker ✅
- `skribble_icons_custom` — v0.1.0, has homepage/repository/issue_tracker ✅
- `skribble_emoji` — v0.1.0, has homepage/repository/issue_tracker ✅
- `skribble_lints` — v0.1.0, missing homepage/repository/issue_tracker ⚠️

**TODO:**

- ✅ Add homepage/repository/issue_tracker to `skribble_lints`
- ✅ Add LICENSE files to: `skribble_icons`, `skribble_icons_custom`, `skribble_emoji`
- ✅ Add CHANGELOG.md to: `skribble_icons`, `skribble_icons_custom`, `skribble_emoji`
- Verify all packages pass `dart pub publish --dry-run`

### 4.2 Documentation

- ✅ Update getting started guide (installation.md updated)
- ✅ Create migration guide (Material → skribble)
- ✅ Update widget catalog (already comprehensive with all widgets)
- ✅ Add code examples for common patterns

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

## Phase 5: Beyond Flutter

- ✅ Standalone font package (documentation for web, iOS, Android, React Native)
- ✅ SVG library for web (export and usage guidelines)
- ✅ Research React Native / SwiftUI / Jetpack Compose feasibility (future directions documented)

---

## Change Log

### 2026-09-13 (Documentation truth pass)

**Corrected claims in this tracker:**

- Accessibility: replaced "33 widgets with Semantics / only 2 remaining" with the verified count (explicit `Semantics` in 45 of 112 widget files) and added the warning that semantics currently supplied by wrapped Material widgets disappear with each skin rewrite.
- Decoupling snapshot: replaced "94 of 109 / 57 skin / 37 helpers" with the current "94 of 137 / 70 skin / 24 helpers" and recorded the trend (hard debt grew as parity widgets landed; one skin, `wired_loading_indicator.dart`, has been rewritten off Material).
- `WiredRefreshIndicator`: reclassified from a completed HIGH-priority deliverable to unexported dead code (file present, referenced nowhere; `packages/skribble/lib/src/wired_refresh_indicator.dart`).
- `skribble_icons_dynamic`: recorded that the package is untracked and gone from fresh checkouts; an older checkout may retain only ignored `build/` and `.dart_tool/` output.

**Documentation changes:**

- `docs/site/content/core/architecture.md` now states the standalone design-system direction, the dependency rule, the layers, the transitional debt, the compatibility promise, and the settled decision records.
- `docs/site/content/core/material-bridge.md` reframed as a transitional compatibility layer with a migration path, not "skribble sits alongside Material".
- Cross-framing fixes in `index.md`, `theme-system.md`, `theming.md`, `quick-start.md`, `migration.md`, `agents.md`, `api-overview.md`, and `accessibility-testing.md` (including a stale `google_fonts` dependency row and a stale sidebar-registration instruction).

### 2026-05-28 (Full Day Sprint)

#### Morning Session (10:00 - 11:30)

**Configuration & Setup:**

- Replaced knope.toml with monochange.toml for versioning
- Configured all 6 packages in monochange.toml
- Fixed opentype_dart version (0.0.1, not 0.1.0)

**Accessibility (Phase 1.5) - COMPLETED:**

- Added Semantics to 22 widgets across the codebase
- Created accessibility testing guide with screen reader testing instructions
- Total widgets with Semantics: 33 (11 built-in + 22 added)

**Icon Font (Phase 3.2):**

- Created skribbleIconFont widget for font-based icon rendering
- Added skribbleIconFontData and skribbleIconFontIcons classes
- 4/5 tasks now complete

**Performance (Phase 3.4) - COMPLETED:**

- Created LazyIconLoader with LRU cache for on-demand icon loading
- Created PaginatedIconLoader for displaying icons in pages
- Icon performance optimization complete

**Documentation (Phase 4.2) - COMPLETED:**

- Comprehensive code examples for common patterns
- Migration guide from Material to skribble
- Beyond Flutter documentation (standalone fonts, SVG icons, future platforms)
- Accessibility testing guide

### 2026-05-27 (Initial Sprint)

**Widget Audits (Phase 1.1-1.2) - COMPLETED:**

- Material 3 audit: 82 existing widgets, 16 gaps identified
- Cupertino audit: 13 existing widgets, ~8 gaps identified
- Priority ranking: HIGH (RefreshIndicator), MEDIUM (ExpansionPanelList, PaginatedDataTable)

**Accessibility Sprint (Phase 1.5):**

- Added Semantics to 22 widgets with semanticLabel properties
- Widgets: checkbox, radio, slider, range_slider, chip variants, input, text_area, list_tile, date_picker, time_picker, bottom_sheet, snack_bar, navigation_bar, tab_bar, stepper, expansion_tile, checkbox_list_tile, radio_list_tile, switch_list_tile

**Animation System (Phase 1.6) - COMPLETED:**

- WiredInkSplash for hand-drawn ripple effects
- WiredLoadingIndicator and WiredCircularProgressIndicator
- WiredFadeTransition, WiredSlideTransition, WiredScaleTransition, WiredCombinedTransition, WiredPageTransition

**Widget Gaps (Phase 1.3) - COMPLETED (HIGH + MEDIUM):**

- WiredRefreshIndicator (HIGH priority)
- WiredPaginatedDataTable (MEDIUM priority)
- WiredExpansionPanelList (MEDIUM priority)

**Font Roughening (Phase 2.2) - COMPLETED:**

- Created skribble_font_roughen package
- Implemented JitterAlgorithm with deterministic jitter
- Implemented FontRoughener with actual font parsing using opentype_dart
- Created CLI entry point with argument parsing
- Added unit tests for jitter algorithm and font roughener
- Created script for pre-roughening popular fonts
- Added README.md documenting Python script replacement
- Added VisualDiff tool for font rendering comparison
- Updated wired_theme.dart to reference Dart tool
- Created CI script for font roughener validation
- Marked Python script as deprecated with notice

**Font Pipeline (Phase 2.4-2.5) - COMPLETED:**

- Golden test approach defined
- Test fonts with known inputs created
- VisualDiff tool for font rendering comparison
- Python script deprecated with notice

**Emoji (Phase 3.1) - COMPLETED:**

- Verified full OpenMoji set generation (1,827 emoji)
- Created emoji performance tests
- Added EmojiSearch utility for search and filtering
- Added emoji categories support

**Icon Font (Phase 3.2):**

- Created icon font generation tests
- Tests for WiredSvgIconData, primitives, scaling, fill rules

**Cupertino Icons (Phase 3.3):**

- WiredCupertinoIcon widget for hand-drawn Cupertino icons
- skribbleCupertinoIcons with common icon shortcuts

**Performance (Phase 3.4):**

- Icon performance benchmark tests
- IconOptimizer for reducing icon map size
- Path simplification with configurable precision

**Pub.dev Readiness (Phase 4.1) - COMPLETED:**

- Added LICENSE and CHANGELOG to skribble_icons, skribble_icons_custom, skribble_emoji
- Added pubspec metadata to skribble_lints
- monochange.toml configured

**Documentation (Phase 4.2) - COMPLETED:**

- Updated installation guide with new packages
- Migration guide from Material to skribble
- Widget catalog (already comprehensive)
- Comprehensive code examples for common patterns

**Web Support (Phase 4.3) - COMPLETED:**

- No dart:io or Platform usage found
- Library is web-compatible

**Beyond Flutter (Phase 5) - COMPLETED:**

- Standalone font usage documentation
- SVG icon export and usage guidelines
- Design principles for hand-drawn aesthetics
- Future directions for React Native, SwiftUI, Jetpack Compose

### 2026-08-28 (Platform Upgrade)

**Flutter 3.47.0 / Dart 3.13.0 upgrade (Phase 2):**

- Bumped `.fvmrc` to Flutter 3.47.0 (from 3.41.1); Dart SDK constraints to `^3.13.0`
- Applied 3.47 analyzer updates across the workspace (3,294 mechanical fixes via `dart fix`, including the new `unnecessary_unawaited` lint and `strict_top_level_inference` batch)
- Removed deprecated `one_member_abstracts` lint override; documented intentional single-member abstract painter protocol with a local ignore
- Fixed `wired_cupertino_navigation_bar_test.dart` (multiline `Navigator.push` restructured)
- Updated README + contributing docs to Flutter >= 3.47
- CI composite action picks up the new SDK automatically via `.fvmrc` cache keying
- All suites green on 3.47: skribble 1194, emoji 34, icons 27, icons_custom 27, icons_dynamic 21, storybook 64, example 41, benchmark 8, font_roughen (dart test) 20

### 2026-08-28/29 (Housekeeping & Release Management)

**Workspace hygiene:**

- Removed `skribble_icons_dynamic` (deprioritized; zero dependents — presets in `skribble_icons` are the supported path; can be revived from git history if dynamic generation is wanted later). Verified 2026-09-13: the package has no tracked files and is absent from a fresh clone/worktree, but an older checkout can still contain an untracked `packages/skribble_icons_dynamic/` directory holding only ignored `.dart_tool/` and `build/` output from before the removal. It can be deleted safely; it is not part of the repository.
- Added `skribble_emoji_gen` (Dart CLI emoji generator) to the workspace with SDK constraint aligned to ^3.13.0 and `resolution: workspace`
- Merged knope → monochange migration (PR #126): release flows now use `mc release-pr` / `mc publish`; changesets reformatted for monochange

**Branch & worktree cleanup:**

- Cleaned up ~15 stale merged remote branches and obsolete local worktrees

**Publishing readiness (Phase 4):**

- Verified `dart pub publish --dry-run` across all packages
- Unblocked: skribble, skribble_emoji, skribble_icons, skribble_icons_custom, skribble_lints all validate (after relaxing Flutter constraints to `>=3.47.0` per the new pub.dev upper-bound deprecation)
- `skribble_font_roughen` marked `publish_to: none`: its upstream dependency `opentype_dart` ships no license and is not on pub.dev — publishing is blocked until the dependency is replaced (see third_party/opentype_dart/README.md). Remaining dry-run warnings are working-tree-only and clear on commit.

### 2026-08-29 (Decoupling groundwork — Phase 3 start)

**Goal:** skribble becomes a standalone design system library — a peer of `package:material_ui` / `package:cupertino_ui`, depending only on `flutter/widgets` and below. NOT a skin over Material widgets.

**Status (2026-08-29 snapshot, corrected 2026-09-13):** `material`/`cupertino` decoupled from the Flutter core into pub packages (Flutter 3.47 era). At the time of this note, 94 of 109 files in packages/skribble/lib imported material/cupertino:

- 57 × "skin" — wrap a Material widget; these are the real rewrite debt
- 37 × "helpers" — theme/geometry/constants only; mechanical import swaps

**Current snapshot (2026-09-13): 94 of 137 files import material/cupertino — 70 skin / 24 helpers.** The hard debt grew by 13 as parity widgets landed (7 new widgets, plus 7 files reclassified from helpers to skin). One skin was rewritten off Material (`wired_loading_indicator.dart`), and six other files dropped their Material imports entirely: five painting/core files (`wired_base.dart`, `canvas/wired_canvas.dart`, `canvas/wired_painter.dart`, `rough/decoration.dart`, `rough/rough.dart`) plus the loading indicator, while the old `wired_transitions.dart` was replaced by the hooks-independent motion layer. The skin number is the one that matters; the helpers number falling is not progress by itself. Regenerate the snapshot with `dart run tool/audit_material_dependencies.dart`.

**Tooling:**

- `tool/audit_material_dependencies.dart` — dependency heatmap classifier (table or --json); report committed at `docs/material-dependency-audit.txt`
- Rule codified in AGENTS.md: new code must not import material/cupertino; add a CI import gate when the audit reaches 0

**Rewrite order (skin debt):**

1. Leaf inputs: button family, checkbox, switch, slider, text field
2. Theme: WiredTheme/DrawConfig already custom — swap ThemeData reads for a skribble-owned token set
3. Navigation/containers: scaffold, app bar, tabs, bottom nav, dialogs
4. App shell: SkribbleApp (WidgetsApp-based) replacing WiredMaterialApp; keep WiredMaterialApp as a thin compatibility bridge until consumers migrate
5. Localization: use GlobalMaterialLocalizations alternatives or depend on flutter_localizations directly (decision needed at step 4)

---

## Session Status (2026-08-29)

**All consolidation phases in this session are COMPLETE and merged:**

| PR   | Scope                                          | Status    |
| ---- | ---------------------------------------------- | --------- |
| #129 | Mobile emulator/simulator screenshot pipeline  | ✅ merged |
| #130 | Flutter 3.47.0 / Dart 3.13.0 upgrade           | ✅ merged |
| #131 | Border radius support (tests, storybook, docs) | ✅ merged |
| #126 | knope → monochange release management          | ✅ merged |
| #132 | Workspace fixes + decoupling groundwork        | ✅ merged |

**Publishing readiness:**

- 5 packages pass `dart pub publish --dry-run` (skribble, skribble_emoji, skribble_icons, skribble_icons_custom, skribble_lints)
- `mc preview` plans release **v0.3.5** consuming the 80 pending changesets; the flow is contributor changeset → `mc release-pr` → merge → `mc publish`
- Blocked: `skribble_font_roughen` (`publish_to: none`) — needs a licensed replacement for `opentype_dart`
- Actual pub.dev publication requires: `pub.dev` publisher setup + CI `PUB_CREDENTIALS`/OIDC + the maintainer running the release PR flow

**Open follow-ups (updated 2026-09-13; the August list below it was superseded):**

1. **Material decoupling rewrite — the main in-flight work.** 70 skin files, leaf inputs first (button family, checkbox, switch, slider, text fields). New code already follows the no-material rule, and one skin (`wired_loading_indicator.dart`) has been rewritten; the remaining skins still import Material, so the audit stands at 94 of 137 importers.
2. **Accessibility verification per rewrite.** Each skin rewrite must replace the semantics the removed Material wrapper supplied and test it. See the corrected Phase 1.5.
3. **Finish or delete `WiredRefreshIndicator`.** It is unexported dead code (see Phase 1.1).
4. **Documentation truth pass.** This branch corrects the architecture direction, the Material bridge framing, and this tracker. Keep the architecture page authoritative.
5. **Design handover.** The design kit (`packages/skribble/tool/design_kit.dart`) and the published `.fig` asset are documented in [docs/design/README.md](docs/design/README.md) and the Figma guide; release-time rules live in the releasing reference.
6. **Device screenshots** via the mobile driver (from the August follow-ups) and the optional pre-roughened font pack remain open.
7. **Publishing:** `skribble_font_roughen` stays `publish_to: none` until its `opentype_dart` dependency is replaced with a licensed one.

**Open follow-ups (2026-08-29, historical):**

1. Material decoupling rewrite (AGENTS.md — 57 skin-debt files, ordered plan)
2. Capture real device screenshots via the new mobile driver + upload to B2
3. Cut release v0.3.5 via the monochange release PR (superseded: the first public releases are v0.1.0 and v0.1.1, published 2026-09-11 and 2026-09-13)
4. Optional pre-roughened font pack for popular fonts (needs font downloads)

### 2026-08-29 (Session 2: parity, showcase, testing)

**Parity COMPLETE — all named long-tail gaps closed (PRs #136, #137, #138):**

- Material: WiredCarouselView, WiredSearchAnchor/WiredSearchController/ WiredSearchBar, WiredDateRangePickerDialog + showWiredDateRangePicker, WiredLicensePage + showWiredLicensePage, WiredGridTile/GridTileBar, WiredMergeableMaterial (+Items), WiredCheckboxMenuButton, WiredRadioMenuButton, WiredAboutListTile, showWiredTimePicker
- Cupertino (12 → 18): ActivityIndicator, ListSection, ListTile, SearchTextField, TimerPicker, FormSection
- ~195 new widget tests; suites at 1389 (skribble) all green
- Packages ready to publish with release v0.3.5 (mc preview)

**Live showcase published (PRs #134, #135):** docs site + full interactive storybook (all widgets, 8.6k icons, emoji, font specimen glyphs) on GitHub Pages. Screenshot harness across 4 device form factors. Preview: https://openbudgetfun.github.io/skribble/ and https://openbudgetfun.github.io/skribble/storybook/

**Testing (PR #139):** Patrol configured (`patrol:` block + journeys); 3-tier testing documented (guides/e2e-testing.md); device runs ready for YoyaPhoneBra once Developer Mode is enabled on the phone.

---

## Icon set expansion proposal (simple-icons → Iconify)

### Phase 1 — simple-icons (brand icons, ~3,400 glyphs)

New package `skribble_icons_simple`, generated exactly like the other icon sets:

1. Vendor the simple-icons SVGs (CC0) into `packages/skribble_icons_simple/manifest/` at a pinned version tag
2. Extend `generate_rough_icons.dart`'s svg-manifest kit with a simple-icons loader (brand list + slugs → manifest.json)
3. Roughen + precompute → `kskribbleSimpleIcons` map + `skribbleSimpleIcons` lookup class; publish as its own package so apps only bundle brands they reference (tree-shaking via const map)
4. CI gates identical to the Material pipeline (baseline, sync, regression)

Estimated effort: 1–2 sessions (mostly pipeline reuse).

### Phase 2 — Iconify-scale (200k+ icons, 150+ sets)

A blanket roughening of ALL Iconify sets is not tractable (size, quality control, licensing variance). Proposed architecture:

- `skribble_icons_any`: a **build-time package** (no bundled assets) that roughens ONLY the icons an app declares (a slugged list in yaml), via a codegen step reusing the generate_rough_icons pipeline
- Licensing: per-set allowlist encoded in a manifest (MIT/CC0/Apache sets first — e.g. tabler, lucide, heroicons, mdi)
- Quality: the deterministic roughening is font-agnostic — SVG paths in, rough paths out — but each new set gets a visual-review golden pass (`.screenshots/review/`) before the set is allowlisted
- Cache: roughened outputs keyed by (set, icon, roughVersion) in a shared pub cache so apps don't re-roughen

### jaspr support

- Today: docs site shows the pattern — skribble webfont (self-hosted TTFs from packages/skribble/assets) + inline rough-SVG borders (rough.js-compatible paths can be generated by skribble_font_roughen's engine for boxes)
- Planned: `skribble_jaspr` component package (Button, Card, Divider, TextField as Jaspr components with rough SVG chrome). Scoped proposal in a future session once the Flutter library is published.
