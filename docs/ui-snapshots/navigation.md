# Navigation Components

Hand-drawn navigation elements for app structure and wayfinding.

## WiredAppBar

A top app bar with a hand-drawn bottom border line.

![WiredAppBar](https://f005.backblazeb2.com/file/skribble-screenshots/navigation/wired-app-bar.png)

- Implements `PreferredSizeWidget`
- Supports `title`, `leading`, `actions`
- Rough-drawn bottom line separator

## WiredBottomNavigationBar

A bottom navigation bar with circular selection indicators.

![WiredBottomNavigationBar](https://f005.backblazeb2.com/file/skribble-screenshots/navigation/wired-bottom-nav.png)

- Custom `WiredBottomNavItem` class
- Hand-drawn circle indicators for active items
- Supports icon and label for each item

## WiredNavigationBar

A Material 3 style navigation bar with hand-drawn indicators.

![WiredNavigationBar](https://f005.backblazeb2.com/file/skribble-screenshots/navigation/wired-navigation-bar.png)

- Custom `WiredNavigationDestination` class
- Rounded rectangle fill for selected item
- Bottom-positioned bar layout

## WiredNavigationRail

A vertical navigation rail with hand-drawn elements.

![WiredNavigationRail](https://f005.backblazeb2.com/file/skribble-screenshots/navigation/wired-navigation-rail.png)

- Custom `WiredNavigationRailDestination` class
- Left-edge line separator
- Vertical icon/label layout

## WiredDrawer

A navigation drawer panel with a hand-drawn right-edge border.

![WiredDrawer](https://f005.backblazeb2.com/file/skribble-screenshots/navigation/wired-drawer.png)

- Rough-drawn right edge line
- Standard drawer width
- Contains arbitrary child content

## WiredTabBar

A horizontal tab bar with hand-drawn underline indicator.

![WiredTabBar](https://f005.backblazeb2.com/file/skribble-screenshots/navigation/wired-tab-bar.png)

- Implements `PreferredSizeWidget`
- Hand-drawn underline for selected tab
- Works with `TabController` and `TabBarView`
