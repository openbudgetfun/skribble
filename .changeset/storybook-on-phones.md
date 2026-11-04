---
skribble_site: fix
---

# The storybook fits phones at large text sizes

A tour of the storybook on an Android emulator, the iOS Simulator, and macOS found pages that broke at 2× text. The emoji page overflowed by 214 pixels because its header did not scroll; it now scrolls as one page, and its category chips no longer clip. Icon names on the glyph page broke mid-word in fixed 64-pixel tiles; the tiles now grow with the text. Pages no longer add the status-bar inset a second time under the ink-style toolbar.

The storybook also gains a device tour, `integration_test/device_tour_test.dart`, which visits every page on a real platform, checks each screen for cramped and squeezed text, and saves the captures on the host.
