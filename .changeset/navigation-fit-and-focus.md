---
skribble: patch
---

# Navigation fits narrow phones, notches, and keyboards

- `WiredAppBar` keeps its title on one line with an ellipsis, follows text scaling up to 1.34 times like Material's app bar, and marks the title as a header. Long titles used to wrap and be cut off.
- `WiredTabBar` keeps each label on one line with an ellipsis and a little side padding, so neighbouring labels no longer run together or get cut mid-word, and its underline stays below the letters. The bar is now exactly its `height`, which an app bar's `bottom` slot requires.
- `WiredBottomNavigationBar` and `WiredNavigationBar` pad themselves above the home indicator of notched phones, and grow with large text instead of overflowing.
- Tabs, bottom navigation items, navigation bar and rail destinations, and navigation drawer destinations take keyboard focus, activate with Enter or Space, and are announced as selectable buttons with their selected state. Tabs also announce their position, such as `Reviews, tab 3 of 4`.
