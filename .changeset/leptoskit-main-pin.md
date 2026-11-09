---
skribble_leptoskit: patch
skribble_leptoskit_charts: patch
skribble_leptoskit_maps: patch
---

# Build and test the Rust crates against leptoskit main

The Rust crates keep their crates.io version requirements for leptoskit, so consumers stay free to choose their own leptoskit commit, but the workspace now pins the leptoskit crates it uses to a `main` commit through a `[patch.crates-io]` section in the root `Cargo.toml`, and its builds and tests run against that commit. `main` is ahead of the published 0.3 releases: new widgets and exports there collided with names these crates also export through glob imports (`Camera`, `Theme`), so tests and examples now import the skribble names explicitly, and everything builds and passes against the pinned rev.

The patch lives in the workspace root, and cargo applies `[patch]` sections only from the workspace root, so the pinned commit does not follow a consumer's build on its own. Every install section now documents the `[patch.crates-io]` entries a consumer adds to their own root manifest, shared through one MDT block: `leptoskit`, `leptoskit_native`, and `leptoskit_testing` at the same rev the skribble commit they depend on pins. The stale `ifiokjr/leptoskit` links are replaced with the repository's new `leptoskit/leptoskit` home.

New tests cover the native drawing path through leptoskit's real renderer: a `WiredBox` commits a stretched `Vector` whose rough path repeats for a seed and changes with it, and a `Sketch` commits a fitted `Vector` drawing its doodle, so it is no longer empty on native.
