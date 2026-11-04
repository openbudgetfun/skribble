---
title: Contributing
description: How to set up the workspace, follow conventions, and submit mergeable pull requests.
---

Thanks for your interest in contributing to skribble! This guide covers the workflow, conventions, and quality gates you should know before submitting a pull request. The repository's `CONTRIBUTING.md` carries the same guide; both are synced from `templates/*.t.md` with MDT. AI coding agents should also read the [Agents](agents) reference.

Just want to use skribble in an app? See [Installation](/getting-started/installation) instead.

## Prerequisites

<!-- {=docsContribPrerequisites} -->

- [devenv](https://devenv.sh/) (recommended). `devenv shell` provides the pinned Flutter and Dart, melos, `mdt`, `dprint`, `monochange`, and the git hooks. CI runs every check through it.
- Without devenv: [FVM](https://fvm.app/) with the Flutter version pinned in `.fvmrc` (currently 3.47.0), plus `mdt` and `dprint` on your `PATH` for the documentation checks.
- For the npm packages in `js/`: Node.js and pnpm. For the Rust crates in `rust/`: the toolchain pinned in `rust-toolchain.toml`.

<!-- {/docsContribPrerequisites} -->

## Clone and set up

<!-- {=docsSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# With devenv (recommended): provides flutter, melos, mdt, dprint, and the git hooks
devenv shell

# Without devenv: install the pinned Flutter 3.47.0 with FVM
fvm install
fvm use --force

# Install dependencies for the whole workspace
flutter pub get
```

<!-- {/docsSetupSection} -->

## Repository layout

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

## Workspace commands

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

## Development workflow

<!-- {=docsContribWorkflow} -->

1. **Create a branch** from `main`, for example `git switch -c pr/my-feature main`.
2. **Make changes**, following the conventions below. Update the documentation in the same pull request: every change is documented.
3. **Run the quality gates** before pushing. The pre-push hook runs the lint gates for you inside devenv.
4. **Add a changeset** in `.changeset/` for any change to a published package (see the releasing reference), then open a pull request against `main`.

<!-- {/docsContribWorkflow} -->

## Widget conventions

<!-- {=docsWidgetConventions} -->

- UI components use `HookWidget` (or `HookConsumerWidget` when Riverpod is needed). Motion lifecycle code in `packages/skribble/lib/src/motion/` uses standard Flutter `State` and ticker providers instead, and its public API accepts `Animation<double>`; see `docs/site/content/core/motion.md`.
- Every widget name starts with `Wired`, for example `WiredButton` and `WiredAppBar`.
- Read colors, stroke width, and roughness from `WiredTheme.of(context)`; never hardcode them.
- Isolate repaints with `buildWiredElement(child: ...)` or by extending `WiredBaseWidget`.
- New code imports `package:flutter/widgets.dart` and below, never `package:flutter/material.dart` or `package:flutter/cupertino.dart`. Only `packages/skribble/lib/src/compat/` may import them.
- Interactive widgets take a `semanticLabel`, and every public class and parameter has a `///` dartdoc comment. Reuse the shared wording in `templates/dart.t.md` where it fits.

<!-- {/docsWidgetConventions} -->

<!-- {=docsInkPaddingRule} -->

Give the ink room to breathe. Content keeps at least `kWiredInkPadding` (8 pixels above and below, 12 at the sides) from any hand-drawn line around it; buttons and chips use `kWiredButtonPadding` (16 at the sides). Heights are minimums (`BoxConstraints(minHeight: kWiredButtonHeight)`), never fixed, so controls grow with larger fonts and text scaling instead of squeezing their text against the ink. `package:skribble/testing.dart` (`crampedText`, `squeezedText`) checks this, and the storybook, docs, and example app run it on every page and example at 360, 768, and 1280 pixels and at 1.3× text.

<!-- {/docsInkPaddingRule} -->

## Testing requirements

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

### Test host and helpers

<!-- {=docsTestHelpers} -->

New and converted tests use the `pumpWired()` host and the public-API helpers from one barrel:

```dart
// Static example: test
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpWired(
      tester,
      WiredButton(onPressed: () => tapped = true, child: const Text('Hi')),
    );
    await tapWired(tester, findWired<WiredButton>());
    expect(tapped, isTrue);
  });
}
```

`pumpWiredRtl` and `pumpWiredScaled` are the same host with right-to-left text or a scaled `TextScaler`. `packages/skribble/test/helpers/README.md` lists every helper and the migration pattern. `pumpApp()` from `test/helpers/pump_app.dart` remains only for files not yet migrated; it exposes Material slots new tests should not depend on.

<!-- {/docsTestHelpers} -->

## Code quality gates

All of these must pass for a pull request to be merged:

<!-- {=docsContribQualityGatesSection} -->

```bash
# Every lint check CI runs: dprint formatting, dart analyze with fatal infos,
# MDT documentation sync, and monochange changeset and manifest rules
lint:all

# Zero Dart format drift
dart format --set-exit-if-changed -o none .

# Every Flutter and pure-Dart test suite
test:all
```

While iterating on one package, `dart analyze --fatal-infos .` and `flutter test --concurrency=2` from its directory are quicker. Changes under `js/` also need `pnpm install && pnpm run check`, and changes under `rust/` need the `cargo fmt`, `cargo clippy`, and `cargo test` commands from the commands list.

<!-- {/docsContribQualityGatesSection} -->

## Shared documentation with MDT

<!-- {=docsMdtWorkflow} -->

Text that appears in more than one place, such as the install snippet, the minimal app, the commands list, these contributor rules, and repeated dartdoc, is written once as an [MDT](https://github.com/ifiokjr/mdt) **provider** in `templates/*.t.md` and copied into every **consumer** block. Never edit the text between a consumer's tags: `mdt update` overwrites it.

A provider lives only in a `templates/*.t.md` file:

```markdown
<!-- {@docsExampleSnippet} -->

The shared text, in Markdown.

<!-- {/docsExampleSnippet} -->
```

A consumer can sit in any scanned Markdown file, including READMEs, docs pages, `CONTRIBUTING.md`, and `AGENTS.md`:

```markdown
<!-- {=docsExampleSnippet} -->
<!-- {/docsExampleSnippet} -->
```

In Dart, the tags go inside `///` comments, and a `linePrefix` transformer re-adds the comment prefix, at the member's indentation, to each synced line:

```dart
// Static example: pseudocode
class WiredExample extends HookWidget {
  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;
}
```

- **Look before adding.** Run `mdt list` to see every provider and where it is consumed, and reuse one before writing a near-duplicate. Name new providers `docs<Topic>` for Markdown and `dart<Topic>` for dartdoc.
- **Add a provider** only for text that appears in at least two places. Write it in a `templates/*.t.md` file, replace each copy with a consumer block, then run `mdt update`.
- **Render values from manifests.** `mdt.toml` declares `[data]` sources (the skribble pubspec and `.fvmrc`), so a provider can write `{{ skribble.environment.flutter }}` instead of a hand-typed version. Providers are therefore [minijinja](https://docs.rs/minijinja) templates: text that needs literal double braces goes inside a raw block.
- **Reach a new file type.** Markdown and Dart are scanned already; add other files to `[include] patterns` in `mdt.toml`.
- **Sync and check.** `fix:docs` runs `mdt update` and `lint:docs` runs `mdt check`; `fix:all` and `lint:all` include them, and CI fails when a consumer is stale. mdt formats synced Markdown with dprint, so run `dprint fmt` (or `fix:format`) after editing a template.

<!-- {/docsMdtWorkflow} -->

## Git hooks

<!-- {=docsGitHooksTable} -->

Git hooks are managed by devenv and driven by [prek](https://github.com/j178/prek). They install automatically the first time you enter the devenv shell (`devenv shell`); the generated config lives at `.pre-commit-config.yaml` (gitignored).

| Hook             | Stage      | What it runs                                                                   |
| ---------------- | ---------- | ------------------------------------------------------------------------------ |
| `lint:commit`    | pre-commit | `lint:format` (dprint) across the workspace                                    |
| `secrets:commit` | pre-commit | gitleaks scan of staged changes (`.gitleaks.toml`)                             |
| `lint:push`      | pre-push   | CI lint parity: dependency refresh, `lint:all`, and `monochange step validate` |
| `secrets:push`   | pre-push   | gitleaks scan of the full git history                                          |

Hooks call devenv profile scripts by absolute path, so they work from plain `git` calls outside the devenv shell. Run them on demand with `prek run` (pre-commit) or `prek run --hook-type pre-push`, or skip them for a single commit with `git commit --no-verify`; CI still enforces every check.

<!-- {/docsGitHooksTable} -->

## Commit messages

<!-- {=docsCommitConventions} -->

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add WiredAvatar widget
fix: correct WiredSlider thumb offset
refactor: migrate WiredChip tests to pumpWired
test: add Generator.arc tests
docs: share the install snippet through mdt
chore: bump pnpm
```

<!-- {/docsCommitConventions} -->

## Adding a new widget — checklist

<!-- {=docsNewWidgetChecklist} -->

1. Create `packages/skribble/lib/src/wired_<name>.dart` as a `HookWidget`, following the widget conventions.
2. Export it from `packages/skribble/lib/skribble.dart`.
3. Add `packages/skribble/test/widgets/wired_<name>_test.dart` with at least 6 tests covering the testing requirements.
4. Add a showcase entry to the matching page in `apps/skribble_storybook/lib/pages/`.
5. Add `///` dartdoc comments on the class and every public parameter.
6. Document it on the matching `docs/site/content/widgets/<category>.md` page and in `docs/site/content/reference/api-overview.md`.
7. Add a changeset, then run the quality gates.

<!-- {/docsNewWidgetChecklist} -->

## Documentation requirements

**Documentation must be updated whenever APIs change or features are added.** This includes:

- Widget catalog pages in `docs/site/content/widgets/`
- Getting-started guides if the change is fundamental
- The [Agents](agents) reference if agent workflows change
- MDT template blocks if reusable patterns are affected (see [Shared documentation with MDT](#shared-documentation-with-mdt))
- Dartdoc comments on all public API surfaces

## Screenshots and images

<!-- {=docsImagesOutOfGit} -->

- **Keep image files out of Git**, including screenshots, design exports, and golden snapshots. Save them in gitignored local output directories, upload review images with `gh pr create/edit/comment --attach`, or use external file storage. Put the resulting attachment or download URL in the PR or a README. Prefer pixel assertions against in-memory renders when a visual test can express the expected behavior without a committed image.
- Before pushing, check staged additions and the branch's commits for image files. Remove newly introduced images from an unmerged branch's history before publishing the corrected branch; deleting them only in a later commit still leaves the repository bloated.

<!-- {/docsImagesOutOfGit} -->

<!-- {=docsDesignScreenshotsRule} -->

- Every pull request that changes what skribble draws or how it lays out must show the change. That covers widget appearance, the rough engine, pens and fillers, icons and emoji, fonts, theme defaults, spacing, and the storybook or docs visuals.
- Capture **before and after** screenshots from the same harness: the storybook, `melos run screenshot`, or an in-memory render. Include both light and dark themes, and narrow and wide widths when layout changes.
- Upload them to the pull request itself with the GitHub CLI's `--attach` flag, never by committing them:
  - when opening: `gh pr create --attach './before.png#Before' --attach './after.png#After'`;
  - later captures: `gh pr edit <n> --attach ...` or `gh pr comment <n> --attach ...`.
- Text after `#` is the image's alt text. A local path already referenced in the body (`![Before](./before.png)`) is replaced with the uploaded URL; anything else is appended.
- Put the images in a collapsible `<details>` section of the description, and say what the captures do not cover. Inspect every image first so it exposes no secrets or personal data.

<!-- {/docsDesignScreenshotsRule} -->

## Need help?

- Check the [Agents](agents) reference for AI agent-specific guidance
- Open an issue at [github.com/openbudgetfun/skribble/issues](https://github.com/openbudgetfun/skribble/issues)

## Develop the Flutter documentation

The documentation app belongs to the Dart workspace and renders the canonical Markdown under `docs/site/content/`. Add a Markdown file in an existing content directory and it appears in the catalog automatically. For a new directory, also add its asset path to the docs pubspec. Shared MDT content still comes from `templates/*.t.md`.

Run `docs:site:serve --web-port=4178` to preview the app. `docs:site:build --base-href=/skribble/docs/` produces `docs/site/build/web/`, including per-route entrypoints for direct GitHub Pages reloads. The Pages workflow serves the docs under `docs/`, beneath the [landing page](#develop-the-landing-page), and bundles the separate storybook under `docs/storybook/`.

Widget tests render and scroll every page at mobile and desktop widths. Patrol browser journeys exercise live examples, responsive navigation, and real clipboard access. Run them from `docs/site` with `patrol test --device chrome --target integration_test/docs_test.dart --web-headless`.

Preserve ordinary text selection when changing the article renderer. Copy buttons complement selection; they do not replace it. Cache parsing outside scrolling, avoid rebuilding the article on animation ticks, and inspect a release build before claiming a scrolling improvement.

## Develop the landing page

The skribble.dev landing page lives in `apps/skribble_site`. It is a [Jaspr](https://jaspr.site) app rendered to static HTML with `skribble_jaspr`, so the page ships hand-drawn SVG and a small enhancement script rather than a Flutter canvas. Run `site:serve` to build it and open `http://localhost:8080/`, or `site:build --base-path=/skribble/` to build for a sub-path.

The build turns each font into a Latin-subset WOFF with `pyftsubset` from fontTools, which `devenv shell` provides; outside it, `pip install fonttools`.

`dart test` in `apps/skribble_site` checks accessibility attributes, stable markup, and that every `docs/...` link has a page here. Check visual changes in light and dark at 360, 768, and 1280 pixels, with reduced motion on and off.
