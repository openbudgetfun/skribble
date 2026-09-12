---
title: Loaders and skeletons
description: Animated ink, moving doodles, and pencil-hatched skeletons for loading states.
---

# Loaders and skeletons

Use `WiredLoader` for an unknown wait, `WiredSkeleton` to reserve space, and `WiredSkeletonOverlay` to retain a component's layout while hiding its content. For known completion percentages, use [progress indicators](/widgets/feedback).

## Choose a rhythm

| Style      | Drawing                            | Suggested use              |
| ---------- | ---------------------------------- | -------------------------- |
| `orbit`    | Uneven ring and travelling pen tip | Compact general loading    |
| `dots`     | Three hopping ink dots             | Replies and inline status  |
| `bars`     | Five bowed pencil strokes          | Processing a file          |
| `ripple`   | Soft expanding contour rings       | Quiet background waits     |
| `flower`   | Rotating flower doodle             | A friendly empty panel     |
| `scribble` | A loop drawing and erasing itself  | Sketches and creative work |

The collection takes inspiration from the variety in [react-native-indicators](https://github.com/n4kz/react-native-indicators). These are original Flutter drawings and animations; flower and scribble reuse Skribble's existing seeded flourish geometry.

```dart
// Static example: api
WiredLoader(
  style: WiredLoaderStyle.scribble,
  size: 56,
  duration: Duration(milliseconds: 2400),
  seed: 8,
  semanticLabel: 'Preparing your sketch',
)
```

`color` defaults to the theme's text color. `strokeWidth` defaults to 2 logical pixels at the requested size. Smaller parent bounds scale the drawing proportionally. `seed` changes the curves without making them jitter on every frame.

Pass a caller-owned `Animation<double>` as `progress` to coordinate several loaders. Its phase runs from 0 to 1 for a complete loop; values outside that range clamp to the endpoints. The loader does not start, stop, or dispose a borrowed animation. Without one it owns a repeating clock. `duration` must be positive.

`animating: false`, `WiredMotion(enabled: false)`, the platform's reduced-motion preference, and muted `TickerMode` settle the drawing to a visible fixed pose and stop its own clock. External animations detach from painting while settled. Remove the loader when work finishes. A pause does not imply completion.

The existing `WiredLoadingIndicator` now uses the orbit renderer and inherits these motion policies, retaining its size, color, and stroke-width parameters.

## Pencil skeletons

```dart
// Static example: api
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    WiredSkeleton(width: 180, height: 20),
    SizedBox(height: 12),
    WiredSkeleton(width: 240, height: 14),
    SizedBox(height: 8),
    WiredSkeleton(width: 160, height: 14),
  ],
)
```

Set `borderRadius` for rounded blocks or a circular avatar. `color` supplies ink at low opacity. Hatching stays stationary and slowly changes opacity. `animating: false` and the shared motion policies keep it still. A null width follows the parent; a null height fills a bounded parent's height. Give standalone placeholders explicit dimensions when the parent does not constrain them.

## Preserve a component's layout

```dart
// Static example: api
WiredSkeletonOverlay(
  loading: isLoading,
  semanticLabel: 'Loading account details',
  skeleton: const WiredSkeleton(height: null),
  child: accountCard,
)
```

The overlay measures the real child and fits the skeleton into the same bounds. It retains the child's mounted state. During loading it hides the child and excludes its pointer input, focus, semantics, and tickers. Loading completion restores the child without replacing its element. Focus is not automatically restored. The default placeholder is a single hatched block; pass a row or column of skeletons to match structured content, as in the live card above. This is an explicit placeholder layout, not automatic text or image detection.

## Accessible status

Loaders and overlays announce a stable, localizable `semanticLabel` in a live region. Animation frames never announce percentages for an unknown wait. Use null on decorative loaders beside an already labelled status message. Individual skeleton blocks are silent. Reduced motion leaves a visible loading cue, so always pair long waits with useful status text and offer cancellation where your task supports it.
