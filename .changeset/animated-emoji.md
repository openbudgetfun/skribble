---
skribble_emoji: minor
---

# Animated emoji, and emoji outside Flutter

`WiredAnimatedEmoji` brings an emoji to life: its parts move and its lines boil, retraced eight times a second by a fresh hand like a hand-drawn cartoon. The most-used emoji have their own choreography (a heart beats, a hand waves around its wrist, a flame flickers, tears fall and fade), and every other emoji moves with its family. Motion follows `WiredMotion`, the platform's reduced-motion setting, and `TickerMode`, showing the emoji at rest when motion is off, and `loops` plays a reaction a set number of times before it rests.

```dart
const WiredAnimatedEmoji('❤️', size: 48);

const wave = EmojiMotion([
  EmojiTrack('hand', EmojiMove.wave(swings: 3), pivot: Alignment(0, .8)),
]);
const WiredAnimatedEmoji('👋', motion: wave);
```

`EmojiMotion`, `EmojiTrack`, `EmojiMove`, and `EmojiPose` describe motion, and `EmojiMotions.of` gives skribble's own. `EmojiDrawing` gains `inking` (a retraced inking of the same shapes), `boundsOf(part)`, and per-part `opacity` when painting.

`EmojiVector` exposes the same inked geometry as SVG path data, with `toSvg()`, and `package:skribble_emoji/lottie.dart` exports `emojiLottie`, which builds a Lottie animation of an emoji's motion and boil for lottie-web and the iOS and Android players. Releases attach the choreographed emoji as `skribble-emoji-lottie.zip`.
