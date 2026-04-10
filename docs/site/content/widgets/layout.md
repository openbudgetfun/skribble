---
title: Layout
description: Hand-drawn cards, dividers, list tiles, scaffolds, and other layout widgets in the Skribble design system.
---

# Layout

Skribble provides layout and structural widgets that form the scaffolding of your app's UI. These replace Material and Cupertino containers with sketchy hand-drawn borders and paper-like backgrounds. All layout widgets read their palette from `WiredTheme.of(context)`.

---

## WiredCard

A card with a hand-drawn rectangle border. Supports optional hachure fill for a more prominent appearance.

<!-- {=docsCardUsage} -->
```dart
WiredCard(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card content'),
  ),
)

// Filled card
WiredCard(
  fill: true,
  height: 200,
  child: Center(child: Text('Filled card')),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget?` | `null` | The card content. |
| `fill` | `bool` | `false` | Whether to apply hachure fill to the card background. |
| `height` | `double?` | `130.0` | Card height. Set to `null` for intrinsic sizing. |

### Notes

- The border uses `WiredRectangleBase` with `theme.fillColor` and `theme.borderColor`.
- When `fill` is `true`, the card gets a `RoughFilter.hachureFiller` background.
- When `height` is `null`, the card uses `IntrinsicHeight` to size itself to its content.
- The internal `Card` has transparent color and shadow so the hand-drawn border is the only visible chrome.

---

## WiredDivider

A hand-drawn horizontal divider line. Renders a sketchy line spanning the full width of its parent.

<!-- {=docsDividerUsage} -->
```dart
Column(
  children: [
    WiredListTile(title: Text('Item 1')),
    WiredDivider(),
    WiredListTile(title: Text('Item 2')),
  ],
)
```

### Constructor parameters

None. `WiredDivider` has no configurable parameters beyond the inherited `key`.

### Notes

- The line is drawn with `WiredLineBase` using `theme.borderColor`.
- A transparent `Divider` is stacked beneath to maintain standard spacing.
- Fixed height of 1 logical pixel for the drawn line.

---

## WiredListTile

A list tile with a hand-drawn separator line at the bottom. Supports leading, title, subtitle, and trailing widgets.

<!-- {=docsListTileUsage} -->
```dart
WiredListTile(
  leading: WiredAvatar(radius: 20, child: Text('A')),
  title: Text('Alice Johnson'),
  subtitle: Text('alice@example.com'),
  trailing: WiredIconButton(icon: Icons.chevron_right, onPressed: () {}),
  onTap: () => navigateToProfile(),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `leading` | `Widget?` | `null` | Widget before the title (e.g., avatar or icon). |
| `title` | `Widget?` | `null` | Primary text. Rendered at 16px with `theme.textColor`. |
| `subtitle` | `Widget?` | `null` | Secondary text. Rendered at 14px with `theme.disabledTextColor`. |
| `trailing` | `Widget?` | `null` | Widget at the trailing edge. |
| `onTap` | `VoidCallback?` | `null` | Called when the tile is tapped. |
| `showDivider` | `bool` | `true` | Whether to show the bottom divider line. |

### Notes

- Horizontal padding is 16px; vertical padding is 12px.
- Uses `InkWell` for tap feedback.
- The divider is a 1px `WiredLineBase` drawn at full width.

---

## WiredExpansionTile

An expansion tile with a hand-drawn border that expands to reveal child content. The expand/collapse arrow animates on tap.

<!-- {=docsExpansionTileUsage} -->
```dart
WiredExpansionTile(
  title: Text('Advanced Settings'),
  children: [
    WiredSwitchListTile(
      title: Text('Debug mode'),
      value: debugMode,
      onChanged: (v) => setState(() => debugMode = v),
    ),
  ],
)
```

---

## WiredDataTable

A data table with hand-drawn column headers and row borders. Each cell is separated by sketchy lines.

<!-- {=docsDataTableUsage} -->
```dart
WiredDataTable(
  columns: [
    DataColumn(label: Text('Name')),
    DataColumn(label: Text('Age')),
    DataColumn(label: Text('Role')),
  ],
  rows: [
    DataRow(cells: [
      DataCell(Text('Alice')),
      DataCell(Text('30')),
      DataCell(Text('Engineer')),
    ]),
    DataRow(cells: [
      DataCell(Text('Bob')),
      DataCell(Text('25')),
      DataCell(Text('Designer')),
    ]),
  ],
)
```

---

## WiredStepper

A step-by-step wizard with hand-drawn circles for step indicators and sketchy connecting lines.

<!-- {=docsStepperUsage} -->
```dart
WiredStepper(
  currentStep: currentStep,
  onStepContinue: () => setState(() => currentStep++),
  onStepCancel: () => setState(() => currentStep--),
  steps: [
    Step(title: Text('Account'), content: Text('Create your account')),
    Step(title: Text('Profile'), content: Text('Set up your profile')),
    Step(title: Text('Done'), content: Text('All set!')),
  ],
)
```

---

## WiredCalendar

A standalone calendar widget with hand-drawn day cells and month navigation. Days are rendered within sketchy rectangle cells.

<!-- {=docsCalendarUsage} -->
```dart
WiredCalendar(
  selectedDate: selectedDate,
  onDateSelected: (date) => setState(() => selectedDate = date),
)
```

---

## WiredScrollbar

A scrollbar with a hand-drawn track and thumb. Wraps Flutter's `Scrollbar` with sketchy styling.

<!-- {=docsScrollbarUsage} -->
```dart
WiredScrollbar(
  child: ListView.builder(
    itemCount: 100,
    itemBuilder: (context, index) => WiredListTile(
      title: Text('Item $index'),
    ),
  ),
)
```

---

## WiredScaffold

A Material `Scaffold` wrapper tuned for Skribble's paper-like palette. Provides the familiar scaffold API with hand-drawn theme integration.

<!-- {=docsScaffoldUsage} -->
```dart
WiredScaffold(
  appBar: WiredAppBar(title: Text('My App')),
  body: Center(child: Text('Hello, Skribble!')),
  floatingActionButton: WiredFloatingActionButton(
    icon: Icons.add,
    onPressed: () {},
  ),
  drawer: WiredDrawer(
    child: ListView(
      children: [
        WiredDrawerHeader(child: Text('Menu')),
        WiredListTile(title: Text('Home')),
      ],
    ),
  ),
  bottomNavigationBar: WiredBottomNavigationBar(
    items: [
      WiredBottomNavItem(icon: Icons.home, label: 'Home'),
      WiredBottomNavItem(icon: Icons.settings, label: 'Settings'),
    ],
  ),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `appBar` | `PreferredSizeWidget?` | `null` | App bar (typically `WiredAppBar`). |
| `body` | `Widget?` | `null` | Main body content. |
| `backgroundColor` | `Color?` | `null` | Background. Defaults to `theme.paperBackgroundColor`. |
| `bodyPadding` | `EdgeInsetsGeometry?` | `null` | Padding applied around the body. |
| `applySafeArea` | `bool` | `false` | Wrap the body in a `SafeArea`. |
| `floatingActionButton` | `Widget?` | `null` | FAB widget. |
| `floatingActionButtonAnimator` | `FloatingActionButtonAnimator?` | `null` | FAB animation. |
| `floatingActionButtonLocation` | `FloatingActionButtonLocation?` | `null` | FAB position. |
| `drawer` | `Widget?` | `null` | Side drawer. |
| `endDrawer` | `Widget?` | `null` | End drawer. |
| `drawerScrimColor` | `Color?` | `null` | Scrim overlay color. Defaults to `theme.borderColor` at 12% opacity. |
| `bottomNavigationBar` | `Widget?` | `null` | Bottom navigation bar. |
| `bottomSheet` | `Widget?` | `null` | Persistent bottom sheet. |
| `persistentFooterButtons` | `List<Widget>?` | `null` | Footer buttons. |
| `resizeToAvoidBottomInset` | `bool?` | `null` | Whether body resizes for the keyboard. |
| `extendBody` | `bool` | `false` | Extend body behind bottom navigation. |
| `extendBodyBehindAppBar` | `bool` | `false` | Extend body behind app bar. |
| `primary` | `bool` | `true` | Whether this is the primary scaffold. |

### Notes

- The background defaults to `theme.paperBackgroundColor`, a softly lifted paper tone.
- Delegates to Flutter's `Scaffold` internally, so all standard scaffold behaviors work.
- Scrim color for drawers is automatically derived from `theme.borderColor`.

---

## WiredReorderableListView

A reorderable list with hand-drawn drag handles and separator lines. Items can be dragged to reorder.

<!-- {=docsReorderableListViewUsage} -->
```dart
WiredReorderableListView(
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final item = items.removeAt(oldIndex);
      items.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    });
  },
  children: [
    for (final item in items)
      WiredListTile(
        key: ValueKey(item.id),
        title: Text(item.name),
      ),
  ],
)
```

---

## WiredDismissible

A dismissible wrapper with hand-drawn swipe-to-dismiss background. Shows a sketchy indicator as the user swipes.

<!-- {=docsDismissibleUsage} -->
```dart
WiredDismissible(
  key: ValueKey(item.id),
  onDismissed: (direction) => removeItem(item),
  child: WiredListTile(title: Text(item.name)),
)
```

---

## WiredSelectableText

Selectable text rendered with Skribble's text color from the theme. Allows copy-paste of displayed text.

<!-- {=docsSelectableTextUsage} -->
```dart
WiredSelectableText('This text can be selected and copied.')
```

---

## WiredDrawerHeader

A drawer header area with a hand-drawn bottom border. Typically placed at the top of a `WiredDrawer`.

<!-- {=docsDrawerHeaderUsage} -->
```dart
WiredDrawerHeader(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      WiredAvatar(radius: 30, child: Text('S')),
      SizedBox(height: 8),
      Text('Skribble App'),
    ],
  ),
)
```

---

## WiredUserAccountsDrawerHeader

A drawer header with account info: avatar, name, and email. Displays a hand-drawn border and themed background.

<!-- {=docsUserAccountsDrawerHeaderUsage} -->
```dart
WiredUserAccountsDrawerHeader(
  accountName: Text('Jane Doe'),
  accountEmail: Text('jane@example.com'),
  currentAccountPicture: WiredAvatar(
    radius: 36,
    backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
  ),
)
```

---

## WiredAvatar

A hand-drawn circular avatar. Displays an image, icon, or initials inside a sketchy circle border with optional hachure fill.

<!-- {=docsAvatarUsage} -->
```dart
// With initials
WiredAvatar(
  radius: 24,
  child: Text('JD'),
)

// With image
WiredAvatar(
  radius: 24,
  backgroundImage: NetworkImage('https://example.com/photo.jpg'),
)

// With icon fallback
WiredAvatar(
  radius: 20,
  child: Icon(Icons.person),
)
```

### Constructor parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `backgroundImage` | `ImageProvider?` | `null` | Background image, clipped to a circle. |
| `foregroundImage` | `ImageProvider?` | `null` | Foreground image overlaid on top. |
| `backgroundColor` | `Color?` | `null` | Background color. Defaults to `theme.borderColor` at 15% opacity. |
| `foregroundColor` | `Color?` | `null` | Color for text/icons. Defaults to `theme.textColor`. |
| `radius` | `double` | `20` | Radius of the avatar circle. |
| `child` | `Widget?` | `null` | Content widget (initials text or icon). |
| `minRadius` | `double?` | `null` | Minimum radius constraint. |
| `maxRadius` | `double?` | `null` | Maximum radius constraint. |

### Notes

- When `backgroundImage` is provided, the hachure fill is disabled to show the image.
- If the image fails to load, falls back to the child or a `WiredIcon(Icons.person)`.
- Text content is sized at 70% of the radius; icon content matches the radius.
- The circle border is always drawn with `WiredCircleBase` using `theme.borderColor`.

---

## WiredPageScaffold (Cupertino)

A Cupertino page scaffold with hand-drawn navigation bar and paper-like background. Mirrors the `CupertinoPageScaffold` API.

<!-- {=docsPageScaffoldUsage} -->
```dart
WiredPageScaffold(
  navigationBar: WiredCupertinoNavigationBar(
    middle: Text('Page'),
  ),
  child: Center(child: Text('Cupertino page content')),
)
```

---

## WiredTabScaffold (Cupertino)

A Cupertino tab scaffold with a hand-drawn tab bar and page switching. Mirrors the `CupertinoTabScaffold` API.

<!-- {=docsTabScaffoldUsage} -->
```dart
WiredTabScaffold(
  tabBar: WiredCupertinoTabBar(
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    ],
  ),
  tabBuilder: (context, index) {
    return Center(child: Text('Tab $index'));
  },
)
```
