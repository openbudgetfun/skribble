---
title: Installation
description: Add skribble and its default hand-drawn typeface to a Flutter app, then pick optional fonts, icons, maps, and charts.
order: 1
---

# Installation

Adding skribble to a Flutter app takes one command. If you want to work on skribble itself, skip to [Contribute to skribble](#contribute-to-skribble).

## Requirements

<!-- {=docsRequirements} -->

skribble needs Flutter 3.47.0 or later (Dart 3.13.0 or later). Run `flutter --version` to check yours.

<!-- {/docsRequirements} -->

Any Flutter app works, including one made with `flutter create`. skribble supports every Flutter platform: Android, iOS, web, macOS, Windows, and Linux.

<!-- {=docsInstallSection} -->

## Install in an app

From your Flutter app's directory, add the library and its default typeface in one step:

```bash
flutter pub add skribble skribble_font_noto_sketch
```

`skribble` paints the hand-drawn borders, fills, and icons. `skribble_font_noto_sketch` adds Skribble Noto Sketch, the default lettering: it is the step that makes text _look_ hand-drawn too. There is nothing else to set up: no font registration, no assets to copy, and no Material app.

Then import the library in your Dart files:

```dart
// Static example: setup
import 'package:skribble/skribble.dart';
```

<!-- {/docsInstallSection} -->

That is the whole setup. Continue with the [Quick Start](/getting-started/quick-start) to build and run your first hand-drawn screen.

## Choose another typeface

Skribble Noto Sketch is the recommended lettering, and you need no code to use it. To pick another one, install its package and select it on the theme:

<!-- {=docsTypefaceTable} -->

| Typeface                                  | Package                     | Select with                                                  | Follows the roughness level |
| ----------------------------------------- | --------------------------- | ------------------------------------------------------------ | --------------------------- |
| Skribble Noto Sketch (default)            | `skribble_font_noto_sketch` | nothing: it is the default, or `WiredFont.notoSketch`        | No                          |
| Skribble Noto Soft                        | `skribble_font_noto`        | `WiredThemeData(font: WiredFont.noto)`                       | No                          |
| Skribble Noto Lively                      | `skribble_font_noto_lively` | `WiredThemeData(font: WiredFont.notoLively)`                 | No                          |
| Recursive Casual, Linear, and Mono (code) | `skribble_font_recursive`   | `WiredThemeData(font: WiredFont.casual)`, `.linear`, `.mono` | Yes                         |

Install the package for each typeface you select; every package bundles its own font files, so it works offline. The Skribble Noto packages cover Latin, Greek, and Cyrillic in one Regular face, and Flutter synthesizes bold and italic. Recursive has seven real weights with italics. An explicit `fontFamily` on `WiredThemeData` overrides the choice.

<!-- {/docsTypefaceTable} -->

For example, the Recursive typefaces are the right choice for code (`WiredFont.mono`) or when you need real bold and italic faces:

```bash
flutter pub add skribble_font_recursive
```

```dart
// Static example: configuration
WiredThemeData(font: WiredFont.casual)
```

To use the default family on a single `TextStyle` outside the theme, qualify it with its package:

```dart
// Static example: configuration
TextStyle(
  fontFamily: skribbleFontFamily, // 'SkribbleNotoSketch'
  package: 'skribble_font_noto_sketch',
)
```

Every other script Noto covers, including Arabic, Hebrew, Devanagari, Thai, Chinese, Japanese, and Korean, is in the Skribble Noto font kit on each [GitHub release](https://github.com/openbudgetfun/skribble/releases/latest). Add the scripts you need as your own font families and list them in `WiredThemeData.fontFamilyFallback`; [Compare the lettering](/core/font-comparison#skribble-noto) shows how. The fonts live in separate packages so the core stays small and an app ships only the lettering it uses; see [Upgrading to 0.2](/getting-started/upgrading-to-0-2).

## Troubleshooting

**Text is drawn in the system font.** Borders, buttons, and cards render hand-drawn without a font package, but text needs one. Check that `skribble_font_noto_sketch` (or the package for the typeface you selected) is listed under `dependencies` in your `pubspec.yaml`, then stop the app and run it again: a hot reload does not load newly added font assets.

**pub resolved `skribble_font_noto_sketch 0.0.0`.** Version `0.0.0` only reserves the package name and contains no fonts. These docs follow the `main` branch, so a package they describe can reach pub.dev with the next release. Until it does, keep the lettering of the latest published release with `flutter pub add skribble_font_recursive`; the Recursive Casual face is that release's default.

**Version solving failed.** Check the [requirements](#requirements) with `flutter --version`, and run `flutter upgrade` if your Flutter is older.

## Optional packages

Install a companion package when your app needs it:

```bash
flutter pub add skribble_icons   # Material, Lucide, Boxicons, and brand icons
flutter pub add skribble_emoji   # hand-drawn emoji for every Unicode emoji
flutter pub add skribble_maps    # MapLibre maps with hand-drawn overlays
flutter pub add skribble_charts  # hand-drawn financial charts
```

[Icons](/widgets/icons), [Emoji](/widgets/emoji), [Maps](/widgets/maps), and [Charts](/widgets/charts) document each one with interactive examples. The core package already draws 51 of its own glyphs (`SkribbleGlyphs`) for checkboxes, chevrons, and close buttons, so you only need `skribble_icons` for larger icon sets. Every published package is listed in the [API overview](/reference/api-overview#companion-packages).

## Beyond Flutter

- **Jaspr websites.** `skribble_jaspr` renders rough borders, highlights, and doodles on the server with zero client JavaScript. See [Using skribble on Jaspr](../guides/jaspr).
- **JavaScript and TypeScript.** The `@skribble.dev` npm packages draw the same hand-drawn shapes in plain browsers, Node, React, React Native, Vue, and Svelte, and replace rough.js. See [Using skribble from JavaScript](../guides/javascript).
- **Rust and leptoskit.** `skribble_leptoskit` brings the hand-drawn components to [leptoskit](https://github.com/ifiokjr/leptoskit) apps written once in Rust, on the web and natively. `skribble_rough` is the Rust port of the rough engine underneath. See [Using skribble with leptoskit](../guides/leptoskit).

## Contribute to skribble

To work on skribble itself, clone the workspace:

<!-- {=docsSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# With devenv (recommended): provides flutter, melos, mdt, dprint, and the git hooks
devenv shell

# Without devenv: install the pinned Flutter 3.47.0 with FVM
fvm install
fvm use --force

# Install dependencies for the whole workspace
flutter pub get
```

<!-- {/docsSetupSection} -->

The [Contributing](/reference/contributing) guide lists the workspace commands, conventions, and quality gates.

## Next steps

- [Quick Start](/getting-started/quick-start) -- build and run your first skribble app
- [Your First Widget](/getting-started/first-widget) -- add buttons, inputs, cards, and checkboxes
- [Theming](/getting-started/theming) -- customize the hand-drawn palette
