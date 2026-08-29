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

### Material decoupling direction (hard target)

Skribble's endgame is a **standalone design system library** — a peer of
`package:material_ui` / `package:cupertino_ui`, depending only on
`flutter/widgets` and below, not a hand-drawn skin over Material widgets.

- **New code MUST NOT import `package:flutter/material.dart` or
  `package:flutter/cupertino.dart`.**
- Existing Material usage is transitional debt. The current state is tracked
  in `docs/material-dependency-audit.txt` (regenerate with
  `dart run tool/audit_material_dependencies.dart`):
  ~57 files wrap a Material widget ("skin" debt — the real rewrite work),
  ~37 files only use helpers/constants (mechanical import swaps, do these
  opportunistically).
- Rewrite order for skin-debt: leaf input widgets first (buttons, checkbox,
  switch, slider, text field), then containers/navigation (scaffold, app
  bar, tabs), keeping `WiredMaterialApp`/`WiredTheme` as a compatibility
  bridge for consuming apps until the last PR.
- When the audit reaches 0, add a CI gate that fails any PR reintroducing a
  material/cupertino import into `packages/skribble/lib`.

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

### Documentation

- **Every change must be documented.** No PR should be merged without documentation for what was changed or added. This is a hard rule.
- Documentation MUST be updated whenever APIs change, features are added, or behavior is modified
- Update the relevant widget catalog page in `docs/site/content/widgets/` when adding or modifying widgets
- Update getting-started guides in `docs/site/content/getting-started/` when changing fundamental APIs
- Update core concept pages in `docs/site/content/core/` when modifying the theme system, rough engine, or painting infrastructure
- Update `docs/site/content/reference/agents.md` when agent workflows or conventions change
- Update `docs/site/content/reference/api-overview.md` when public exports change
- Update MDT template blocks in `template.t.md` when reusable patterns change, then run `mdt update`
- Add dartdoc `///` comments on all public classes and parameters
- See `docs/site/content/reference/agents.md` section "Documentation update requirements" for the complete checklist

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
  docs/site/                 # Documentation site (Jaspr)
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

# Serve docs site locally
docs:site:serve

# Build docs site for deployment
docs:site:build
```
