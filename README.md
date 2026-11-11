<p align="center">
  <a href="https://openbudgetfun.github.io/skribble/">
    <picture>
      <source
        media="(prefers-color-scheme: dark)"
        srcset="assets/brand/skribble-dark-transparent.svg"
      >
      <img
        src="assets/brand/skribble-light-transparent.svg"
        alt="skribble: a little smile in square brackets"
        width="240"
        height="240"
      >
    </picture>
  </a>
</p>

<h1 align="center">skribble</h1>

<p align="center">
  Sketchy, hand-drawn UI components for <em>Flutter</em>.
</p>

<br />

<p align="center">
  <a href="https://openbudgetfun.github.io/skribble/getting-started/installation"><strong>Getting Started</strong></a> ·
  <a href="https://openbudgetfun.github.io/skribble/widgets/buttons"><strong>Widgets</strong></a> ·
  <a href="https://openbudgetfun.github.io/skribble/storybook/"><strong>Live Demo</strong></a> ·
  <a href="https://openbudgetfun.github.io/skribble/showcase/overview"><strong>Showcase</strong></a> ·
  <a href="https://openbudgetfun.github.io/skribble"><strong>Documentation</strong></a> ·
  <a href="CONTRIBUTING.md"><strong>Contributing</strong></a>
</p>

<br />

<p align="center">
  <a href="https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml"><img src="https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml/badge.svg" alt="Continuous integration status"></a>
  <a href="https://openbudgetfun.github.io/skribble/"><img src="https://img.shields.io/badge/docs-openbudgetfun.github.io%2Fskribble-violet" alt="Documentation"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%E2%89%A53.47-blue?logo=flutter" alt="Flutter"></a>
</p>

<br />

A hand-drawn design system for Flutter. skribble gives your app a unique, informal aesthetic, with widget APIs that feel familiar if you know Material and Cupertino.

## Get started

<!-- {=docsRequirements} -->

skribble needs Flutter 3.47.0 or later (Dart 3.13.0 or later). Run `flutter --version` to check yours.

<!-- {/docsRequirements} -->

<!-- {=docsQuickInstallSection|replace:"// Static example: setup\n":""} -->

```bash
flutter pub add skribble skribble_font_noto_sketch
```

`skribble` draws the widgets; `skribble_font_noto_sketch` adds the default hand-drawn lettering. Without the font package, borders still look sketchy but text falls back to the system font. Then import the library:

```dart
import 'package:skribble/skribble.dart';
```

<!-- {/docsQuickInstallSection} -->

Replace `lib/main.dart` with a minimal app and run it with `flutter run`:

<!-- {=docsMinimalAppSection|replace:"// Static example: setup\n":""} -->

```dart
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      title: 'My sketchy app',
      // Supplies the Material theme and localizations that some Wired
      // widgets, such as WiredInput, still need while they wrap Material.
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: WiredScaffold(
        appBar: WiredAppBar(title: Text('My sketchy app')),
        body: Center(
          child: WiredButton(
            onPressed: () {},
            child: Text('Press me'),
          ),
        ),
      ),
    ),
  );
}
```

<!-- {/docsMinimalAppSection} -->

The [Quick Start](https://openbudgetfun.github.io/skribble/getting-started/quick-start) builds a full form and a widget test from here, and [Installation](https://openbudgetfun.github.io/skribble/getting-started/installation) covers other typefaces, icons, maps, and charts.

## Design with skribble

Open the [Figma design system](https://www.figma.com/design/pjRi0rh4NWkGRROPlWLLBo/Skribble-Design-System) for reusable components, light and dark colors, the bracketed-smile logo, and hand-drawn flourishes. See the [design kit guide](docs/design/README.md) for coverage, downloads, and how the Figma assets map to Flutter.

Prefer a local file? Download the [editable Figma source from the latest release](https://github.com/openbudgetfun/skribble/releases/latest/download/skribble-design-system.fig) and open it in Figma.

Butterflies, hearts, smiles, flowers, sparkles, scribbles, leaves, clouds, suns, moons, rainbows, comets, balloons, mushrooms, cupcakes, birds, sprouts, waves, and confetti are generated from stable seeds:

```dart
WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 8)
```

skribble is meant to look like a sticker book: bright washes, one loud button, highlighted words, and ink that draws itself on and wriggles. Start from a colourway (`sunny` is the default, then `berry`, `ocean`, `citrus`, and the calm `quiet`) and colour-code content with `theme.accentAt(index)`:

```dart
SkribbleApp(
  wiredTheme: WiredThemeData.colorway(WiredColorway.ocean),
  darkWiredTheme: WiredThemeData.colorway(
    WiredColorway.ocean,
    brightness: Brightness.dark,
  ),
  home: const Home(),
)
```

`WiredCascade`, `WiredEntrance`, `WiredBoil`, `WiredHighlight`, and the `WiredCurves` springs bring screens to life, and all of it settles when the platform asks for reduced motion. [Vivid and alive](https://openbudgetfun.github.io/skribble/guides/vivid-design) has the design rules, written so coding agents can follow them too. The gentle, playful, and expressive roughness presets work with every colourway.

## Packages

<!-- {=docsPackageCatalog} -->

| Package                                                                           | What it adds                                                                                 |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [`skribble`](https://pub.dev/packages/skribble)                                   | The Wired widgets, `SkribbleApp`, the theme, and the Flutter painting layer. Start here.     |
| [`skribble_font_noto_sketch`](https://pub.dev/packages/skribble_font_noto_sketch) | Skribble Noto Sketch, the default hand-drawn lettering                                       |
| [`skribble_font_noto`](https://pub.dev/packages/skribble_font_noto)               | Skribble Noto Soft, the calmest Noto level                                                   |
| [`skribble_font_noto_lively`](https://pub.dev/packages/skribble_font_noto_lively) | Skribble Noto Lively, the most playful Noto level                                            |
| [`skribble_font_recursive`](https://pub.dev/packages/skribble_font_recursive)     | Roughened Recursive Casual, Linear, and Mono, which follow the roughness level               |
| [`skribble_icons`](https://pub.dev/packages/skribble_icons)                       | Every icon set behind one import, with a unified lookup                                      |
| [`skribble_icons_material`](https://pub.dev/packages/skribble_icons_material)     | Flutter's Material icons as hand-drawable geometry                                           |
| [`skribble_icons_lucide`](https://pub.dev/packages/skribble_icons_lucide)         | Lucide outline icons                                                                         |
| [`skribble_icons_bxs`](https://pub.dev/packages/skribble_icons_bxs)               | Boxicons Solid icons                                                                         |
| [`skribble_icons_simple`](https://pub.dev/packages/skribble_icons_simple)         | Simple Icons brand marks                                                                     |
| [`skribble_icons_cib`](https://pub.dev/packages/skribble_icons_cib)               | CoreUI Brands marks                                                                          |
| [`skribble_emoji`](https://pub.dev/packages/skribble_emoji)                       | skribble's own hand-drawn emoji for every Unicode emoji                                      |
| [`skribble_maps`](https://pub.dev/packages/skribble_maps)                         | MapLibre maps with hand-drawn pins, routes, areas, and controls                              |
| [`skribble_charts`](https://pub.dev/packages/skribble_charts)                     | Exact OHLC data, hand-drawn financial charts, indicators, and drawing tools                  |
| [`skribble_rough`](https://pub.dev/packages/skribble_rough)                       | The pure-Dart rough engine, with SVG path output and no Flutter dependency                   |
| [`skribble_jaspr`](https://pub.dev/packages/skribble_jaspr)                       | Server-rendered hand-drawn components for Jaspr sites                                        |
| [`skribble_font_roughen`](https://pub.dev/packages/skribble_font_roughen)         | A command-line tool that roughens your own fonts                                             |
| [`skribble_emoji_gen`](https://pub.dev/packages/skribble_emoji_gen)               | The generator that compiles emoji, glyph art, and icon sets into Dart catalogs (maintainers) |
| [`skribble_lints`](https://pub.dev/packages/skribble_lints)                       | Shared lint rules, extending `very_good_analysis`                                            |

<!-- {/docsPackageCatalog} -->

## Beyond Dart

| Package                                                  | Description                                                                                         |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| [`@skribble.dev/rough`](js/rough/)                       | The rough engine for JavaScript, with React, React Native, Vue, and Svelte bindings in [`js/`](js/) |
| [`skribble_rough`](rust/rough/) (Rust)                   | The rough engine for Rust, drawing byte-identical SVG                                               |
| [`skribble_leptoskit`](rust/leptoskit/) (Rust)           | Hand-drawn components for leptoskit apps on the web and native                                      |
| [`skribble_leptoskit_maps`](rust/leptoskit_maps/) (Rust) | Hand-drawn maps for leptoskit apps: rough areas, routes, pins, and zoom controls                    |

## Apps

| App                                              | Description                                |
| ------------------------------------------------ | ------------------------------------------ |
| [`skribble_storybook`](apps/skribble_storybook/) | Interactive demo showcasing all widgets    |
| [`skribble_example`](apps/skribble_example/)     | A hand-drawn notes app built with skribble |
| [`skribble_benchmark`](apps/skribble_benchmark/) | Rendering benchmarks                       |
| [`skribble_site`](apps/skribble_site/)           | The skribble.dev landing page (Jaspr)      |

## Development

This project uses [devenv](https://devenv.sh) for reproducible environments and [melos](https://melos.invertase.dev) for monorepo management:

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

[CONTRIBUTING.md](CONTRIBUTING.md) lists every workspace command, the conventions, and the quality gates.

## Quality

- `dart analyze --fatal-infos .` passes with zero issues.
- Library and storybook test suites are exercised in CI.
- Screenshot artifacts are validated against `docs/ui-snapshots/screenshot-manifest.txt`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, conventions, and quality gates.

## License

MIT — see [LICENSE](LICENSE).
