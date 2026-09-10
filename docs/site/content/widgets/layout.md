---
title: Layout
description: Hand-drawn cards, dividers, list tiles, scaffolds, and other layout widgets in the Skribble design system.
---

# Layout

Skribble provides layout and structural widgets that form the scaffolding of your app's UI. These replace Material and Cupertino containers with sketchy hand-drawn borders and paper-like backgrounds. All layout widgets read their palette from `WiredTheme.of(context)`.

---

## WiredCard

A card with a hand-drawn rectangle border. Supports optional hachure fill for a more prominent appearance.

```dart
// Live example: card
WiredCard(
  fill: true,
  child: Center(child: Text('Make something lovely')),
)
```

### Constructor parameters

| Parameter | Type      | Default | Description                                           |
| --------- | --------- | ------- | ----------------------------------------------------- |
| `child`   | `Widget?` | `null`  | The card content.                                     |
| `fill`    | `bool`    | `false` | Whether to apply hachure fill to the card background. |
| `height`  | `double?` | `130.0` | Card height. Set to `null` for intrinsic sizing.      |

### Notes

- The border uses `WiredRectangleBase` with `theme.fillColor` and `theme.borderColor`.
- When `fill` is `true`, the card gets a `RoughFilter.hachureFiller` background.
- When `height` is `null`, the card uses `IntrinsicHeight` to size itself to its content.
- The internal `Card` has transparent color and shadow so the hand-drawn border is the only visible chrome.

---

## WiredCarouselView

A horizontally scrolling hand-drawn carousel of rough-bordered cards, analogous to Material 3's `CarouselView`. Each item is drawn with a sketchy rough rounded-rectangle border reading `theme.fillColor` / `theme.borderColor`, with optional hachure fill.

```dart
// Live example: carousel-view
WiredCarouselView(
  borderRadius: BorderRadius.circular(8),
  children: [
    for (final label in ['Little plans', 'Bright ideas', 'Happy accidents'])
      Center(child: Text(label)),
  ],
)
```

### Constructor parameters

| Parameter       | Type                 | Default                     | Description                                                     |
| --------------- | -------------------- | --------------------------- | --------------------------------------------------------------- |
| `children`      | `List<Widget>`       | required                    | The widgets displayed as carousel items.                        |
| `itemExtent`    | `double?`            | `220.0`                     | Width of each item. `null` sizes items to intrinsic width.      |
| `height`        | `double`             | `200.0`                     | Cross-axis height of the carousel.                              |
| `shrinkWrap`    | `bool`               | `true`                      | Size the carousel to its content instead of filling its parent. |
| `fill`          | `bool`               | `false`                     | Hachure (sketchy) background fill for each item card.           |
| `borderRadius`  | `BorderRadius`       | `BorderRadius.circular(12)` | Corner rounding of each item's rough border.                    |
| `padding`       | `EdgeInsetsGeometry` | `EdgeInsets.zero`           | Padding around the scrollable content.                          |
| `reverse`       | `bool`               | `false`                     | Scroll in the reading direction's reverse.                      |
| `onTap`         | `ValueChanged<int>?` | `null`                      | Called with the tapped item's index.                            |
| `semanticLabel` | `String?`            | `null`                      | Semantic label describing the carousel.                         |

### Notes

- Mirrors the Material 3 `itemExtent` / `height` / `children` / `shrinkWrap` API surface for easy migration; per-item material chrome (`elevation`, `shape`, `overlayColor`) is intentionally replaced by the wired card look.
- With `shrinkWrap: true` the underlying list uses a `ListView` with all children; with a fixed `itemExtent` and `shrinkWrap: false` it lazily builds items via `ListView.builder`.
- Items are wrapped in `Semantics` and report as buttons when `onTap` is set.

---

## WiredDivider

A hand-drawn horizontal divider line. Renders a sketchy line spanning the full width of its parent.

```dart
// Live example: divider
const WiredDivider()
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

```dart
// Live example: list-tile
WiredListTile(
  title: Text('Make something lovely'),
  subtitle: const Text('A little note for later'),
  showDivider: false,
  onTap: true ? () {} : null,
)
```

### Constructor parameters

| Parameter     | Type            | Default | Description                                                      |
| ------------- | --------------- | ------- | ---------------------------------------------------------------- |
| `leading`     | `Widget?`       | `null`  | Widget before the title (e.g., avatar or icon).                  |
| `title`       | `Widget?`       | `null`  | Primary text. Rendered at 16px with `theme.textColor`.           |
| `subtitle`    | `Widget?`       | `null`  | Secondary text. Rendered at 14px with `theme.disabledTextColor`. |
| `trailing`    | `Widget?`       | `null`  | Widget at the trailing edge.                                     |
| `onTap`       | `VoidCallback?` | `null`  | Called when the tile is tapped.                                  |
| `showDivider` | `bool`          | `true`  | Whether to show the bottom divider line.                         |

### Notes

- Horizontal padding is 16px; vertical padding is 12px.
- Uses `InkWell` for tap feedback.
- The divider is a 1px `WiredLineBase` drawn at full width.

---

## WiredExpansionTile

An expansion tile with a hand-drawn border that expands to reveal child content. The expand/collapse arrow animates on tap.

```dart
// Live example: expansion-tile
WiredExpansionTile(
  title: Text('Make something lovely'),
  children: const [
    Padding(
      padding: EdgeInsets.all(20),
      child: Text('A small surprise tucked inside.'),
    ),
  ],
)
```

---

## WiredDataTable

A data table with hand-drawn column headers and row borders. Each cell is separated by sketchy lines.

```dart
// Live example: data-table
const WiredDataTable(
  columns: [
    WiredDataColumn(label: Text('Sketch')),
    WiredDataColumn(label: Text('Status')),
  ],
  rows: [
    WiredDataRow(cells: [Text('Paper boats'), Text('Ready')]),
    WiredDataRow(cells: [Text('Tiny gardens'), Text('Growing')]),
  ],
)
```

---

## WiredStepper

A step-by-step wizard with hand-drawn circles for step indicators and sketchy connecting lines.

```dart
// Live example: stepper
HookBuilder(
  builder: (context) {
    final current = useState(0);
    return WiredStepper(
      currentStep: current.value,
      onStepTapped: (index) => current.value = index,
      steps: const [
        WiredStep(
          title: Text('Imagine'),
          content: Text('Start with a small idea.'),
        ),
        WiredStep(title: Text('Make'), content: Text('Give it a little ink.')),
        WiredStep(title: Text('Share'), content: Text('Let someone try it.')),
      ],
    );
  },
)
```

---

## WiredCalendar

A standalone calendar widget with hand-drawn day cells and month navigation. Days are rendered within sketchy rectangle cells.

```dart
// Live example: calendar
HookBuilder(
  builder: (context) {
    final selected = useState('2026-09-09');
    return SizedBox(
      height: 360,
      child: WiredCalendar(
        selected: selected.value,
        onSelected: (date) => selected.value = date,
      ),
    );
  },
)
```

---

## WiredScrollbar

A scrollbar with a hand-drawn track and thumb. Wraps Flutter's `Scrollbar` with sketchy styling.

```dart
// Live example: scrollbar
HookBuilder(
  builder: (context) {
    final controller = useScrollController();
    return SizedBox(
      height: 180,
      child: WiredScrollbar(
        controller: controller,
        thumbVisibility: true,
        child: ListView(
          controller: controller,
          children: [
            for (var index = 0; index < 15; index++)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Little idea ${index + 1}'),
              ),
          ],
        ),
      ),
    );
  },
)
```

---

## WiredScaffold

A Material `Scaffold` wrapper tuned for Skribble's paper-like palette. Provides the familiar scaffold API with hand-drawn theme integration.

```dart
// Live example: scaffold
SizedBox(
  height: 240,
  child: WiredScaffold(
    backgroundColor: const Color(0xffeef1df),
    appBar: const WiredAppBar(title: Text('A little sketchbook')),
    body: Center(child: Text('Make something lovely')),
  ),
)
```

### Constructor parameters

| Parameter                      | Type                            | Default | Description                                                          |
| ------------------------------ | ------------------------------- | ------- | -------------------------------------------------------------------- |
| `appBar`                       | `PreferredSizeWidget?`          | `null`  | App bar (typically `WiredAppBar`).                                   |
| `body`                         | `Widget?`                       | `null`  | Main body content.                                                   |
| `backgroundColor`              | `Color?`                        | `null`  | Background. Defaults to `theme.paperBackgroundColor`.                |
| `bodyPadding`                  | `EdgeInsetsGeometry?`           | `null`  | Padding applied around the body.                                     |
| `applySafeArea`                | `bool`                          | `false` | Wrap the body in a `SafeArea`.                                       |
| `floatingActionButton`         | `Widget?`                       | `null`  | FAB widget.                                                          |
| `floatingActionButtonAnimator` | `FloatingActionButtonAnimator?` | `null`  | FAB animation.                                                       |
| `floatingActionButtonLocation` | `FloatingActionButtonLocation?` | `null`  | FAB position.                                                        |
| `drawer`                       | `Widget?`                       | `null`  | Side drawer.                                                         |
| `endDrawer`                    | `Widget?`                       | `null`  | End drawer.                                                          |
| `drawerScrimColor`             | `Color?`                        | `null`  | Scrim overlay color. Defaults to `theme.borderColor` at 12% opacity. |
| `bottomNavigationBar`          | `Widget?`                       | `null`  | Bottom navigation bar.                                               |
| `bottomSheet`                  | `Widget?`                       | `null`  | Persistent bottom sheet.                                             |
| `persistentFooterButtons`      | `List<Widget>?`                 | `null`  | Footer buttons.                                                      |
| `resizeToAvoidBottomInset`     | `bool?`                         | `null`  | Whether body resizes for the keyboard.                               |
| `extendBody`                   | `bool`                          | `false` | Extend body behind bottom navigation.                                |
| `extendBodyBehindAppBar`       | `bool`                          | `false` | Extend body behind app bar.                                          |
| `primary`                      | `bool`                          | `true`  | Whether this is the primary scaffold.                                |

### Notes

- The background defaults to `theme.paperBackgroundColor`, a softly lifted paper tone.
- Delegates to Flutter's `Scaffold` internally, so all standard scaffold behaviors work.
- Scrim color for drawers is automatically derived from `theme.borderColor`.

---

## WiredReorderableListView

A reorderable list with hand-drawn drag handles and separator lines. Items can be dragged to reorder.

```dart
// Live example: reorderable-list-view
HookBuilder(
  builder: (context) {
    final items = useState(['Paper', 'Ink', 'Possibility']);
    return SizedBox(
      height: 220,
      child: WiredReorderableListView(
        onReorder: (from, to) {
          final next = List<String>.of(items.value);
          next.insert(to > from ? to - 1 : to, next.removeAt(from));
          items.value = next;
        },
        children: [
          for (final item in items.value) Text(item, key: ValueKey(item)),
        ],
      ),
    );
  },
)
```

---

## WiredDismissible

A dismissible wrapper with hand-drawn swipe-to-dismiss background. Shows a sketchy indicator as the user swipes.

```dart
// Live example: dismissible
HookBuilder(
  builder: (context) {
    final visible = useState(true);
    return visible.value
        ? WiredDismissible(
            dismissKey: const ValueKey('sketch'),
            onDismissed: (direction) => visible.value = false,
            child: WiredListTile(
              title: Text('Make something lovely'),
              subtitle: const Text('Swipe to put this away'),
              showDivider: false,
            ),
          )
        : WiredTextButton(
            onPressed: () => visible.value = true,
            child: const Text('Bring it back'),
          );
  },
)
```

---

## WiredSelectableText

Selectable text rendered with Skribble's text color from the theme. Allows copy-paste of displayed text.

```dart
// Live example: selectable-text
WiredSelectableText('Make something lovely')
```

---

## WiredDrawerHeader

A drawer header area with a hand-drawn bottom border. Typically placed at the top of a `WiredDrawer`.

```dart
// Live example: drawer-header
SizedBox(
  height: 180,
  child: WiredDrawerHeader(child: Text('Make something lovely')),
)
```

---

## WiredUserAccountsDrawerHeader

A drawer header with account info: avatar, name, and email. Displays a hand-drawn border and themed background.

```dart
// Live example: user-accounts-drawer-header
WiredUserAccountsDrawerHeader(
  accountName: Text('Make something lovely'),
  accountEmail: const Text('hello@example.com'),
  currentAccountPicture: const WiredAvatar(child: Text('SK')),
)
```

---

## WiredAvatar

A hand-drawn circular avatar. Displays an image, icon, or initials inside a sketchy circle border with optional hachure fill.

```dart
// Live example: avatar
const WiredAvatar(
  radius: 32,
  backgroundColor: Color(0xffe8b59e),
  child: Text('SK'),
)
```

### Constructor parameters

| Parameter         | Type             | Default | Description                                                       |
| ----------------- | ---------------- | ------- | ----------------------------------------------------------------- |
| `backgroundImage` | `ImageProvider?` | `null`  | Background image, clipped to a circle.                            |
| `foregroundImage` | `ImageProvider?` | `null`  | Foreground image overlaid on top.                                 |
| `backgroundColor` | `Color?`         | `null`  | Background color. Defaults to `theme.borderColor` at 15% opacity. |
| `foregroundColor` | `Color?`         | `null`  | Color for text/icons. Defaults to `theme.textColor`.              |
| `radius`          | `double`         | `20`    | Radius of the avatar circle.                                      |
| `child`           | `Widget?`        | `null`  | Content widget (initials text or icon).                           |
| `minRadius`       | `double?`        | `null`  | Minimum radius constraint.                                        |
| `maxRadius`       | `double?`        | `null`  | Maximum radius constraint.                                        |

### Notes

- When `backgroundImage` is provided, the hachure fill is disabled to show the image.
- If the image fails to load, falls back to the child or a `WiredIcon(Icons.person)`.
- Text content is sized at 70% of the radius; icon content matches the radius.
- The circle border is always drawn with `WiredCircleBase` using `theme.borderColor`.

---

## WiredPageScaffold (Cupertino)

A Cupertino page scaffold with hand-drawn navigation bar and paper-like background. Mirrors the `CupertinoPageScaffold` API.

```dart
// Live example: page-scaffold
SizedBox(
  height: 240,
  child: WiredPageScaffold(
    navigationBar: const WiredCupertinoNavigationBar(
      middle: Text('Little notes'),
    ),
    child: Center(child: Text('Make something lovely')),
  ),
)
```

---

## WiredTabScaffold (Cupertino)

A Cupertino tab scaffold with a hand-drawn tab bar and page switching. Mirrors the `CupertinoTabScaffold` API.

```dart
// Live example: tab-scaffold
SizedBox(
  height: 240,
  child: WiredTabScaffold(
    tabs: const [
      WiredTabItem(
        icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
        label: 'Home',
      ),
      WiredTabItem(
        icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
        label: 'Saved',
      ),
    ],
    tabBuilder: (context, index) => Center(
      child: Text(index == 0 ? 'A fresh page' : 'Your favourite sketches'),
    ),
  ),
)
```

---

## WiredGridTile

A grid tile with hand-drawn borders and optional header/footer bars. Mirrors Material's `GridTile`: the child fills the tile while `header` and `footer` overlay its top and bottom edges. Tapping the tile plays a hand-drawn ink splash.

```dart
// Live example: grid-tile
SizedBox(
  height: 180,
  child: WiredGridTile(
    footer: WiredGridTileBar(title: Text('Make something lovely')),
    onTap: () {},
    child: const ColoredBox(color: Color(0xffdde4c9)),
  ),
)
```

### Constructor parameters

| Parameter       | Type            | Default | Description                                                                  |
| --------------- | --------------- | ------- | ---------------------------------------------------------------------------- |
| `child`         | `Widget`        | —       | The tile content, painted beneath the bars.                                  |
| `header`        | `Widget?`       | `null`  | Widget overlaid on the top edge (typically `WiredGridTileBar`).              |
| `footer`        | `Widget?`       | `null`  | Widget overlaid on the bottom edge (typically `WiredGridTileBar`).           |
| `onTap`         | `VoidCallback?` | `null`  | Called when the tile is tapped; enables the ink splash and button semantics. |
| `semanticLabel` | `String?`       | `null`  | Optional semantic label for accessibility.                                   |

---

## WiredGridTileBar

A bar for use as `WiredGridTile.header` or `WiredGridTile.footer`. Mirrors Material's `GridTileBar` with a translucent strip, a rough hand-drawn edge line, and leading/title/subtitle/trailing slots.

```dart
// Live example: grid-tile-bar
WiredGridTileBar(
  title: Text('Make something lovely'),
  subtitle: const Text('A small caption'),
)
```

### Constructor parameters

| Parameter         | Type      | Default | Description                                                       |
| ----------------- | --------- | ------- | ----------------------------------------------------------------- |
| `color`           | `Color?`  | `null`  | Foreground color for text/icons; falls back to `theme.textColor`. |
| `backgroundColor` | `Color?`  | `null`  | Bar background; falls back to a translucent `theme.fillColor`.    |
| `height`          | `double`  | `56`    | Bar height.                                                       |
| `titleSpacing`    | `double`  | `16`    | Spacing between leading, title and trailing.                      |
| `leading`         | `Widget?` | `null`  | Widget shown at the start of the bar.                             |
| `title`           | `Widget?` | `null`  | Primary text of the bar.                                          |
| `subtitle`        | `Widget?` | `null`  | Secondary text shown below `title`.                               |
| `trailing`        | `Widget?` | `null`  | Widget shown at the end of the bar.                               |

### Notes

- The bottom edge of the bar is closed with a rough `WiredLineBase` line so it reads as sketched, not machine-cut.
- Use inside `WiredGridTile.header` or `.footer`; standalone usage also renders correctly.

---

## WiredMergeableMaterial

A vertically stacked group of slices and gaps with hand-drawn borders. Mirrors Material's `MergeableMaterial`: `WiredMaterialSlice` children render as rows inside rough-bordered cards; `WiredMaterialGap` items separate cards and animate size changes, so a gap animating to `0` merges the slices around it.

```dart
// Live example: mergeable-material
HookBuilder(
  builder: (context) {
    final open = useState(false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          onPressed: () => open.value = !open.value,
          child: const Text('Separate the notes'),
        ),
        const SizedBox(height: 12),
        WiredMergeableMaterial(
          children: [
            const WiredMaterialSlice(
              key: ValueKey('first'),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('A bright idea'),
              ),
            ),
            if (open.value) const WiredMaterialGap(key: ValueKey('gap')),
            const WiredMaterialSlice(
              key: ValueKey('second'),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('A happy accident'),
              ),
            ),
          ],
        ),
      ],
    );
  },
)
```

### Constructor parameters

| Parameter           | Type                               | Default         | Description                                                |
| ------------------- | ---------------------------------- | --------------- | ---------------------------------------------------------- |
| `children`          | `List<WiredMergeableMaterialItem>` | required        | Slices and gaps, in order.                                 |
| `hasDividers`       | `bool`                             | `false`         | Draws hand-drawn lines between contiguous slices.          |
| `dividerColor`      | `Color?`                           | `null`          | Divider color override; falls back to `theme.borderColor`. |
| `animationDuration` | `Duration`                         | `300ms`         | Duration for gap grow/collapse animations.                 |
| `animationCurve`    | `Curve`                            | `fastOutSlowIn` | Curve for gap grow/collapse animations.                    |

### Notes

- `WiredMaterialSlice({required LocalKey key, required Widget child, Color? color})` mirrors Material's `MaterialSlice`.
- `WiredMaterialGap({required LocalKey key, double size = 16})` mirrors Material's `MaterialGap`. Gap size changes animate automatically; drive expand/collapse by rebuilding `children` with different gap sizes.
- Like Material's 3.47 API there is no controller; stable `LocalKey`s on items are required so animations track rebuilds.
- Contiguous slices (no positive gap between them) share one card silhouette with rounded corners and internal dividers.

<!-- {=docsWidgetInkSection} -->

## Shared ink and typography

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (2.4 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->

## Drawing cards into place

Wrap a card in `WiredDraw` for a one-time outline entrance, or use `WiredDrawTransition` with a caller-owned animation. Patterned fills scribble in after the outline starts. A card with `height: null` now uses its child's natural layout directly, so responsive `LayoutBuilder` content works without intrinsic-size queries. See [Ink motion](../core/motion).

The transitional `WiredExpansionPanelList` source also inherits ink reveals. Setting a panel's `canTapOnHeader` to false keeps header taps inactive and provides a labeled Wired expand button. This component remains available through its source import while its standalone API is developed.

Long `WiredGridTileBar` titles and subtitles stay on one line with an ellipsis, so a narrow tile keeps room for both labels. Their full text remains available to accessibility services.
