---
skribble: minor
---

# Navigation bar, rail, and action button parity with Material

`WiredNavigationBar`, `WiredNavigationRail`, `WiredFloatingActionButton`, and `WiredIconButton` now cover the parts of Material's `NavigationBar`, `NavigationRail`, `FloatingActionButton`, and `IconButton` that apps reach for, so a Material screen ports without a hand-rolled replacement.

**Navigation bar.** `labelBehavior` (`WiredNavigationDestinationLabelBehavior.alwaysShow`, `onlyShowSelected`, `alwaysHide`), `height`, `backgroundColor`, `indicatorColor`, `colorCoded` (each destination takes `theme.accentAt(index)`), and `animationDuration`. Destinations gain `tooltip`, `enabled`, `badge` (`'3'` for a count, `''` for a dot), `color`, and `isPrimaryAction`, which keeps one destination washed with the accent as the bar's loud action. Destinations now share the bar's width equally instead of sitting 72 pixels apart.

**Navigation rail.** `extended` springs the rail between `minWidth` (72) and `minExtendedWidth` (256) with each label beside its icon. Also `labelType` (`WiredNavigationRailLabelType.none`, `selected`, `all`), `groupAlignment`, `backgroundColor`, `indicatorColor`, `useIndicator`, `colorCoded`, `animationDuration`, `scrollable`, `semanticLabel`, and a nullable `selectedIndex`. Destinations gain `tooltip`, `disabled`, `badge`, and `color`.

Both pop the selected destination's wash in on a spring while its ink draws on, and settle at once when motion is off. Hidden labels are still read by screen readers, with the label as the tooltip.

**Floating action button.** `WiredFloatingActionButton.small` (40), `.large` (96), and `.extended`, a hand-drawn pill with an optional icon and a label that springs back to a circle when `isExtended` turns off. Every form takes `backgroundColor`, `foregroundColor`, `iconSize`, `tooltip`, `heroTag`, `inkInteraction`, `autofocus`, and `focusNode`.

**Icon button.** `WiredIconButton.filled` (accent wash), `.filledTonal` (marker wash), and `.outlined`, plus Material's toggle behaviour through `isSelected` and `selectedIcon`, `fillColor` for colour-coding, `tooltip`, `autofocus`, and `focusNode`. A disabled filled button keeps a faded wash.

`WiredIconButton` no longer wraps Material's `IconButton`, and the navigation bar and rail no longer import Material, so three files leave the Material dependency audit.
