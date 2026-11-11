---
skribble_leptoskit: patch
skribble_leptoskit_charts: patch
skribble_leptoskit_maps: patch
---

# Pin the Rust crates to a leptoskit main commit

`leptoskit`, `leptoskit_native`, and `leptoskit_testing` are git dependencies in `[workspace.dependencies]`, all at `1f7f1462a17a9a33eccb933909f6cdae20d03052` (`https://github.com/leptoskit/leptoskit`, `feat: adopt Exact's performance budgets`). That commit is ahead of the 0.3.0 crates.io release, so the workspace no longer requires `=0.3.0` and does not use a `[patch]` override. Install sections document the same rev. Tests and examples still import skribble's `Theme` and `Camera` by name, and native tests still check that a `WiredBox` and a `Sketch` commit rough `Vector` ink.
