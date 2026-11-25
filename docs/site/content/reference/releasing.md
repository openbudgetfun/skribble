---
title: Releasing
description: How Monochange prepares, validates, and publishes skribble packages.
---

The development shell pins monochange 0.21.0 through `devenv.lock`. Run `devenv shell monochange --version` to verify the CLI before preparing a release.

skribble publishes packages to pub.dev as one synchronized `main` release group:

- `skribble`
- `skribble_emoji`
- `skribble_emoji_gen`
- `skribble_font_noto`
- `skribble_font_noto_lively`
- `skribble_font_noto_sketch`
- `skribble_font_recursive`
- `skribble_font_roughen`
- `skribble_icons`
- `skribble_icons_bxs`
- `skribble_icons_cib`
- `skribble_icons_lucide`
- `skribble_icons_material`
- `skribble_icons_simple`
- `skribble_jaspr`
- `skribble_lints`
- `skribble_rough`

Those packages use the same version and the release tag `v<version>`. `skribble_maps` and `skribble_charts` release independently, with tags `skribble_maps/v<version>` and `skribble_charts/v<version>`. Neither belongs to the `main` group. The website, `skribble_site`, releases on its own too, with tags `skribble_site/v<version>`, but is never published to a registry (see [The website](#the-website)). The two Rust crates (`rust:skribble_rough` and `skribble_core`) form the `rust` group and release to crates.io under `rust/v<version>` (see [Rust crates](#rust-crates)). The five npm packages in `js/` form the `js` group and release to npm under `js/v<version>` (see [npm packages](#npm-packages)). Other applications, the workspace root, and the documentation app remain private.

Both companion packages depend on `skribble`, so Monochange propagates the core package's release severity to them. A breaking core change produces a breaking companion change. Changes confined to maps or charts can release without forcing a release of the main group.

The first public release uses a pre-1.0 `major` bump pinned to `0.1.0`. Package manifests use the unpublished `0.0.1` development baseline after the `0.0.0` registry placeholders. Monochange replaces that baseline when it prepares the release.

## Record a change

Every releasable pull request needs a file in `.changeset/`. Use the configured Monochange command or follow an existing changeset:

```bash
monochange run document
monochange step validate
monochange check
```

Website changes target `skribble_site` and pick their audience with the change type. Use `feat`, `fix`, and the other usual types for the website's developer changelog (build, tooling, deployment), and `user_feat` or `user_fix` for what people visiting skribble.dev can now see or try. Those two types belong to the `user` stream, which is written to the docs' [What's new](/reference/whats-new) page. When a change matters to both audiences, write one changeset for each:

```md
---
skribble_site: user_fix
---

# Highlights cover their whole word on every browser

Circles and marker strokes on the landing page no longer stop short of the word they highlight.
```

`monochange step validate` and `monochange check` do not catch a changeset whose targets mix streams; `monochange step prepare-release --dry-run` does.

### Changeset lint rules

`monochange check` lints every changeset, and the CI `lint` job fails a pull request that violates the policy. Each changeset needs exactly one H1 summary heading of 8–90 characters that does not end with a period and does not use a Conventional Commit prefix (`feat:`, `fix(scope):`, …). The first description sentence must add information beyond the heading instead of restating it, and the body needs at least 80 characters of explanation — 120 plus a code block for `major` bumps — so the generated changelog stays meaningful. Change entries stay in the inline `target: type` form, change types never appear as section headings (`## Breaking`), and each changeset covers one concern; two files target the same package only when a website change needs a note for each audience (see above). The lint rules also cover manifest hygiene: dependencies and assets stay alphabetically sorted, internal dependency versions match the workspace, publishable packages declare required metadata and an SDK constraint, and unmanaged packages declare `publish_to: none`. Run `monochange check --fix` to auto-fix the style rules (`prefer-inline`, sorting); everything else needs a manual edit.

## The release pull request

Every push to `main` runs the `Release PR` workflow. When changesets are pending, it runs `monochange run release` with `MONOCHANGE_RELEASE_BACKEND=hosted`: Monochange plans the version bumps, updates the changelogs and versioned files, and formats them, then the monochange GitHub App on monochange.dev commits the result on the `chore/release/release` branch and opens or refreshes the `chore(release): prepare release` pull request. Review the planned versions and changelogs there, then merge it once every check is green: the `Release PR` workflow detects the merged release commit, tags it, and dispatches `publish.yml` automatically (see [Publish a release](#publish-a-release)).

The release commit is verified and the pull request is opened by the monochange bot, so CI starts on the release pull request by itself; no run needs approving.

To open or refresh the release pull request by hand, dispatch the workflow:

```bash
gh workflow run release.yml
```

## Release from a local checkout

A release can also be prepared and published from a local checkout, without the release pull request. Run it inside the devenv shell so the pinned SDK is used:

```bash
monochange run release-local --diff      # preview planned versions and files
monochange run release-local             # prepare versions and changelogs only
monochange run release-local --commit    # prepare and commit
monochange run release-local --commit --push --tag    # prepare, commit, push, and push tags
monochange run release-local --commit --push --tag --publish-release  # also publish the GitHub releases and font assets
```

`--diff` is not a dry run: it renders the plan and leaves the planned version bumps, changelog entries, and a release manifest in the working tree. Restore the tree with `git checkout -- .` afterwards, or preview read-only with `monochange step prepare-release --dry-run --diff`.

The local run does everything in one pass on `main`: it plans the bumps, syncs dependency references, formats the workspace, creates the release commit, pushes it, pushes the release tags, publishes the GitHub release objects, and attaches the font assets. Pushing the release commit to `main` triggers the `Release PR` workflow to dispatch `publish.yml` in wave order (`publish.yml` has no `push: tags:` trigger); to reconcile or re-dispatch from GitHub manually, run `gh workflow run release.yml --ref <tag>`.

The shared CI setup restores `.fvmrc` after FVM selects the pinned SDK, and the storybook ignores Flutter's generated iOS configuration. These keep the checkout clean while the release command commits.

## Publish a release

Releases complete from GitHub alone — no local checkout or manual tag push is needed. When the release pull request merges into `main`:

1. The `Release PR` workflow (`.github/workflows/release.yml`) detects that `HEAD` is a release commit (`monochange step release-record --from HEAD`).
2. Its `update` job creates and pushes every release tag declared by the release record (`monochange step tag-release --from HEAD --push=true`). Tags already pointing at `HEAD` are skipped.
3. Its `dispatch_publish` job runs `scripts/release/dispatch_publish_runs.sh --wave reconcile`, waits until each tag is visible on `origin`, and dispatches one `publish.yml` run per independent **Wave 1** tag on that tag's ref (`gh workflow run publish.yml --ref <tag> -f tag=<tag>`). Wave 1 includes `v<version>` (`main`), `rust/v<version>`, `js/v<version>`, and `skribble_site/v<version>` (plus Dart companions when `main` is not in the release).
4. Each `publish.yml` run stops at the `publisher` environment for maintainer approval. Because each run is independent, approvals do not have to happen at the same time and no workflow waits or times out on them.
5. Once the `main` (`v<version>`) publish run succeeds and verifies all 17 main packages on pub.dev, its `dispatch_dependents` job dispatches **Wave 2**: `publish.yml` on each Dart companion tag that depends on `skribble` (`skribble_charts/v<version>` and `skribble_maps/v<version>`). Approving those Wave 2 runs finishes the release.

Inside each tag's `publish.yml` run:

1. Both the `publish` and `website` jobs first validate that the workflow ref is a tag (`ref_type == tag`), matches `inputs.tag` if supplied, and matches one of this repository's release tag patterns (`v<semver>`, `rust/v<semver>`, `js/v<semver>`, `skribble_charts/v<semver>`, `skribble_maps/v<semver>`, or `skribble_site/v<semver>`), then check out the tag and verify it is reachable from `main`.
2. `Find the packages this tag publishes` reads the release record and determines which publishable packages and registries (`pub_dev`, `crates_io`, `npm`) this tag owns. `skribble_site/v*` owns no registry packages and skips straight to its GitHub release.
3. When the tag owns registry packages, `monochange publish readiness` runs scoped to only this tag's owned packages (via `--package`), so Dart, Rust, and npm tags do not dry-run each other's ecosystems.
4. Registry authentication runs only for the ecosystems this tag owns: `dart-lang/setup-dart` for pub.dev (after readiness so dependency resolution stays anonymous), `rust-lang/crates-io-auth-action` for crates.io (`CARGO_REGISTRY_TOKEN`), and npm OIDC (`id-token: write`, npm ≥ 11.5.1) for npm.
5. `scripts/release/publish_owned_packages.sh` publishes each owned package in its own `monochange publish packages` invocation in dependency order, then verifies every owned package against the registry named in the release record's `package_publications` (`pub.dev`, `crates.io`, or `npm`).
6. `scripts/release/publish_github_release.sh` creates **only this tag's** GitHub release from monochange's rendered title and notes (`--verify-tag`, `--latest=true` for primary `v<version>` releases and `--latest=false` for namespaced releases). Existing published releases are skipped so re-runs never overwrite manual edits.
7. A separate `website` job deploys the website once per release commit (see [The website](#the-website)). It does not wait for the registry publish.
8. For the main `v<version>` tag, the workflow packages every bundled font family as a zip and exports the animated emoji Lottie archive, uploading both to the `v<version>` GitHub release.
9. For the main `v<version>` tag, refresh the design handover manually as described in [Publish the Figma handover](#publish-the-figma-handover).

For a five-tag release such as 0.4.1 (`v0.4.1`, `rust/v0.1.1`, `skribble_site/v1.1.0`, `skribble_charts/v0.4.1`, `skribble_maps/v0.4.1`), five `publisher` approvals appear across two waves: three in Wave 1 right after merge (`v0.4.1`, `rust/v0.1.1`, `skribble_site/v1.1.0`) and two in Wave 2 automatically after `v0.4.1` succeeds (`skribble_charts/v0.4.1`, `skribble_maps/v0.4.1`).

pub.dev's automated publishing accepts `workflow_dispatch` runs as long as the run's ref is a tag matching the package's configured tag pattern (`ref_type == tag`, `ref == refs/tags/<pattern>`), the `workflow_dispatch` option is enabled in the package's pub.dev Admin tab, and the `publisher` environment matches. crates.io and npm trusted publishing accept `workflow_dispatch` runs on tag refs under the same `publisher` environment as well. `publish.yml` triggers only on `workflow_dispatch` (never on `push: tags:`), so pushing tags by hand cannot bypass Wave 1 → Wave 2 ordering or start duplicate runs.

To run the tag-scoped publish locally instead (using local credentials) or inspect current registry state:

```bash
./scripts/release/publish_owned_packages.sh v<version>          # main group
./scripts/release/publish_owned_packages.sh rust/v<version>     # Rust crates
./scripts/release/publish_owned_packages.sh v<version> --dry-run
```

It resolves the packages the tag owns from the release record, publishes each in its own `monochange publish packages` invocation in dependency order, and then verifies every one of them against its registry (`pub.dev`, `crates.io`, or `npm`). Publishing one package at a time is deliberate: monochange aborts the rest of a batch when any package fails, so a single rejected publish would otherwise leave every package behind it unpublished. A package that fails is reported by name and the script exits non-zero.

Dependency order comes from a `monochange publish readiness` report scoped to the tag's own packages. The script computes one when `--readiness` is omitted, while the workflow computes it before registering the pub.dev credential and passes it in with `--readiness`. The final verification queries each package's registry API directly using the real package name from the package manifest (so `dart:skribble_rough` checks `skribble_rough` on pub.dev and `rust:skribble_rough` checks `skribble_rough` on crates.io). Because registries can accept an upload before their API lists the new version, any version uploaded by the current run is polled for up to 10 minutes before being reported missing. A package whose publish failed is reported at once.

`monochange run release-local --commit --push --tag --publish-release` remains available for a full local release. Font zips are attached by the publish workflow's `v<version>` job; a release published locally uses `publish:fonts` to upload the same archives.

### Publish commands

Use the `monochange publish` commands for every publish task:

```bash
monochange publish packages      # publish package versions from the release record
monochange publish readiness     # check registry readiness without publishing
monochange publish placeholder   # reserve new package names with a 0.0.0 placeholder
```

Each runs the same built-in step as `monochange step publish-packages`, `monochange step publish-readiness`, or `monochange step placeholder-publish` and accepts exactly that step's flags (`--package`, `--dry-run`, `--format`, `--output`, and so on). These docs, the workflows, and the release scripts use the `monochange publish` form. Treat the `monochange step` names as a fallback only, even where an older monochange error hint still prints them. `monochange step publish-release` stays as a step: `monochange publish` has no release subcommand. `monochange run publish` is the workspace's release command, which publishes every package in the current release record, and is separate from `monochange publish packages`.

When npm asks for a one-time password (`EOTP`), get the current code from your authenticator and rerun the same command with it, for example `monochange publish placeholder --otp <CODE>`. `monochange publish packages` has no `--otp` flag; set `NPM_CONFIG_OTP=<CODE>` for that command instead.

### Prerequisites for automated publishing

Two repository-side settings make the automated path work. A release from a local checkout needs only the second.

- **GitHub Actions can open pull requests** — _Settings → Actions → General → Allow GitHub Actions to create and approve pull requests_ must stay enabled, at the organization and repository level, or the release workflow cannot open the release pull request with `GITHUB_TOKEN`.
- **pub.dev automated publishing** — configured per package in the package's Admin tab: repository `openbudgetfun/skribble`, workflow `publish.yml`, environment `publisher`, both `push` and `workflow_dispatch` events enabled, and the tag pattern for that package (`v{{version}}`, `skribble_maps/v{{version}}`, or `skribble_charts/v{{version}}`). pub.dev rejects a tagged publish whose configuration does not match.
- **crates.io trusted publishing** — configured per crate (`skribble_rough` and `skribble_core`) with repository `openbudgetfun/skribble`, workflow `publish.yml`, and environment `publisher`. `publish.yml` exchanges the GitHub Actions OIDC token via `rust-lang/crates-io-auth-action` and passes it to `cargo publish` as `CARGO_REGISTRY_TOKEN`.

  This is per package and cannot be verified from the repository: `monochange publish readiness` reports `manual_verification_required` for every existing package because it cannot read trusted-publisher entries without registry credentials. A package whose rule is missing or mismatched fails at publish time with `The calling GitHub Action is not allowed to publish, because: publishing from github is not enabled`, and no workflow change can fix it — only the Admin tab can. Both v0.2.0 and v0.2.1 failed exactly this way on `skribble_font_recursive` while its sibling packages published normally.

`publish.trusted_publishing` in `monochange.toml` sets `mode = "preferred"`. When a verifiable GitHub Actions identity is present the publish still uses trusted publishing and still verifies the configured repository, workflow, and environment, so the automated path is unchanged. Without that identity — a local run, for example — publishing falls back to standard credentials instead of failing before the first registry call. The default mode, `required`, rejects any publish not backed by a CI identity, which makes trusted publishing mandatory in every environment.

### Font release assets

Each bundled font family ships as a versioned zip attached to the GitHub release, produced by `scripts/release/package_fonts.sh`. The zip stem is the `fontFamily` value a consumer passes to Flutter, except for the `Skribble` family, which keeps its already-published `SkribbleRecursive` stem:

- `SkribbleRecursive-<tag>.zip` — the `Skribble` family, roughened from Recursive Casual
- `SkribbleGentle-<tag>.zip`, `SkribblePlayful-<tag>.zip` — the Casual family at Gentle and Playful roughness
- `SkribbleLinearGentle-<tag>.zip`, `SkribbleLinearPlayful-<tag>.zip`, `SkribbleLinearExpressive-<tag>.zip` — roughened from Recursive Sans Linear
- `SkribbleMonoGentle-<tag>.zip`, `SkribbleMonoPlayful-<tag>.zip`, `SkribbleMonoExpressive-<tag>.zip` — roughened from Recursive Mono Linear

Every zip contains the family's four faces (Regular, Bold, Italic, and BoldItalic) and the `OFL.txt` license.

The family list is read from the `fonts:` block of `packages/skribble/pubspec.yaml`, so declaring a new family is enough to ship it. `package_fonts.sh` fails when a declared family has no matching TTFs, or when a TTF in the fonts directory is not claimed by any declared family, so a release cannot silently drop a family. Ten families are bundled today; the four-family list this replaced omitted the six Linear and Mono families that were already declared in the package.

The publish workflow checks out the release tag, so it packages fonts with the `package_fonts.sh` committed at that tag. A later fix to the script reaches new tags only; use `publish:fonts` to attach the full set to a release that was tagged before the fix.

Fonts are static assets inside `packages/skribble`, so the zip upload is retried safely with `--clobber` when a run repeats. Companion tags (`skribble_maps/v*`, `skribble_charts/v*`) skip the fonts step entirely.

When publishing runs from a developer machine instead of the tag-push workflow, attach the zips with the devenv command:

```bash
publish:fonts                    # newest main-group v<version> tag
publish:fonts v0.2.0             # explicit tag
publish:fonts v0.2.0 --dry-run   # package and list the uploads without sending them
```

The command packages the fonts committed at the tag (`git archive`, not the working tree), so the archives always describe the release they are attached to, and it fails if the GitHub release object does not exist yet.

### Skribble Noto fonts and kit

`publish:fonts` also packages the three Skribble Noto packages: `SkribbleNoto-<tag>.zip`, `SkribbleNotoSketch-<tag>.zip`, and `SkribbleNotoLively-<tag>.zip`, each with its Latin, Greek, and Cyrillic Regular face and `OFL.txt`. A package that does not exist at an older tag is skipped.

The three Noto packages are new to pub.dev. Before the first release that includes them, reserve their names with the one-time `0.0.0` placeholder and register each automated publisher (repository `openbudgetfun/skribble`, workflow `publish.yml`, environment `publisher`, tag pattern `v{{version}}`), as described in [Placeholder publish](#two-things-that-bite-during-a-bootstrap) below. Until then, `publish:owned` reports those three as unpublished while the rest of the group publishes normally:

```bash
monochange publish placeholder --package skribble_font_noto
monochange publish placeholder --package skribble_font_noto_sketch
monochange publish placeholder --package skribble_font_noto_lively
```

The all-scripts kit is too large to commit, so it is built on a developer machine with `tool/skribble_noto/build.py` (see `tool/skribble_noto/README.md`) and uploaded by hand, one zip per level:

```bash
python3 tool/skribble_noto/build.py gf/ofl build/noto
./scripts/release/publish_noto_kit.sh build/noto v0.4.0 --dry-run
./scripts/release/publish_noto_kit.sh build/noto v0.4.0
```

That attaches `SkribbleNoto-Kit-<tag>.zip`, `SkribbleNotoSketch-Kit-<tag>.zip`, and `SkribbleNotoLively-Kit-<tag>.zip`, each with every script's Regular file, `OFL.txt`, and the kit README (`tool/skribble_noto/KIT.md`, shipped as `README.md`). The script checks that the tag and its GitHub release exist before uploading. Rebuild the kit when the generator or the pinned Noto sources change; otherwise re-upload the previous kit to the new tag.

### Rust crates

`rust:skribble_rough` (`rust/rough`) and `skribble_core` (`rust/core`) share the workspace version in `Cargo.toml` and release together as the `rust` group under `rust/v<version>` tags. Both crates already use crates.io trusted publishing (`openbudgetfun/skribble`, `publish.yml`, environment `publisher`). Because monochange 0.21.0 does not perform the crates.io OIDC exchange itself, `publish.yml` runs `rust-lang/crates-io-auth-action` whenever the tag owns Cargo packages and passes its temporary token to `publish_owned_packages.sh` as `CARGO_REGISTRY_TOKEN`; the action's post step revokes the token when the job ends. `skribble_rough` publishes before `skribble_core` in dependency order; if a `crates_io` publish fails (for example when crates.io's index lags past cargo's own wait window), `publish_owned_packages.sh` waits 60 seconds and retries that crate once before recording a failure. Verification queries `crates.io/api/v1/crates/skribble_rough` and `crates.io/api/v1/crates/skribble_core` using the crate names from their `Cargo.toml` manifests.

### npm packages

`@skribble.dev/rough`, `@skribble.dev/react`, `@skribble.dev/react-native`, `@skribble.dev/vue`, and `@skribble.dev/svelte` share one version as the `js` group and release under `js/v<version>`. A JavaScript release never forces a Dart release, and the reverse. They follow the same baseline as the Dart packages: manifests sit at the unpublished `0.0.1` development version after the `0.0.0` registry placeholders, and the first release is pinned to `0.1.0`.

Internal dependencies are plain ranges such as `"@skribble.dev/rough": "^0.1.0"`. Monochange rewrites them with each release and refreshes `pnpm-lock.yaml` with `pnpm install --lockfile-only`. They are never `workspace:` ranges, because trusted publishing runs plain `npm publish`, which would upload a `workspace:` range unchanged. `pnpm-workspace.yaml` keeps pnpm linking the local packages.

Only a tag that owns npm packages installs the pnpm workspace (`pnpm install --frozen-lockfile`) and checks that npm is at least 11.5.1 (the first version with trusted publishing), because readiness is scoped to the packages that tag owns. Each package's `prepack` script builds it and its workspace dependencies first, and the final registry check routes every package to the registry declared in the release record's `package_publications` (`pub.dev`, `crates.io`, or `npm`).

**Before the first `js/v*` tag**, bootstrap npm once. npm only accepts a trusted publisher for a package that already exists, so the first publish cannot come from the workflow:

1. Sign in with an npm account that can publish to the `@skribble.dev` organization (`npm login`).
2. Reserve each name with a `0.0.0` placeholder:

   ```bash
   monochange publish placeholder --package @skribble.dev/rough --dry-run
   monochange publish placeholder --package @skribble.dev/rough
   monochange publish placeholder --package @skribble.dev/react
   monochange publish placeholder --package @skribble.dev/react-native
   monochange publish placeholder --package @skribble.dev/vue
   monochange publish placeholder --package @skribble.dev/svelte
   ```

   npm asks for a one-time password on each publish when the account uses two-factor authentication. Add `--otp <CODE>` with the current code from your authenticator, for example `monochange publish placeholder --package @skribble.dev/rough --otp <CODE>`.

3. On npmjs.com, open each package's _Settings → Trusted publishing_ and add a GitHub Actions publisher: repository `openbudgetfun/skribble`, workflow `publish.yml`, environment `publisher`. A recent npm CLI can do the same from the command line, for example `npm trust github @skribble.dev/rough --file publish.yml --repo openbudgetfun/skribble --env publisher --yes`; `monochange publish packages --dry-run` prints this command for every npm package.
4. Check that every name is reserved:

   ```bash
   for p in rough react react-native vue svelte; do
     curl -s -o /dev/null -w "%{http_code} @skribble.dev/$p\n" "https://registry.npmjs.org/@skribble.dev%2f$p"
   done
   ```

A package without a trusted publisher fails at publish time, while its siblings that have one publish normally, the same way `skribble_font_recursive` failed v0.2.0 on pub.dev.

### Animated emoji release asset

The `v<version>` publish run also attaches `skribble-emoji-lottie.zip`: every animated emoji exported as a Lottie file, plus the license. `scripts/release/publish_emoji_lottie.sh` checks the tag out in a temporary worktree and runs the `export Lottie files` test in `packages/skribble_emoji`, so the zip always describes the release it is attached to, and the upload replaces a same-named asset on a re-run. When the export fails, the script prints the test's output before exiting.

```bash
publish:emoji-lottie                    # newest main-group v<version> tag
publish:emoji-lottie v0.3.0 --dry-run   # export and report without uploading
```

The export passes `--plain-name 'export Lottie files'` through the devenv `flutter` script, which forwards its arguments quoted. The v0.3.0 run failed here because the script used to forward them unquoted, splitting the test name into three paths.

The publish workflow triggers only on `workflow_dispatch` against a release tag ref (`gh workflow run publish.yml --ref <tag>`). Both the `publish` and `website` jobs reject non-tag refs (such as `main`) and tags that do not match `v<semver>`, `rust/v<semver>`, `js/v<semver>`, `skribble_charts/v<semver>`, `skribble_maps/v<semver>`, or `skribble_site/v<semver>`.

The pub.dev automated publisher for `skribble_maps` uses repository `openbudgetfun/skribble`, workflow `publish.yml`, GitHub environment `publisher`, and tag pattern `skribble_maps/v{{version}}`. Its `0.0.0` placeholder was published with Monochange before the automated publisher was registered.

## Publish the Figma handover

Main-group releases publish the design handoff assets consumers design against:

- **`skribble-design-system.fig`** — the editable Figma design system, attached to the release marked Latest. Save the export outside the checkout and upload it as described in [docs/design/README.md](https://github.com/openbudgetfun/skribble/blob/main/docs/design/README.md). Figma exports are release assets and must never be committed to Git.
- **The generated design kit** — fonts, editable SVG pen specimens, token README, and manifest, produced by `packages/skribble/tool/design_kit.dart` and attached as `skribble-design-kit-v<version>.zip` so the fonts and specimens travel with the published version.

Run the handover publish manually after the GitHub release exists:

```bash
git checkout v<version>
devenv shell dart run packages/skribble/tool/design_kit.dart
cd build && zip -r skribble-design-kit-v<version>.zip design-kit && cd ..
gh release upload v<version> build/skribble-design-kit-v<version>.zip
```

Rules for the handover publish step:

- **Generate from the release tag, never from `main`.** The kit must be produced at the exact commit the packages were published from, so design assets match published code. Font geometry and pen settings change with the rough engine, and a kit built from `main` matches no released version.
- **Verify completeness before uploading.** The kit must contain 36 font files in `fonts/` and 18 specimens in `specimens/`, with a `manifest.json` listing both. The counts come from the design kit test; the check catches a partially regenerated kit before it ships.
- Verify the `.fig` upload separately: confirm the uploaded asset size and SHA-256 digest before sharing the download link, and attach the export to the release whose code it matches.
- A `skribble_maps`-only or `skribble_charts`-only release does not ship design assets. The kit reflects the core package's fonts and rough engine, which the companion packages do not change.
- If a release changed the fonts or the rough engine, refreshing the handover is mandatory, not optional. Mention the design kit in the changeset so the release notes record the refresh.
- Link the Figma guide from the release notes body, next to the package list.

The [Figma workflow guide](../guides/figma) documents how agents and designers consume the released assets and assemble per-design handover bundles.

## Release checks on every pull request

CI validates publishing before anything is released. Two jobs in the `CI` workflow run on every pull request and every push to `main`:

- **`publish-check`** validates the pull request as-is. `monochange publish packages --dry-run --all` runs `dart pub publish --dry-run` (or `flutter pub publish --dry-run` for Flutter packages) for every Dart package against pub.dev and `npm publish --dry-run` for every npm package, the same validation the publish workflow performs before a real publish.
- **`release-publish`** validates the release commit. When the branch carries at least one pending changeset it runs `monochange step prepare-release --release-json` and `monochange step commit-release --no-verify` locally — the same version bumps, changelog updates, and release record `monochange run release` will produce — then checks `monochange publish readiness` and repeats the publish dry-run against that commit. Nothing is pushed, tagged, or published.

  The `MIN_CHANGESETS` job-level environment variable sets the threshold, currently `1`: every releasable change is validated before it merges, and only a branch with nothing to release skips. The step prints the pending count against the threshold, so a skip explains itself.

A pull request that would produce an unpublishable release fails here instead of at release time. The per-package publish timeout is raised to 600 seconds in `monochange.toml` because the large Flutter packages can exceed the default on cold caches.

Locally, publishing is previewed through the release flow (run it inside the devenv shell so the pinned SDK is used):

```bash
monochange run publish --dry-run
```

## Recover a partial publish

Recovering a partial publish stays on GitHub: publishing checks each package's registry and skips versions that already exist, existing tags are left alone, and existing GitHub releases are skipped.

- **Retry one failed tag** — click _Re-run failed jobs_ on the failed `Publish` run, or dispatch it again directly on the tag ref:

  ```bash
  gh workflow run publish.yml --ref <tag> -f tag=<tag>
  ```

  To repair only one tag's GitHub release or font/emoji assets after its Wave 2 companions have already published, pass `-f dispatch_dependents=false` (even without that flag, `dispatch_dependents` skips any companion tag that already has a successful publish run at the same commit).

- **Reconcile an entire release commit** — dispatch `release.yml` on one of that release's tags:

  ```bash
  gh workflow run release.yml --ref v<version>
  ```

  Dispatching on a release tag works even after newer commits have landed on `main` (dispatching `release.yml` on `main` once `HEAD` is no longer the release commit prints a notice and dispatches nothing). Reconcile skips tags that already exist and publish runs whose `publish` job already succeeded or is active (so a `website` job failure neither re-dispatches `v<version>` nor blocks Wave 2), dispatching only missing or failed tags (including Wave 2 companions once `v<version>`'s `publish` job has succeeded).

Before rerunning, check which packages are actually missing rather than assuming the failure was transient. A publish that fails with `publishing from github is not enabled` will fail identically on every retry until the package's rule is registered in its registry admin page.

```bash
./scripts/release/publish_owned_packages.sh <tag> --dry-run   # lists the tag's packages and current registry state
```

A recovery run reads `scripts/release/publish_owned_packages.sh`, `scripts/release/publish_github_release.sh`, `scripts/release/dispatch_publish_runs.sh`, and `scripts/release/deploy_website.sh` from `origin/main` so script fixes reach older tags. Everything else — the release record, package manifests, and versions — still comes from the checked-out tag, so the release being published is the tag's. The same does not apply to `scripts/release/package_fonts.sh`, which is why [Font release assets](#font-release-assets) notes that a font-packaging fix reaches only new tags.

Each run uploads its readiness and publication reports for 14 days. Read those artifacts before retrying. Keep the original release tag on the release-record commit.

Useful local checks:

```bash
monochange step validate
monochange check
monochange step prepare-release --dry-run --diff
monochange run publish --dry-run
```

`monochange publish placeholder` is only for the one-time `0.0.0` registry bootstrap needed before pub.dev automated publishing can be enabled. It is not part of normal releases. Select a single package with `--package <name>` when bootstrapping a newly independent package.

For `skribble_charts`, bootstrap after its implementation merges:

```bash
monochange publish placeholder --package skribble_charts --dry-run
monochange publish placeholder --package skribble_charts
```

Then configure its pub.dev automated publisher with repository `openbudgetfun/skribble`, workflow `publish.yml`, environment `publisher`, and tag pattern `skribble_charts/v{{version}}`. Allow both `push` and `workflow_dispatch`. The placeholder reserves the package name; the subsequent release publishes the chart implementation.

### Two things that bite during a bootstrap

**Use the pinned SDK.** Monochange shells out to `dart pub publish`, which resolves `dart` from `PATH` rather than through the devenv `dart`/`flutter` wrappers. On a machine whose system Dart is older than the workspace's `environment.sdk` constraint, the run fails with a version-solving error naming the wrong SDK. Prepend the workspace SDK inside the shell:

```bash
devenv shell bash -c '
  export PATH="$PWD/.fvm/flutter_sdk/bin:$PATH"
  monochange publish placeholder
'
```

**Expect to be rate limited.** pub.dev caps new-package creation independently of its documented daily publish guidance. A fresh bootstrap of several packages typically publishes four and then returns `the "package-created" operation is blocked, as its rate limit has been reached`. The command is safe to rerun: it skips versions that already exist, so the fix is to wait for the window to clear and run it again. Verify with the registry rather than the exit code, since a partial run exits non-zero after publishing some packages:

```bash
for p in skribble_icons_lucide skribble_icons_material; do
  curl -s -o /dev/null -w "%{http_code} $p\n" "https://pub.dev/api/packages/$p"
done
```

A `200` means the name is reserved.

## The website

The website is the skribble.dev landing page (`apps/skribble_site`) with the documentation under `docs/` and the storybook under `docs/storybook/`. It deploys with releases, not with every push to `main`, so the docs always describe packages you can install. Each deploy also renders the link-preview image, `docs/share-card.png`, that every page's Open Graph and Twitter card tags point at.

`skribble_site` is a monochange package with `publish = { enabled = false }`: it gets a version, a changelog (`apps/skribble_site/CHANGELOG.md`), a `skribble_site/v<version>` tag, and a GitHub release titled `skribble.dev v<version>`, but nothing is sent to pub.dev. Its publish run skips the registry steps and only creates the GitHub release.

Every release deploys the website once. The publish workflow's `website` job runs `scripts/release/deploy_website.sh` with its tag, and only the first release tag at the commit in priority order (`v*`, then `rust/v*`, `js/v*`, `skribble_maps/v*`, `skribble_charts/v*`, and `skribble_site/v*`) dispatches the `Docs Pages` workflow. That workflow runs on `main`, because the `github-pages` environment only accepts deployments from `main`, and builds the tagged commit. A dispatch is one of the few events the workflow's `GITHUB_TOKEN` may start, so a release always deploys, including a Rust-only, npm-only, or site-only release.

### What's new

Changesets with the `user_feat` and `user_fix` types belong to the `user` stream. monochange appends them to [What's new](/reference/whats-new) (`docs/site/content/reference/whats-new.md`) when it prepares a website release, so the page ships in the same deploy. Preview the next entry without changing anything:

```bash
monochange notes --output user --target skribble_site
```

### Deploy by hand

Nothing deploys between releases, so if skribble.dev still shows the previous release after a publish run, its `website` job failed or never ran: redeploy that release's tag by hand. Prefer the tag over the tip of `main`, which may document changes that are not released yet.

Redeploy a release, or deploy the tip of `main` between releases, by dispatching `Docs Pages` on `main`:

```bash
gh workflow run docs-pages.yml --ref main -f release_tag=v0.4.0   # a release
gh workflow run docs-pages.yml --ref main                        # the tip of main
./scripts/release/deploy_website.sh v0.4.0 --dry-run              # which tag owns a release's deploy
```
