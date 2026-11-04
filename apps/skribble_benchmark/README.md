# skribble_benchmark

Measures what it costs to draw skribble icons. Each page draws the same glyphs two ways and times the frames:

- **Runtime** draws `WiredSvgIcon`, which roughens each glyph with the rough engine.
- **Pre-computed** draws `PrecomputedIcon` (`lib/widgets/precomputed_icon.dart`), which paints the glyph's SVG paths straight to the canvas. It is the fastest an icon can draw, so the gap between the two is the cost of the hand-drawn look.

| Page           | What it measures                                                             |
| -------------- | ---------------------------------------------------------------------------- |
| Single Icon    | Build and paint time of one icon over 100 frames                             |
| Grid of Icons  | 10 to 200 icons at once: average and P95 frame times over 60 frames          |
| Scrolling List | 500 icon rows while you scroll: average and P95 frame times, and jank frames |

The app is a plain Material harness, not a skribble showcase, so the only skribble drawing on screen is the icons being measured.

## Run it

Frame timings only mean something in profile mode on real hardware. The repository has no platform folders for this app, so generate the ones you need once (Git ignores them):

```bash
cd apps/skribble_benchmark
flutter create --empty --org fun.openbudget --project-name skribble_benchmark \
  --platforms=android,ios,macos .
flutter run --profile -d <device>
```

`--empty` writes only the platform folders and leaves `lib/` and `test/` alone. `flutter devices` lists the IDs for `-d`. On iOS, profile mode needs a physical device; simulators only run debug builds.

## Test it

```bash
cd apps/skribble_benchmark
flutter test
```

- `test/benchmark_app_test.dart` opens every page and checks that it draws both kinds of icon.
- `test/icon_paint_benchmark_test.dart` repaints the icons in the test environment and prints the average frame time against a 16 ms budget. Use it to compare two versions of the rough engine on the same machine. The numbers are not device frame times.
