---
skribble_leptoskit: patch
skribble_leptoskit_charts: patch
skribble_leptoskit_maps: patch
---

# Pin the Rust crates to LeptosKit 0.3.0

`leptoskit`, `leptoskit_native`, and `leptoskit_testing` are published at 0.3.0, so the workspace requires that release exactly (`=0.3.0`) from crates.io. The published crates are tag `v0.3.0` (`2e575b1e7e8100910667e7c2e1472a792d569c95`). The `[patch.crates-io]` override that followed leptoskit `main` is gone, and the install sections document the same exact requirement. Tests and examples still import skribble's `Theme` and `Camera` by name, and native tests still check that a `WiredBox` and a `Sketch` commit rough `Vector` ink.
