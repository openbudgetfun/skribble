# Skribble

[![CI](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/skribble/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.41-blue?logo=flutter)](https://flutter.dev)

A hand-drawn design system for Flutter. Skribble provides 80+ sketchy,
hand-drawn UI components that give your app a unique, informal aesthetic —
with familiar Material and Cupertino APIs.

## Packages

| Package | Description |
|---|---|
| [`skribble`](packages/skribble/) | Main UI library — 81 widget files, 85 exports |
| [`skribble_lints`](packages/skribble_lints/) | Shared lint rules |

## Apps

| App | Description |
|---|---|
| [`skribble_storybook`](apps/skribble_storybook/) | Interactive demo showcasing all widgets |

## Quick Start

```bash
# Install dependencies
dart pub get

# Run analysis (zero issues required)
melos analyze

# Run all tests (1,059 total)
melos flutter-test

# Format
melos format
```

## Development

This project uses [devenv](https://devenv.sh) for reproducible environments
and [melos](https://melos.invertase.dev) for monorepo management.

```bash
devenv shell    # Enter dev environment
lint:all        # Analyze + format
test:all        # Run all tests
test:coverage   # Generate lcov coverage
```

## Stats

| Metric | Value |
|---|---|
| Widget tests | 857 |
| Rough engine tests | 138 |
| Smoke tests | 6 |
| Storybook tests | 58 |
| **Total tests** | **1,059** |
| `dart analyze` | 0 issues |
| `dart doc` | 0 warnings |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, conventions, and quality gates.

## License

MIT — see [LICENSE](LICENSE).
