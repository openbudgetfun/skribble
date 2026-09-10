---
title: Releasing
description: How Monochange prepares, validates, and publishes Skribble packages.
---

Skribble publishes seven packages to pub.dev as one synchronized release group:

- `skribble`
- `skribble_emoji`
- `skribble_emoji_gen`
- `skribble_font_roughen`
- `skribble_icons`
- `skribble_icons_custom`
- `skribble_lints`

All packages use the same version and the release tag `v<version>`. Applications, the workspace root, and the documentation site remain private.

The first public release uses a pre-1.0 `major` bump pinned to `0.1.0`. Package manifests use the unpublished `0.0.1` development baseline after the `0.0.0` registry placeholders. Monochange replaces that baseline when it prepares the release pull request.

## Record a change

Every releasable pull request needs a file in `.changeset/`. Use the configured Monochange command or follow an existing changeset:

```bash
monochange run document
monochange step validate
monochange check
```

### Changeset lint rules

`monochange check` lints every changeset, and the CI `lint` job fails a pull request that violates the policy. Each changeset needs exactly one H1 summary heading of 8–90 characters that does not end with a period and does not use a Conventional Commit prefix (`feat:`, `fix(scope):`, …). The first description sentence must add information beyond the heading instead of restating it, and the body needs at least 80 characters of explanation — 120 plus a code block for `major` bumps — so the generated changelog stays meaningful. Change entries stay in the inline `target: type` form, change types never appear as section headings (`## Breaking`), and two changesets cannot target the same package. The lint rules also cover manifest hygiene: dependencies and assets stay alphabetically sorted, internal dependency versions match the workspace, publishable packages declare required metadata and an SDK constraint, and unmanaged packages declare `publish_to: none`. Run `monochange check --fix` to auto-fix the style rules (`prefer-inline`, sorting); everything else needs a manual edit.

After the pull request merges, the `Release PR` workflow refreshes the long-running `monochange/release*` pull request. It prepares package versions and changelogs, then embeds the authoritative release record in the release commit.

The shared CI setup restores `.fvmrc` after FVM selects the pinned SDK, and the storybook ignores Flutter's generated iOS configuration. These keep the checkout clean while Monochange commits the release branch.

The rough-icon generator exposes parsing and rendering helpers for its tests. The declarations suppress `unreachable_from_main`, while the file suppresses the analyzer's contradictory `unnecessary_ignore` result when those helpers are imported by tests.

## Publish a release

Review and merge the release pull request. The merge starts this sequence:

1. Monochange verifies that `HEAD` is the release-record commit.
2. The release workflow pushes the recorded `v<version>` tag with its scoped GitHub token.
3. It creates a **draft** GitHub release from the release record. The release stays invisible until every publishing step below succeeds.
4. It dispatches the trusted pub.dev workflow against that tag. This explicit dispatch is required because GitHub suppresses new workflow runs for ordinary events created by `GITHUB_TOKEN`.
5. The publish workflow's `fonts` job waits for the draft release, then packages every bundled font family as a zip and uploads the archives to it.
6. Monochange runs publish readiness checks. The workflow also executes `dart pub publish --dry-run` immediately before each real publish.
7. The `publisher` environment publishes all seven packages in dependency order.
8. Once the packages exist on pub.dev and the font zips are attached, the workflow flips the draft release to published and marks it latest.

### Font release assets

Each bundled font family ships as a versioned zip attached to the GitHub release, produced by `scripts/release/package_fonts.sh`:

- `SkribbleRecursive-<tag>.zip` — the `Skribble` family, roughened from Recursive
- `SkribbleGentle-<tag>.zip`
- `SkribblePlayful-<tag>.zip`
- `ArchitectsDaughter-<tag>.zip`

Every zip contains the family's TTFs (Regular, Bold, Italic, BoldItalic where available) and the `OFL.txt` license. Fonts are static assets inside `packages/skribble`, so the zip upload is retried safely with `--clobber` when a publish run is re-dispatched.

The rate limit applied only to the packages' first `0.0.0` placeholder publication. Normal version updates do not use the four-hour split or a 12-per-day cap, so the release workflow publishes the complete group in one job.

pub.dev accepts both `push` and `workflow_dispatch` events for every package. The workflow listens for `v*` tag pushes as well as manual dispatches. The release workflow still dispatches the publish workflow explicitly because GitHub does not start a second workflow from a tag created with `GITHUB_TOKEN`.

## Release checks on every pull request

CI validates publishing before anything is released. Two jobs in the `CI` workflow run on every pull request and every push to `main`:

- **`publish-check`** validates the pull request as-is. `monochange step publish-packages --dry-run --all` runs `dart pub publish --dry-run` (or `flutter pub publish --dry-run` for Flutter packages) for all seven packages against pub.dev, the same validation the publish workflow performs before a real publish.
- **`publish-check-release`** validates the release commit. When the branch has pending changesets, it runs `monochange step prepare-release --release-json` and `monochange step commit-release --no-verify` locally — the same version bumps, changelog updates, and release record the release pull request will produce — then checks `monochange step publish-readiness` for all seven packages and repeats the publish dry-run against that commit. Nothing is pushed, tagged, or published.

A pull request that would produce an unpublishable release fails here instead of at release time. The per-package publish timeout is raised to 600 seconds in `monochange.toml` because the large Flutter packages can exceed the default on cold caches.

Locally, the same publish preview is available as a Monochange command (run it inside the devenv shell so the pinned SDK is used):

```bash
monochange run publish-check
```

## Recover a partial publish

Rerunning the publish workflow at the release tag is safe at the package step: Monochange checks pub.dev and skips package versions that already exist. Always dispatch it with the release tag as its ref; branch and scheduled runs do not satisfy the trusted-publishing identity.

Each run uploads its readiness and publication reports for 14 days. Read those artifacts before retrying. Keep the original release tag on the release-record commit.

Useful local checks:

```bash
monochange step validate
monochange check
monochange step prepare-release --dry-run --diff
monochange step placeholder-publish --dry-run --format json
```

`placeholder-publish` is only for the one-time `0.0.0` registry bootstrap needed before pub.dev automated publishing can be enabled. It is not part of normal releases.
