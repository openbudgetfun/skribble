---
title: What's new
description: What changed on skribble.dev, release by release.
---

# What's new

What changed on skribble.dev, newest first. These notes come from the website's user-facing changesets and are added when the website is released. The packages keep their own changelogs: see the [releases on GitHub](https://github.com/openbudgetfun/skribble/releases).

## [1.0.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_site/v1.0.0) (2026-10-27)

### Features

#### Use skribble in Rust and leptoskit apps

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #270](https://github.com/openbudgetfun/skribble/pull/270)

A new guide, [Using skribble with leptoskit](https://openbudgetfun.github.io/skribble/guides/leptoskit), introduces two Rust crates in the repository's `rust/` folder. `skribble_rough` is a Rust port of the rough engine that draws byte-identical SVG to the Dart engine. `skribble_leptoskit` builds hand-drawn components on it for [leptoskit](https://github.com/ifiokjr/leptoskit) apps: boxes, cards, circles, badges, buttons, text fields, checkboxes, radios, switches, progress bars, highlights, dividers, and doodles.

On the web the components draw rough ink that follows dark mode. On macOS, iOS, Android, Windows, and Linux they keep the same layout, colours, and line weight with straight lines, because leptoskit cannot draw paths natively yet. Until leptoskit is published, both crates install from Git.

- **skribble.dev shows the chart and map packages.** The landing page has a new "Charts and maps" section. It shows a hand-drawn candlestick chart from `skribble_charts` and a map with sketched pins, a route, and an area from `skribble_maps`, and links to the live examples in the docs. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #272](https://github.com/openbudgetfun/skribble/pull/272)
- **skribble.dev is lettered in Noto Sketch and shares as a picture.** The landing page and the documentation now use Skribble Noto Sketch, skribble's default typeface, for their text and headings. Links to skribble.dev or any docs page now preview as a large card with the page's own title and description and a hand-drawn image of skribble. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #262](https://github.com/openbudgetfun/skribble/pull/262)
- **See what changed on skribble.dev.** The footer of skribble.dev now links to a What's new page in the documentation. Every website release adds a short note there about what visitors can now see or try, newest first, starting with this first numbered release of skribble.dev. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #259](https://github.com/openbudgetfun/skribble/pull/259)
