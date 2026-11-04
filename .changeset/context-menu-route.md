---
skribble: patch
---

# Context menus stay on screen and close like menus

`WiredContextMenu` now opens as a modal route. The menu stays inside the screen's safe area, opens above its anchor when there is no room below, traps focus, and closes on a tap outside, the Escape key, or the back gesture. Enter and Space activate the focused item, a right-click opens the menu on desktop, and screen readers hear it named by the new `semanticLabel`, which defaults to `Menu`. It is drawn on the theme's paper instead of a hard-coded white sheet that hid its border and dark-theme text, destructive items use the theme's `errorColor`, and the widget no longer imports Material.
