<!-- Shared content for the widget catalog pages. -->
<!-- {@docsWidgetInkSection} -->

## Shared ink and typography

Borders in this category now use the nearest `WiredThemeData.strokeWidth` (2.4 logical pixels by default) and drawing configuration. Rounded pen caps and joins, bleed insets, and sufficient divider space keep the stroke visible. Labels that apply a local text style retain the inherited font family. Theme changes repaint the updated color and width. See [Theme System](../core/theme-system) for configuration and [the quality report](https://github.com/openbudgetfun/skribble/blob/main/docs/hand-drawn-quality.md) for the rendering checks.

<!-- {/docsWidgetInkSection} -->

<!-- {@docsButtonBasicUsage} -->

```dart
WiredButton(
  onPressed: () {
    // Handle tap
  },
  child: Text('Press Me'),
)
```

<!-- {/docsButtonBasicUsage} -->
