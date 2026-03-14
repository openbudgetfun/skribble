# Contributing to Skribble

Thanks for your interest in contributing! This guide covers the workflow,
conventions, and quality gates you should know before submitting a PR.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.41
- [Melos](https://melos.invertase.dev/) for monorepo commands
- (Optional) [devenv](https://devenv.sh/) — the CI uses it; you can use plain
  Flutter locally

## Repository Layout

```
skribble/
├── packages/skribble/          # Main UI component library
│   ├── lib/src/                # Widget & rough-engine source
│   ├── test/                   # Widget + rough-engine tests
│   └── example/                # pub.dev example app
├── packages/skribble_lints/    # Shared lint rules
└── apps/skribble_storybook/    # Demo / showcase app
```

## Getting Started

```bash
# Install dependencies
flutter pub get

# Verify everything builds
melos run analyze
melos run flutter-test
```

## Development Workflow

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

## Widget Conventions

- Every widget **must** use `HookWidget` (or `HookConsumerWidget`).
  No `StatefulWidget` or `StatelessWidget`.
- All widgets use the `Wired` prefix (e.g., `WiredButton`, `WiredAppBar`).
- Read border/fill colors from `WiredTheme.of(context)` — never hardcode.
- Wrap with `RepaintBoundary` via `WiredBaseWidget`.

## Testing Requirements

Every widget test file must have **≥ 6 `testWidgets`** covering:

| Category | Example |
|---|---|
| Rendering | Renders without error, renders child content |
| Dimensions | Correct size, respects custom height/width |
| Interaction | Responds to tap, calls `onChanged` |
| State | Rebuilds on value change, animations complete |
| Edge cases | Null values, rapid interactions |
| Accessibility | Semantic labels where applicable |

### Test helpers

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

## Code Quality Gates

All of these must pass for a PR to be merged:

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

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add WiredAvatar widget
fix: correct WiredSlider thumb offset
refactor: migrate test files to pumpApp
test: add Generator.arc tests
docs: update parity matrix
chore: bump version to 0.3.1
```

## Adding a New Widget

1. Create `lib/src/wired_<name>.dart` using `HookWidget`.
2. Export from `lib/skribble.dart`.
3. Add `test/widgets/wired_<name>_test.dart` with ≥ 6 tests.
4. Add a showcase entry in the storybook app.
5. Add a `///` doc comment on the public class.
6. Run all quality gates.
