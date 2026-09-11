---
title: Releasing
description: How Monochange prepares, validates, and publishes Skribble packages.
---

Skribble publishes seven packages to pub.dev as one synchronized `main` release group:

- `skribble`
- `skribble_emoji`
- `skribble_emoji_gen`
- `skribble_font_roughen`
- `skribble_icons`
- `skribble_icons_custom`
- `skribble_lints`

Those packages use the same version and the release tag `v<version>`. `skribble_maps` and `skribble_charts` release independently, with tags `skribble_maps/v<version>` and `skribble_charts/v<version>`. Neither belongs to the `main` group. Applications, the workspace root, and the documentation site remain private.

Both companion packages depend on `skribble`, so Monochange propagates the core package's release severity to them. A breaking core change produces a breaking companion change. Changes confined to maps or charts can release without forcing a release of the seven-package group.

The first public release uses a pre-1.0 `major` bump pinned to `0.1.0`. Package manifests use the unpublished `0.0.1` development baseline after the `0.0.0` registry placeholders. Monochange replaces that baseline when it prepares the release.

## Record a change

Every releasable pull request needs a file in `.changeset/`. Use the configured Monochange command or follow an existing changeset:

```bash
monochange run document
monochange step validate
monochange check
```

### Changeset lint rules

`monochange check` lints every changeset, and the CI `lint` job fails a pull request that violates the policy. Each changeset needs exactly one H1 summary heading of 8–90 characters that does not end with a period and does not use a Conventional Commit prefix (`feat:`, `fix(scope):`, …). The first description sentence must add information beyond the heading instead of restating it, and the body needs at least 80 characters of explanation — 120 plus a code block for `major` bumps — so the generated changelog stays meaningful. Change entries stay in the inline `target: type` form, change types never appear as section headings (`## Breaking`), and two changesets cannot target the same package. The lint rules also cover manifest hygiene: dependencies and assets stay alphabetically sorted, internal dependency versions match the workspace, publishable packages declare required metadata and an SDK constraint, and unmanaged packages declare `publish_to: none`. Run `monochange check --fix` to auto-fix the style rules (`prefer-inline`, sorting); everything else needs a manual edit.

After the pull request merges, release the changes locally. Releases are prepared from `main` on your machine — there is no release pull request bot. Run the release inside the devenv shell so the pinned SDK is used:

```bash
monochange run release --diff            # preview planned versions and files
monochange run release                   # prepare versions and changelogs only
monochange run release --commit          # prepare and commit
monochange run release --commit --push --tag          # prepare, commit, push, and push tags
monochange run release --commit --push --tag --publish-release  # also publish the GitHub releases
```

The full run does everything in one pass: it plans the bumps, syncs dependency references, formats the workspace, creates the release commit, pushes it to `main`, pushes the release tags, and creates the published GitHub release objects from the embedded release record.

The shared CI setup restores `.fvmrc` after FVM selects the pinned SDK, and the storybook ignores Flutter's generated iOS configuration. These keep the checkout clean while the release command commits.

## Publish a release

`monochange run release` with `--tag` pushes the release tags to GitHub — `v<version>` for the main group plus the namespaced maps or charts tag when that package is included. Because the tags are pushed with your own credentials, each tag push is a real workflow event that fires the publish workflow:

1. The publish workflow checks out the tag and verifies it matches a commit reachable from `main`.
2. Monochange checks publish readiness for the packages in the release record.
3. setup-dart registers the trusted pub.dev token, and Monochange publishes exactly the packages recorded in the release commit's release record, in dependency order. Re-runs skip versions that already exist on pub.dev.
4. For the main `v<version>` tag, the workflow packages every bundled font family as a zip and uploads the archives to the GitHub release.
5. The workflow publishes the GitHub release objects from the release record.

Run the publish locally instead (or after the release tags already exist) with:

```bash
monochange run publish
```

pub.dev's automated publishing only accepts GitHub Actions runs triggered by pushing a git tag. `workflow_dispatch` runs — even against a tag ref — are rejected, so publish from tag pushes.

### Font release assets

Each bundled font family ships as a versioned zip attached to the GitHub release, produced by `scripts/release/package_fonts.sh`:

- `SkribbleRecursive-<tag>.zip` — the `Skribble` family, roughened from Recursive
- `SkribbleGentle-<tag>.zip`
- `SkribblePlayful-<tag>.zip`
- `ArchitectsDaughter-<tag>.zip`

Every zip contains the family's TTFs (Regular, Bold, Italic, BoldItalic where available) and the `OFL.txt` license. Fonts are static assets inside `packages/skribble`, so the zip upload is retried safely with `--clobber` when a publish run re-runs. Companion tags (`skribble_maps/v*`, `skribble_charts/v*`) skip the fonts step entirely.

pub.dev's automated publisher requires the tag push event, so the publish workflow only listens for `v*`, `skribble_maps/v*`, and `skribble_charts/v*` tag pushes. A `workflow_dispatch` with an explicit `tag` input exists for re-running the non-registry steps, but pub.dev rejects the publish itself on dispatch runs.

The pub.dev automated publisher for `skribble_maps` uses repository `openbudgetfun/skribble`, workflow `publish.yml`, GitHub environment `publisher`, and tag pattern `skribble_maps/v{{version}}`. Its `0.0.0` placeholder was published with Monochange before the automated publisher was registered.

## Release checks on every pull request

CI validates publishing before anything is released. Two jobs in the `CI` workflow run on every pull request and every push to `main`:

- **`publish-check`** validates the pull request as-is. `monochange step publish-packages --dry-run --all` runs `dart pub publish --dry-run` (or `flutter pub publish --dry-run` for Flutter packages) for all seven packages against pub.dev, the same validation the publish workflow performs before a real publish.
- **`publish-check-release`** validates the release commit. When the branch has pending changesets, it runs `monochange step prepare-release --release-json` and `monochange step commit-release --no-verify` locally — the same version bumps, changelog updates, and release record `monochange run release` will produce — then checks `monochange step publish-readiness` and repeats the publish dry-run against that commit. Nothing is pushed, tagged, or published.

A pull request that would produce an unpublishable release fails here instead of at release time. The per-package publish timeout is raised to 600 seconds in `monochange.toml` because the large Flutter packages can exceed the default on cold caches.

Locally, publishing is previewed through the release flow (run it inside the devenv shell so the pinned SDK is used):

```bash
monochange run publish --dry-run
```

## Recover a partial publish

Rerunning the publish workflow at the release tag is safe at the package step: Monochange checks pub.dev and skips package versions that already exist. Dispatch it with the release tag as its ref; branch and scheduled runs do not satisfy the trusted-publishing identity.

Each run uploads its readiness and publication reports for 14 days. Read those artifacts before retrying. Keep the original release tag on the release-record commit.

Useful local checks:

```bash
monochange step validate
monochange check
monochange step prepare-release --dry-run --diff
monochange run publish --dry-run
```

`placeholder-publish` is only for the one-time `0.0.0` registry bootstrap needed before pub.dev automated publishing can be enabled. It is not part of normal releases. Select a single package with `--package <name>` when bootstrapping a newly independent package.

For `skribble_charts`, bootstrap after its implementation merges:

```bash
monochange step placeholder-publish --package skribble_charts --dry-run
monochange step placeholder-publish --package skribble_charts
```

Then configure its pub.dev automated publisher with repository `openbudgetfun/skribble`, workflow `publish.yml`, environment `publisher`, and tag pattern `skribble_charts/v{{version}}`. Allow both `push` and `workflow_dispatch`. The placeholder reserves the package name; the subsequent release publishes the chart implementation.
