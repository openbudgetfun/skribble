---
title: Buttons
description: Hand-drawn button widgets for actions, toggles, and segmented controls in skribble.
---

# Buttons

skribble provides a full set of button widgets that replace their Material and Cupertino counterparts with sketchy, hand-drawn borders, hachure fills, and wobbly outlines. Every button reads its palette from `WiredTheme.of(context)` and extends `HookWidget`.

---

## WiredButton

A basic button with a hand-drawn rectangle border. The simplest entry point for actions.

<!-- {=docsButtonBasicUsage} -->

```dart
// Live example: button
WiredButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: () {},
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

<!-- {/docsButtonBasicUsage} -->

### Constructor parameters

| Parameter       | Type               | Default                                 | Description                                                      |
| --------------- | ------------------ | --------------------------------------- | ---------------------------------------------------------------- |
| `borderRadius`  | `BorderRadius`     | `BorderRadius.all(Radius.circular(10))` | Rough corner radii; use zero for square corners.                 |
| `child`         | `Widget`           | **required**                            | The button label.                                                |
| `onPressed`     | `void Function()?` | `null`                                  | Callback when the button is tapped; `null` disables the button.  |
| `semanticLabel` | `String?`          | `null`                                  | Accessibility label exposed to screen readers.                   |
| `seed`          | `int?`             | `null`                                  | Varies the hand behind the ink; give neighbours different seeds. |

### Notes

- Rectangular buttons are at least `kWiredButtonHeight` (42) tall and grow with their label, keeping `kWiredButtonPadding` (16 at the sides, 8 above and below) between the ink and the text at any font size or text scale. The padding is the same on every platform: Material's compact desktop density no longer takes 8 pixels off it on macOS, Windows, and Linux.
- Every button is one semantics node: a button with its enabled state, tap and focus actions, and a label. `semanticLabel` replaces the label text rather than being read alongside it.
- `WiredElevatedButton` and `WiredFilledButton` take the same `seed`, as `WiredOutlinedButton` already did.
- The border is drawn with a `RoughBoxDecoration` using the theme's `borderColor`.
- Text color inherits from `theme.textColor`.
- Pass `onPressed: null` to disable the button. Taps are ignored and the label renders with `theme.disabledTextColor`, matching `WiredFilledButton` and the other rectangular button variants.

---

## WiredElevatedButton

An elevated variant: a solid paper face over a lightly pencilled offset shadow. The shadow's hachure is drawn at 40% of the border colour, so the button lifts without a heavy dark slab.

```dart
// Live example: elevated-button
WiredElevatedButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: true ? () {} : null,
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

### Constructor parameters

| Parameter       | Type            | Default                                 | Description                                       |
| --------------- | --------------- | --------------------------------------- | ------------------------------------------------- |
| `borderRadius`  | `BorderRadius`  | `BorderRadius.all(Radius.circular(10))` | Rough corner radii; use zero for square corners.  |
| `child`         | `Widget`        | **required**                            | The button label.                                 |
| `onPressed`     | `VoidCallback?` | `null`                                  | Callback when tapped. `null` disables the button. |
| `semanticLabel` | `String?`       | `null`                                  | Accessibility label.                              |

### Notes

- The shadow offset is 2 logical pixels down and right.
- Both shadow and face use `HachureFiller` with different gap values for depth.

---

## WiredFilledButton

A button coloured in with the theme's highlighter, analogous to Material's `FilledButton`. Good for primary call-to-action placement. By default it is filled with the theme's `accentColor` (tomato in the sunny colourway), the one loud thing on the screen to press, and labelled in whichever of ink or paper reads better on it. Pass `fillColor` for another colour, such as `theme.accentAt(2)`.

```dart
// Live example: filled-button
WiredFilledButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: true ? () {} : null,
  fillColor: const Color(0xffff6b4a),
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

### Constructor parameters

| Parameter         | Type            | Default                                 | Description                                                                                            |
| ----------------- | --------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `borderRadius`    | `BorderRadius`  | `BorderRadius.all(Radius.circular(10))` | Rough corner radii; use zero for square corners.                                                       |
| `child`           | `Widget`        | **required**                            | The button label.                                                                                      |
| `onPressed`       | `VoidCallback?` | `null`                                  | Callback when tapped.                                                                                  |
| `fillColor`       | `Color?`        | `null`                                  | Custom fill color. Defaults to `theme.accentColor`.                                                    |
| `foregroundColor` | `Color?`        | `null`                                  | Text/icon color. Defaults to the theme's text or paper colour, whichever contrasts more with the fill. |
| `semanticLabel`   | `String?`       | `null`                                  | Accessibility label.                                                                                   |

### Notes

- The solid fill keeps the label readable and retains a small, uneven overlap along the outline.
- When `fillColor` is not provided the button uses `theme.accentColor`. Earlier versions washed it with `theme.markerColor`; pass `fillColor: theme.markerColor` to keep that softer look.
- Give each screen one filled button, and use `WiredOutlinedButton` or `WiredTextButton` for the rest. See [Vivid and alive](/guides/vivid-design).

---

## WiredFloatingActionButton

A circular floating action button: a hand-drawn circle filled with `theme.accentColor`, with its icon in `theme.onAccentColor`. Designed for primary screen actions. Mirrors Material's `FloatingActionButton`, including the small, large, and extended forms.

```dart
// Live example: floating-button
WiredFloatingActionButton(
  icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
  semanticLabel: 'Add an idea',
  onPressed: true ? () {} : null,
)
```

### Sizes

`WiredFloatingActionButton.small` is 40px and `WiredFloatingActionButton.large` is 96px, matching Material.

```dart
// Live example: floating-button-sizes
Wrap(
  spacing: 16,
  runSpacing: 16,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    WiredFloatingActionButton.small(
      icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      tooltip: 'Add',
      onPressed: true ? () {} : null,
    ),
    WiredFloatingActionButton(
      icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      tooltip: 'Add',
      onPressed: true ? () {} : null,
    ),
    WiredFloatingActionButton.large(
      icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      tooltip: 'Add',
      onPressed: true ? () {} : null,
    ),
  ],
)
```

### Extended

`WiredFloatingActionButton.extended` draws a hand-drawn pill around an optional icon and a label. Turn `isExtended` off, for example while a list scrolls, and it springs back to a circle around the icon. Tap the example to try it.

```dart
// Live example: floating-button-extended
HookBuilder(
  builder: (context) {
    final extended = useState(true);
    return WiredFloatingActionButton.extended(
      icon: const IconData(0xe21a, fontFamily: 'MaterialIcons'),
      label: Text('Make something lovely'),
      isExtended: extended.value,
      onPressed: true
          ? () => extended.value = !extended.value
          : null,
    );
  },
)
```

### Constructor parameters

| Parameter                  | Type                   | Default      | Description                                                                                   |
| -------------------------- | ---------------------- | ------------ | --------------------------------------------------------------------------------------------- |
| `icon`                     | `IconData`             | **required** | The icon in the center. Optional for `.extended`.                                             |
| `label`                    | `Widget`               | **required** | `.extended` only: the label beside the icon.                                                  |
| `onPressed`                | `VoidCallback?`        | `null`       | Callback when tapped. Null disables the button.                                               |
| `size`                     | `double`               | `56.0`       | Diameter of the FAB, or the minimum height of an extended one.                                |
| `iconSize`                 | `double?`              | `null`       | Glyph size. Defaults to 43% of `size` (20 for `.small`, 36 for `.large`, 24 for `.extended`). |
| `backgroundColor`          | `Color?`               | `null`       | The wash, such as `theme.accentAt(2)`. Defaults to `theme.accentColor`.                       |
| `foregroundColor`          | `Color?`               | `null`       | Icon and label color. Defaults to `theme.onColor(backgroundColor)`.                           |
| `iconColor`                | `Color?`               | `null`       | Icon color override; wins over `foregroundColor` for the icon.                                |
| `tooltip`                  | `String?`              | `null`       | Hand-drawn tooltip on long press or hover, also read by screen readers.                       |
| `heroTag`                  | `Object?`              | `null`       | Wraps the button in a `Hero`. Null adds none, so several FABs never clash.                    |
| `inkInteraction`           | `WiredInkInteraction?` | `null`       | Overrides the theme's ink feedback on press.                                                  |
| `autofocus`                | `bool`                 | `false`      | Focuses the button when nothing else is focused.                                              |
| `focusNode`                | `FocusNode?`           | `null`       | An optional focus node.                                                                       |
| `semanticLabel`            | `String?`              | `null`       | Accessibility label.                                                                          |
| `isExtended`               | `bool`                 | `true`       | `.extended` only: shows the label, or collapses to a circle when false.                       |
| `extendedIconLabelSpacing` | `double`               | `8`          | `.extended` only: space between the icon and the label.                                       |
| `extendedPadding`          | `EdgeInsetsGeometry?`  | `null`       | `.extended` only: padding inside the pill. Defaults to 16 at the sides.                       |

### Notes

- The circular forms use `WiredCircleBase` with a 0.9 diameter ratio; the extended form uses a pill-shaped `RoughBoxDecoration` at least 56px tall, which grows with larger text.
- Taps, hover, keyboard focus, and Enter or Space activation are handled without a Material ancestor, and pressing presses the ink like the other buttons.
- Typically placed in `WiredScaffold.floatingActionButton`, or as the `leading` widget of a `WiredNavigationRail`.

---

## WiredIconButton

An icon button enclosed in a hand-drawn circle border with no fill. Ideal for toolbar actions and compact controls. Mirrors Material's `IconButton`, including its filled, tonal, and outlined forms and its toggle behaviour.

```dart
// Live example: icon-button
WiredIconButton(
  icon: const IconData(0xe25b, fontFamily: 'MaterialIcons'),
  semanticLabel: 'Favourite',
  onPressed: true ? () {} : null,
)
```

### Variants

`WiredIconButton.filled` washes the circle with `theme.accentColor`, for the one loud action in a toolbar. `WiredIconButton.filledTonal` washes it with `theme.markerColor`. `WiredIconButton.outlined` matches the default look, since every skribble icon button already draws its ring, and exists so Material code ports unchanged. Pass `fillColor: theme.accentAt(i)` to colour-code a row of them.

```dart
// Live example: icon-button-variants
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    WiredIconButton(
      icon: const IconData(0xe25b, fontFamily: 'MaterialIcons'),
      tooltip: 'Favourite',
      onPressed: true ? () {} : null,
    ),
    WiredIconButton.filled(
      icon: const IconData(0xe571, fontFamily: 'MaterialIcons'),
      tooltip: 'Send',
      onPressed: true ? () {} : null,
    ),
    WiredIconButton.filledTonal(
      icon: const IconData(0xe593, fontFamily: 'MaterialIcons'),
      tooltip: 'Share',
      onPressed: true ? () {} : null,
    ),
    WiredIconButton.outlined(
      icon: const IconData(0xe21a, fontFamily: 'MaterialIcons'),
      tooltip: 'Edit',
      onPressed: true ? () {} : null,
    ),
  ],
)
```

### Toggle

Pass `isSelected` and `selectedIcon` to make a toggle. A selected button draws `selectedIcon` on a wash and is announced as selected; an unselected filled or tonal toggle keeps only its ring.

```dart
// Live example: icon-button-toggle
HookBuilder(
  builder: (context) {
    final saved = useState(false);
    return WiredIconButton(
      icon: const IconData(0xe0f4, fontFamily: 'MaterialIcons'),
      selectedIcon: const IconData(0xe0f1, fontFamily: 'MaterialIcons'),
      isSelected: saved.value,
      tooltip: saved.value ? 'Remove bookmark' : 'Bookmark',
      onPressed: true ? () => saved.value = !saved.value : null,
    );
  },
)
```

### Constructor parameters

| Parameter        | Type                   | Default      | Description                                                                     |
| ---------------- | ---------------------- | ------------ | ------------------------------------------------------------------------------- |
| `icon`           | `IconData`             | **required** | The icon to display.                                                            |
| `onPressed`      | `VoidCallback?`        | `null`       | Callback when tapped. Null disables the button.                                 |
| `size`           | `double`               | `48.0`       | Overall width and height of the hand-drawn frame.                               |
| `iconSize`       | `double?`              | `null`       | Glyph size; mirrors `IconButton.iconSize`. Defaults to `size / 2`.              |
| `iconColor`      | `Color?`               | `null`       | Glyph color override. Defaults to the ink that reads on the wash.               |
| `color`          | `Color?`               | `null`       | Glyph color; mirrors `IconButton.color` and wins over `iconColor`.              |
| `fillColor`      | `Color?`               | `null`       | The wash of a filled, tonal, or selected button, such as `theme.accentAt(3)`.   |
| `isSelected`     | `bool?`                | `null`       | Toggle state, mirroring `IconButton.isSelected`. Null makes an ordinary button. |
| `selectedIcon`   | `IconData?`            | `null`       | Icon drawn while `isSelected` is true. Falls back to `icon`.                    |
| `tooltip`        | `String?`              | `null`       | Hand-drawn tooltip on long press or hover, also read by screen readers.         |
| `inkInteraction` | `WiredInkInteraction?` | `null`       | Overrides the theme's ink feedback on press.                                    |
| `autofocus`      | `bool`                 | `false`      | Focuses the button when nothing else is focused.                                |
| `focusNode`      | `FocusNode?`           | `null`       | An optional focus node.                                                         |
| `semanticLabel`  | `String?`              | `null`       | Accessibility label.                                                            |

### Notes

- The inner icon renders at `iconSize`, which defaults to 50% of `size`.
- The standard and outlined circles use `RoughFilter.noFiller` so only the hand-drawn border is visible.
- With `onPressed: null` and no explicit `color` or `iconColor`, the glyph uses `theme.disabledTextColor`, and a filled or tonal wash fades to 35%.
- Built on `package:flutter/widgets.dart` alone: no Material `IconButton` underneath, so it works in a `SkribbleApp` without a Material ancestor.

---

## WiredOutlinedButton

A button with a thick hand-drawn border (2px stroke width) and no fill. The heavier outline provides strong visual emphasis without a background.

```dart
// Live example: outlined-button
WiredOutlinedButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: true ? () {} : null,
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

### Constructor parameters

| Parameter       | Type            | Default                                 | Description                                      |
| --------------- | --------------- | --------------------------------------- | ------------------------------------------------ |
| `borderRadius`  | `BorderRadius`  | `BorderRadius.all(Radius.circular(10))` | Rough corner radii; use zero for square corners. |
| `child`         | `Widget`        | **required**                            | The button label.                                |
| `onPressed`     | `VoidCallback?` | `null`                                  | Callback when tapped.                            |
| `semanticLabel` | `String?`       | `null`                                  | Accessibility label.                             |

### Notes

- Doubles the border stroke width compared to `WiredButton` for extra emphasis.

---

## WiredTextButton

A text-only button with a sketchy underline drawn beneath the label. No border or fill surrounds the text.

```dart
// Live example: text-button
WiredTextButton(
  onPressed: true ? () {} : null,
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

### Constructor parameters

| Parameter       | Type            | Default      | Description           |
| --------------- | --------------- | ------------ | --------------------- |
| `child`         | `Widget`        | **required** | The button label.     |
| `onPressed`     | `VoidCallback?` | `null`       | Callback when tapped. |
| `semanticLabel` | `String?`       | `null`       | Accessibility label.  |

### Notes

- The underline is drawn with `WiredLineBase` spanning the intrinsic width of the child.
- Good for inline-style links within paragraphs of text.
- There is deliberately no `borderRadius`: the text button draws a line, not a box.
- The label keeps `kWiredInkPadding` (12 at the sides, 8 above and below) at every text scale and on every platform, so the underline never touches it. A disabled label uses `theme.disabledTextColor`.

---

## WiredToggleButtons

A multi-toggle button group where each button gets a sketchy rectangle border. Selected buttons receive the theme's `markerColor` wash; unselected buttons remain transparent.

```dart
// Live example: toggle-buttons
HookBuilder(
  builder: (context) {
    final selected = useState([true, false, false]);
    return WiredToggleButtons(
      isSelected: selected.value,
      onPressed: true
          ? (index) {
              final next = List<bool>.of(selected.value);
              next[index] = !next[index];
              selected.value = next;
            }
          : null,
      children: const [Text('B'), Text('I'), Text('U')],
    );
  },
)
```

### Constructor parameters

| Parameter           | Type                 | Default      | Description                                                    |
| ------------------- | -------------------- | ------------ | -------------------------------------------------------------- |
| `children`          | `List<Widget>`       | **required** | Button labels.                                                 |
| `isSelected`        | `List<bool>`         | **required** | Selection state per button. Must match `children` length.      |
| `onPressed`         | `ValueChanged<int>?` | `null`       | Called with the tapped index.                                  |
| `height`            | `double`             | `42`         | Least height of each toggle button; it grows with larger text. |
| `horizontalPadding` | `double`             | `16`         | Horizontal padding inside each button.                         |

### Notes

- Asserts that `children.length == isSelected.length` at construction time.
- Selected buttons keep their ink text and icons, in a heavier weight, over the marker wash.
- Labels keep 8 pixels above and below; every button in the group matches the tallest label.
- Each button is focusable, activates with Enter or Space, and reports a button with its toggled state. `onPressed: null` disables every button and takes them out of focus traversal.

---

## WiredSegmentedButton

A segmented control with connected rounded rectangles, analogous to Material 3's `SegmentedButton`. Each segment can display a label and optional icon.

```dart
// Live example: segmented-button
HookBuilder(
  builder: (context) {
    final selected = useState({'week'});
    return WiredSegmentedButton<String>(
      segments: const [
        WiredButtonSegment(value: 'day', label: Text('Day')),
        WiredButtonSegment(value: 'week', label: Text('Week')),
        WiredButtonSegment(value: 'month', label: Text('Month')),
      ],
      selected: selected.value,
      onSelectionChanged: true
          ? (value) => selected.value = value
          : null,
    );
  },
)
```

### WiredButtonSegment parameters

| Parameter | Type        | Default      | Description                           |
| --------- | ----------- | ------------ | ------------------------------------- |
| `value`   | `T`         | **required** | The value this segment represents.    |
| `label`   | `Widget`    | **required** | Displayed label.                      |
| `icon`    | `IconData?` | `null`       | Optional icon shown before the label. |

### WiredSegmentedButton parameters

| Parameter               | Type                          | Default      | Description                                       |
| ----------------------- | ----------------------------- | ------------ | ------------------------------------------------- |
| `segments`              | `List<WiredButtonSegment<T>>` | **required** | The available segments.                           |
| `selected`              | `Set<T>`                      | **required** | Currently selected values.                        |
| `onSelectionChanged`    | `void Function(Set<T>)?`      | `null`       | Called when selection changes.                    |
| `multiSelectionEnabled` | `bool`                        | `false`      | Allow selecting multiple segments simultaneously. |

### Notes

- The outer container uses `WiredRoundedRectangleBase` with 8px border radius.
- Vertical divider lines between segments are drawn with `WiredLineBase`.
- Selected segments are washed with the theme's `markerColor` via `RoughBoxDecoration`. (They used a hachure fill, whose lines ran through the label.)
- Segment labels use `theme.textColor`.
- Each segment is focusable, activates with Enter or Space, and reports a button with its selected state. `onSelectionChanged: null` disables every segment.

---

## WiredCupertinoButton

A Cupertino-style press-opacity button with a hand-drawn rounded rectangle border. Mirrors the `CupertinoButton` API including a `.filled` factory constructor.

```dart
// Live example: cupertino-button
WiredCupertinoButton(
  onPressed: true ? () {} : null,
  color: const Color(0xffe8957d),
  borderRadius: BorderRadius.circular(8),
  child: Text('Make something lovely'),
)
```

### Constructor parameters

| Parameter        | Type                  | Default                                | Description                                        |
| ---------------- | --------------------- | -------------------------------------- | -------------------------------------------------- |
| `child`          | `Widget`              | **required**                           | The button label.                                  |
| `onPressed`      | `VoidCallback?`       | **required**                           | Callback when tapped. `null` disables the button.  |
| `padding`        | `EdgeInsetsGeometry?` | `null`                                 | Padding around the child. Defaults to `16h / 10v`. |
| `color`          | `Color?`              | `null`                                 | Background color. Set automatically by `.filled`.  |
| `disabledColor`  | `Color`               | `CupertinoColors.quaternarySystemFill` | Background when disabled.                          |
| `minSize`        | `double`              | `kMinInteractiveDimensionCupertino`    | Minimum tap target size.                           |
| `pressedOpacity` | `double`              | `0.4`                                  | Opacity applied during a press gesture.            |
| `borderRadius`   | `BorderRadius?`       | `BorderRadius.circular(8)`             | Rounded rectangle corner radius.                   |
| `alignment`      | `AlignmentGeometry`   | `Alignment.center`                     | Child alignment within the button.                 |

### Notes

- Uses a `useState` hook for tracking press state and `AnimatedOpacity` for the press feedback.
- The filled variant sets `color` to `CupertinoColors.activeBlue` and uses hachure fill.
- Disabled buttons render at 40% opacity.
- The button reports a button role and its enabled state, joins focus traversal while enabled, and activates with Enter or Space.

## Keyboard and focus

Every button, chip, segment, and Cupertino control on this page can be reached with Tab and activated with Enter or Space. A focused control draws a sketchy outline a few pixels outside its own ink, in the theme's `borderColor`, so it shows on dark paper as well as light. The Material-backed buttons (`WiredButton`, `WiredElevatedButton`, `WiredFilledButton`, `WiredOutlinedButton`, `WiredTextButton`) mark focus by thickening their own ink instead. A disabled control leaves focus traversal and reports itself disabled.

<!-- {=docsWidgetInkSection} -->

## Shared ink and typography

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (1.6 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->

`WiredFilledButton` uses an opaque rough fill so its label stays readable. Without an explicit foreground color, it picks the theme's text or paper colour, whichever contrasts more with the fill.

## Ink motion

Wrap this component in `WiredDraw` or `WiredDrawTransition` to draw its rough outline and patterned fill. Button variants also reinforce their ink on hover, focus, and press. Labels and solid backgrounds stay readable. See [Ink motion](../core/motion) for timing, supported variants, and disabling motion.

Disabled filled buttons retain the contrast-selected foreground at 75% opacity, so labels and icons remain legible on their opaque ink background.

## Decorative interaction styles

The six standard Wired button variants accept `inkInteraction`. Leave it unset to inherit `WiredThemeData.inkInteraction`, use `WiredInkInteraction.none` for still ink, `pressure` for subtle reinforcement, or `redraw` for a short pen trace on press. Text and opaque fills stay visible. Reduced motion always takes precedence. See [Ink motion](/core/motion#choose-how-buttons-respond) for examples and animation ownership.

## Rough rounded corners

`WiredButton`, `WiredFilledButton`, `WiredElevatedButton`, and `WiredOutlinedButton` use a soft 10 px corner radius. Their `borderRadius` parameter accepts a `BorderRadius`, including `BorderRadius.zero` for square corners. Both the straight segments and corner arcs use the nearest theme's roughness; a radius does not introduce a smooth, machine-drawn outline.

Change **radius** beside a live example to compare square, softly rounded, and rounder shapes. The fill follows the same rough contour, retaining a little marker overlap.

---

## API consistency with Material

The button family was audited against its Material counterparts so a migration is a small diff. What matches: `child`, `onPressed` (nullable, and null disables the button), `semanticLabel`, and per-widget color overrides. `WiredIconButton` now also accepts `iconSize` and `color`, the names `IconButton` uses; `size` and `iconColor` remain as the original names.

Deliberate deviations, kept because renaming them would break existing callers:

- `WiredIconButton.size` measures the whole frame, while Material's `iconSize` measures the glyph. Use `iconSize` for the Material meaning.
- The Wired buttons have no `style`/`ButtonStyle`, `onLongPress`, `focusNode`, `autofocus`, or `statesController`. Styling flows through `WiredThemeData` and `inkInteraction` instead.
- `WiredTextButton` has no `borderRadius` because it draws an underline, not a box.
