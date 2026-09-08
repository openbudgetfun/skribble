---
title: Installation
description: Add Skribble to a Flutter app or set up the full workspace for contributing.
---

# Installation

There are two ways to get started with Skribble: add it to an existing app as a dependency, or clone the workspace to contribute.

## App usage

<!-- {=docsInstallSection} -->

## Install in an app

Add the `skribble` package to your Flutter project:

```bash
dart pub add skribble
```

Then import it:

```dart
import 'package:skribble/skribble.dart';
```

<!-- {/docsInstallSection} -->

## Workspace contribution setup

<!-- {=docsWorkspaceSetupSection} -->

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

<!-- {/docsWorkspaceSetupSection} -->

## Development commands

<!-- {=docsWorkspaceDevCommandsSection} -->

```bash
# Run all lint checks (format + analyze)
lint:all

# Run dart analyze across all packages
melos run analyze

# Run Flutter widget tests
melos run flutter-test

# Format all Dart code
dart format .

# Fix all fixable lint and format issues
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
```

<!-- {/docsWorkspaceDevCommandsSection} -->

## Next steps

- [Quick Start](/getting-started/quick-start) -- build your first Skribble app
- [Your First Widget](/getting-started/first-widget) -- add buttons, inputs, and cards
- [Theming](/getting-started/theming) -- customize the hand-drawn palette
