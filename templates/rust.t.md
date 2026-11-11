<!-- Shared text for the Rust crates in rust/: their READMEs and the
     leptoskit guide on the docs site. -->

<!-- {@leptoskitInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so `WiredBox` pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/leptoskitInkRoom} -->

<!-- The git rev below must stay in step with `[workspace.dependencies]`
      in the root `Cargo.toml`; bump both together. -->

<!-- {@leptoskitPatch} -->

These crates build and test against leptoskit `main` at `1f7f1462a17a9a33eccb933909f6cdae20d03052` (`feat: adopt Exact's performance budgets`). The pin is a git dependency on `leptoskit`, `leptoskit_native`, and `leptoskit_testing` in `[workspace.dependencies]` in the root [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml), not a `[patch]` override. Use that same rev for any of those crates you depend on directly so the graph stays on one checkout. It needs Rust 1.95 or later.

<!-- {/leptoskitPatch} -->
