# Ink motion design

## Caller usage

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(motionEnabled: true),
  home: WiredDraw(child: WiredCard(child: Text('A little magic'))),
);

// The caller owns this ordinary Flutter animation.
WiredDrawTransition(progress: controller, child: notebook);

// A subtree can opt out. A disabled ancestor cannot be overridden.
WiredMotion(enabled: false, child: notebook);
```

## Grounding

`WiredCard` and most shapes compose `WiredCanvas`, `WiredPainter`, and a `WiredPainterBase`. Buttons and several controls construct `RoughBoxDecoration`. Both paths call `Generator` to produce a `Drawable` containing outline, solid-fill, and sketch-fill operation sets. Previously both rendering paths regenerated these operations during every paint.

The shared drawing layer owns path conversion and measured pen distance. The canvas painter and decoration painter each own a size-dependent cache. The widget layer resolves animation policy and passes a borrowed paint signal. Text, layout, focus, hit testing, and semantic content remain with the component.

## Alternatives and synthesis

Two independent design candidates compared explicit animation parameters on individual controls against an inherited drawing transition. The explicit candidate makes per-control choreography visible, but repeats parameters across the component library and makes whole-card entrances cumbersome. The subtree candidate gives consumers one opt-in wrapper and supports local overrides.

We chose the subtree transition, with public low-level animation parameters on `WiredPainter` and `RoughBoxDecoration` for custom rendering. There is no motion configuration object, custom controller, scheduler, or hooks adapter. `Animation<double>` already provides ownership, reversal, curves, intervals, route integration, and hooks interoperability.

The architecture skill's arena runner was unavailable in this environment. Two read-only design agents supplied the distinct candidates directly.

## Rendering contract

`RoughDrawing` snapshots paths and paints. It measures contours lazily, once, then extracts cumulative prefixes in generated pen order. The outline occupies 0–65% of the timeline; hatch strokes overlap from 30–100%. Paint order remains fill below outline. Solid backgrounds stay complete throughout to keep label contrast. A partial solid path would produce wedges, and fading a dark button background would leave a white label unreadable.

Pressure increases stroke width by up to 25% over 120 milliseconds. Button geometry and seeds stay fixed. Flutter's `WidgetStatesController` supplies hover, keyboard focus, pressed, and disabled state. No extra gesture detector competes with the control. There is no repeating wobble or label displacement.

`WiredPainterBase.prepare` is optional. Existing custom imperative painters continue working, with static output until they opt into prepared ink. This preserves the public painter protocol.

## Lifecycle and accessibility

`WiredDraw` owns a standard `AnimationController` with a ticker provider. `WiredDrawTransition` borrows its animation and never starts, stops, or disposes it. It inherits the animation identity, not its current value. Paint listeners therefore update frames without rebuilding or relaying out children. Decoration painters detach listeners on disposal. Muted subtrees detach from external paint signals; owned tickers follow Flutter's `TickerMode` behavior.

A disabled theme, disabled motion boundary, or platform reduced-motion setting settles ink immediately. Re-enabling motion does not replay a completed implicit entrance. Consumer controllers remain under consumer control.

The new motion implementation uses standard Flutter state/ticker classes with no hooks imports. This follows the user's explicit requirement for independent Flutter animation primitives. Existing component HookWidgets remain unchanged in that respect. It is a scoped exception to the older hooks-only convention.

## Verification contract

Pixel tests compare static and completed geometry, partial paths, hatch timing, reverse replay, and solid fill contrast. Lifecycle tests exercise borrowed controllers, nested policy, dynamic reduced motion, ticker muting, geometry caching, and stable child builds. Interaction tests cover mouse, keyboard, disabled state, cancellation, and rapid changes. The storybook demonstrates replay, reversal, precise progress, and global opt-out on phone and desktop. Patrol drives those controls in a real browser; captured frames document the visual result.

The expansion-panel tests also open, close, and rapidly toggle panels while ink is hidden or motion is disabled. Paginated-table coverage lives alongside the ordinary table tests in `test/widgets/wired_data_table_test.dart`; it exercises page changes, source notifications, empty data, semantic labels, and usable pagination during a reveal. These transitional components are tested through their source imports without adding new public exports. An inactive expansion header now honors `canTapOnHeader: false`; a labeled Wired icon button still opens and closes its panel. The regression test first reproduced the ignored setting, then verified both the inactive header and the button's callbacks.

## Flutter references

[CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) accepts a repaint listenable so animation can bypass build and layout. [AnimationController](https://api.flutter.dev/flutter/animation/AnimationController-class.html) documents ticker ownership and `TickerMode` behavior. [AnimationBehavior](https://api.flutter.dev/flutter/animation/AnimationBehavior.html) describes platform reduced-motion behavior; decorative ink additionally settles immediately through Skribble's policy.
