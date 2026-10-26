---
skribble_site: user_feat
---

# Use skribble in Rust and leptoskit apps

A new guide, [Using skribble with leptoskit](https://openbudgetfun.github.io/skribble/guides/leptoskit), introduces two Rust crates in the repository's `rust/` folder. `skribble_rough` is a Rust port of the rough engine that draws byte-identical SVG to the Dart engine. `skribble_leptoskit` builds hand-drawn components on it for [leptoskit](https://github.com/ifiokjr/leptoskit) apps: boxes, cards, circles, badges, buttons, text fields, checkboxes, radios, switches, progress bars, highlights, dividers, and doodles.

On the web the components draw rough ink that follows dark mode. On macOS, iOS, Android, Windows, and Linux they keep the same layout, colours, and line weight with straight lines, because leptoskit cannot draw paths natively yet. Until leptoskit is published, both crates install from Git.
