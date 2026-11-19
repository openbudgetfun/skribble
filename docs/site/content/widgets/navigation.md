---
title: Navigation
description: Hand-drawn app bars, navigation bars, drawers, tabs, and menus in the skribble design system.
---

# Navigation

skribble provides navigation chrome that replaces Material and Cupertino navigation components with sketchy, hand-drawn variants. Every widget reads its palette from `WiredTheme.of(context)`.

---

## WiredAppBar

An app bar with a hand-drawn bottom border line. Implements `PreferredSizeWidget` so it can be used directly in `WiredScaffold.appBar`.

```dart
// Live example: app-bar
WiredAppBar(title: Text('Make something lovely'))
```

### Constructor parameters

| Parameter         | Type            | Default | Description                                  |
| ----------------- | --------------- | ------- | -------------------------------------------- |
| `title`           | `Widget?`       | `null`  | Title widget, rendered with bold 20px text.  |
| `leading`         | `Widget?`       | `null`  | Widget before the title (e.g., menu button). |
| `actions`         | `List<Widget>?` | `null`  | Action widgets at the trailing edge.         |
| `height`          | `double`        | `56.0`  | App bar height.                              |
| `backgroundColor` | `Color?`        | `null`  | Background color. Defaults to transparent.   |

### Notes

- The bottom border is a 2px `WiredLineBase` spanning full width.
- Title text uses `theme.textColor` at 20px bold, stays on one line, and ends with an ellipsis when it does not fit.
- Like Material's `AppBar`, the title follows the platform's text scaling up to 1.34 times, so a large setting cannot push it out of the bar's fixed height. `leading` and `actions` share the limit, so a text button there keeps its ink padding.
- Screen readers hear the title as a header.
- Wrapped in `SafeArea(bottom: false)` to respect system UI.

---

## WiredBottomNavigationBar

A bottom navigation bar with hand-drawn circle selection indicators around active icons.

```dart
// Live example: bottom-navigation-bar
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredBottomNavigationBar(
      currentIndex: selected.value,
      onTap: (index) => selected.value = index,
      items: const [
        WiredBottomNavItem(
          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
          label: 'Home',
        ),
        WiredBottomNavItem(
          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
          label: 'Saved',
        ),
      ],
    );
  },
)
```

### WiredBottomNavItem parameters

| Parameter | Type       | Description                |
| --------- | ---------- | -------------------------- |
| `icon`    | `IconData` | The icon for this tab.     |
| `label`   | `String`   | Text label below the icon. |

### WiredBottomNavigationBar parameters

| Parameter      | Type                       | Default      | Description                  |
| -------------- | -------------------------- | ------------ | ---------------------------- |
| `items`        | `List<WiredBottomNavItem>` | **required** | Tab items.                   |
| `currentIndex` | `int`                      | `0`          | Currently selected index.    |
| `onTap`        | `ValueChanged<int>?`       | `null`       | Called when a tab is tapped. |

### Notes

- At least 60px tall plus the top border line, and taller when large text needs it.
- Pads itself above the home indicator and other bottom insets of notched phones.
- Selected items show a 32px `WiredCircleBase` behind the icon.
- Unselected items use `theme.disabledTextColor`.
- Each item takes keyboard focus (Enter or Space selects it) and is announced as a selectable button with its label.

---

## WiredNavigationBar

A Material 3 style navigation bar with hand-drawn rounded rectangle selection indicators, mirroring Material's `NavigationBar`: `selectedIcon`, label behaviour, badges, disabled destinations, and colour-coded washes.

```dart
// Live example: navigation-bar
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredNavigationBar(
      selectedIndex: selected.value,
      onDestinationSelected: (index) => selected.value = index,
      destinations: const [
        WiredNavigationDestination(
          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
          label: 'Home',
        ),
        WiredNavigationDestination(
          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
          label: 'Saved',
        ),
      ],
    );
  },
)
```

### Labels, badges, and colour

Give each destination its own wash with `colorCoded`, hide the quieter labels on a crowded phone with `labelBehavior`, put counts on icons with `badge`, and keep one loud "create" destination with `isPrimaryAction`.

```dart
// Live example: navigation-bar-vivid
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredNavigationBar(
      selectedIndex: selected.value,
      onDestinationSelected: (index) => selected.value = index,
      colorCoded: true,
      labelBehavior: WiredNavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        WiredNavigationDestination(
          icon: IconData(0xe248, fontFamily: 'MaterialIcons'),
          label: 'Discover',
        ),
        WiredNavigationDestination(
          icon: IconData(0xe3c3, fontFamily: 'MaterialIcons'),
          label: 'Inbox',
          badge: '3',
        ),
        WiredNavigationDestination(
          icon: IconData(0xe44f, fontFamily: 'MaterialIcons'),
          label: 'Alerts',
          badge: '',
        ),
        WiredNavigationDestination(
          icon: IconData(0xe0b7, fontFamily: 'MaterialIcons'),
          label: 'Create',
          isPrimaryAction: true,
        ),
      ],
    );
  },
)
```

### WiredNavigationDestination parameters

| Parameter         | Type        | Default      | Description                                                                        |
| ----------------- | ----------- | ------------ | ---------------------------------------------------------------------------------- |
| `icon`            | `IconData`  | **required** | Default icon.                                                                      |
| `selectedIcon`    | `IconData?` | `null`       | Icon shown when selected. Falls back to `icon`.                                    |
| `label`           | `String`    | **required** | Text label below the icon, also read by screen readers.                            |
| `tooltip`         | `String?`   | `null`       | Tooltip for screen readers. Defaults to `label` when the label is hidden.          |
| `enabled`         | `bool`      | `true`       | A disabled destination dims, ignores taps, and leaves focus traversal.             |
| `badge`           | `String?`   | `null`       | A hand-drawn badge on the icon: `'3'` for a count, `''` for a dot.                 |
| `color`           | `Color?`    | `null`       | This destination's wash when selected, such as `theme.accentAt(i)`.                |
| `isPrimaryAction` | `bool`      | `false`      | Keeps the icon on a wash of `color` or the theme's `accentColor`, selected or not. |

### WiredNavigationBar parameters

| Parameter               | Type                                      | Default      | Description                                                                     |
| ----------------------- | ----------------------------------------- | ------------ | ------------------------------------------------------------------------------- |
| `destinations`          | `List<WiredNavigationDestination>`        | **required** | Navigation destinations.                                                        |
| `selectedIndex`         | `int`                                     | `0`          | Currently selected destination index.                                           |
| `onDestinationSelected` | `ValueChanged<int>?`                      | `null`       | Called when a destination is tapped.                                            |
| `labelBehavior`         | `WiredNavigationDestinationLabelBehavior` | `alwaysShow` | `alwaysShow`, `onlyShowSelected`, or `alwaysHide`, as in Material.              |
| `height`                | `double`                                  | `80`         | Minimum height, not counting the top line or bottom safe area.                  |
| `backgroundColor`       | `Color?`                                  | `null`       | Paper behind the bar. Defaults to transparent.                                  |
| `indicatorColor`        | `Color?`                                  | `null`       | Wash behind the selected destination. Defaults to `markerColor`.                |
| `colorCoded`            | `bool`                                    | `false`      | Washes each destination with `theme.accentAt(index)` when it is selected.       |
| `animationDuration`     | `Duration`                                | `420ms`      | How long the wash takes to pop in and draw. `Duration.zero` switches instantly. |
| `semanticLabel`         | `String?`                                 | `null`       | Label for the bar as a whole. Defaults to "Navigation bar".                     |

### Notes

- At least `height` (80px) tall plus the top border line, and taller when large text needs it.
- Destinations share the bar's width equally, as Material's do.
- Pads itself above the home indicator and other bottom insets of notched phones.
- The selection indicator is a 64x34 rounded rectangle washed with `markerColor` (or the destination's colour), with the icon in `theme.onColor(wash)` on top. It pops in on a spring while its ink draws on, and appears at once when motion is off.
- Selected labels use bold weight; unselected labels use `theme.disabledTextColor`.
- Each destination takes keyboard focus and is announced as a selectable button with its label. A hidden label is still announced, with the label as its tooltip.

---

## WiredNavigationRail

A vertical navigation rail with hand-drawn rounded rectangle selection indicators, mirroring Material's `NavigationRail`. Best for desktop and tablet layouts.

The selection indicator is 56 by 40, leaving 8 pixels around the icon, and each destination grows with its label.

```dart
// Live example: navigation-rail
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return SizedBox(
      height: 240,
      child: WiredNavigationRail(
        selectedIndex: selected.value,
        onDestinationSelected: (index) => selected.value = index,
        destinations: const [
          WiredNavigationRailDestination(
            icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
            label: 'Home',
          ),
          WiredNavigationRailDestination(
            icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
            label: 'Saved',
          ),
        ],
      ),
    );
  },
)
```

### Extended rail

Set `extended` to spring the rail open to `minExtendedWidth`, with each label beside its icon. Tap the menu button to fold it back.

```dart
// Live example: navigation-rail-extended
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    final extended = useState(true);
    return SizedBox(
      height: 300,
      child: WiredNavigationRail(
        extended: extended.value,
        colorCoded: true,
        selectedIndex: selected.value,
        onDestinationSelected: (index) => selected.value = index,
        leading: WiredIconButton(
          icon: const IconData(0xe3dc, fontFamily: 'MaterialIcons'),
          tooltip: extended.value ? 'Collapse' : 'Expand',
          onPressed: () => extended.value = !extended.value,
        ),
        destinations: const [
          WiredNavigationRailDestination(
            icon: IconData(0xe33a, fontFamily: 'MaterialIcons'),
            label: 'Inbox',
            badge: '12',
          ),
          WiredNavigationRailDestination(
            icon: IconData(0xe571, fontFamily: 'MaterialIcons'),
            label: 'Sent',
          ),
          WiredNavigationRailDestination(
            icon: IconData(0xe205, fontFamily: 'MaterialIcons'),
            label: 'Drafts',
          ),
        ],
      ),
    );
  },
)
```

### WiredNavigationRailDestination parameters

| Parameter      | Type        | Default      | Description                                                               |
| -------------- | ----------- | ------------ | ------------------------------------------------------------------------- |
| `icon`         | `IconData`  | **required** | Default icon.                                                             |
| `selectedIcon` | `IconData?` | `null`       | Icon when selected. Falls back to `icon`.                                 |
| `label`        | `String`    | **required** | Text label, also read by screen readers.                                  |
| `tooltip`      | `String?`   | `null`       | Tooltip for screen readers. Defaults to `label` when the label is hidden. |
| `disabled`     | `bool`      | `false`      | A disabled destination dims, ignores taps, and leaves focus traversal.    |
| `badge`        | `String?`   | `null`       | A hand-drawn badge on the icon: `'12'` for a count, `''` for a dot.       |
| `color`        | `Color?`    | `null`       | This destination's wash when selected, such as `theme.accentAt(i)`.       |

### WiredNavigationRail parameters

| Parameter               | Type                                   | Default      | Description                                                                    |
| ----------------------- | -------------------------------------- | ------------ | ------------------------------------------------------------------------------ |
| `destinations`          | `List<WiredNavigationRailDestination>` | **required** | Rail destinations.                                                             |
| `selectedIndex`         | `int?`                                 | `0`          | Currently selected destination index, or `null` for none.                      |
| `onDestinationSelected` | `ValueChanged<int>?`                   | `null`       | Called when a destination is tapped.                                           |
| `leading`               | `Widget?`                              | `null`       | Widget above the destinations (e.g., a FAB or menu button).                    |
| `trailing`              | `Widget?`                              | `null`       | Widget below the destinations, pushed to the bottom.                           |
| `extended`              | `bool`                                 | `false`      | Springs the rail to `minExtendedWidth` with labels beside the icons.           |
| `labelType`             | `WiredNavigationRailLabelType`         | `all`        | `none`, `selected`, or `all` labels under the icons of a compact rail.         |
| `groupAlignment`        | `double`                               | `-1`         | Where the destinations sit: -1 top, 0 centre, 1 bottom.                        |
| `minWidth`              | `double`                               | `72`         | Width of a compact rail.                                                       |
| `minExtendedWidth`      | `double`                               | `256`        | Width of an extended rail.                                                     |
| `backgroundColor`       | `Color?`                               | `null`       | Paper behind the rail. Defaults to transparent.                                |
| `indicatorColor`        | `Color?`                               | `null`       | Wash behind the selected destination. Defaults to `markerColor`.               |
| `useIndicator`          | `bool`                                 | `true`       | When false, only the ink and bold label mark the selection.                    |
| `colorCoded`            | `bool`                                 | `false`      | Washes each destination with `theme.accentAt(index)` when it is selected.      |
| `animationDuration`     | `Duration`                             | `420ms`      | How long the wash and the width change take. `Duration.zero` switches at once. |
| `scrollable`            | `bool`                                 | `false`      | Scrolls the destinations when they do not fit, instead of overflowing.         |
| `semanticLabel`         | `String?`                              | `null`       | Label for the rail as a whole.                                                 |

### Notes

- A compact rail is `minWidth` (72px) wide with a hand-drawn vertical divider line on the right edge.
- The compact selection indicator is a 56x40 rounded rectangle washed with `markerColor` (or the destination's colour), with the icon in `theme.onColor(wash)`. An extended rail washes the whole row, label included.
- Each compact destination is at least 56px tall with 4px vertical spacing.
- While the rail springs open it keeps the compact layout until there is room for a label beside the icon, so nothing overflows mid-animation.
- Destinations take keyboard focus: the arrow keys move between them and Enter or Space selects one. Screen readers hear each as a selectable button, including hidden labels.

---

## WiredNavigationDrawer

A side navigation drawer with a hand-drawn border. Displays a list of navigation destinations with sketchy selection indicators.

Destinations are at least 48 pixels tall, grow with their label, and keep it centred, clear of the selection ink. Each takes keyboard focus and is announced as a selectable button.

```dart
// Live example: navigation-drawer
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return SizedBox(
      height: 220,
      child: WiredNavigationDrawer(
        selectedIndex: selected.value,
        onDestinationSelected: (index) => selected.value = index,
        destinations: const [
          WiredNavigationDrawerDestination(
            icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
            label: 'Home',
          ),
          WiredNavigationDrawerDestination(
            icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
            label: 'Saved',
          ),
        ],
      ),
    );
  },
)
```

### Notes

- Use inside `WiredScaffold.drawer` or `WiredScaffold.endDrawer`.
- Children can include `WiredDrawerHeader`, `WiredDivider`, and any other widgets.

---

## WiredTabBar

A tab bar with hand-drawn underline indicators. Each tab label gets a sketchy line beneath it when selected.

```dart
// Live example: tab-bar
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredTabBar(
      tabs: const ['Ideas', 'Sketches', 'Notes'],
      selectedIndex: selected.value,
      onTap: (index) => selected.value = index,
    );
  },
)
```

### Notes

- `WiredTabBar` is controlled: pass `selectedIndex` and update it from `onTap`. Pair it with an `IndexedStack` or a `PageView` for the content.
- The active tab indicator is a hand-drawn line using `WiredLineBase`, drawn below the label so it never crosses its letters.
- Labels stay on one line. When narrow screens or large text leave too little room, a label shrinks to fit and ends with an ellipsis only past its floor.
- The bar is at least `height` tall and grows with large text, keeping 8 pixels between each label and its underline. In a fixed slot, such as an app bar's `bottom`, it is exactly `height` tall.
- Tabs take keyboard focus: the arrow keys move between them and Enter or Space selects one. Screen readers hear each tab as a selectable button with its position, such as `Sketches, tab 2 of 3`.

---

## WiredDrawer

A hand-drawn drawer panel with a sketchy border, suitable for side menus.

```dart
// Live example: drawer
SizedBox(
  height: 180,
  child: WiredDrawer(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text('Make something lovely'),
    ),
  ),
)
```

---

## WiredPopupMenuButton

A popup menu triggered by a button press. Menu items appear in a hand-drawn bordered overlay.

```dart
// Live example: popup-menu-button
HookBuilder(
  builder: (context) {
    final selected = useState('Choose an action');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredPopupMenuButton<String>(
          items: const [
            WiredPopupMenuItem(value: 'Saved', child: Text('Save')),
            WiredPopupMenuItem(value: 'Shared', child: Text('Share')),
          ],
          onSelected: (value) => selected.value = value,
        ),
        Text(selected.value),
      ],
    );
  },
)
```

### Notes

- The menu's outline uses the theme's `strokeWidth`, and each item keeps `kWiredInkPadding` inside its hand-drawn box.

---

## WiredMenuBar

A horizontal menu bar with hand-drawn borders, suitable for desktop-style navigation.

```dart
// Live example: menu-bar
WiredMenuBar(
  children: [
    WiredSubmenuButton(
      menuChildren: [
        WiredMenuItemButton(onPressed: () {}, child: const Text('New sketch')),
        WiredMenuItemButton(onPressed: () {}, child: const Text('Save sketch')),
      ],
      child: Text('Make something lovely'),
    ),
  ],
)
```

---

## WiredBottomAppBar

A bottom app bar with a hand-drawn top border. Its content is centred inside the ink padding, and the bar stays above the home indicator on notched phones.

```dart
// Live example: bottom-app-bar
WiredBottomAppBar(child: Text('Make something lovely'))
```

### Constructor parameters

| Parameter     | Type                  | Default                                             | Description                                                         |
| ------------- | --------------------- | --------------------------------------------------- | ------------------------------------------------------------------- |
| `child`       | `Widget?`             | `null`                                              | The bar's content, usually a `Row` of buttons. Centred vertically.  |
| `color`       | `Color?`              | `null`                                              | Background; falls back to `theme.fillColor`.                        |
| `height`      | `double?`             | `56`                                                | Least bar height; the bar grows when its content needs more room.   |
| `padding`     | `EdgeInsetsGeometry?` | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` | Space between the hand-drawn line and `child`.                      |
| `elevation`   | `double?`             | `null`                                              | Kept for parity with `BottomAppBar`; the bar draws no shadow.       |
| `shape`       | `NotchedShape?`       | `null`                                              | Kept for parity with `BottomAppBar`; no notch is cut for a FAB yet. |
| `notchMargin` | `double`              | `4`                                                 | Kept for parity with `BottomAppBar`; see `shape`.                   |

---

## WiredSliverAppBar

A sliver app bar with hand-drawn borders for use in `CustomScrollView`. Supports expanding/collapsing behavior.

```dart
// Live example: sliver-app-bar
SizedBox(
  height: 240,
  child: CustomScrollView(
    slivers: [
      WiredSliverAppBar(
        title: Text('Make something lovely'),
        expandedHeight: 120,
        pinned: true,
      ),
      SliverList.list(
        children: [
          for (var index = 0; index < 8; index++)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sketch ${index + 1}'),
            ),
        ],
      ),
    ],
  ),
)
```

---

## WiredCupertinoNavigationBar

A Cupertino-style navigation bar with hand-drawn borders. Mirrors the `CupertinoNavigationBar` API with sketchy styling.

```dart
// Live example: cupertino-navigation-bar
WiredCupertinoNavigationBar(middle: Text('Make something lovely'))
```

### Notes

- With `middle` unset and `automaticallyImplyMiddle` on (the default), the bar shows a `CupertinoPageRoute`'s `title`, as `CupertinoNavigationBar` does. It never shows a route's name, such as `/settings`.

---

## WiredCupertinoTabBar

A Cupertino-style tab bar with hand-drawn selection indicators. Mirrors the `CupertinoTabBar` API.

```dart
// Live example: cupertino-tab-bar
HookBuilder(
  builder: (context) {
    final selected = useState(0);
    return WiredCupertinoTabBar.destinations(
      currentIndex: selected.value,
      onTap: (index) => selected.value = index,
      items: const [
        WiredBottomNavItem(
          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
          label: 'Home',
        ),
        WiredBottomNavItem(
          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
          label: 'Saved',
        ),
      ],
    );
  },
)
```

---

## WiredCheckboxMenuButton

A menu item showing a hand-drawn checkbox as its leading icon. Mirrors Material's `CheckboxMenuButton`: activating the item toggles the value and (by default) keeps the menu open so several options can be flipped in a row. Best used inside `WiredSubmenuButton` within a `WiredMenuBar`.

```dart
// Live example: checkbox-menu-button
HookBuilder(
  builder: (context) {
    final checked = useState(true);
    return WiredMenuBar(
      children: [
        WiredSubmenuButton(
          menuChildren: [
            WiredCheckboxMenuButton(
              value: checked.value,
              onChanged: (value) => checked.value = value ?? false,
              child: Text('Make something lovely'),
            ),
          ],
          child: const Text('Options'),
        ),
      ],
    );
  },
)
```

### Constructor parameters

| Parameter         | Type                   | Default  | Description                                                         |
| ----------------- | ---------------------- | -------- | ------------------------------------------------------------------- |
| `value`           | `bool?`                | required | Current checked state (`null` = indeterminate).                     |
| `child`           | `Widget`               | required | The item label.                                                     |
| `tristate`        | `bool`                 | `false`  | Whether `null` values are allowed.                                  |
| `onChanged`       | `ValueChanged<bool?>?` | `null`   | Called with the next state on activation; `null` disables the item. |
| `closeOnActivate` | `bool`                 | `false`  | Whether activation closes the containing menu.                      |
| `semanticLabel`   | `String?`              | `null`   | Optional semantic label for the checkbox icon.                      |

### Notes

- The toggle follows Material's cycle: `false → true`, `true → (tristate ? null : false)`, `null → true`.
- The icon reuses the rough-frame checkbox visual (`RoughBoxDecoration` frame around a transparent checkbox) and participates in menu anchoring via `MenuItemButton`.
- The item reports `checked` semantics for screen readers.

---

## WiredRadioMenuButton

A menu item showing a hand-drawn radio button as its leading icon. Mirrors Material's `RadioMenuButton`: activating the item selects `value` within `groupValue`, and the menu closes after activation so selection feels immediate.

```dart
// Live example: radio-menu-button
HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in ['paper', 'ink'])
          WiredRadioMenuButton<String>(
            value: value,
            groupValue: selected.value,
            onChanged: (value) => selected.value = value!,
            child: Text(value),
          ),
      ],
    );
  },
)
```

### Constructor parameters

| Parameter         | Type                | Default  | Description                                                                                |
| ----------------- | ------------------- | -------- | ------------------------------------------------------------------------------------------ |
| `value`           | `T`                 | required | Value this item represents.                                                                |
| `groupValue`      | `T?`                | required | Currently selected value of the radio group.                                               |
| `child`           | `Widget`            | required | The item label.                                                                            |
| `onChanged`       | `ValueChanged<T?>?` | `null`   | Called with `value` on activation (or `null` when `toggleable`); `null` disables the item. |
| `toggleable`      | `bool`              | `false`  | Whether an already-selected item can be deselected.                                        |
| `closeOnActivate` | `bool`              | `true`   | Whether activation closes the containing menu.                                             |
| `semanticLabel`   | `String?`           | `null`   | Optional semantic label for the radio icon.                                                |

### Notes

- The leading icon draws a rough `WiredCircleBase` ring plus a hachure-filled inner dot when selected — the same visual language as `WiredRadio`.
- Reports `checked` semantics so screen readers announce the group state.

---

## WiredAboutListTile

A list tile that opens a hand-drawn about dialog when tapped. Mirrors Material's `AboutListTile`: combines a `WiredListTile` with `showWiredAboutDialog` and the application metadata fields.

```dart
// Live example: about-list-tile
WiredAboutListTile(
  applicationName: 'A little sketchbook',
  applicationVersion: '1.0',
  child: Text('Make something lovely'),
)
```

### Constructor parameters

| Parameter             | Type            | Default | Description                                   |
| --------------------- | --------------- | ------- | --------------------------------------------- |
| `icon`                | `Widget?`       | `null`  | Widget shown at the start of the tile.        |
| `child`               | `Widget?`       | `null`  | Tile content; falls back to `About <name>`.   |
| `applicationName`     | `String?`       | `null`  | Application name shown in the dialog.         |
| `applicationVersion`  | `String?`       | `null`  | Version string shown in the dialog.           |
| `applicationIcon`     | `Widget?`       | `null`  | Application icon shown in the dialog.         |
| `applicationLegalese` | `String?`       | `null`  | Legal text shown at the bottom of the dialog. |
| `aboutBoxChildren`    | `List<Widget>?` | `null`  | Extra children below the about information.   |
| `semanticLabel`       | `String?`       | `null`  | Optional semantic label for accessibility.    |

### Notes

- Tapping the tile calls `showWiredAboutDialog` with all application metadata passed through.
- The dialog can be dismissed via its Close button or the modal barrier; use `showLicensePage` from within the dialog for license details.

<!-- {=docsWidgetInkSection} -->

## Shared ink and typography

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (1.6 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->

Shown item labels in `WiredBottomNavigationBar`, `WiredNavigationBar`, `WiredNavigationRail` (beside the icon too, when extended), and `WiredTabBar` stay on one line and fit their item with [`WiredFitText`](layout#wiredfittext): a label too wide for its item shrinks, to no less than three quarters of its size or 9 px, before it ends in an ellipsis. Screen readers still hear the full label.
