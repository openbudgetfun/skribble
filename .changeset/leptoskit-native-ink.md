---
skribble_leptoskit: minor
skribble_rough_rs: minor
---

# Draw skribble_leptoskit ink natively on leptoskit 0.3

`skribble_leptoskit` now builds on leptoskit 0.3 from crates.io and draws its ink with leptoskit's `Vector` element, which the web renderer shows as inline SVG and every native backend (macOS, iOS, Android, Windows, Linux) draws with its own path API. Native apps get the same rough borders, sketched fills, and ticks as the web, and `Sketch` draws on native too. Ink paints with the element's text colour, so `dark:` classes recolour it on every platform.

The `web` feature is gone: there is nothing to turn on. `skribble_rough` and `skribble_leptoskit` are now published to crates.io and release together under `rust/v<version>` tags.
