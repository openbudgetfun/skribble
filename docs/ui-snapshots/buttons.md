# Button Components

Hand-drawn button variants that give your Flutter app a sketchy, informal look.

## WiredButton

A basic text button wrapped in a rough-drawn rectangular border with thin strokes.

![WiredButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-button.png)

- Default height: 42.0
- Uses `RoughBoxDecoration` with thin border
- Wraps Flutter's `TextButton` internally
- Supports `onPressed` callback

## WiredElevatedButton

A filled button with hachure-pattern fill and shadow offset for a raised appearance.

![WiredElevatedButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-elevated-button.png)

- Hachure fill pattern for the hand-drawn look
- Shadow offset gives depth
- Disabled state supported (no `onPressed`)

## WiredOutlinedButton

An outlined button with thick hand-drawn border and no fill.

![WiredOutlinedButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-outlined-button.png)

- Thick border strokes for emphasis
- No fill, transparent background
- Pairs well with `WiredElevatedButton` for action hierarchy

## WiredTextButton

A minimal text button with a hand-drawn underline instead of a border.

![WiredTextButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-text-button.png)

- No surrounding border
- Sketchy underline drawn beneath text
- Lightweight for inline or secondary actions

## WiredIconButton

An icon button enclosed in a hand-drawn circle.

![WiredIconButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-icon-button.png)

- Circle border drawn with rough strokes
- Accepts any `IconData`
- Commonly used in toolbars and action rows

## WiredFloatingActionButton

A circular FAB with icon, filled with the hachure pattern.

![WiredFloatingActionButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-fab.png)

- Circular shape with hachure fill
- Primary action button for screens
- Pairs with `Scaffold.floatingActionButton`

## WiredSegmentedButton

Connected rounded rectangles forming a segmented toggle control.

![WiredSegmentedButton](https://f005.backblazeb2.com/file/skribble-screenshots/buttons/wired-segmented-button.png)

- Supports single and multi-selection
- Uses `WiredButtonSegment<T>` for each option
- Hand-drawn separators between segments
- Selection indicator via filled segment
