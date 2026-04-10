---
title: Installation
description: Add Skribble to a Flutter app or set up the full workspace for contributing.
---

# Installation

There are two ways to get started with Skribble: add it to an existing app as a dependency, or clone the workspace to contribute.

## App usage

<!-- {=docsInstallSection} -->

Add the Skribble package to your Flutter project:

```bash
dart pub add skribble
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  skribble: ^0.1.0
```

Then run:

```bash
dart pub get
```

Import the library in any Dart file:

```dart
import 'package:skribble/skribble.dart';
```

That single import gives you access to every Wired widget, the theming system, the rough-drawing engine, and the icon set. No additional setup is required -- just start using Wired widgets in your widget tree.

<!-- {/docsInstallSection} -->

## Workspace contribution setup

<!-- {=docsWorkspaceSetupSection} -->

To contribute to Skribble or run the storybook app locally, clone the repository and set up the development environment.

### Prerequisites

- **Flutter SDK** -- managed by [FVM](https://fvm.app/) (the pinned version is in `.fvmrc`)
- **Dart SDK** -- bundled with Flutter
- **devenv** -- the project uses [devenv](https://devenv.sh/) for reproducible tooling (Melos, formatters, linters)
- **Melos** -- workspace management for the monorepo (installed via devenv)

### Clone and bootstrap

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# Activate the devenv shell (installs Melos, FVM, and other tools)
devenv shell

# Install the pinned Flutter SDK
fvm install

# Bootstrap all packages (resolves deps, links local packages)
melos bootstrap
```

### Workspace structure

```
skribble/
  packages/skribble/             # Main UI component library
  packages/skribble_lints/       # Shared lint rules
  apps/skribble_storybook/       # Demo/showcase app
  docs/site/                     # Documentation site (this site)
```

The `packages/skribble/` directory contains all Wired widgets, the rough-drawing engine, the theme system, and the generated icon font. `apps/skribble_storybook/` is a Flutter app that showcases every widget with live examples.

<!-- {/docsWorkspaceSetupSection} -->

## Development commands

<!-- {=docsWorkspaceDevCommandsSection} -->

All commands are run from the repository root via Melos:

```bash
# Analyze all packages for lint and type errors
melos run analyze

# Run all Flutter widget tests
melos run flutter-test

# Format all Dart code
melos run format

# Capture widget screenshots to .screenshots/
melos run screenshot

# Apply all auto-fixable lint rules across the workspace
melos run fix:all
```

### Running the storybook

```bash
cd apps/skribble_storybook
flutter run -d chrome    # or -d macos, -d linux, etc.
```

### Running tests for a single package

```bash
cd packages/skribble
flutter test
```

### Analyzing a single package

```bash
cd packages/skribble
dart analyze --fatal-infos .
```

<!-- {/docsWorkspaceDevCommandsSection} -->

## Next steps

- [Quick Start](/getting-started/quick-start) -- build your first Skribble app
- [Your First Widget](/getting-started/first-widget) -- add buttons, inputs, and cards
- [Theming](/getting-started/theming) -- customize the hand-drawn palette
