---
title: Feedback
description: Hand-drawn dialogs, snack bars, tooltips, progress indicators, and other feedback widgets in the Skribble design system.
---

# Feedback

Skribble provides feedback widgets that communicate status, confirmations, and progress using sketchy hand-drawn visuals. All feedback widgets read their palette from `WiredTheme.of(context)`.

---

## WiredDialog

A dialog with a hand-drawn rectangle border drawn behind the content. Uses Flutter's `Dialog` widget internally.

<!-- {=docsDialogUsage} -->

```dart
showDialog(
  context: context,
  builder: (context) => WiredDialog(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Are you sure?'),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            WiredTextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            SizedBox(width: 8),
            WiredButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirm'),
            ),
          ],
        ),
      ],
    ),
  ),
);
```

### Constructor parameters

| Parameter | Type                  | Default      | Description                                                |
| --------- | --------------------- | ------------ | ---------------------------------------------------------- |
| `child`   | `Widget`              | **required** | The dialog content.                                        |
| `padding` | `EdgeInsetsGeometry?` | `null`       | Padding around the content. Defaults to 20px on all sides. |

### Notes

- The background uses `WiredRectangleBase` with `theme.fillColor` and `theme.borderColor`.
- The border is drawn with 5px inset from the dialog edge for a natural offset.
- No fill is applied (uses `RoughFilter.noFiller`), keeping a clean background.

---

## WiredSnackBarContent / showWiredSnackBar

A snack bar content wrapper with a hand-drawn border and solid fill. The `showWiredSnackBar` helper function displays it via `ScaffoldMessenger`.

<!-- {=docsSnackBarUsage} -->

```dart
// Using the helper function
showWiredSnackBar(
  context,
  content: WiredSnackBarContent(
    child: Text('Item saved successfully'),
    action: WiredTextButton(
      onPressed: () {},
      child: Text('Undo'),
    ),
  ),
);

// Or build it manually
showWiredSnackBar(
  context,
  content: Text('Simple message'),
  duration: Duration(seconds: 3),
);
```

### showWiredSnackBar parameters

| Parameter  | Type              | Default      | Description                          |
| ---------- | ----------------- | ------------ | ------------------------------------ |
| `content`  | `Widget`          | **required** | The snack bar content.               |
| `duration` | `Duration`        | `4 seconds`  | How long the snack bar is displayed. |
| `action`   | `SnackBarAction?` | `null`       | Optional action button.              |

### WiredSnackBarContent parameters

| Parameter | Type      | Default      | Description                      |
| --------- | --------- | ------------ | -------------------------------- |
| `child`   | `Widget`  | **required** | The message content.             |
| `action`  | `Widget?` | `null`       | Optional trailing action widget. |

### Notes

- The content uses a `SolidFiller` for an opaque background with `theme.fillColor`.
- The border is 1.5px using `theme.borderColor`.
- The snack bar uses `SnackBarBehavior.floating` with transparent background so the hand-drawn border is visible.

---

## WiredTooltip

A tooltip with a hand-drawn rectangle border. Wraps Flutter's `Tooltip` widget with sketchy decoration.

<!-- {=docsTooltipUsage} -->

```dart
WiredTooltip(
  message: 'Add to favorites',
  child: WiredIconButton(
    icon: Icons.favorite_border,
    onPressed: () {},
  ),
)
```

### Constructor parameters

| Parameter      | Type        | Default      | Description                                |
| -------------- | ----------- | ------------ | ------------------------------------------ |
| `child`        | `Widget`    | **required** | The widget that triggers the tooltip.      |
| `message`      | `String`    | **required** | The tooltip message.                       |
| `waitDuration` | `Duration?` | `null`       | Delay before showing the tooltip on hover. |
| `showDuration` | `Duration?` | `null`       | How long the tooltip stays visible.        |

### Notes

- The tooltip decoration uses `RoughBoxDecoration` with `theme.fillColor` background.
- Text is styled at 12px with `theme.textColor`.

---

## WiredProgress

A hand-drawn linear progress bar. Renders a sketchy rectangle track with a hachure-filled progress region that animates via an `AnimationController`.

<!-- {=docsProgressUsage} -->

```dart
// In a HookWidget:
final controller = useAnimationController(
  duration: Duration(seconds: 2),
);

// Start the animation
controller.forward();

WiredProgress(
  controller: controller,
  value: 0.0, // Starting value
)
```

### Constructor parameters

| Parameter    | Type                  | Default      | Description                          |
| ------------ | --------------------- | ------------ | ------------------------------------ |
| `controller` | `AnimationController` | **required** | Drives the progress animation.       |
| `value`      | `double`              | `0.0`        | Initial progress value (0.0 to 1.0). |

### Notes

- Progress bar height is 20px.
- The filled portion uses hachure fill with `theme.borderColor` (gap: 1.5).
- The track border uses `theme.borderColor` with no fill.
- The widget measures its own width after layout to compute the fill extent.

---

## WiredCircularProgress

A circular progress indicator with a hand-drawn arc and background circle. Supports both determinate and indeterminate modes.

<!-- {=docsCircularProgressUsage} -->

```dart
// Indeterminate (spinner)
WiredCircularProgress()

// Determinate (specific progress)
WiredCircularProgress(
  value: 0.65,
  size: 64,
  strokeWidth: 4,
)
```

### Constructor parameters

| Parameter     | Type      | Default | Description                                              |
| ------------- | --------- | ------- | -------------------------------------------------------- |
| `value`       | `double?` | `null`  | Progress from 0.0 to 1.0. `null` for indeterminate mode. |
| `size`        | `double`  | `48.0`  | Diameter of the indicator.                               |
| `strokeWidth` | `double`  | `3`     | Width of the progress arc.                               |

### Notes

- In indeterminate mode, the arc rotates continuously with a 2-second cycle.
- The background circle uses `WiredCircleBase` with 0.9 diameter ratio.
- The progress arc is rendered by a custom `_ArcPainter` with `StrokeCap.round`.

---

## WiredBadge

A badge overlay that positions a hand-drawn circle indicator at the top-right corner of its child. Supports optional text labels.

<!-- {=docsBadgeUsage} -->

```dart
WiredBadge(
  label: '3',
  child: WiredIconButton(
    icon: Icons.notifications,
    onPressed: () {},
  ),
)

// Dot badge (no label)
WiredBadge(
  child: WiredIcon(icon: Icons.mail),
)
```

### Constructor parameters

| Parameter         | Type      | Default      | Description                                      |
| ----------------- | --------- | ------------ | ------------------------------------------------ |
| `child`           | `Widget`  | **required** | The widget to badge.                             |
| `label`           | `String?` | `null`       | Text inside the badge. When `null`, shows a dot. |
| `isVisible`       | `bool`    | `true`       | Whether the badge is shown.                      |
| `backgroundColor` | `Color?`  | `null`       | Badge color. Defaults to `theme.borderColor`.    |

### Notes

- The badge is positioned at `right: -6, top: -6`.
- Dot badges are 16px; labeled badges auto-size based on text length.
- Uses `WiredCircleBase` with hachure fill (gap: 1.0) and white bold text at 10px.

---

## WiredBottomSheet

A bottom sheet with a hand-drawn top border. Can be shown as a modal or persistent sheet.

<!-- {=docsBottomSheetUsage} -->

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => WiredBottomSheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredListTile(title: Text('Option 1'), onTap: () {}),
        WiredListTile(title: Text('Option 2'), onTap: () {}),
      ],
    ),
  ),
);
```

---

## WiredAboutDialog / showWiredAboutDialog

An about dialog with a hand-drawn border, application icon, and version info. The `showWiredAboutDialog` helper function displays it.

<!-- {=docsAboutDialogUsage} -->

```dart
showWiredAboutDialog(
  context: context,
  applicationName: 'My Sketchy App',
  applicationVersion: '1.0.0',
  applicationIcon: WiredIcon(icon: Icons.draw, size: 48),
  children: [
    Text('A hand-drawn Flutter application.'),
  ],
);
```

---

## WiredContextMenu

A context menu with hand-drawn borders, triggered by long-press or right-click. Menu items appear in a sketchy bordered overlay.

<!-- {=docsContextMenuUsage} -->

```dart
WiredContextMenu(
  items: [
    WiredContextMenuItem(title: 'Copy', onTap: () => copy()),
    WiredContextMenuItem(title: 'Paste', onTap: () => paste()),
    WiredContextMenuItem(title: 'Delete', onTap: () => delete()),
  ],
  child: Text('Right-click or long-press me'),
)
```

---

## WiredAnimatedIcon

A hand-drawn wrapper around Flutter's `AnimatedIcon`. Applies Skribble theming to animated icon transitions.

<!-- {=docsAnimatedIconUsage} -->

```dart
// In a HookWidget:
final controller = useAnimationController(
  duration: Duration(milliseconds: 300),
);

WiredAnimatedIcon(
  icon: AnimatedIcons.menu_arrow,
  progress: controller,
  size: 24,
)
```

### Constructor parameters

| Parameter       | Type                | Default      | Description                                                |
| --------------- | ------------------- | ------------ | ---------------------------------------------------------- |
| `icon`          | `AnimatedIconData`  | **required** | The animated icon data (e.g., `AnimatedIcons.menu_arrow`). |
| `progress`      | `Animation<double>` | **required** | Animation progress from 0.0 to 1.0.                        |
| `color`         | `Color?`            | `null`       | Icon color. Defaults to `theme.textColor`.                 |
| `size`          | `double?`           | `null`       | Icon size.                                                 |
| `semanticLabel` | `String?`           | `null`       | Accessibility label.                                       |
| `textDirection` | `TextDirection?`    | `null`       | Text direction for the icon.                               |

---

## WiredMaterialBanner

A banner with a hand-drawn border displayed at the top of the scaffold. Contains a message and action buttons.

<!-- {=docsMaterialBannerUsage} -->

```dart
ScaffoldMessenger.of(context).showMaterialBanner(
  WiredMaterialBanner(
    content: Text('New version available'),
    actions: [
      WiredTextButton(
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
        child: Text('Dismiss'),
      ),
      WiredButton(
        onPressed: () => updateApp(),
        child: Text('Update'),
      ),
    ],
  ),
);
```

---

## WiredCupertinoAlertDialog

A Cupertino-style alert dialog with hand-drawn borders. Mirrors the `CupertinoAlertDialog` API with sketchy styling.

<!-- {=docsCupertinoAlertDialogUsage} -->

```dart
showCupertinoDialog(
  context: context,
  builder: (context) => WiredCupertinoAlertDialog(
    title: Text('Delete Item?'),
    content: Text('This action cannot be undone.'),
    actions: [
      WiredCupertinoButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      WiredCupertinoButton(
        onPressed: () {
          deleteItem();
          Navigator.pop(context);
        },
        child: Text('Delete'),
      ),
    ],
  ),
);
```

---

## WiredCupertinoActionSheet

A Cupertino-style action sheet with hand-drawn borders. Slides up from the bottom of the screen.

<!-- {=docsCupertinoActionSheetUsage} -->

```dart
showCupertinoModalPopup(
  context: context,
  builder: (context) => WiredCupertinoActionSheet(
    title: Text('Choose an option'),
    actions: [
      WiredCupertinoButton(
        onPressed: () => Navigator.pop(context, 'camera'),
        child: Text('Take Photo'),
      ),
      WiredCupertinoButton(
        onPressed: () => Navigator.pop(context, 'gallery'),
        child: Text('Choose from Gallery'),
      ),
    ],
    cancelButton: WiredCupertinoButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'),
    ),
  ),
);
```
