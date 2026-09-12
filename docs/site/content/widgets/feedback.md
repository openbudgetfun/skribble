---
title: Feedback
description: Hand-drawn dialogs, snack bars, tooltips, progress indicators, and other feedback widgets in the Skribble design system.
---

# Feedback

Skribble provides feedback widgets that communicate status, confirmations, and progress using sketchy hand-drawn visuals. All feedback widgets read their palette from `WiredTheme.of(context)`.

---

## WiredDialog

A dialog with a hand-drawn rectangle border drawn behind the content. Uses Flutter's `Dialog` widget internally.

```dart
// Live example: dialog
Builder(
  builder: (context) => WiredButton(
    child: const Text('Open a little dialog'),
    onPressed: () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close dialog',
      pageBuilder: (context, animation, secondaryAnimation) => WiredDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Make something lovely'),
            WiredTextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Lovely'),
            ),
          ],
        ),
      ),
    ),
  ),
)
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

```dart
// Live example: snack-bar-content
WiredSnackBarContent(
  action: WiredTextButton(onPressed: () {}, child: const Text('Undo')),
  child: Text('Make something lovely'),
)
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

```dart
// Live example: tooltip
WiredTooltip(
  message: 'Make something lovely',
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Hover or long press here'),
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

```dart
// Live example: progress
HookBuilder(
  builder: (context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 600),
      initialValue: 1,
    );
    return WiredProgress(controller: controller, value: .6);
  },
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

```dart
// Live example: circular-progress
WiredCircularProgress(value: .6)
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

```dart
// Live example: badge
WiredBadge(
  label: '3',
  isVisible: true,
  child: const Padding(padding: EdgeInsets.all(16), child: Text('New ideas')),
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

```dart
// Live example: bottom-sheet
Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Make something lovely'),
            WiredTextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
    child: const Text('Open the sheet'),
  ),
)
```

---

## WiredAboutDialog / showWiredAboutDialog

An about dialog with a hand-drawn border, application icon, and version info. The `showWiredAboutDialog` helper function displays it.

```dart
// Live example: about-dialog
Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredAboutDialog(
      context: context,
      applicationName: 'Make something lovely',
      applicationVersion: '1.0',
    ),
    child: const Text('About this sketchbook'),
  ),
)
```

---

## WiredLicensePage / showWiredLicensePage

A hand-drawn license page listing the open source packages the app uses, analogous to Material's `LicensePage`. Data is read from `LicenseRegistry` (each entry contributes its paragraphs to every package it names), so the page reflects the same license inventory as Material's page. Each package renders as a rough-bordered header with its license paragraphs beneath a hand-drawn divider.

```dart
// Live example: license-page
Builder(
  builder: (context) => WiredButton(
    onPressed: () =>
        showWiredLicensePage(context: context, applicationName: 'Make something lovely'),
    child: const Text('Read the licenses'),
  ),
)
```

Also exported: `loadWiredLicenses()` and `WiredLicenseLibrary` for callers that want the aggregated package/paragraph data.

### Constructor parameters

| Parameter            | Type                 | Default              | Description                                    |
| -------------------- | -------------------- | -------------------- | ---------------------------------------------- |
| `applicationName`    | `String?`            | `'This app'`         | name in the page header.                       |
| `applicationVersion` | `String?`            | `null`               | Version line under the header.                 |
| `applicationIcon`    | `Widget?`            | `null`               | Icon (typically a logo) above the header text. |
| `padding`            | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | Padding around the scrollable license list.    |

### Notes

- `showWiredLicensePage` pushes a full-screen route wrapping the page in a wired scaffold with a "Licenses" app bar and back button.
- While licenses load asynchronously the page shows a wired spinner, then a "Built with N open source packages" summary line.
- Packages are listed alphabetically and deduplicated by name.

---

## WiredContextMenu

A context menu with hand-drawn borders, triggered by long-press or right-click. Menu items appear in a sketchy bordered overlay.

```dart
// Live example: context-menu
WiredContextMenu(
  actions: [
    WiredContextMenuAction(label: 'Save', onPressed: () {}),
    WiredContextMenuAction(label: 'Share', onPressed: () {}),
  ],
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text('Make something lovely'),
  ),
)
```

---

## WiredAnimatedIcon

A hand-drawn wrapper around Flutter's `AnimatedIcon`. Applies Skribble theming to animated icon transitions.

```dart
// Live example: animated-icon
HookBuilder(
  builder: (context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 350),
    );
    final open = useState(false);
    return WiredButton(
      onPressed: () {
        open.value = !open.value;
        if (MediaQuery.disableAnimationsOf(context)) {
          controller.value = open.value ? 1 : 0;
        } else if (open.value) {
          controller.forward();
        } else {
          controller.reverse();
        }
      },
      child: WiredAnimatedIcon.menuClose(
        progress: controller,
        semanticLabel: open.value ? 'Close' : 'Open menu',
      ),
    );
  },
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

```dart
// Live example: material-banner
HookBuilder(
  builder: (context) {
    final visible = useState(true);
    return visible.value
        ? WiredMaterialBanner(
            content: Text('Make something lovely'),
            backgroundColor: const Color(0xffdde4c9),
            actions: [
              WiredTextButton(
                onPressed: () => visible.value = false,
                child: const Text('Got it'),
              ),
            ],
          )
        : WiredTextButton(
            onPressed: () => visible.value = true,
            child: const Text('Show banner'),
          );
  },
)
```

---

## WiredCupertinoAlertDialog

A Cupertino-style alert dialog with hand-drawn borders. Mirrors the `CupertinoAlertDialog` API with sketchy styling.

```dart
// Live example: cupertino-alert-dialog
Builder(
  builder: (context) => WiredButton(
    child: const Text('Show an alert'),
    onPressed: () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close alert',
      pageBuilder: (context, animation, secondaryAnimation) =>
          WiredCupertinoAlertDialog(
            title: Text('Make something lovely'),
            content: const Text('Your sketch is ready to keep.'),
            actions: [
              WiredCupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep it'),
              ),
            ],
          ),
    ),
  ),
)
```

---

## WiredCupertinoActionSheet

A Cupertino-style action sheet with hand-drawn borders. Slides up from the bottom of the screen.

```dart
// Live example: cupertino-action-sheet
Builder(
  builder: (context) => WiredButton(
    child: const Text('Choose what happens next'),
    onPressed: () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close actions',
      pageBuilder: (context, animation, secondaryAnimation) => Align(
        alignment: Alignment.bottomCenter,
        child: WiredCupertinoActionSheet(
          title: Text('Make something lovely'),
          actions: [
            WiredCupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save the sketch'),
            ),
          ],
          cancelButton: WiredCupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
      ),
    ),
  ),
)
```

<!-- {=docsWidgetInkSection} -->

## Shared ink and typography

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (2.4 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->

## More loading styles

See [Loaders and skeletons](/widgets/loading) for six animated ink rhythms, drawing flourishes, pencil placeholders, and overlays that preserve component layout. `WiredLoadingIndicator` now shares the orbit renderer and respects reduced motion and disabled ticker scopes.
