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

The first public release is pinned to `0.1.0`. Package manifests use the unpublished `0.0.1` development baseline after the `0.0.0` registry placeholders. Monochange replaces that baseline when it prepares the release pull request.

## Record a change

Every releasable pull request needs a file in `.changeset/`. Use the configured Monochange command or follow an existing changeset:

```bash
monochange run document
monochange step validate
monochange check
```

After the pull request merges, the `Release PR` workflow refreshes the long-running `chore/release*` pull request. It prepares package versions and changelogs, then embeds the authoritative release record in the release commit.

The shared CI setup restores `.fvmrc` after FVM selects the pinned SDK, and the storybook ignores Flutter's generated iOS configuration. These keep the checkout clean while Monochange commits the release branch.

## Publish a release

Review and merge the release pull request. The merge starts this sequence:

1. Monochange verifies that `HEAD` is the release-record commit.
2. The release workflow pushes the recorded `v<version>` tag with its scoped GitHub token.
3. It dispatches the trusted pub.dev workflow against that tag. This explicit dispatch is required because GitHub suppresses new workflow runs for ordinary events created by `GITHUB_TOKEN`.
4. Monochange runs publish readiness checks. The workflow also executes `dart pub publish --dry-run` immediately before each real publish.
5. The `publisher` environment publishes four dependency-ordered packages.
6. The `publisher-resume` environment waits four hours, then publishes the remaining three packages from the same dispatched run.
7. Monochange publishes the GitHub release after every package exists on pub.dev.

The two environments keep each registry batch within the project's four-package, four-hour limit. Do not remove the wait timer from `publisher-resume` or combine the batches.

## Recover a partial publish

Rerunning the publish workflow at the release tag is safe at the package step: Monochange checks pub.dev and skips package versions that already exist. Always dispatch it with the release tag as its ref; branch and scheduled runs do not satisfy the trusted-publishing identity.

Each batch uploads its readiness and publication reports for 14 days. Read those artifacts before retrying. Keep the original release tag on the release-record commit.

Useful local checks:

```bash
monochange step validate
monochange check
monochange step prepare-release --dry-run --diff
monochange step placeholder-publish --dry-run --format json
```

`placeholder-publish` is only for the one-time `0.0.0` registry bootstrap needed before pub.dev automated publishing can be enabled. It is not part of normal releases.
