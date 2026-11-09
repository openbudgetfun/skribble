<!-- Shared text for the Rust crates in rust/: their READMEs and the
     leptoskit guide on the docs site. -->

<!-- {@leptoskitInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so `WiredBox` pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/leptoskitInkRoom} -->

<!-- The pinned rev below must stay in step with the `[patch.crates-io]`
      section in the root `Cargo.toml`; bump both together. -->

<!-- {@leptoskitPatch} -->

The leptoskit requirements above stay crates.io ranges so you stay free to choose your own leptoskit commit, but the skribble Rust crates build and test against leptoskit's `main`, which runs ahead of the 0.3 releases on crates.io. Bring the same commit into your build with a `[patch.crates-io]` section in your root `Cargo.toml`: cargo applies `[patch]` sections only from the workspace root, so a patch inside a dependency never reaches you. Keep every entry at the same rev, in step with the rev pinned in [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml) at the root of the skribble repository at the commit you depend on, and give any leptoskit crate you depend on directly that same rev, so the graph holds one leptoskit checkout. The rev below needs Rust 1.95 or later.

```toml
[patch.crates-io]
leptoskit = { git = "https://github.com/leptoskit/leptoskit", rev = "c0c5013b708e17723cb48062036b40f22f694a57" }
leptoskit_native = { git = "https://github.com/leptoskit/leptoskit", rev = "c0c5013b708e17723cb48062036b40f22f694a57" }
leptoskit_testing = { git = "https://github.com/leptoskit/leptoskit", rev = "c0c5013b708e17723cb48062036b40f22f694a57" }
```

<!-- {/leptoskitPatch} -->
