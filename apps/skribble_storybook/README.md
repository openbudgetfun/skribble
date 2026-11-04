# skribble_storybook

The interactive showcase app for [skribble](https://pub.dev/packages/skribble) — every Wired widget, runnable and browsable. **[Open the live storybook](https://openbudgetfun.github.io/skribble/storybook/)**.

## Run it

From `apps/skribble_storybook`, inside `devenv shell` so the Flutter version matches `.fvmrc`:

```bash
flutter pub get
flutter run -d chrome   # or -d macos, or a simulator or emulator ID from `flutter devices`
```

The storybook ships runners for web, Android, iOS, and macOS. The maps page draws real MapLibre maps on Android, iOS, and web. MapLibre has no macOS renderer, so on macOS that page shows the plugin's "not yet supported" message. Android requests the internet permission for the map tiles; the other pages work offline. Building for Android needs JDK 21, because the `maplibre_gl` plugin compiles at Java source level 21; with an older JDK the build stops with `invalid source release: 21`. Point `JAVA_HOME` at a JDK 21, or run `flutter config --jdk-dir <path>`. The first iOS build fetches MapLibre's Swift package, a large download that can take several minutes. The macOS window opens at 800 × 600 and won't shrink below 360 × 480, the narrowest layout the tests check.

The toolbar starts on Skribble Noto Sketch, the default, and changes between the bundled Casual, Linear, or Mono font, the three Skribble Noto levels (chips Noto, Sketch, and Lively), and the Gentle, Playful, or Expressive ink style across every page. The app depends explicitly on `skribble_font_recursive` and the three `skribble_font_noto*` packages so release builds include the same fonts as the docs.

## What's inside

- **Skribble Icons** searches all six icon sets and previews each result at three sizes.
- **Rough Icons** retains the dedicated Material name and codepoint browser.
- **Font Specimen** covers weights 300–900, italics, and glyph blocks.
- **Variable fonts** exposes all five Recursive axes and editable sample text.
- **Loading and skeletons** includes every loader style, progress, placeholders, and the full loading screen, with controls to pause motion or reveal content.
- **Doodles and fills** displays every doodle and fill pattern with changeable seeds.
- Existing pages cover controls, navigation, layout, tables, charts, maps, emoji, motion, and the working sketchbook. Layout includes expansion panels and Data Display includes a paginated table.

The entry point registers the rough Material catalog before creating the app. Component examples use `WiredIcon` so their artwork matches the library.

Every page pushed over the home page starts its app bar with `StorybookBackButton`, skribble's own hand-drawn arrow, because `WiredAppBar` adds no back button and a desktop window has no back gesture. On a narrow screen with large text, the ink, typeface, and paper toolbar stops at half the height and scrolls. A category card on the home page fills with the marker colour while the keyboard focuses it.

Browser journeys scroll to the actual chart drawing point before tapping it, keeping the drawing interaction reachable with the bundled fonts at phone widths.

## Test it

From `apps/skribble_storybook`:

```bash
flutter test                                                    # widget tests
flutter test integration_test/navigation_test.dart -d <device>  # on a device
```

`test/breathing_room_test.dart` checks every page for cramped and squeezed text at 360, 768, and 1280 pixels and at 1.3× text. `test/navigation_access_test.dart` checks the back button on every page, the toolbar at 320 pixels with 2× text, and the keyboard focus on the home page.

For a visual pass, `flutter test --update-goldens test/visual_review_test.dart` renders nine pages with the real fonts into `.screenshots/review/` at the repository root. Later runs compare against those captures until you capture again. They are local only: CI skips them, and Git ignores both the captures and the `test/failures/` diffs a mismatch writes.

### Device tour

The device tour runs every page on a real platform, with its own engine, fonts, screen size, and density. It works on an iOS Simulator, an Android emulator, a phone, or a macOS window. On each page it scrolls a screen at a time, in the day and night themes and at 1× and 2× text. It checks every screen for overflow, cramped text, lines through text, crowded icons, and squeezed paragraphs, and saves a PNG of each screen on the host:

```bash
SKRIBBLE_TOUR_DIR=/tmp/skribble-tour/pixel flutter drive -d <device> \
  --driver=test_driver/device_tour_test.dart \
  --target=integration_test/device_tour_test.dart
```

Findings go to `findings.txt` in the same directory, and the test fails when there are any. Use `--dart-define=SKRIBBLE_TOUR_THEMES=paper` or `--dart-define=SKRIBBLE_TOUR_SCALES=1,1.3,2` to choose the passes.
