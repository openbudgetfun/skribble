---
title: Navigation
description: Hand-drawn app bars, navigation bars, drawers, tabs, and menus in the Skribble design system.
---

# Navigation

Skribble provides navigation chrome that replaces Material and Cupertino navigation components with sketchy, hand-drawn variants. Every widget reads its palette from `WiredTheme.of(context)`.

---

## WiredAppBar

An app bar with a hand-drawn bottom border line. Implements `PreferredSizeWidget` so it can be used directly in `WiredScaffold.appBar`.

<!-- {=docsAppBarUsage} -->
```dart
WiredAppBar(
  title: Text('My App'),
  leading: WiredIconButton(
    icon: Icons.menu,
    onPressed: () => Scaffold.of(context).openDrawer(),
  ),
  actions: [
    WiredIconButton(icon: Icons.search, onPressed: () {}),
  ],
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `Widget?` | `null` | Title widget, rendered with bold 20px text. |
| `leading` | `Widget?` | `null` | Widget before the title (e.g., menu button). |
| `actions` | `List<Widget>?` | `null` | Action widgets at the trailing edge. |
| `height` | `double` | `56.0` | App bar height. |
| `backgroundColor` | `Color?` | `null` | Background color. Defaults to transparent. |

### Notes

- The bottom border is a 2px `WiredLineBase` spanning full width.
- Title text uses `theme.textColor` at 20px bold.
- Wrapped in `SafeArea(bottom: false)` to respect system UI.

---

## WiredBottomNavigationBar

A bottom navigation bar with hand-drawn circle selection indicators around active icons.

<!-- {=docsBottomNavUsage} -->
```dart
WiredBottomNavigationBar(
  currentIndex: selectedTab,
  onTap: (index) => setState(() => selectedTab = index),
  items: [
    WiredBottomNavItem(icon: Icons.home, label: 'Home'),
    WiredBottomNavItem(icon: Icons.search, label: 'Search'),
    WiredBottomNavItem(icon: Icons.person, label: 'Profile'),
  ],
)
```

### WiredBottomNavItem parameters

| Parameter | Type | Description |
|---|---|---|
| `icon` | `IconData` | The icon for this tab. |
| `label` | `String` | Text label below the icon. |

### WiredBottomNavigationBar parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<WiredBottomNavItem>` | **required** | Tab items. |
| `currentIndex` | `int` | `0` | Currently selected index. |
| `onTap` | `ValueChanged<int>?` | `null` | Called when a tab is tapped. |

### Notes

- Height is 60px plus a 2px top border line.
- Selected items show a 32px `WiredCircleBase` behind the icon.
- Unselected items use `theme.disabledTextColor`.

---

## WiredNavigationBar

A Material 3 style navigation bar with hand-drawn rounded rectangle selection indicators and support for `selectedIcon`.

<!-- {=docsNavigationBarUsage} -->
```dart
WiredNavigationBar(
  selectedIndex: currentIndex,
  onDestinationSelected: (index) => setState(() => currentIndex = index),
  destinations: [
    WiredNavigationDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    WiredNavigationDestination(icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Explore'),
    WiredNavigationDestination(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ],
)
```

### WiredNavigationDestination parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `icon` | `IconData` | **required** | Default icon. |
| `selectedIcon` | `IconData?` | `null` | Icon shown when selected. Falls back to `icon`. |
| `label` | `String` | **required** | Text label below the icon. |

### WiredNavigationBar parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `destinations` | `List<WiredNavigationDestination>` | **required** | Navigation destinations. |
| `selectedIndex` | `int` | `0` | Currently selected destination index. |
| `onDestinationSelected` | `ValueChanged<int>?` | `null` | Called when a destination is tapped. |

### Notes

- Height is 80px plus a 2px top border line.
- The selection indicator is a 56x28 rounded rectangle with hachure fill (gap: 2.0).
- Selected labels use bold weight; unselected labels use `theme.disabledTextColor`.

---

## WiredNavigationRail

A vertical navigation rail with hand-drawn rounded rectangle selection indicators. Best for desktop and tablet layouts.

<!-- {=docsNavigationRailUsage} -->
```dart
WiredNavigationRail(
  selectedIndex: currentIndex,
  onDestinationSelected: (index) => setState(() => currentIndex = index),
  leading: WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
  destinations: [
    WiredNavigationRailDestination(icon: Icons.home, label: 'Home'),
    WiredNavigationRailDestination(icon: Icons.bookmark, label: 'Saved'),
    WiredNavigationRailDestination(icon: Icons.settings, label: 'Settings'),
  ],
)
```

### WiredNavigationRailDestination parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `icon` | `IconData` | **required** | Default icon. |
| `selectedIcon` | `IconData?` | `null` | Icon when selected. Falls back to `icon`. |
| `label` | `String` | **required** | Text label below the icon. |

### WiredNavigationRail parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `destinations` | `List<WiredNavigationRailDestination>` | **required** | Rail destinations. |
| `selectedIndex` | `int` | `0` | Currently selected destination index. |
| `onDestinationSelected` | `ValueChanged<int>?` | `null` | Called when a destination is tapped. |
| `leading` | `Widget?` | `null` | Widget above the destinations (e.g., FAB). |
| `trailing` | `Widget?` | `null` | Widget below the destinations, pushed to the bottom. |

### Notes

- Rail width is 72px with a 2px vertical divider line on the right edge.
- The selection indicator is a 48x28 rounded rectangle with hachure fill.
- Each destination is 56px tall with 4px vertical spacing.

---

## WiredNavigationDrawer

A side navigation drawer with a hand-drawn border. Displays a list of navigation destinations with sketchy selection indicators.

<!-- {=docsNavigationDrawerUsage} -->
```dart
WiredNavigationDrawer(
  selectedIndex: currentIndex,
  onDestinationSelected: (index) => setState(() => currentIndex = index),
  children: [
    WiredDrawerHeader(child: Text('My App')),
    // destinations...
  ],
)
```

### Notes

- Use inside `WiredScaffold.drawer` or `WiredScaffold.endDrawer`.
- Children can include `WiredDrawerHeader`, `WiredDivider`, and any other widgets.

---

## WiredTabBar

A tab bar with hand-drawn underline indicators. Each tab label gets a sketchy line beneath it when selected.

<!-- {=docsTabBarUsage} -->
```dart
WiredTabBar(
  controller: tabController,
  tabs: [
    Tab(text: 'Tab 1'),
    Tab(text: 'Tab 2'),
    Tab(text: 'Tab 3'),
  ],
)
```

### Notes

- Works with a standard `TabController`.
- The active tab indicator is a hand-drawn line using `WiredLineBase`.
- Pair with `TabBarView` for content switching.

---

## WiredDrawer

A hand-drawn drawer panel with a sketchy border, suitable for side menus.

<!-- {=docsDrawerUsage} -->
```dart
WiredScaffold(
  drawer: WiredDrawer(
    child: ListView(
      children: [
        WiredDrawerHeader(child: Text('Menu')),
        WiredListTile(title: Text('Home'), onTap: () {}),
        WiredListTile(title: Text('Settings'), onTap: () {}),
      ],
    ),
  ),
  body: Center(child: Text('Content')),
)
```

---

## WiredPopupMenuButton

A popup menu triggered by a button press. Menu items appear in a hand-drawn bordered overlay.

<!-- {=docsPopupMenuUsage} -->
```dart
WiredPopupMenuButton<String>(
  onSelected: (value) => print(value),
  itemBuilder: (context) => [
    PopupMenuItem(value: 'edit', child: Text('Edit')),
    PopupMenuItem(value: 'delete', child: Text('Delete')),
  ],
)
```

---

## WiredMenuBar

A horizontal menu bar with hand-drawn borders, suitable for desktop-style navigation.

<!-- {=docsMenuBarUsage} -->
```dart
WiredMenuBar(
  children: [
    WiredPopupMenuButton(
      child: Text('File'),
      itemBuilder: (context) => [...],
    ),
    WiredPopupMenuButton(
      child: Text('Edit'),
      itemBuilder: (context) => [...],
    ),
  ],
)
```

---

## WiredBottomAppBar

A bottom app bar with a hand-drawn top border. Can contain actions and an optional notch for a FAB.

<!-- {=docsBottomAppBarUsage} -->
```dart
WiredScaffold(
  bottomNavigationBar: WiredBottomAppBar(
    child: Row(
      children: [
        WiredIconButton(icon: Icons.menu, onPressed: () {}),
        Spacer(),
        WiredIconButton(icon: Icons.search, onPressed: () {}),
      ],
    ),
  ),
  floatingActionButton: WiredFloatingActionButton(icon: Icons.add, onPressed: () {}),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
)
```

---

## WiredSliverAppBar

A sliver app bar with hand-drawn borders for use in `CustomScrollView`. Supports expanding/collapsing behavior.

<!-- {=docsSliverAppBarUsage} -->
```dart
CustomScrollView(
  slivers: [
    WiredSliverAppBar(
      title: Text('Scrollable'),
      expandedHeight: 200,
      floating: true,
    ),
    SliverList(delegate: SliverChildListDelegate([...])),
  ],
)
```

---

## WiredCupertinoNavigationBar

A Cupertino-style navigation bar with hand-drawn borders. Mirrors the `CupertinoNavigationBar` API with sketchy styling.

<!-- {=docsCupertinoNavBarUsage} -->
```dart
WiredCupertinoNavigationBar(
  middle: Text('Page Title'),
  leading: WiredCupertinoButton(
    onPressed: () => Navigator.pop(context),
    child: Text('Back'),
  ),
)
```

---

## WiredCupertinoTabBar

A Cupertino-style tab bar with hand-drawn selection indicators. Mirrors the `CupertinoTabBar` API.

<!-- {=docsCupertinoTabBarUsage} -->
```dart
WiredCupertinoTabBar(
  currentIndex: selectedTab,
  onTap: (index) => setState(() => selectedTab = index),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
)
```
