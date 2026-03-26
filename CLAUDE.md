# Skribble — Hand-Drawn Flutter Design System

## Project Rules

### Widget Development

- Every widget MUST use `HookWidget` (or `HookConsumerWidget` if Riverpod is needed)
- No `StatefulWidget` or `StatelessWidget` — hooks only
- All widgets use the "Wired" prefix (e.g., `WiredButton`, `WiredAppBar`)
- Follow existing patterns:
  - `WiredPainterBase` for painting rough shapes
  - `WiredCanvas` for composing painters with fillers
  - `WiredBaseWidget` for repaint isolation via `RepaintBoundary`

### Testing

- Every widget MUST have comprehensive widget tests covering:
  - Rendering: renders without error, renders child content, correct dimensions
  - Interaction: responds to tap/input, calls callbacks
  - State changes: rebuilds on value change, animations complete
  - Edge cases: null values, rapid interactions, overflow
  - Accessibility: semantic labels where applicable
- Widget tests go in `packages/skribble/test/` mirroring `lib/src/` structure
- Integration tests go in `apps/skribble_storybook/integration_test/`

### Screenshots

- Screenshots saved to `.screenshots/` (gitignored)
- Organized by category: `.screenshots/<category>/<widget>.png`

### Code Style

- Follow existing lint rules from `skribble_lints`
- When lint issues are reported, run `fix:all` before making manual lint-only edits
- Use `dart format` for formatting
- Run `dart analyze --fatal-infos .` before committing

### Workspace Structure

```
skribble/
  packages/skribble/         # Main UI component library
  packages/skribble_lints/   # Shared lint rules
  apps/skribble_storybook/   # Demo/showcase app
```

### Commands

```bash
# Analyze all packages
melos run analyze

# Run Flutter tests
melos run flutter-test

# Format code
melos run format

# Capture screenshots
melos run screenshot
```
