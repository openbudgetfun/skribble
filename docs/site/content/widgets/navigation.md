---
title: Navigation
description: Hand-drawn app bars, navigation bars, drawers, tabs, and menus in the Skribble design system.
---

# Navigation

Skribble provides navigation chrome that replaces Material and Cupertino navigation components with sketchy, hand-drawn variants. Every widget reads its palette from `WiredTheme.of(context)`.

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
- Title text uses `theme.textColor` at 20px bold.
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

- Height is 60px plus a 2px top border line.
- Selected items show a 32px `WiredCircleBase` behind the icon.
- Unselected items use `theme.disabledTextColor`.

---

## WiredNavigationBar

A Material 3 style navigation bar with hand-drawn rounded rectangle selection indicators and support for `selectedIcon`.

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

### WiredNavigationDestination parameters

| Parameter      | Type        | Default      | Description                                     |
| -------------- | ----------- | ------------ | ----------------------------------------------- |
| `icon`         | `IconData`  | **required** | Default icon.                                   |
| `selectedIcon` | `IconData?` | `null`       | Icon shown when selected. Falls back to `icon`. |
| `label`        | `String`    | **required** | Text label below the icon.                      |

### WiredNavigationBar parameters

| Parameter               | Type                               | Default      | Description                           |
| ----------------------- | ---------------------------------- | ------------ | ------------------------------------- |
| `destinations`          | `List<WiredNavigationDestination>` | **required** | Navigation destinations.              |
| `selectedIndex`         | `int`                              | `0`          | Currently selected destination index. |
| `onDestinationSelected` | `ValueChanged<int>?`               | `null`       | Called when a destination is tapped.  |

### Notes

- Height is 80px plus a 2px top border line.
- The selection indicator is a 56x28 rounded rectangle with hachure fill (gap: 2.0).
- Selected labels use bold weight; unselected labels use `theme.disabledTextColor`.

---

## WiredNavigationRail

A vertical navigation rail with hand-drawn rounded rectangle selection indicators. Best for desktop and tablet layouts.

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

### WiredNavigationRailDestination parameters

| Parameter      | Type        | Default      | Description                               |
| -------------- | ----------- | ------------ | ----------------------------------------- |
| `icon`         | `IconData`  | **required** | Default icon.                             |
| `selectedIcon` | `IconData?` | `null`       | Icon when selected. Falls back to `icon`. |
| `label`        | `String`    | **required** | Text label below the icon.                |

### WiredNavigationRail parameters

| Parameter               | Type                                   | Default      | Description                                          |
| ----------------------- | -------------------------------------- | ------------ | ---------------------------------------------------- |
| `destinations`          | `List<WiredNavigationRailDestination>` | **required** | Rail destinations.                                   |
| `selectedIndex`         | `int`                                  | `0`          | Currently selected destination index.                |
| `onDestinationSelected` | `ValueChanged<int>?`                   | `null`       | Called when a destination is tapped.                 |
| `leading`               | `Widget?`                              | `null`       | Widget above the destinations (e.g., FAB).           |
| `trailing`              | `Widget?`                              | `null`       | Widget below the destinations, pushed to the bottom. |

### Notes

- Rail width is 72px with a 2px vertical divider line on the right edge.
- The selection indicator is a 48x28 rounded rectangle with hachure fill.
- Each destination is 56px tall with 4px vertical spacing.

---

## WiredNavigationDrawer

A side navigation drawer with a hand-drawn border. Displays a list of navigation destinations with sketchy selection indicators.

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

- Works with a standard `TabController`.
- The active tab indicator is a hand-drawn line using `WiredLineBase`.
- Pair with `TabBarView` for content switching.

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

A bottom app bar with a hand-drawn top border. Can contain actions and an optional notch for a FAB.

```dart
// Live example: bottom-app-bar
WiredBottomAppBar(child: Text('Make something lovely'))
```

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

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (2.4 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->
