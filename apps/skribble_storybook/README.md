# skribble_storybook

The interactive showcase app for [skribble](https://pub.dev/packages/skribble) — every Wired widget, runnable and browsable. **[Open the live storybook](https://openbudgetfun.github.io/skribble/storybook/)**.

## Run it

```bash
flutter pub get
flutter run -d chrome   # or any device
```

The toolbar changes the bundled Casual, Linear, or Mono font and the Gentle, Playful, or Expressive ink style across every page. The app depends explicitly on `skribble_font_recursive` so release builds include the same fonts as the docs.

## What's inside

- **Skribble Icons** searches all six icon sets and previews each result at three sizes.
- **Rough Icons** retains the dedicated Material name and codepoint browser.
- **Font Specimen** covers weights 300–900, italics, and glyph blocks.
- **Variable fonts** exposes all five Recursive axes and editable sample text.
- **Loading and skeletons** includes every loader style, progress, placeholders, and the full loading screen, with controls to pause motion or reveal content.
- **Doodles and fills** displays every doodle and fill pattern with changeable seeds.
- Existing pages cover controls, navigation, layout, tables, charts, maps, emoji, motion, and the working sketchbook. Layout includes expansion panels and Data Display includes a paginated table.

The entry point registers the rough Material catalog before creating the app. Component examples use `WiredIcon` so their artwork matches the library.

Browser journeys scroll to the actual chart drawing point before tapping it, keeping the drawing interaction reachable with the bundled fonts at phone widths.
