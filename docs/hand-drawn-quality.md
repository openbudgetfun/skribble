# Hand-drawn quality work

Skribble now uses a real outline-derived Recursive Casual family, a broader rounded pen for UI borders, and complete OpenMoji 17 artwork. The storybook's **The sketchbook** page combines those pieces in an interactive notebook with morning and evening palettes.

## What was wrong

- The old font roughener changed a temporary glyph display path but did not serialize the modified outlines. Another bundled-font script wrote text placeholders. The shipped family had also switched to Architects Daughter, which was not the requested source.
- Many widgets fixed their borders at one pixel or bypassed the theme's roughness. Painter invalidation compared only runtime types, so color and width changes could leave stale pixels. Some dividers allocated only one or two pixels to a thicker stroke.
- Local `DefaultTextStyle` replacements discarded the font family. The storybook manually loaded only the regular style, masking asset registration problems.
- The emoji generator discarded joined sequences and skin modifiers and conflated flags. Rendering discarded source colors. SVG transforms, transparency, and clipping also needed preservation.
- Curated rough icons had 128-unit coordinates declared as a 24-unit canvas. The runtime solid-fill routine joined separate contours and painted over holes.
- Checkbox and slider local state could diverge from external updates; the slider repeatedly scheduled an immediate future during build. Input decorations doubled the sketch border and could obscure it with an opaque Material fill.

## Changes

The font writer now rewrites static TrueType outlines and verifies the saved representation. It preserves all source glyphs, spacing, and layout tables. Four source styles produce four deterministic Skribble styles. Coherent deformation gives a rounded, uneven pen appearance without jagged counters. The family is bundled under the package-qualified font name, and local widget styles inherit it.

The default border is 2.4 logical pixels, with roughness 1.8 and a 2-unit maximum random offset. Round caps and joins, insets for stroke bleed, stable seeded repaints, and sufficient divider space make the pen visible without clipping. Theme updates repaint the actual geometry. Runtime icon wobble is smaller than layout-border wobble, because a 24-pixel symbol must remain legible.

The rougher follow-up replaces the single smooth curve along each long border with two wandering strokes connected about every 48 pixels. Their control points stay within the reserved jitter band. Small circles reduce their jitter to preserve visible thumb centres. Font strength is now 36 per 1,000 units per em, twice the previous default of 18, across all four Recursive Casual styles. Glyph coverage, spacing, and shaping tables remain unchanged.

OpenMoji 17.0.0 contributes 4,495 named entries, including flags, modifiers, ZWJ sequences, and Unicode 17 additions. Source colors, unfilled strokes, even-odd contours, nested transforms, transparency, and the Ontario emblem's clip survive generation. Artwork is gently warped once during generation. All 30 curated icons regenerate from their checked-in SVG manifest with their correct view boxes. The existing Material pipeline covers 8,622 unique icon codepoints (8,825 names including aliases) in Flutter 3.47.0.

## Reproduce

Run these from the repository root in `devenv shell`:

```bash
dart run packages/skribble_emoji_gen/bin/update_assets.dart
dart run packages/skribble_font_roughen/bin/roughen_fonts.dart --check
./scripts/check_rough_icons_ci.sh all
melos run test --no-select
test:all
dart analyze --fatal-infos .
dart run tool/font_specimen.dart
```

`update_assets.dart` verifies pinned SHA-256 hashes before parsing the OpenMoji downloads, then rebuilds emoji, curated icons, and fonts. CI rebuilds these assets and rejects uncommitted differences. To update OpenMoji, deliberately change the version and hashes, regenerate, run the corpus and pixel tests, and inspect the artwork. No credentials or publishing step are needed.

The source SVG importer supports the features used by the pinned corpus. It is not a general SVG browser: flatten unsupported filters, CSS, external references, and group-opacity compositing before introducing a new source. Fonts likewise require static TrueType inputs, not arbitrary OpenType formats.

## Verification

The regression suite checks all source glyphs, all 4,495 emoji paths, all curated icon bounds, filled icon counters at 24/48/96 pixels, color and alpha pixels, clipping, deterministic ink, theme repainting, external checkbox/slider state, and inputs at 100–300% text scaling in a scrollable form. Notebook widget tests cover 320, 390, 820, and 1,440-pixel layouts, long notes, save/reset, and palette changes.

Patrol runs the notebook in Chromium at phone, tablet, and desktop widths. It enters and saves accented text and currency, checks a task, resets the notebook, changes palette, and operates the reminder. Browser screenshots and traces are retained as test artifacts. These are browser runs; native Android/iOS runners are separate work.

Visual specimens and screenshots are stored locally in `.screenshots/`. Rendered output, rather than file existence, is the acceptance check. Blank captures taken before Flutter's first frame are not evidence.

## Remaining scope

The library still has transitional Material and Cupertino wrappers, recorded in `docs/material-dependency-audit.txt`. This work improves their shared typography and drawing; it does not claim the standalone-library migration is complete. Font coverage is the complete Recursive Casual source coverage, not every Unicode script. OpenMoji artwork remains recognizable as OpenMoji, with a small pen wobble rather than a new illustration style. Repeated glyphs have fixed outlines, as in any static font.

Documentation template validation also exposed old unclosed consumer markers and unused providers. Orphan markers were removed without deleting examples, valid consumer blocks were closed, and the shared theme pattern was regenerated with `mdt update`.

## Review follow-ups

The review added first-frame slider geometry checks for a 10–100 range and both endpoints. The thumb is positioned from layout constraints, the track reserves pen space, and disabled sliders expose no change callback. Checkbox `null` is explicitly treated as unchecked; this remains a binary control. Input hints use the themed secondary text color in both palettes. Filled buttons use opaque ink with a contrasting foreground, and switch thumbs use opaque paper.

SVG import also preserves dash patterns and offsets, cap/join styles, miter limits, and stroke-before-fill ordering. Hidden elements are omitted. Import tests cover inheritance and transforms, and both SVG renderers have pixel checks for dash gaps and square endpoints. The extraction directory is cleared before each rebuild so removed upstream files cannot linger. Asset CI checks tracked changes and newly generated files.

The completed visual review covers 13 catalog routes at 390 and 1,440 pixels, with three settled scroll captures each (78 images), plus all four font specimens and notebook morning/evening views. These are representative screens, not an assertion that every possible widget configuration has been inspected. Catalog Patrol covers 11 navigation and control journeys; notebook Patrol covers five responsive interaction journeys with explicit saved-text, reset, palette-color, and reminder postconditions.

## Consumer roughness levels

The follow-up adds Gentle, Playful, and Expressive app-level presets with matching four-style font families. The storybook picker changes the root theme and preserves notebook state across selection and navigation. Nested themes now synchronize typography as well as border configuration. Font metadata and shaping preservation are checked across all twelve assets; widget and Patrol coverage exercise level propagation, state retention, independent overrides, and different viewport widths.
