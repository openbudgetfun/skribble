---
title: Cupertino Parity
description: Hand-drawn Cupertino-style widgets in Skribble — activity indicators, list sections, search fields, timer pickers, and form sections.
---

# Cupertino Parity

Skribble ships hand-drawn equivalents for the most common `Cupertino` widgets. All `wired_cupertino_*` widgets keep the "Wired" prefix, are built as `HookWidget`s, and draw their chrome exclusively with the rough engine (`WiredCanvas` + `WiredPainterBase` painters) — nothing is a skin over a Cupertino widget. Every widget reads its palette from `WiredTheme.of(context)`.

This page is the catalog for the full `wired_cupertino_*` family: the widgets added in the parity batch (`WiredCupertinoActivityIndicator`, `WiredCupertinoListSection`, `WiredCupertinoListTile`, `WiredCupertinoSearchTextField`, `WiredCupertinoTimerPicker`, `WiredCupertinoFormSection`) plus the existing cupertino counterparts.

---

## WiredCupertinoActivityIndicator

An iOS-style sunburst spinner drawn with hand-drawn strokes. Each of the twelve radial segments is a jittered tick that fades out behind the leading segment, and the whole set rotates continuously while `animating` is true.

```dart
WiredCupertinoActivityIndicator(
  animating: true,
  radius: 12,
)
```

### Constructor parameters

| Parameter       | Type      | Default            | Description                                                            |
| --------------- | --------- | ------------------ | ---------------------------------------------------------------------- |
| `animating`     | `bool`    | `true`             | When false, the spinner renders statically and schedules no frames.     |
| `radius`        | `double`  | `10`               | Radius of the spinner; the widget is a `2 * radius` square.             |
| `color`         | `Color?`  | `theme.borderColor`| Color of the leading segments; trailing segments fade to transparent.  |
| `strokeWidth`   | `double`  | `2`                | Stroke width of each hand-drawn tick.                                  |
| `segmentCount`  | `int`     | `12`               | Number of segments around the circle (at least 2).                     |
| `semanticLabel` | `String?` | `null`             | Optional label exposed to screen readers (e.g. "Loading").             |

### Notes

- Animate via `useEffect` + `AnimationController.repeat()`, mirroring `WiredLoadingIndicator`.
- `animating: false` is idle-safe for tests that use `pumpAndSettle`.

---

## WiredCupertinoListSection

An inset-grouped list section, equivalent to `CupertinoListSection.insetGrouped`. Wraps its children (typically `WiredCupertinoListTile`s) in a single hand-drawn rounded-rectangle card and draws a sketchy separator line between each row. Optional header/footer text renders in a 13px footnote style.

```dart
WiredCupertinoListSection(
  header: Text('Documents'),
  footer: Text('Shared with your team.'),
  children: [
    WiredCupertinoListTile(title: Text('Roadmap.pdf'), onTap: () {}),
    WiredCupertinoListTile(title: Text('Budget Q3.key'), onTap: () {}),
  ],
)
```

### Constructor parameters

| Parameter          | Type                | Default                                        | Description                                        |
| ------------------ | ------------------- | ---------------------------------------------- | -------------------------------------------------- |
| `children`         | `List<Widget>`      | **required**                                   | Rows of the section, usually list tiles.           |
| `header`           | `Widget?`           | `null`                                         | Small helper text above the group.                 |
| `footer`           | `Widget?`           | `null`                                         | Small footnote text below the group.               |
| `margin`           | `EdgeInsetsGeometry`| `horizontal: 16, vertical: 8`                  | Outer margin around the whole section.             |
| `backgroundColor`  | `Color?`            | `theme.fillColor`                              | Fill color of the group card.                      |
| `separatorIndent`  | `double`            | `16`                                           | Leading inset for the hand-drawn separators.       |

---

## WiredCupertinoListTile

An iOS-style list tile with the same leading / title / subtitle / trailing API as `CupertinoListTile`, plus an `additionalTrailingText` detail label. The whole row is tappable and exposed as a button to assistive tech.

```dart
WiredCupertinoListTile(
  leading: Text('📄'),
  title: Text('Roadmap.pdf'),
  subtitle: Text('Updated yesterday'),
  additionalTrailingText: '2 MB',
  trailing: Text('›'),
  onTap: () {},
)
```

### Constructor parameters

| Parameter                | Type                 | Default                                   | Description                                                |
| ------------------------ | -------------------- | ----------------------------------------- | ---------------------------------------------------------- |
| `leading`                | `Widget?`            | `null`                                    | Widget at the start of the tile.                           |
| `title`                  | `Widget?`            | `null`                                    | Primary content (17px `theme.textColor`).                  |
| `subtitle`               | `Widget?`            | `null`                                    | Secondary content (14px `theme.disabledTextColor`).        |
| `trailing`               | `Widget?`            | `null`                                    | Widget at the end of the tile (e.g. a chevron).            |
| `additionalTrailingText` | `String?`            | `null`                                    | Small detail label before the trailing widget.             |
| `onTap`                  | `VoidCallback?`      | `null`                                    | Called when the tile is tapped.                            |
| `backgroundColor`        | `Color?`             | `null`                                    | Hand-drawn solid fill behind the tile when set.            |
| `padding`                | `EdgeInsetsGeometry?`| `horizontal: 16, vertical: 10`            | Padding around the tile content.                           |
| `semanticLabel`          | `String?`            | `null`                                    | Optional semantic label; the tile is a button when tappable.|

### Notes

- Requires `title` or `subtitle` (at least one must be provided).
- The tap target spans the full row width (`HitTestBehavior.opaque`).

---

## WiredCupertinoSearchTextField

A stadium-shaped search input equivalent to `CupertinoSearchTextField`. It has a hand-drawn rounded border, a sketchy rough magnifier prefix glyph, placeholder support, and submit handling. Built on `EditableText` (flutter/widgets only).

```dart
WiredCupertinoSearchTextField(
  placeholder: 'Search widgets',
  onSubmitted: (query) => runSearch(query),
)
```

### Constructor parameters

| Parameter           | Type                   | Default                      | Description                                                    |
| ------------------- | ---------------------- | ---------------------------- | -------------------------------------------------------------- |
| `controller`        | `TextEditingController?`| `null` — creates one        | Controls the text being edited.                                |
| `placeholder`       | `String?`              | `null`                       | Shown when the field is empty, hidden while typing.            |
| `placeholderStyle`  | `TextStyle?`           | 14px disabled color          | Style for the placeholder.                                     |
| `style`             | `TextStyle?`           | 17px `theme.textColor`       | Style for the input text.                                      |
| `onChanged`         | `ValueChanged<String>?`| `null`                       | Called on every text change.                                   |
| `onSubmitted`       | `ValueChanged<String>?`| `null`                       | Called when the search action fires.                           |
| `prefixWidget`      | `Widget?`              | sketchy magnifier glyph      | Widget before the text.                                        |
| `suffixWidget`      | `Widget?`              | `null`                       | Widget after the text.                                         |
| `enabled`           | `bool`                 | `true`                       | Disabled fields are read-only at 40% opacity.                  |
| `autofocus`         | `bool`                 | `false`                      | Requests focus on first build.                                 |
| `focusNode`         | `FocusNode?`           | `null` — creates one         | Focus node for the field.                                      |
| `textInputAction`   | `TextInputAction?`     | `.search`                    | Keyboard submit action.                                        |
| `height`            | `double`               | `36`                         | Field height.                                                  |
| `borderRadius`      | `BorderRadius?`        | stadium matching `height`    | Hand-drawn border radius.                                      |
| `semanticLabel`     | `String?`              | `null`                       | Optional semantic label.                                       |

---

## WiredCupertinoTimerPicker

An iOS timer picker built by composing hour / minute / second wheels on top of `WiredCupertinoPicker`, so the sketches on the borders and center highlight come straight from the picker internals. Modes: `hm` (default), `hms`, and `ms`. Wheel granularity is controlled with `minuteInterval` / `secondInterval` (both must evenly divide 60).

```dart
WiredCupertinoTimerPicker(
  mode: WiredCupertinoTimerPickerMode.hms,
  initialTimerDuration: Duration(hours: 1, minutes: 30),
  onTimerDurationChanged: (duration) => setState(...),
)
```

### Constructor parameters

| Parameter              | Type                             | Default   | Description                                             |
| ---------------------- | -------------------------------- | --------- | ------------------------------------------------------- |
| `onTimerDurationChanged`| `ValueChanged<Duration>`        | **required** | Called whenever any wheel settles.                  |
| `initialTimerDuration` | `Duration`                       | `zero`    | Used only when the widget is first built.               |
| `mode`                 | `WiredCupertinoTimerPickerMode`  | `.hm`     | Which wheels to show (`hm`, `hms`, `ms`).               |
| `minuteInterval`       | `int`                            | `1`       | Granularity of the minutes wheel; divides 60.           |
| `secondInterval`       | `int`                            | `1`       | Granularity of the seconds wheel; divides 60.           |
| `itemExtent`           | `double`                         | `32`      | Height of each wheel item.                              |
| `height`               | `double`                         | `216`     | Total height of the picker.                             |

---

## WiredCupertinoFormSection

A grouped form-section wrapper equivalent to `CupertinoFormSection.insetGrouped`. Children sit in one hand-drawn rounded rectangle with sketchy dividers between rows, plus optional header/footer text. Unlike `WiredCupertinoListSection`, the group is left unfilled so nested inputs keep a clean paper background.

```dart
WiredCupertinoFormSection(
  header: Text('Account'),
  footer: Text('Changes sync to all devices.'),
  children: [
    WiredInput(labelText: 'Name'),
    WiredInput(labelText: 'Email'),
  ],
)
```

### Constructor parameters

| Parameter        | Type                 | Default                                        | Description                                 |
| ---------------- | -------------------- | ---------------------------------------------- | ------------------------------------------- |
| `children`       | `List<Widget>`       | **required**                                   | Rows of the section, e.g. inputs and tiles. |
| `header`         | `Widget?`            | `null`                                         | Small helper text above the group.          |
| `footer`         | `Widget?`            | `null`                                         | Small footnote text below the group.        |
| `margin`         | `EdgeInsetsGeometry` | `horizontal: 16, vertical: 8`                  | Outer margin around the whole section.      |
| `dividerIndent`  | `double`             | `16`                                           | Leading inset for the hand-drawn dividers.  |

---

## Existing cupertino widgets

The widgets below were part of earlier releases and keep their individual APIs:

| Widget                           | Replaces (Cupertino)     | Docs location        |
| -------------------------------- | ------------------------ | -------------------- |
| `WiredCupertinoButton`           | `CupertinoButton`        | Buttons page         |
| `WiredCupertinoTextField`        | `CupertinoTextField`     | Inputs page          |
| `WiredCupertinoSlider`           | `CupertinoSlider`        | Inputs page          |
| `WiredCupertinoPicker`           | `CupertinoPicker`        | Selection page       |
| `WiredCupertinoDatePicker`       | `CupertinoDatePicker`    | Selection page       |
| `WiredCupertinoSegmentedControl` | `CupertinoSegmentedControl` | Selection page    |
| `WiredCupertinoSwitch`           | `CupertinoSwitch`        | Selection page       |
| `WiredCupertinoNavigationBar`    | `CupertinoNavigationBar` | Navigation page      |
| `WiredCupertinoTabBar`           | `CupertinoTabBar`        | Navigation page      |
| `WiredCupertinoScaffold`         | `CupertinoPageScaffold`  | Layout page          |
| `WiredCupertinoAlertDialog`      | `CupertinoAlertDialog`   | Feedback page        |
| `WiredCupertinoActionSheet`      | `CupertinoActionSheet`   | Feedback page        |