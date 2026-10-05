---
skribble: major
---

# Mark selections with a marker wash, and give progress a value

`WiredThemeData` gains `markerColor`, a highlighter wash under selected and active things with ink still drawing the shape and label on top. It defaults to `WiredPalette.lilac`, and `WiredThemeData.cuddly(brightness: Brightness.dark)` uses the new `WiredPalette.dusk`. The Material bridge maps it to the primary and secondary container colours.

Navigation bar and rail indicators, navigation drawer selections, progress and slider fills, switch tracks, toggle buttons, and stepper circles now use the marker instead of dense ink hatching, which buried icons and hid white or paper labels. Selected toggle-button labels were invisible before; they now stay in ink. The Cupertino segmented control, switch, and slider take their colours from the theme instead of iOS system blue and green, and `WiredCupertinoSlider.thumbColor` is now nullable.

`WiredProgress` is driven by a value and no longer wraps a Material `LinearProgressIndicator`:

```dart
// Before
WiredProgress(controller: controller, value: 0.3);

// After
WiredProgress(value: uploaded / total, semanticLabel: 'Uploading');
const WiredProgress(); // indeterminate
```

The fill glides to each new value (settling at once when motion is off), an absent value sweeps, values are clamped, right-to-left text fills from the right, and the percentage is reported to screen readers.
