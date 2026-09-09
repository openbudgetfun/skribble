---
title: Ink motion
description: Draw borders and hatch fills with standard Flutter animations, cascading motion settings, and reduced-motion support.
---

# Ink motion

Wrap a group of Wired widgets to draw its ink into place. Text, icons, layout, semantics, and hit targets stay stable throughout the reveal.

```dart
WiredDraw(
  child: WiredCard(
    child: Text('Make something worth keeping.'),
  ),
)
```

`WiredDraw` plays once on mount, over 650 milliseconds. Give it a new key to replay. Entrances are opt-in, so scrolling a normal list does not animate every card. Set `duration` and `curve` when the occasion needs a different pace.

## Own the timing

`WiredDrawTransition` accepts any `Animation<double>`. Zero hides outlines and patterned fill; one completes them. The outline draws first and shading follows with a short overlap. Solid backgrounds stay opaque for readable labels.

```dart
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
    child: WiredCard(child: Text('Hello, tomorrow.')),
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
final later = controller.drive(
  CurveTween(curve: Interval(0.2, 1, curve: Curves.easeOutCubic)),
);
WiredDrawTransition(progress: later, child: nextCard);
```

Skribble borrows the animation. It never starts, stops, or disposes a controller passed to `WiredDrawTransition`. This also works with route animations and controllers owned by other libraries.

## Flutter hooks

The animation implementation uses Flutter widgets, tickers, and animations. It has no hooks-specific controller or adapter. Existing Skribble components still use hooks internally. Consumers using `flutter_hooks` can write:

```dart
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

## Turn motion off

At the app root:

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(motionEnabled: false),
  home: notebook,
)
```

For one section:

```dart
WiredMotion(enabled: false, child: notebook)
```

A disabled ancestor wins over nested enabled scopes. The platform's `MediaQuery.disableAnimations` also settles ink immediately. Turning motion back on does not replay an implicit entrance that has already settled. This setting controls Skribble's decorative ink. Consumer animations and existing functional animations such as progress indicators keep their own policies.

`TickerMode` mutes owned tickers. Paint listeners detach from external animations while the subtree is muted, then resume at the caller's current value. Skribble does not pause the caller's controller.

## Interaction feedback

`WiredButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredElevatedButton`, `WiredTextButton`, and `WiredIconButton` gently reinforce the pen on hover, keyboard focus, and press. The stroke grows by up to 25% over 120 milliseconds and relaxes when the state ends. The seed and label position stay fixed. Disabled controls remain idle. Motion-off and reduced motion remove this decorative response while preserving the control's normal focus and activation behavior.

## Custom drawing

Built-in `WiredCanvas` shapes and Wired rough decorations inherit the reveal. SVG icons, font glyphs, Material internals, and legacy imperative custom painters remain static. A drawing scope does not animate every visual in an app.

For custom decorations, resolve the ambient policy at the widget boundary:

```dart
RoughBoxDecoration(
  progress: WiredDrawTransition.progressOf(context),
  borderStyle: RoughDrawingStyle(width: 2.4, color: inkColor),
)
```

Low-level `RoughBoxDecoration` and `WiredPainter` accept a borrowed `progress` and `pressure`. They have no `BuildContext` and cannot discover accessibility policy by themselves. A null progress means complete; null pressure means idle.

Custom `WiredPainterBase` implementations can override `prepare` to return a `RoughDrawing`. Keep the existing `paintRough` method for direct callers. Prepared paths and contour lengths are cached per painter and size. Animation ticks repaint without rebuilding children or regenerating rough geometry. Elastic progress is clamped to zero through one; non-finite progress settles at complete. There is no global geometry cache.

## Choose how buttons respond

`WiredInkInteraction` controls decorative button feedback. The default is `pressure`: existing strokes become a little stronger on hover, keyboard focus, and press. `redraw` also traces the outline and patterned fill over 360 milliseconds when a press begins. `none` keeps the ink still.

```dart
WiredThemeData(
  roughnessLevel: WiredRoughness.gentle,
  inkInteraction: WiredInkInteraction.redraw,
)
```

A button can override the surrounding theme:

```dart
WiredFilledButton(
  inkInteraction: WiredInkInteraction.redraw,
  fillColor: Color(0xffe87960),
  onPressed: saveIdea,
  child: Text('Keep this little idea'),
)
```

This option is available on `WiredButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredElevatedButton`, `WiredTextButton`, and `WiredIconButton`. Each control retains its normal gestures, keyboard behavior, and callback. Repeated presses restart the trace without changing its deterministic geometry. Solid fills stay opaque, and labels stay still. A surrounding draw transition limits how much ink an interaction may reveal.

Use redraw for a few meaningful actions; pressure is a quieter default for dense toolbars. `WiredMotion(enabled: false)`, `WiredThemeData(motionEnabled: false)`, muted tickers, and platform reduced motion settle the decoration. Consumer-owned controllers remain consumer-owned, including controllers supplied by Flutter hooks.
