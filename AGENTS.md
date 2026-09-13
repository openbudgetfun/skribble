# skribble — Hand-Drawn Flutter Design System

## Project Rules

### Brand and casing

- The brand word is always lowercase **skribble** — in READMEs, docs site pages and frontmatter, and source comments. Sentence position does not change it: a heading reads `# skribble`.
- Keep machine-readable names as they are: identifiers (`SkribbleIcons`), bundled font families (`Skribble`, `SkribbleGentle`), asset names (`Skribble-Bold.ttf`), the Figma URL slug (`Skribble-Design-System`), and runtime strings such as app titles, page names, and semantic labels.
- The root `README.md` keeps a centered header: the logo (240px, linked to the docs site), `<h1 align="center">skribble</h1>`, a one-line tagline, centered links into the documentation, then the badges. Those links point at `https://openbudgetfun.github.io/skribble/`.

### Widget Development

- UI components use `HookWidget` (or `HookConsumerWidget` if Riverpod is needed).
- Motion lifecycle code in `packages/skribble/lib/src/motion/` and its controller examples use standard Flutter `State` and ticker providers; motion scopes use `InheritedWidget`. Their public API accepts `Animation<double>` and remains independent of hooks. See `docs/site/content/core/motion.md` when changing animation ownership or policy.
- All widgets use the "Wired" prefix (e.g., `WiredButton`, `WiredAppBar`)
- Follow existing patterns:
  - `WiredPainterBase` for painting rough shapes
  - `WiredCanvas` for composing painters with fillers
  - `WiredBaseWidget` for repaint isolation via `RepaintBoundary`

### Material decoupling direction (hard target)

skribble's endgame is a **standalone design system library** — a peer of `package:material_ui` / `package:cupertino_ui`, depending only on `flutter/widgets` and below, not a hand-drawn skin over Material widgets.

- **New code MUST NOT import `package:flutter/material.dart` or `package:flutter/cupertino.dart`.**
- Existing Material usage is transitional debt. The current state is tracked in `docs/material-dependency-audit.txt` (regenerate with `dart run tool/audit_material_dependencies.dart > docs/material-dependency-audit.txt`; CI fails if this file goes stale): 69 core files wrap a Material widget ("skin" debt — the real rewrite work), 15 core files only use helpers/constants (mechanical import swaps, do these opportunistically).
- `packages/skribble/lib/src/compat/` is the sanctioned compatibility layer and the only place allowed to import material/cupertino. Its job is interop and migration (theme conversion both ways, hosting Material widgets in a Skribble app, hosting Wired widgets in a Material or Cupertino app), not parity. Nothing in the core may depend on it, and it must not grow new `MaterialApp` passthroughs.
- New Skribble apps use `SkribbleApp` (built on `WidgetsApp`, no Material ancestor). `WiredMaterialApp` (`lib/src/compat/wired_material_app.dart`) is the transitional bridge for apps that still need `MaterialApp`.
- Rewrite order for skin-debt: leaf input widgets first (buttons, checkbox, switch, slider, text field), then containers/navigation (scaffold, app bar, tabs), keeping `WiredMaterialApp`/`WiredTheme`/`WiredMaterialTheme` as the compatibility bridge for consuming apps until the last PR.
- Debt is ratcheted, not just tracked: the `material-debt-ratchet` CI job fails any PR whose audit counts exceed `docs/material-dependency-baseline.json`. Counts may drop freely; an increase requires refreshing the baseline (`dart run tool/audit_material_dependencies.dart --write-baseline docs/material-dependency-baseline.json`) and explaining the increase in the PR. When the core count reaches 0, this hardens into a plain import ban on `packages/skribble/lib` outside `src/compat`.

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
- **Keep image files out of Git**, including screenshots, design exports, and golden snapshots. Save them in gitignored local output directories, upload review images with `gh pr create/edit/comment --attach`, or use external file storage. Put the resulting attachment or download URL in the PR or a README.
- Before pushing, check staged additions and the branch's commits for image files. Remove newly introduced images from an unmerged branch's history before publishing the corrected branch; deleting them only in a later commit still leaves the repository bloated.

### Documentation

- **Figma exports belong on the latest GitHub release, never in Git.** Save `.fig` files outside the checkout and publish them as `skribble-design-system.fig`. Follow `docs/design/README.md` for upload and verification. Link downloads through `releases/latest/download/skribble-design-system.fig`.

- **Every change must be documented.** No PR should be merged without documentation for what was changed or added. This is a hard rule.
- Documentation MUST be updated whenever APIs change, features are added, or behavior is modified
- Update the relevant widget catalog page in `docs/site/content/widgets/` when adding or modifying widgets
- Update getting-started guides in `docs/site/content/getting-started/` when changing fundamental APIs
- Update core concept pages in `docs/site/content/core/` when modifying the theme system, rough engine, or painting infrastructure
- Update `docs/site/content/reference/agents.md` when agent workflows or conventions change
- Update `docs/site/content/reference/api-overview.md` when public exports change
- Update MDT template blocks in `templates/*.t.md` when reusable patterns change, then run `mdt update`
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
  docs/site/                 # Documentation site (Flutter)
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

# Validate release configuration and changesets
monochange step validate
monochange check

# Preview release files without changing the workspace
monochange step prepare-release --dry-run --diff

# Attach the bundled font zips to a GitHub release (--dry-run to preview)
publish:fonts
```
