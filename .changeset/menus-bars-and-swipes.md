---
skribble: patch
---

# Popup menus, Cupertino navigation bars, and swipe-to-delete follow the theme

- `WiredPopupMenuButton` items keep `kWiredInkPadding` inside their hand-drawn boxes, instead of 4 pixels above and below. The menu outline uses the theme's `strokeWidth` instead of a fixed 1.5.
- `WiredCupertinoNavigationBar` no longer shows the route's name, such as `/` or `/settings`, as its title. Like `CupertinoNavigationBar`, it implies the title from a `CupertinoPageRoute`'s `title`.
- `WiredDismissible`'s default delete background uses the theme's `errorColor` instead of Material red, and its icon is drawn in whichever of the theme's ink or paper stands out more. `deleteColor` is now nullable, and null means the theme's error color.
