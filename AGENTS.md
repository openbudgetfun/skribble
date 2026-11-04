# skribble — Hand-Drawn Flutter Design System

## Project Rules

<!-- Text between mdt consumer tags is synced from templates/*.t.md by
     `mdt update` (fix:docs). Edit the template, not the synced copy. -->

### Brand and casing

<!-- {=docsBrandCasingRules} -->

- The brand word is always lowercase **skribble** — in READMEs, docs site pages and frontmatter, and source comments. Sentence position does not change it: a heading reads `# skribble`, and a page title reads `title: skribble — Hand-Drawn Flutter Design System`.
- Keep machine-readable names as they are: identifiers (`SkribbleIcons`), bundled font families (`Skribble`, `SkribbleGentle`), asset names (`Skribble-Bold.ttf`), the Figma URL slug (`Skribble-Design-System`), and runtime strings such as app titles, page names, and semantic labels.
- The root `README.md` keeps a centered header: the logo (240px, linked to the docs site), `<h1 align="center">skribble</h1>`, a one-line tagline, centered links into the documentation, then the badges. Those links point at `https://openbudgetfun.github.io/skribble/`.

<!-- {/docsBrandCasingRules} -->

### Widget Development

- UI components use `HookWidget` (or `HookConsumerWidget` if Riverpod is needed).
- Motion lifecycle code in `packages/skribble/lib/src/motion/` and its controller examples use standard Flutter `State` and ticker providers; motion scopes use `InheritedWidget`. Their public API accepts `Animation<double>` and remains independent of hooks. See `docs/site/content/core/motion.md` when changing animation ownership or policy.
- All widgets use the "Wired" prefix (e.g., `WiredButton`, `WiredAppBar`)
- Follow existing patterns:
  - `WiredPainterBase` for painting rough shapes
  - `WiredCanvas` for composing painters with fillers
  - `WiredBaseWidget` for repaint isolation via `RepaintBoundary`

<!-- {=docsInkPaddingRule} -->

Give the ink room to breathe. Content keeps at least `kWiredInkPadding` (8 pixels above and below, 12 at the sides) from any hand-drawn line around it; buttons and chips use `kWiredButtonPadding` (16 at the sides). Heights are minimums (`BoxConstraints(minHeight: kWiredButtonHeight)`), never fixed, so controls grow with larger fonts and text scaling instead of squeezing their text against the ink. `package:skribble/testing.dart` (`crampedText`, `squeezedText`) checks this; `crampedText(root, lines: true, icons: true)` also catches a hand-drawn line crossing text and an icon crowding its circle. The storybook and example app run all three checks on every page at 360, 768, and 1280 pixels and at 1.3× text, and the docs site runs them on every example at 340 and 720 pixels.

<!-- {/docsInkPaddingRule} -->

### Material decoupling direction (hard target)

skribble's endgame is a **standalone design system library** — a peer of `package:material_ui` / `package:cupertino_ui`, depending only on `flutter/widgets` and below, not a hand-drawn skin over Material widgets.

- **New code MUST NOT import `package:flutter/material.dart` or `package:flutter/cupertino.dart`.**
- Existing Material usage is transitional debt. The current state is tracked in `docs/material-dependency-audit.txt` (regenerate with `dart run tool/audit_material_dependencies.dart > docs/material-dependency-audit.txt`; CI fails if this file goes stale): <!-- {~materialSkinDebt:"{{ materialDebt.skin }}"} -->65<!-- {/materialSkinDebt} --> core files wrap a Material or Cupertino widget ("skin" debt — the real rewrite work), <!-- {~materialHelperDebt:"{{ materialDebt.helpers }}"} -->13<!-- {/materialHelperDebt} --> core files only use helpers/constants (mechanical import swaps, do these opportunistically).
- `packages/skribble/lib/src/compat/` is the sanctioned compatibility layer and the only place allowed to import material/cupertino. Its job is interop and migration (theme conversion both ways, hosting Material widgets in a Skribble app, hosting Wired widgets in a Material or Cupertino app), not parity. Nothing in the core may depend on it, and it must not grow new `MaterialApp` passthroughs.
- New Skribble apps use `SkribbleApp` (built on `WidgetsApp`, no Material ancestor). `WiredMaterialApp` (`lib/src/compat/wired_material_app.dart`) is the transitional bridge for apps that still need `MaterialApp`.
- Rewrite order for skin-debt: leaf input widgets first (buttons, checkbox, switch, slider, text field), then containers/navigation (scaffold, app bar, tabs), keeping `WiredMaterialApp`/`WiredTheme`/`WiredMaterialTheme` as the compatibility bridge for consuming apps until the last PR.
- Debt is ratcheted, not just tracked: the `material-debt-ratchet` CI job fails any PR whose audit counts exceed `docs/material-dependency-baseline.json`. Counts may drop freely; an increase requires refreshing the baseline (`dart run tool/audit_material_dependencies.dart --write-baseline docs/material-dependency-baseline.json`) and explaining the increase in the PR. When the core count reaches 0, this hardens into a plain import ban on `packages/skribble/lib` outside `src/compat`.

### Testing

Every widget MUST have comprehensive widget tests.

<!-- {=docsTestingRequirements} -->

Every widget test file has at least 6 `testWidgets`, written against skribble's public API, covering:

1. **Rendering**: renders without error, child content appears, rough paint is reached.
2. **Dimensions**: correct default size, custom size respected, sensible non-zero size.
3. **Interaction**: taps and input fire callbacks; a disabled widget ignores them.
4. **State**: rebuilds when values change; animations settle.
5. **Edge cases**: null values, empty strings, rapid interactions, overflow, and large, zero, or small constraints.
6. **Accessibility and direction**: semantic label, role, and state where applicable; RTL layout; scaled text.

Widget tests go in `packages/skribble/test/`, with one `test/widgets/wired_<name>_test.dart` per widget. Integration tests go in `apps/skribble_storybook/integration_test/`. Never assert on the Material or Cupertino control a widget currently wraps; `test/tool/no_material_test_coupling_test.dart` enforces this.

<!-- {/docsTestingRequirements} -->

### Screenshots

- Screenshots saved to `.screenshots/` (gitignored)
- Organized by category: `.screenshots/<category>/<widget>.png`

<!-- {=docsImagesOutOfGit} -->

- **Keep image files out of Git**, including screenshots, design exports, and golden snapshots. Save them in gitignored local output directories, upload review images with `gh pr create/edit/comment --attach`, or use external file storage. Put the resulting attachment or download URL in the PR or a README. Prefer pixel assertions against in-memory renders when a visual test can express the expected behavior without a committed image.
- Before pushing, check staged additions and the branch's commits for image files. Remove newly introduced images from an unmerged branch's history before publishing the corrected branch; deleting them only in a later commit still leaves the repository bloated.

<!-- {/docsImagesOutOfGit} -->

### Design changes ship with screenshots on the pull request

<!-- {=docsDesignScreenshotsRule} -->

- Every pull request that changes what skribble draws or how it lays out must show the change. That covers widget appearance, the rough engine, pens and fillers, icons and emoji, fonts, theme defaults, spacing, and the storybook or docs visuals.
- Capture **before and after** screenshots from the same harness: the storybook, `melos run screenshot`, or an in-memory render. Include both light and dark themes, and narrow and wide widths when layout changes.
- Upload them to the pull request itself with the GitHub CLI's `--attach` flag, never by committing them:
  - when opening: `gh pr create --attach './before.png#Before' --attach './after.png#After'`;
  - later captures: `gh pr edit <n> --attach ...` or `gh pr comment <n> --attach ...`.
- Text after `#` is the image's alt text. A local path already referenced in the body (`![Before](./before.png)`) is replaced with the uploaded URL; anything else is appended.
- Put the images in a collapsible `<details>` section of the description, and say what the captures do not cover. Inspect every image first so it exposes no secrets or personal data.

<!-- {/docsDesignScreenshotsRule} -->

### Documentation

<!-- {=docsFigmaReleaseRule} -->

**Figma exports belong on the latest GitHub release, never in Git**, including renamed or archived copies. Save `.fig` files outside the checkout, publish them as `skribble-design-system.fig` on the release marked Latest, and verify the uploaded size and SHA-256 digest; `docs/design/README.md` describes the upload and verification. Link downloads through `releases/latest/download/skribble-design-system.fig`. The `design-asset-policy` CI job rejects tracked Figma exports.

<!-- {/docsFigmaReleaseRule} -->

- **Every change must be documented.** No PR should be merged without documentation for what was changed or added. This is a hard rule.
- Documentation MUST be updated whenever APIs change, features are added, or behavior is modified
- Update the relevant widget catalog page in `docs/site/content/widgets/` when adding or modifying widgets
- Update getting-started guides in `docs/site/content/getting-started/` when changing fundamental APIs
- Update core concept pages in `docs/site/content/core/` when modifying the theme system, rough engine, or painting infrastructure
- Update `docs/site/content/reference/agents.md` when agent workflows or conventions change
- Update `docs/site/content/reference/api-overview.md` when public exports change
- Update MDT template blocks in `templates/*.t.md` when reusable patterns change, then run `mdt update` (`fix:docs`). Text duplicated across files belongs in one provider; see "Shared documentation with MDT" in `CONTRIBUTING.md`
- Add dartdoc `///` comments on all public classes and parameters
- See `docs/site/content/reference/agents.md` section "Documentation update requirements" for the complete checklist

### Code Style

- Follow existing lint rules from `skribble_lints`
- When lint issues are reported, run `fix:all` before making manual lint-only edits
- Use `dart format` for formatting
- Run `dart analyze --fatal-infos .` before committing

### Workspace Structure

<!-- {=docsRepoLayout} -->

```
skribble/
├── packages/
│   ├── skribble/              # Main UI library: Wired widgets, SkribbleApp, theme, painting layer
│   │   ├── lib/src/           # Widget, theme, and rough painting source (lib/src/compat/ holds the Material bridge)
│   │   ├── test/              # Widget tests in test/widgets/, engine tests in test/rough/, helpers in test/helpers/
│   │   ├── example/           # pub.dev example
│   │   └── tool/              # Icon generation, design kit, and audit tools
│   ├── skribble_rough/        # Pure-Dart rough engine with SVG output (no Flutter)
│   ├── skribble_font_*/       # Hand-drawn fonts (Noto Sketch, Noto, Noto Lively, Recursive) and the font roughener
│   ├── skribble_icons*/       # Icon sets (Material, Lucide, Boxicons, Simple Icons, CoreUI) and the umbrella package
│   ├── skribble_emoji*/       # Hand-drawn emoji and the catalog generator
│   ├── skribble_maps/         # MapLibre maps with hand-drawn overlays
│   ├── skribble_charts/       # Hand-drawn financial charts
│   ├── skribble_jaspr/        # Server-rendered components for Jaspr sites
│   └── skribble_lints/        # Shared lint rules
├── apps/
│   ├── skribble_storybook/    # Interactive demo of every widget, plus screenshot integration tests
│   ├── skribble_example/      # A hand-drawn notes app
│   ├── skribble_benchmark/    # Rendering benchmarks
│   └── skribble_site/         # skribble.dev landing page (Jaspr, static HTML)
├── docs/site/                 # Documentation site (Flutter); pages live in docs/site/content/
├── templates/                 # MDT providers for documentation shared across files
├── js/                        # npm packages: @skribble.dev/rough + React, React Native, Vue, Svelte
└── rust/                      # Cargo workspace: skribble_rough (Rust engine) + skribble_leptoskit components
```

<!-- {/docsRepoLayout} -->

### Commands

<!-- {=docsCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run every lint check: dprint formatting, dart analyze, MDT docs sync, and monochange
lint:all

# Fix everything fixable: MDT docs sync, dprint formatting, then dart fix
fix:all

# Sync the shared MDT documentation blocks, or check that they are in sync
fix:docs
lint:docs

# Run dart analyze across all packages (infos are fatal)
melos run analyze

# Run the Flutter widget tests
melos run flutter-test

# Run every Flutter and pure-Dart test suite, or collect merged coverage
test:all
test:coverage

# Format all Dart code
melos run format

# Capture component screenshots
melos run screenshot

# Serve or build the documentation site
docs:site:serve
docs:site:build

# Build or serve the skribble.dev landing page (Jaspr)
site:build
site:serve

# Generate rough Material icon SVGs, or the icon font (TTF + Dart helpers)
melos run rough-icons
melos run rough-icons-font

# Run the CI rough icon checks, or verify every committed icon catalog
melos run rough-icons-ci-check
melos run icons-check

# Build, typecheck, and test the npm packages in js/
pnpm install && pnpm run check

# Format, lint, and test the Rust crates in rust/
cargo fmt --all && cargo clippy --workspace --all-targets --all-features -- -D warnings && cargo test --workspace --all-features
```

<!-- {/docsCommandsSection} -->

Release and cross-engine maintenance:

<!-- {=docsReleaseCommandsSection} -->

```bash
# Validate release configuration and changesets
monochange step validate
monochange check

# Preview release files without changing the workspace
monochange step prepare-release --dry-run --diff

# Attach the bundled font zips to a GitHub release (--dry-run to preview)
publish:fonts

# Publish the packages a release tag owns, then verify the registry
publish:owned v<version>

# Tag the merged release commit at HEAD and push its tags, watching each publish
publish:tags

# Regenerate the Dart parity fixtures for @skribble.dev/rough and the Rust skribble_rough
dart run packages/skribble_rough/tool/js_parity_fixtures.dart > js/rough/test/fixtures/dart-parity.json
```

<!-- {/docsReleaseCommandsSection} -->
