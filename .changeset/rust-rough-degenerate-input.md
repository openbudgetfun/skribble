---
skribble_site: fix
---

# skribble_rough finishes on empty arcs and zero-length dashes

The Rust engine in `rust/rough` takes the Dart engine's arc fix, so the three engines agree again: an arc whose sweep is empty, reversed, or not finite draws nothing and runs no filler, where it drew a stub before, and a start angle far below zero is normalised in one step instead of a turn at a time. A `Generator` used directly also finishes for a sweep a hair above zero, a huge `curve_step_count`, an infinite edge (no ink, no hachure), and a `dashed` fill whose `dash_offset` and `dash_gap` add up to less than 0.1 (undashed hachure). A negative `rounded_rectangle` keeps square corners. Ordinary shapes draw exactly as before, and the parity tests still match the Dart fixtures byte for byte.
