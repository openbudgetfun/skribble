---
skribble_rough: none
---

# Add parity fixtures for the npm rough engine

`tool/js_parity_fixtures.dart` writes hashed SVG output for every shape, fill style, and pen, plus Dart's `Random(seed)` stream. The new `@skribble.dev/rough` npm package replays these fixtures in its tests and must draw byte-identical SVG, so the JavaScript port and this engine stay in step. The package's public API is unchanged.
