# Skribble

<picture>
  <source
    media="(prefers-color-scheme: dark)"
    srcset="assets/brand/skribble-dark-transparent.svg"
  >
  <img
    src="assets/brand/skribble-light-transparent.svg"
    alt="Skribble: a little smile in square brackets"
    width="120"
    height="120"
  >
</picture>

[![CI](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml) [![Docs](https://img.shields.io/badge/docs-openbudgetfun.github.io%2Fskribble-violet)](https://openbudgetfun.github.io/skribble/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.47-blue?logo=flutter)](https://flutter.dev)

A hand-drawn design system for Flutter. Skribble provides sketchy, hand-drawn UI components that give your app a unique, informal aesthetic — with familiar Material and Cupertino APIs.

**[Documentation](https://openbudgetfun.github.io/skribble/)** | **[Widget Catalog](https://openbudgetfun.github.io/skribble/widgets/buttons)** | **[Getting Started](https://openbudgetfun.github.io/skribble/getting-started/installation)**

## Design with Skribble

Open the [Figma design system](https://www.figma.com/design/pjRi0rh4NWkGRROPlWLLBo/Skribble-Design-System) for reusable components, light and dark colors, the bracketed-smile logo, and hand-drawn flourishes. See the [design kit guide](docs/design/README.md) for coverage, downloads, and how the Figma assets map to Flutter.

Prefer a local file? Download the [editable Figma source](assets/design/skribble-design-system.fig) and open it in Figma.

Butterflies, hearts, smiles, flowers, sparkles, scribbles, leaves, clouds, suns, moons, rainbows, comets, balloons, mushrooms, cupcakes, birds, sprouts, waves, and confetti are generated from stable seeds:

```dart
WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 8)
```

Use `WiredThemeData.cuddly()` for warm paper and plum ink, or pass `brightness: Brightness.dark` for dark paper. The gentle, playful, and expressive roughness presets work with either palette.

## Packages

| Package                                      | Description                                                |
| -------------------------------------------- | ---------------------------------------------------------- |
| [`skribble`](packages/skribble/)             | Main UI library (Wired widgets, rough engine, and exports) |
| [`skribble_maps`](packages/skribble_maps/)   | MapLibre maps with hand-drawn overlays and controls        |
| [`skribble_lints`](packages/skribble_lints/) | Shared lint rules                                          |

## Apps

| App                                              | Description                             |
| ------------------------------------------------ | --------------------------------------- |
| [`skribble_storybook`](apps/skribble_storybook/) | Interactive demo showcasing all widgets |

## Quick Start

```bash
# Install dependencies
dart pub get

# Run analysis (zero issues required)
melos analyze

# Run all tests
melos flutter-test

# Format
melos format
```

## Development

This project uses [devenv](https://devenv.sh) for reproducible environments and [melos](https://melos.invertase.dev) for monorepo management.

```bash
devenv shell    # Enter dev environment
lint:all        # Analyze + format
test:all        # Run all tests
test:coverage   # Generate lcov coverage
```

## Quality

- `dart analyze --fatal-infos .` passes with zero issues.
- Library and storybook test suites are exercised in CI.
- Screenshot artifacts are validated against `docs/ui-snapshots/screenshot-manifest.txt`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, conventions, and quality gates.

## License

MIT — see [LICENSE](LICENSE).
