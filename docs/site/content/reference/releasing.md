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

Those packages use the same version and the release tag `v<version>`. `skribble_maps` is released independently with its own version and the namespaced tag `skribble_maps/v<version>`. It does not belong to the `main` group. Applications, the workspace root, and the documentation site remain private.

`skribble_maps` depends on `skribble`, so Monochange propagates the core package's release severity to it. A breaking `skribble` change therefore produces a breaking `skribble_maps` change, while map-only changes can release without forcing a release of the seven-package group.

The first public release uses a pre-1.0 `major` bump pinned to `0.1.0`. Package manifests use the unpublished `0.0.1` development baseline after the `0.0.0` registry placeholders. Monochange replaces that baseline when it prepares the release pull request.

## Record a change

Every releasable pull request needs a file in `.changeset/`. Use the configured Monochange command or follow an existing changeset:

```bash
monochange run document
monochange step validate
monochange check
```

After the pull request merges, the `Release PR` workflow refreshes the long-running `chore/release*` pull request. It prepares package versions and changelogs, then embeds the authoritative release record in the release commit.

The shared CI setup restores `.fvmrc` after FVM selects the pinned SDK, and the storybook ignores Flutter's generated iOS configuration. These keep the checkout clean while Monochange commits the release branch.

The rough-icon generator exposes parsing and rendering helpers for its tests. The declarations suppress `unreachable_from_main`, while the file suppresses the analyzer's contradictory `unnecessary_ignore` result when those helpers are imported by tests.

## Publish a release

Review and merge the release pull request. The merge starts this sequence:

1. Monochange verifies that `HEAD` is the release-record commit.
2. The release workflow pushes every recorded tag: `v<version>` for the main group and `skribble_maps/v<version>` when the map package is included.
3. It dispatches the trusted pub.dev workflow against each tag in sequence. This explicit dispatch is required because GitHub suppresses new workflow runs for ordinary events created by `GITHUB_TOKEN`.
4. Monochange runs publish readiness checks. The workflow also executes `dart pub publish --dry-run` immediately before each real publish.
5. The `publisher` environment publishes either all seven main-group packages in dependency order or only `skribble_maps`, according to the tag namespace.
6. Monochange publishes the corresponding GitHub release after the selected packages exist on pub.dev.

The rate limit applied only to the packages' first `0.0.0` placeholder publication. Normal version updates do not use the four-hour split or a 12-per-day cap, so the release workflow publishes the complete group in one job.

pub.dev accepts both `push` and `workflow_dispatch` events for every package. The workflow listens for `v*` and `skribble_maps/v*` tag pushes as well as manual dispatches. The release workflow still dispatches the publish workflow explicitly because GitHub does not start a second workflow from a tag created with `GITHUB_TOKEN`.

The pub.dev automated publisher for `skribble_maps` uses repository `openbudgetfun/skribble`, workflow `publish.yml`, GitHub environment `publisher`, and tag pattern `skribble_maps/v{{version}}`. Its `0.0.0` placeholder was published with Monochange before the automated publisher was registered.

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

`placeholder-publish` is only for the one-time `0.0.0` registry bootstrap needed before pub.dev automated publishing can be enabled. It is not part of normal releases. Select a single package with `--package <name>` when bootstrapping a newly independent package.
