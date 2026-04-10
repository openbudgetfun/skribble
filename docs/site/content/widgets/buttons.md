---
title: Buttons
description: Hand-drawn button widgets for actions, toggles, and segmented controls in Skribble.
---

# Buttons

Skribble provides a full set of button widgets that replace their Material and Cupertino counterparts with sketchy, hand-drawn borders, hachure fills, and wobbly outlines. Every button reads its palette from `WiredTheme.of(context)` and extends `HookWidget`.

---

## WiredButton

A basic button with a hand-drawn rectangle border. The simplest entry point for actions.

<!-- {=docsButtonBasicUsage} -->
```dart
WiredButton(
  onPressed: () => print('tapped'),
  child: Text('Click me'),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The button label. |
| `onPressed` | `void Function()` | **required** | Callback when the button is tapped. |
| `semanticLabel` | `String?` | `null` | Accessibility label exposed to screen readers. |

### Notes

- The button uses `kWiredButtonHeight` for consistent sizing across all rectangular buttons.
- The border is drawn with a `RoughBoxDecoration` using the theme's `borderColor`.
- Text color inherits from `theme.textColor`.

---

## WiredElevatedButton

An elevated variant with a slight offset shadow layer rendered behind the main button face. Both the shadow and the face use hachure fills for a tactile, layered look.

<!-- {=docsElevatedButtonUsage} -->
```dart
WiredElevatedButton(
  onPressed: () {},
  child: Text('Elevated'),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The button label. |
| `onPressed` | `VoidCallback?` | `null` | Callback when tapped. `null` disables the button. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### Notes

- The shadow offset is 2 logical pixels down and right.
- Both shadow and face use `HachureFiller` with different gap values for depth.

---

## WiredFilledButton

A solid button with a dense hachure fill, analogous to Material's `FilledButton`. Good for primary call-to-action placement.

<!-- {=docsFilledButtonUsage} -->
```dart
WiredFilledButton(
  onPressed: () {},
  child: Text('Submit'),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The button label. |
| `onPressed` | `VoidCallback?` | `null` | Callback when tapped. |
| `fillColor` | `Color?` | `null` | Custom fill color. Defaults to `theme.borderColor`. |
| `foregroundColor` | `Color?` | `null` | Text/icon color. Defaults to white. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### Notes

- The hachure gap is tighter (2px) than the elevated button for a denser fill.
- When `fillColor` is not provided the button uses `theme.borderColor` for a high-contrast filled look.

---

## WiredFloatingActionButton

A circular floating action button with a hand-drawn circle border and hachure fill. Designed for primary screen actions.

<!-- {=docsFabUsage} -->
```dart
WiredFloatingActionButton(
  icon: Icons.add,
  onPressed: () {},
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `icon` | `IconData` | **required** | The icon displayed in the center. |
| `onPressed` | `VoidCallback?` | `null` | Callback when tapped. |
| `size` | `double` | `56.0` | Diameter of the FAB. |
| `iconColor` | `Color?` | `null` | Icon color override. Defaults to `theme.fillColor`. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### Notes

- Uses `WiredCircleBase` with a 0.9 diameter ratio for the outer circle.
- The icon is rendered with `WiredIcon` at 43% of the FAB size, using solid fill style.
- Typically placed in `WiredScaffold.floatingActionButton`.

---

## WiredIconButton

An icon button enclosed in a hand-drawn circle border with no fill. Ideal for toolbar actions and compact controls.

<!-- {=docsIconButtonUsage} -->
```dart
WiredIconButton(
  icon: Icons.favorite,
  onPressed: () {},
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `icon` | `IconData` | **required** | The icon to display. |
| `onPressed` | `VoidCallback?` | `null` | Callback when tapped. |
| `size` | `double` | `48.0` | Overall size of the button. |
| `iconColor` | `Color?` | `null` | Icon color override. Defaults to `theme.textColor`. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### Notes

- The inner icon renders at 50% of the button size.
- The circle uses `RoughFilter.noFiller` so only the hand-drawn border is visible.

---

## WiredOutlinedButton

A button with a thick hand-drawn border (2px stroke width) and no fill. The heavier outline provides strong visual emphasis without a background.

<!-- {=docsOutlinedButtonUsage} -->
```dart
WiredOutlinedButton(
  onPressed: () {},
  child: Text('Outlined'),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The button label. |
| `onPressed` | `VoidCallback?` | `null` | Callback when tapped. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### Notes

- Doubles the border stroke width compared to `WiredButton` for extra emphasis.

---

## WiredTextButton

A text-only button with a sketchy underline drawn beneath the label. No border or fill surrounds the text.

<!-- {=docsTextButtonUsage} -->
```dart
WiredTextButton(
  onPressed: () {},
  child: Text('Learn more'),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The button label. |
| `onPressed` | `VoidCallback?` | `null` | Callback when tapped. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### Notes

- The underline is drawn with `WiredLineBase` spanning the intrinsic width of the child.
- Good for inline-style links within paragraphs of text.

---

## WiredToggleButtons

A multi-toggle button group where each button gets a sketchy rectangle border. Selected buttons receive a hachure fill; unselected buttons remain transparent.

<!-- {=docsToggleButtonsUsage} -->
```dart
WiredToggleButtons(
  isSelected: [true, false, false],
  onPressed: (index) {
    setState(() {
      isSelected[index] = !isSelected[index];
    });
  },
  children: [
    Icon(Icons.format_bold),
    Icon(Icons.format_italic),
    Icon(Icons.format_underline),
  ],
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `children` | `List<Widget>` | **required** | Button labels. |
| `isSelected` | `List<bool>` | **required** | Selection state per button. Must match `children` length. |
| `onPressed` | `ValueChanged<int>?` | `null` | Called with the tapped index. |
| `height` | `double` | `42` | Height of each toggle button. |
| `horizontalPadding` | `double` | `16` | Horizontal padding inside each button. |

### Notes

- Asserts that `children.length == isSelected.length` at construction time.
- Selected buttons render white text/icons over the hachure fill.

---

## WiredSegmentedButton

A segmented control with connected rounded rectangles, analogous to Material 3's `SegmentedButton`. Each segment can display a label and optional icon.

<!-- {=docsSegmentedButtonUsage} -->
```dart
WiredSegmentedButton<String>(
  segments: [
    WiredButtonSegment(value: 'day', label: Text('Day')),
    WiredButtonSegment(value: 'week', label: Text('Week')),
    WiredButtonSegment(value: 'month', label: Text('Month'), icon: Icons.calendar_today),
  ],
  selected: {'week'},
  onSelectionChanged: (newSelection) {
    setState(() => selected = newSelection);
  },
)
```

### WiredButtonSegment parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `T` | **required** | The value this segment represents. |
| `label` | `Widget` | **required** | Displayed label. |
| `icon` | `IconData?` | `null` | Optional icon shown before the label. |

### WiredSegmentedButton parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `segments` | `List<WiredButtonSegment<T>>` | **required** | The available segments. |
| `selected` | `Set<T>` | **required** | Currently selected values. |
| `onSelectionChanged` | `void Function(Set<T>)?` | `null` | Called when selection changes. |
| `multiSelectionEnabled` | `bool` | `false` | Allow selecting multiple segments simultaneously. |

### Notes

- The outer container uses `WiredRoundedRectangleBase` with 8px border radius.
- Vertical divider lines between segments are drawn with `WiredLineBase`.
- Selected segments receive a hachure fill via `RoughBoxDecoration`.

---

## WiredCupertinoButton

A Cupertino-style press-opacity button with a hand-drawn rounded rectangle border. Mirrors the `CupertinoButton` API including a `.filled` factory constructor.

<!-- {=docsCupertinoButtonUsage} -->
```dart
// Default (outlined)
WiredCupertinoButton(
  onPressed: () {},
  child: Text('Cupertino'),
)

// Filled variant
WiredCupertinoButton.filled(
  onPressed: () {},
  child: Text('Filled Cupertino'),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | **required** | The button label. |
| `onPressed` | `VoidCallback?` | **required** | Callback when tapped. `null` disables the button. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the child. Defaults to `16h / 10v`. |
| `color` | `Color?` | `null` | Background color. Set automatically by `.filled`. |
| `disabledColor` | `Color` | `CupertinoColors.quaternarySystemFill` | Background when disabled. |
| `minSize` | `double` | `kMinInteractiveDimensionCupertino` | Minimum tap target size. |
| `pressedOpacity` | `double` | `0.4` | Opacity applied during a press gesture. |
| `borderRadius` | `BorderRadius?` | `BorderRadius.circular(8)` | Rounded rectangle corner radius. |
| `alignment` | `AlignmentGeometry` | `Alignment.center` | Child alignment within the button. |

### Notes

- Uses a `useState` hook for tracking press state and `AnimatedOpacity` for the press feedback.
- The filled variant sets `color` to `CupertinoColors.activeBlue` and uses hachure fill.
- Disabled buttons render at 40% opacity.
