---
title: Contributing
description: How to set up the workspace, follow conventions, and submit mergeable pull requests.
---

Thanks for your interest in contributing to Skribble! This guide covers the workflow, conventions, and quality gates you should know before submitting a PR.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.41
- [FVM](https://fvm.app/) for Flutter version management
- (Optional) [devenv](https://devenv.sh/) — the CI uses it; you can use plain Flutter locally

## Clone and set up

<!-- {=docsContribSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# If using devenv
direnv allow

# If not using devenv
fvm install
fvm use --force
flutter pub get
```

<!-- {/docsContribSetupSection} -->

## Repository layout

```
skribble/
├── packages/skribble/          # Main UI component library
│   ├── lib/src/                # Widget & rough-engine source
│   ├── test/                   # Widget + rough-engine tests
│   └── tool/                   # Icon generation CLI
├── packages/skribble_lints/    # Shared lint rules
├── packages/skribble_icons_custom/  # Custom icon set example
├── apps/skribble_storybook/    # Demo / showcase app
└── docs/site/                  # Documentation site (Jaspr)
```

## Development workflow

1. **Create a branch** from `main`:
   ```bash
   git checkout -b pr/my-feature main
   ```

2. **Make changes** — follow the conventions below.

3. **Run checks** before committing:
   ```bash
   dart format .
   dart analyze --fatal-infos .
   cd packages/skribble && flutter test test/
   ```

4. **Open a PR** against `main`.

## Widget conventions

- Every widget **must** use `HookWidget` (or `HookConsumerWidget` if Riverpod is needed). No `StatefulWidget` or `StatelessWidget`.
- All widgets use the `Wired` prefix (e.g., `WiredButton`, `WiredAppBar`).
- Read border/fill colors from `WiredTheme.of(context)` — never hardcode.
- Wrap with `RepaintBoundary` via `buildWiredElement()` or `WiredBaseWidget`.
- Add `///` doc comments on every public class and parameter.
- Include a `semanticLabel` parameter for accessibility on interactive widgets.

## Testing requirements

Every widget test file must have **>= 6 `testWidgets`** covering:

| Category | Example |
|----------|---------|
| Rendering | Renders without error, renders child content |
| Dimensions | Correct size, respects custom height/width |
| Interaction | Responds to tap, calls `onChanged` |
| State | Rebuilds on value change, animations complete |
| Edge cases | Null values, rapid interactions |
| Accessibility | Semantic labels where applicable |

### Test helper

Use `pumpApp()` from `test/helpers/pump_app.dart`:

```dart
import '../helpers/pump_app.dart';

// Body slot (default)
await pumpApp(tester, WiredButton(child: Text('Hi'), onPressed: () {}));

// AppBar slot
await pumpApp(tester, WiredAppBar(title: Text('T')), asAppBar: true);

// BottomNavigationBar slot
await pumpApp(tester, myNavBar, asBottomNav: true);

// Drawer slot
await pumpApp(tester, WiredDrawer(child: Text('X')), asDrawer: true);
```

## Code quality gates

All of these must pass for a PR to be merged:

<!-- {=docsContribQualityGatesSection} -->

```bash
# Zero issues (including info-level)
dart analyze --fatal-infos .

# Zero format drift
dart format --set-exit-if-changed .

# All tests green
flutter test

# Zero dartdoc warnings
dart doc --dry-run .
```

<!-- {/docsContribQualityGatesSection} -->

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add WiredAvatar widget
fix: correct WiredSlider thumb offset
refactor: migrate test files to pumpApp
test: add Generator.arc tests
docs: update parity matrix
chore: bump version to 0.3.1
```

## Adding a new widget — checklist

1. Create `lib/src/wired_<name>.dart` using `HookWidget`
2. Export from `lib/skribble.dart` (alphabetical order)
3. Add `test/widgets/wired_<name>_test.dart` with >= 6 tests
4. Add a showcase entry in the storybook app
5. Add a `///` doc comment on the public class
6. Run all quality gates
7. Update the docs site widget catalog page

## Documentation requirements

**Documentation must be updated whenever APIs change or features are added.** This includes:

- Widget catalog pages in `docs/site/content/widgets/`
- Getting-started guides if the change is fundamental
- The [Agents](agents) reference if agent workflows change
- MDT template blocks if reusable patterns are affected
- Dartdoc comments on all public API surfaces

## Running the full CI suite locally

```bash
# Format + analyze
lint:all

# All tests
test:all

# Coverage
test:coverage

# Icon regression checks
melos run rough-icons-ci-check
```

## Need help?

- Check the [Agents](agents) reference for AI agent-specific guidance
- Open an issue at [github.com/openbudgetfun/skribble/issues](https://github.com/openbudgetfun/skribble/issues)
