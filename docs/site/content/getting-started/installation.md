---
title: Installation
description: Add skribble to a Flutter app or set up the full workspace for contributing.
---

# Installation

There are two ways to get started with skribble: add it to an existing app as a dependency, or clone the workspace to contribute.

## App usage

<!-- {=docsInstallSection} -->

## Install in an app

Add the `skribble` package to your Flutter project:

```bash
dart pub add skribble
```

Add the default hand-drawn typeface, Skribble Noto Sketch, so text renders sketchy, not in the system font. This is the step that makes a first app _look_ hand-drawn:

```bash
flutter pub add skribble_font_noto_sketch
```

Then import it:

```dart
// Static example: setup
import 'package:skribble/skribble.dart';
```

<!-- {/docsInstallSection} -->

## Hand-drawn text: don't skip the font package

`skribble` paints the wobbly borders, fills, and icons, but the **hand-drawn lettering ships in separate packages**. They are split out deliberately so the core stays small and you only pay for the fonts you use — see [Upgrading to 0.2](/getting-started/upgrading-to-0-2).

The default and recommended typeface is **Skribble Noto Sketch**, from `skribble_font_noto_sketch`. It is redrawn from [Google Noto](https://fonts.google.com/noto) with a round marker pen, a slight bounce, and three alternating drawings of every Latin letter, so repeated letters never look stamped. It is also the lightest download: one Regular face of under 1 MB, from which Flutter synthesizes bold and italic.

Without a font package, borders, buttons, and cards still render hand-drawn, but `Text` falls back to the platform font. Once you add `skribble_font_noto_sketch`, Flutter registers the family from its pubspec and `WiredTheme` uses it automatically — no extra code. To set the family by hand on a single `TextStyle`, qualify it with the package:

```dart
// Static example: configuration
TextStyle(
  fontFamily: skribbleFontFamily, // 'SkribbleNotoSketch'
  package: 'skribble_font_noto_sketch',
)
```

### Other typefaces

Skribble Noto comes at two more levels, each its own package: `skribble_font_noto` (Soft, the calmest) and `skribble_font_noto_lively` (the most playful). The packages bundle Latin, Greek, and Cyrillic. Every other script Noto covers, including Arabic, Hebrew, Devanagari, Thai, Chinese, Japanese, and Korean, is in the Skribble Noto font kit on each [GitHub release](https://github.com/openbudgetfun/skribble/releases/latest). Add the scripts you need as your own font families and list them in `WiredThemeData.fontFamilyFallback`; [Compare the lettering](/core/font-comparison#skribble-noto) shows how.

`skribble_font_recursive` holds the roughened Recursive typefaces: Casual, Linear, and Mono, in four weights with italics, each redrawn at the Gentle, Playful, and Expressive roughness levels so the lettering follows the theme. It was the previous default, and it is the right choice for code (`WiredFont.mono`) or when you need real bold and italic faces. Install the package you want and select it:

```bash
flutter pub add skribble_font_recursive
```

```dart
// Static example: configuration
WiredThemeData(font: WiredFont.casual) // or .linear, .mono, .noto, .notoLively
```

## Optional maps and financial charts

Install either companion package when your app needs it:

```bash
flutter pub add skribble_maps
flutter pub add skribble_charts
```

[Maps](/widgets/maps) combines a MapLibre basemap with hand-drawn pins, routes, and areas. [Charts](/widgets/charts) supports candlesticks, indicators, and editable drawings. Both pages include interactive examples; Storybook includes larger demonstrations under Maps and Financial charts.

## Jaspr websites

skribble's hand-drawn look also works on [Jaspr](https://jaspr.site) sites without Flutter. `skribble_jaspr` renders rough borders, highlights, and doodles on the server with zero client JavaScript. See [Using skribble on Jaspr](../guides/jaspr) for installation and the stylesheet.

## JavaScript and TypeScript

The `@skribble.dev` npm packages draw the same hand-drawn shapes in plain browsers, Node, React, React Native, Vue, and Svelte, and replace rough.js. See [Using skribble from JavaScript](../guides/javascript).

## Rust and leptoskit

`skribble_leptoskit` brings the hand-drawn components to [leptoskit](https://github.com/ifiokjr/leptoskit) apps written once in Rust, with rough ink on the web and the same components on macOS, iOS, Android, Windows, and Linux. `skribble_rough` is the Rust port of the rough engine underneath. See [Using skribble with leptoskit](../guides/leptoskit).

## Workspace contribution setup

<!-- {=docsSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# If using devenv
direnv allow

# If not using devenv
fvm install
fvm use --force

# Install dependencies
flutter pub get
```

<!-- {/docsSetupSection} -->

## Development commands

<!-- {=docsCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run all lint checks (format + analyze + docs)
lint:all

# Run dart analyze across all packages
melos run analyze

# Run Flutter widget tests
melos run flutter-test

# Format all Dart code
dart format .

# Fix all fixable lint, format, and docs issues
fix:all

# Capture component screenshots
melos run screenshot

# Generate rough Material icon SVGs
melos run rough-icons

# Generate rough icon font (TTF + Dart helpers)
melos run rough-icons-font

# Generate custom icon artifacts from SVG manifest
melos run rough-icons-custom

# Run CI-equivalent rough icon checks
melos run rough-icons-ci-check

# Build, typecheck, and test the npm packages in js/
pnpm install && pnpm run check
```

<!-- {/docsCommandsSection} -->

## Next steps

- [Quick Start](/getting-started/quick-start) -- build your first skribble app
- [Your First Widget](/getting-started/first-widget) -- add buttons, inputs, and cards
- [Theming](/getting-started/theming) -- customize the hand-drawn palette
