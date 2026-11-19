---
title: Using skribble with leptoskit (Rust)
description: leptoskit apps get skribble's hand-drawn components, charts, and maps from leptoskit's own leptoskit_skribble crate, built on skribble_core.
---

# Using skribble with leptoskit (Rust)

[leptoskit](https://github.com/leptoskit/leptoskit) lets you write an app's interface once in Rust and render it on the web and as native widgets on macOS, iOS, Android, Windows, and Linux. Its [`leptoskit_skribble`](https://github.com/leptoskit/leptoskit/tree/main/crates/leptoskit_skribble) crate gives that interface skribble's hand-drawn look: rough borders, sketched fills, pen marks around text, scribbles, charts, and maps, drawn with leptoskit's `Vector` element on every platform.

The integration lives in the leptoskit repository so it can follow leptoskit's fast-moving API, and it builds on [`skribble_core`](rust), skribble's framework-free design system for Rust. skribble supplies the colours, the component ink, the charts, and the maps; leptoskit turns them into components.

## Moving from `skribble_leptoskit`

The `skribble_leptoskit`, `skribble_leptoskit_charts`, and `skribble_leptoskit_maps` crates published from this repository are replaced by `leptoskit_skribble`. The components keep their names, so most apps only change their imports:

| Before                                | After                                  |
| ------------------------------------- | -------------------------------------- |
| `use skribble_leptoskit::*;`          | `use leptoskit_skribble::*;`           |
| `use skribble_leptoskit_charts::...;` | `use leptoskit_skribble::charts::...;` |
| `use skribble_leptoskit_maps::...;`   | `use leptoskit_skribble::maps::...;`   |
| `skribble_leptoskit::colorway`        | `skribble_core::colorway`              |

Colours are now `skribble_core::colorway::Rgba` values everywhere a `Tone` or `Palette` takes one, so there is no `color(rgba)` conversion to make.
