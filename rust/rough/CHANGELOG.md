# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.0) (2026-11-07)

### Features

#### Draw skribble_leptoskit ink natively on leptoskit 0.3

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/skribble/pull/277)

`skribble_leptoskit` now builds on leptoskit 0.3 from crates.io and draws its ink with leptoskit's `Vector` element, which the web renderer shows as inline SVG and every native backend (macOS, iOS, Android, Windows, Linux) draws with its own path API. Native apps get the same rough borders, sketched fills, and ticks as the web, and `Sketch` draws on native too. Ink paints with the element's text colour, so `dark:` classes recolour it on every platform.

The `web` feature is gone: there is nothing to turn on. `skribble_rough` and `skribble_leptoskit` are now published to crates.io and release together under `rust/v<version>` tags.
