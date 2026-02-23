# Skribble

A hand-drawn design system for Flutter. Skribble provides sketchy, hand-drawn UI components that give your app a unique, informal aesthetic.

## Packages

| Package | Description |
|---------|-------------|
| `skribble` | Umbrella package with hand-drawn UI widgets (WiredButton, WiredCard, etc.) |
| `skribble_rough` | Drawing engine for rough/hand-drawn rendering |
| `skribble_lints` | Centralized lint rules for the workspace |

## Getting Started

```bash
# Install dependencies
dart pub get

# Run analysis
melos analyze

# Run tests
melos flutter-test
```

## Development

This project uses [devenv](https://devenv.sh) for reproducible development environments and [melos](https://melos.invertase.dev) for monorepo management.

```bash
# Enter the dev environment
devenv shell

# Install all dependencies
install:all

# Run all checks
lint:all
test:all
```
