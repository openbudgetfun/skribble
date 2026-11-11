---
title: Ink motion
description: Draw borders and hatch fills with standard Flutter animations, cascading motion settings, and reduced-motion support.
---

# Ink motion

Wrap a group of Wired widgets to draw its ink into place. Text, icons, layout, semantics, and hit targets stay stable throughout the reveal.

```dart
// Live example: ink-basic
WiredDraw(
  child: WiredCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Make something lovely'),
    ),
  ),
)
```

`WiredDraw` plays once on mount, over 650 milliseconds. Give it a new key to replay. Entrances are opt-in, so scrolling a normal list does not animate every card. Set `duration` and `curve` when the occasion needs a different pace.

## Try the ink

Replay the entrance, then change the progress value to inspect the outline and shading at your own pace.

```dart
// Live example: ink-reveal
HookBuilder(
  builder: (context) {
    final replay = useState(0);
    return Column(
      children: [
        WiredDraw(
          key: ValueKey(replay.value),
          child: WiredCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Make something lovely'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        WiredOutlinedButton(
          onPressed: () => replay.value++,
          child: const Text('Draw again'),
        ),
      ],
    );
  },
)
```

```dart
// Live example: ink-progress
WiredDrawTransition(
  progress: AlwaysStoppedAnimation(.6),
  child: WiredCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Make something lovely'),
    ),
  ),
)
```

## Own the timing

`WiredDrawTransition` accepts any `Animation<double>`. Zero hides outlines and patterned fill; one completes them. The outline draws first and shading follows with a short overlap. Solid backgrounds stay opaque for readable labels.

```dart
// Static example: custom-class
class NoteState extends State<Note> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final ink = controller.drive(CurveTween(curve: Curves.easeInOutCubic));

  @override
  void initState() {
    super.initState();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) => WiredDrawTransition(
    progress: ink,
    child: WiredCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Hello, tomorrow.'),
      ),
    ),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

Call `controller.forward(from: 0)` to replay, `controller.reverse()` to unwind, or assign `controller.value` to scrub. Nest a transition to give one component its own timing. An `Interval` provides ordinary Flutter staggering:

```dart
// Static example: api
final later = controller.drive(
  CurveTween(curve: Interval(0.2, 1, curve: Curves.easeOutCubic)),
);
WiredDrawTransition(progress: later, child: nextCard);
```

skribble borrows the animation. It never starts, stops, or disposes a controller passed to `WiredDrawTransition`. This also works with route animations and controllers owned by other libraries.

## Flutter hooks

The animation implementation uses Flutter widgets, tickers, and animations. It has no hooks-specific controller or adapter. Existing skribble components still use hooks internally. Consumers using `flutter_hooks` can write:

```dart
// Static example: configuration
final controller = useAnimationController(
  duration: const Duration(milliseconds: 800),
);
useEffect(() {
  controller.forward();
  return null;
}, [controller]);

return WiredDrawTransition(progress: controller, child: notebook);
```

Let the hook dispose its controller. Do not call `forward` directly during every build, and do not manually dispose a hooks-owned controller.

## Spring entrances

`WiredEntrance` brings its child onto the page like a sticker pressed onto paper: it springs up from a little below, small and slightly tilted, fades in, and its ink draws itself on as it lands. `WiredCascade` lays out a column or row of children and brings them in one after another, 70 milliseconds apart.

```dart
// Live example: entrance-cascade
HookBuilder(
  builder: (context) {
    final replay = useState(0);
    final theme = WiredTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredCascade(
          key: ValueKey(replay.value),
          spacing: 12,
          children: [
            for (final (i, plant) in const ['Fern', 'Cactus', 'Basil'].indexed)
              WiredCard(
                height: null,
                color: theme.accentAt(i),
                child: Text(plant),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WiredOutlinedButton(
            onPressed: () => replay.value++,
            child: const Text('Again!'),
          ),
        ),
      ],
    );
  },
)
```

For a lazily built list, wrap each item in `WiredEntrance.staggered(index: i, child: ...)`. Items past the tenth start together, so a long list never keeps its reader waiting. Tune an entrance with `delay`, `duration` (720 milliseconds), `curve` (`WiredCurves.springy`), the starting `offset` (18 pixels below; the x offset flips in RTL), `scale` (0.92), and `turns` (a small anticlockwise tilt), or pass `drawInk: false` to keep the ink still. Layout, semantics, and hit testing never wait: the child has its full size from the first frame and only its paint moves, so taps land even while it is arriving.

## Boiling lines

Hand-drawn animation redraws every frame, so its lines shimmer, or "boil". `WiredBoil` does the same to every Wired outline, hatch, and doodle below it: it redraws them eight times a second, cycling through three drawings of the same shape. Text, layout, and state stay put.

```dart
// Live example: boil-doodle
const WiredBoil(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [
      WiredDoodle(
        kind: WiredDoodleKind.sun,
        size: 72,
        fillColor: WiredPalette.sunshine,
      ),
      WiredDoodle(
        kind: WiredDoodleKind.heart,
        size: 72,
        fillColor: WiredPalette.bubblegum,
      ),
      WiredDoodle(
        kind: WiredDoodleKind.sparkle,
        size: 72,
        fillColor: WiredPalette.sky,
      ),
    ],
  ),
)
```

Every boiling frame rebuilds the subtree's ink, so boil a few focal drawings, such as a logo, an empty state, or a celebration, not a whole screen. Set `framesPerSecond` (12 is livelier) and `drawings`, or toggle `enabled` to boil only while something is hovered or focused. Shapes that choose their own `seed` boil too: `WiredBoil.seedOffsetOf(context)` is the offset they add. Because a boil never ends, tests that use one pump frames for a while instead of `pumpAndSettle`.

## Motion curves

`WiredCurves` holds skribble's timing, for its own widgets and yours:

| Curve                 | Feel                                                                   |
| --------------------- | ---------------------------------------------------------------------- |
| `WiredCurves.pen`     | A hand drawing a line: a quick start, a long glide, and a soft landing |
| `WiredCurves.snappy`  | A firm spring that barely overshoots, for toggles and small controls   |
| `WiredCurves.springy` | A lively spring with a visible overshoot; the entrance default         |
| `WiredCurves.bouncy`  | A playful spring that bounces past its target, for celebrations        |

```dart
// Static example: configuration
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: WiredCurves.springy,
  height: expanded ? 240 : 120,
  child: card,
)
```

The springs are `WiredSpringCurve`s: the step response of a damped spring, tuned to settle exactly at one when the animation ends, so the same spring feels right at any duration. Make your own with `WiredSpringCurve(bounce: 0.25)`. Springs overshoot one on the way, so use them for position, size, scale, and rotation, not opacity.

## Highlights

`WiredHighlight` swipes a highlighter behind a word, or draws a pen stroke under it, and draws itself on when it appears. See [Vivid and alive](/guides/vivid-design#highlight-what-matters) for a live example. Its child is inked to stay legible on the swipe in light and dark themes. Inside a `WiredEntrance` or `WiredDraw`, pass `animate: false` to follow their timing.

## Turn motion off

At the app root:

```dart
// Static example: setup
WiredMaterialApp(
  wiredTheme: WiredThemeData(motionEnabled: false),
  home: notebook,
)
```

For one section:

```dart
// Static example: setup
WiredMotion(enabled: false, child: notebook)
```

A disabled ancestor wins over nested enabled scopes. The platform's `MediaQuery.disableAnimations` also settles ink immediately: entrances appear in place, boiling stops on the usual drawing, and highlights are drawn at once. Turning motion back on does not replay an implicit entrance that has already settled. This setting controls skribble's decorative ink. Consumer animations and existing functional animations such as progress indicators keep their own policies.

`TickerMode` mutes owned tickers. Paint listeners detach from external animations while the subtree is muted, then resume at the caller's current value. skribble does not pause the caller's controller.

## Interaction feedback

`WiredButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredElevatedButton`, `WiredTextButton`, and `WiredIconButton` gently reinforce the pen on hover, keyboard focus, and press. The stroke grows by up to 25% over 120 milliseconds and relaxes when the state ends. The seed and label position stay fixed. Disabled controls remain idle. Motion-off and reduced motion remove this decorative response while preserving the control's normal focus and activation behavior.

## Custom drawing

Built-in `WiredCanvas` shapes and Wired rough decorations inherit the reveal. SVG icons, font glyphs, Material internals, and legacy imperative custom painters remain static. A drawing scope does not animate every visual in an app.

For custom decorations, resolve the ambient policy at the widget boundary:

```dart
// Static example: configuration
RoughBoxDecoration(
  progress: WiredDrawTransition.progressOf(context),
  borderStyle: RoughDrawingStyle(width: 2.4, color: inkColor),
)
```

Low-level `RoughBoxDecoration` and the internal `WiredPainter` adapter that `WiredCanvas` creates accept a borrowed `progress` and `pressure`. They have no `BuildContext` and cannot discover accessibility policy by themselves. A null progress means complete; null pressure means idle.

Custom `WiredPainterBase` implementations can override `prepare` to return a `RoughDrawing`. Keep the existing `paintRough` method for direct callers. Prepared paths and contour lengths are cached per painter and size. Animation ticks repaint without rebuilding children or regenerating rough geometry. Elastic progress is clamped to zero through one; non-finite progress settles at complete. `RoughDrawing.paint` also takes an `outlineColor`, so a prepared drawing can follow a color animation, such as a focus fade, without regenerating. Painters cache per instance; the one shared cache holds the outlines of `RoughOutlinedBorder` and the rough input border, keyed by size, pen width, corner radii, and seed, never by color.

## Choose how buttons respond

`WiredInkInteraction` controls decorative button feedback. The default is `pressure`: existing strokes become a little stronger on hover, keyboard focus, and press. `redraw` also traces the outline and patterned fill over 360 milliseconds when a press begins. `none` keeps the ink still.

```dart
// Static example: configuration
WiredThemeData(
  roughnessLevel: WiredRoughness.gentle,
  inkInteraction: WiredInkInteraction.redraw,
)
```

A button can override the surrounding theme:

```dart
// Live example: redraw-button
WiredFilledButton(
  inkInteraction: WiredInkInteraction.redraw,
  fillColor: const Color(0xffff6b4a),
  borderRadius: BorderRadius.circular(8),
  onPressed: () {},
  child: Text('Make something lovely'),
)
```

This option is available on `WiredButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredElevatedButton`, `WiredTextButton`, and `WiredIconButton`. Each control retains its normal gestures, keyboard behavior, and callback. Repeated presses restart the trace without changing its deterministic geometry. Solid fills stay opaque, and labels stay still. A surrounding draw transition limits how much ink an interaction may reveal.

Use redraw for a few meaningful actions; pressure is a quieter default for dense toolbars. `WiredMotion(enabled: false)`, `WiredThemeData(motionEnabled: false)`, muted tickers, and platform reduced motion settle the decoration. Consumer-owned controllers remain consumer-owned, including controllers supplied by Flutter hooks.

## Static design handoff

The [design kit](../reference/design-kit) exports resting and pressed button ink with identical paths and layout bounds. Its manifest maps reduced motion to the completed resting specimen. Use those files when prototyping the 120 ms pressure response or the 650 ms entry reveal. Keep labels, solid backgrounds, focus indication, and hit regions available throughout.

## Repeating loading ink

[Loaders and skeletons](/widgets/loading) use a shared internal clock that stops when `WiredMotion` is disabled, the platform requests reduced motion, or `TickerMode` is muted. They settle to a visible pose. `WiredLoader.progress` can borrow an ordinary animation; its owner retains control and ownership, while the painter detaches from ticks when motion is disabled. Geometry stays cached across ticks. Skeleton overlays also mute the hidden child's tickers until loading finishes.
