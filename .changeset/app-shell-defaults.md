---
skribble: minor
---

# `SkribbleApp` sets up icons, selection, and scrolling, and stops rebuilding on every inset change

- `WiredThemeScope`, which `SkribbleApp` and `WiredTheme` install, now sets the icon colour to the theme's `textColor`, as it already did for text. An `Icon` or `WiredIcon` with no colour of its own was drawn in `IconThemeData.fallback`'s black, which vanished on dark paper.
- `SkribbleApp` installs a `DefaultSelectionStyle` from the theme: the cursor in `borderColor` and the highlight in a translucent wash of `textColor`.
- New `SkribbleApp.scrollBehavior`, defaulting to the new `SkribbleScrollBehavior`: overscroll stretches on Android instead of Flutter's white glow, and the desktop scrollbar thumb is a wash of the theme's `textColor`. Pass `null` for Flutter's plain `ScrollBehavior`.
- New `SkribbleApp.onNavigationNotification`, forwarded to `WidgetsApp`.
- `SkribbleApp` and `WiredMaterialApp` depend only on the platform brightness and high-contrast setting from `MediaQuery`. Before, they depended on the whole `MediaQueryData`, so every frame of a keyboard animation or window resize rebuilt the app shell.
- `WiredMaterialApp` with no `darkWiredTheme` keeps a light Material `ThemeData` on a dark platform, as `MaterialApp` does without a `darkTheme`. Before, it converted the light palette with a dark brightness, giving Material widgets dark menus and fields on light paper. Its high-contrast dark theme now falls back to `highContrastWiredTheme` before `wiredTheme`, matching `SkribbleApp` and `MaterialApp`.
- The `SkribbleApp` docs now describe the high-contrast dark fallback correctly and state the text-scaling policy: the shell does not clamp the platform's text scale.
