---
skribble: none
---

# Keep the release PR branch prefix stable across releases

The release PR branch prefix moved back to `chore/release` after the `monochange/release` rename orphaned the long-running release pull request: Monochange could no longer find it, so it tried to create a replacement PR whose generated body — the full changelog of every pending `0.1.0` changeset — exceeded GitHub's 65536-character pull request body limit, failing the `Release PR` workflow on every push to `main`. The prefix can only change while no release PR is open, ideally after a release consumes the pending changesets so the first PR under the new prefix is created from a small body. The attribution step in the release workflow and the releasing documentation were reverted to match.
