---
skribble_emoji: patch
skribble_icons: patch
---

# Decorative emoji can stay out of semantics, and both packages ship an example

- `WiredEmoji` and `WiredAnimatedEmoji` treat `semanticLabel: ''` as decorative and leave the emoji out of semantics. Before, an empty label still added an unlabelled image node, so an emoji beside text that already said the same thing was announced as a blank image.
- Text that is not a known emoji now keeps a custom `semanticLabel`, which the plain-text fallback used to drop.
- `skribble_emoji` and `skribble_icons` add a runnable `example/example.dart`, each covered by a smoke test.
