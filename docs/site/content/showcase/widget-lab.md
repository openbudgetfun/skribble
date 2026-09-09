---
title: Widget lab
description: Working widgets, editable parameters, and matching Dart source.
---

# A little widget workshop

Change a label, pick an enum value, or adjust the corner radius. The preview and Dart source update together. Each example runs real Flutter code; copy the expression into your widget tree. Examples using HookBuilder also need flutter_hooks.

Try the roughness choices at the top of this page to compare every outline and the lettering. Rounded corners use the same drawing configuration as straight edges.

## Checkbox

```dart
// Live example: checkbox
HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Keep this idea',
        ),
        const SizedBox(width: 12),
        Flexible(child: Text('Make something lovely')),
      ],
    );
  },
)
```

## Switch

```dart
// Live example: switch
HookBuilder(
  builder: (context) {
    final enabled = useState(true);
    return WiredSwitch(
      value: enabled.value,
      onChanged: (value) {
        enabled.value = value;
      },
    );
  },
)
```

## Slider

```dart
// Live example: slider
WiredSlider(
  value: .6,
  divisions: 10,
  semanticLabel: 'Amount',
  onChanged: true ? (value) => true : null,
)
```

## Input

```dart
// Live example: input
WiredInput(
  labelText: 'Make something lovely',
  hintText: 'A tiny spark of an idea…',
)
```

## Text Area

```dart
// Live example: text-area
WiredTextArea(
  hintText: 'Make something lovely',
)
```

## Card

```dart
// Live example: card
WiredCard(
  fill: true,
  child: Center(child: Text('Make something lovely')),
)
```

## List Tile

```dart
// Live example: list-tile
WiredListTile(
  title: Text('Make something lovely'),
  subtitle: const Text('A little note for later'),
  showDivider: false,
  onTap: true ? () {} : null,
)
```

## Chip

```dart
// Live example: chip
WiredChip(label: Text('Make something lovely'))
```

## Choice Chip

```dart
// Live example: choice-chip
HookBuilder(
  builder: (context) {
    final selected = useState(false);
    return WiredChoiceChip(
      label: Text('Make something lovely'),
      selected: selected.value,
      onSelected: (value) => selected.value = value,
    );
  },
)
```

## Filter Chip

```dart
// Live example: filter-chip
HookBuilder(
  builder: (context) {
    final selected = useState(true);
    return WiredFilterChip(
      label: Text('Make something lovely'),
      selected: selected.value,
      onSelected: (value) => selected.value = value,
    );
  },
)
```

## Circular Progress

```dart
// Live example: circular-progress
WiredCircularProgress(value: .6)
```

## Rounded Canvas

```dart
// Live example: rounded-canvas
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 260,
      height: 140,
      child: WiredCanvas(
        painter: WiredRoundedRectangleBase(
          borderRadius: BorderRadius.circular(8),
          borderColor: theme.borderColor,
          fillColor: const Color(0xffde987d),
          strokeWidth: theme.strokeWidth,
        ),
        fillerType: RoughFilter.hachureFiller,
      ),
    );
  },
)
```

## Cupertino Filled Button

```dart
// Live example: cupertino-filled-button
WiredCupertinoButton.filled(
      onPressed: true ? () {} : null,
      borderRadius: BorderRadius.circular(8),
      child: Text('Make something lovely'),
    )
```

## About these examples

The widget catalog contains compiled previews and typed controls. Editing a control updates the preview and its highlighted, copyable source. Enum controls expose the actual variants supported by that example. Code that defines an app shell, custom class, asset generator, or platform setup remains reference material; it cannot run as an isolated widget expression. The editor does not execute arbitrary pasted Dart.
