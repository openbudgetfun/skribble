<!-- Contributor guide content shared by CONTRIBUTING.md,
     docs/site/content/reference/contributing.md, AGENTS.md, and the agents
     reference. Links are repository paths in backticks so the same text
     reads correctly on GitHub and on the docs site. -->

<!-- {@docsContribPrerequisites} -->

- [devenv](https://devenv.sh/) (recommended). `devenv shell` provides the pinned Flutter and Dart, melos, `mdt`, `dprint`, `monochange`, and the git hooks. CI runs every check through it.
- Without devenv: [FVM](https://fvm.app/) with the Flutter version pinned in `.fvmrc` (currently {{ fvm.flutter }}), plus `mdt` and `dprint` on your `PATH` for the documentation checks.
- For the npm packages in `js/`: Node.js and pnpm. For the Rust crates in `rust/`: the toolchain pinned in `rust-toolchain.toml`.

<!-- {/docsContribPrerequisites} -->

<!-- {@docsRepoLayout} -->

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

<!-- {@docsContribWorkflow} -->

1. **Create a branch** from `main`, for example `git switch -c pr/my-feature main`.
2. **Make changes**, following the conventions below. Update the documentation in the same pull request: every change is documented.
3. **Run the quality gates** before pushing. The pre-push hook runs the lint gates for you inside devenv.
4. **Add a changeset** in `.changeset/` for any change to a published package (see the releasing reference), then open a pull request against `main`.

<!-- {/docsContribWorkflow} -->

<!-- {@docsWidgetConventions} -->

- UI components use `HookWidget` (or `HookConsumerWidget` when Riverpod is needed). Motion lifecycle code in `packages/skribble/lib/src/motion/` uses standard Flutter `State` and ticker providers instead, and its public API accepts `Animation<double>`; see `docs/site/content/core/motion.md`.
- Every widget name starts with `Wired`, for example `WiredButton` and `WiredAppBar`.
- Read colors, stroke width, and roughness from `WiredTheme.of(context)`; never hardcode them.
- Isolate repaints with `buildWiredElement(child: ...)` or by extending `WiredBaseWidget`.
- New code imports `package:flutter/widgets.dart` and below, never `package:flutter/material.dart` or `package:flutter/cupertino.dart`. Only `packages/skribble/lib/src/compat/` may import them.
- Interactive widgets take a `semanticLabel`, and every public class and parameter has a `///` dartdoc comment. Reuse the shared wording in `templates/dart.t.md` where it fits.

<!-- {/docsWidgetConventions} -->

<!-- {@docsTestingRequirements} -->

Every widget test file has at least 6 `testWidgets`, written against skribble's public API, covering:

1. **Rendering**: renders without error, child content appears, rough paint is reached.
2. **Dimensions**: correct default size, custom size respected, sensible non-zero size.
3. **Interaction**: taps and input fire callbacks; a disabled widget ignores them.
4. **State**: rebuilds when values change; animations settle.
5. **Edge cases**: null values, empty strings, rapid interactions, overflow, and large, zero, or small constraints.
6. **Accessibility and direction**: semantic label, role, and state where applicable; RTL layout; scaled text.

Widget tests go in `packages/skribble/test/`, with one `test/widgets/wired_<name>_test.dart` per widget. Integration tests go in `apps/skribble_storybook/integration_test/`. Never assert on the Material or Cupertino control a widget currently wraps; `test/tool/no_material_test_coupling_test.dart` enforces this.

<!-- {/docsTestingRequirements} -->

<!-- {@docsTestHelpers} -->

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

<!-- {@docsGitHooksTable} -->

Git hooks are managed by devenv and driven by [prek](https://github.com/j178/prek). They install automatically the first time you enter the devenv shell (`devenv shell`); the generated config lives at `.pre-commit-config.yaml` (gitignored).

| Hook             | Stage      | What it runs                                                                   |
| ---------------- | ---------- | ------------------------------------------------------------------------------ |
| `lint:commit`    | pre-commit | `lint:format` (dprint) across the workspace                                    |
| `secrets:commit` | pre-commit | gitleaks scan of staged changes (`.gitleaks.toml`)                             |
| `lint:push`      | pre-push   | CI lint parity: dependency refresh, `lint:all`, and `monochange step validate` |
| `secrets:push`   | pre-push   | gitleaks scan of the full git history                                          |

Hooks call devenv profile scripts by absolute path, so they work from plain `git` calls outside the devenv shell. Run them on demand with `prek run` (pre-commit) or `prek run --hook-type pre-push`, or skip them for a single commit with `git commit --no-verify`; CI still enforces every check.

<!-- {/docsGitHooksTable} -->

<!-- {@docsCommitConventions} -->

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

<!-- {@docsNewWidgetChecklist} -->

1. Create `packages/skribble/lib/src/wired_<name>.dart` as a `HookWidget`, following the widget conventions.
2. Export it from `packages/skribble/lib/skribble.dart`.
3. Add `packages/skribble/test/widgets/wired_<name>_test.dart` with at least 6 tests covering the testing requirements.
4. Add a showcase entry to the matching page in `apps/skribble_storybook/lib/pages/`.
5. Add `///` dartdoc comments on the class and every public parameter.
6. Document it on the matching `docs/site/content/widgets/<category>.md` page and in `docs/site/content/reference/api-overview.md`.
7. Add a changeset, then run the quality gates.

<!-- {/docsNewWidgetChecklist} -->

<!-- {@docsMdtWorkflow} -->

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
- **Render values from manifests.** `mdt.toml` declares `[data]` sources (the skribble pubspec and `.fvmrc`), so a provider can write `{% raw %}{{ skribble.environment.flutter }}{% endraw %}` instead of a hand-typed version. Providers are therefore [minijinja](https://docs.rs/minijinja) templates: text that needs literal double braces goes inside a raw block.
- **Reach a new file type.** Markdown and Dart are scanned already; add other files to `[include] patterns` in `mdt.toml`.
- **Sync and check.** `fix:docs` runs `mdt update` and `lint:docs` runs `mdt check`; `fix:all` and `lint:all` include them, and CI fails when a consumer is stale. mdt formats synced Markdown with dprint, so run `dprint fmt` (or `fix:format`) after editing a template.

<!-- {/docsMdtWorkflow} -->
