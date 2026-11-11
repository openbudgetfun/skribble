<!-- Shared text for the Rust crates in rust/: their READMEs and the
     leptoskit guide on the docs site. -->

<!-- {@leptoskitInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so `WiredBox` pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/leptoskitInkRoom} -->

<!-- The exact requirement below must stay in step with
      `[workspace.dependencies]` in the root `Cargo.toml`; bump both together. -->

<!-- {@leptoskitPatch} -->

Those requirements are exact because `leptoskit`, `leptoskit_native`, and `leptoskit_testing` 0.3.0 are published on crates.io, and that release is what these crates build and test against. It is tag `v0.3.0` (`2e575b1e7e8100910667e7c2e1472a792d569c95`). The pin lives in `[workspace.dependencies]` in the root [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml); use the same `=0.3.0` requirement for any of those crates you depend on directly so the graph stays on that release. It needs Rust 1.95 or later.

<!-- {/leptoskitPatch} -->
