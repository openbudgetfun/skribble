# skribble_font_noto_lively

Skribble Noto Lively: a hand-drawn typeface generated from [Google Noto Sans](https://fonts.google.com/noto/specimen/Noto+Sans), at the Lively level, the most playful level: a wider pen, the strongest wobble and bounce, and roomier spacing.

This package bundles Latin, Greek and Cyrillic. Every other Noto script, including Arabic, Devanagari, Thai, Chinese, Japanese and Korean, is in the Skribble Noto Lively font kit attached to each [GitHub release](https://github.com/openbudgetfun/skribble/releases/latest).

The other levels are [`skribble_font_noto`](../skribble_font_noto) (Soft) and [`skribble_font_noto_sketch`](../skribble_font_noto_sketch) (Sketch). Each level is its own package so an app ships only the one it uses.

## Usage

```yaml
dependencies:
  skribble_font_noto_lively: ^0.3.1
```

No code is required: Flutter registers the `SkribbleNotoLively` family from this package's pubspec. Select it through core's theme:

```dart
import 'package:skribble/skribble.dart';

WiredTheme(
  data: WiredThemeData(font: WiredFont.notoLively),
  child: const MyApp(),
)
```

Unlike the Recursive families, the Skribble Noto levels are fixed: the ink's `WiredRoughness` still changes borders and icons, but not this lettering. A bare `TextStyle` qualifies the family with its package:

```dart
const TextStyle(fontFamily: 'SkribbleNotoLively', package: 'skribble_font_noto_lively')
```

The face is Regular (400) only. Flutter synthesises bold where a style asks for it.

## More scripts

Download `SkribbleNotoLively-Kit-<version>.zip` from the release, copy the scripts you need into your app, declare them as font families, and add them to `fontFamilyFallback`:

```yaml
flutter:
  fonts:
    - family: SkribbleNotoLivelyJP
      fonts:
        - asset: fonts/SkribbleNotoLivelyJP-Regular.ttf
```

```dart
const TextStyle(fontFamilyFallback: ['SkribbleNotoLivelyJP'])
```

The kit's own README lists every file. Chinese, Japanese and Korean files are 15 to 27 MB each, so bundle only the ones you ship.

## Provenance

| Field     | Value                                                                                                                               |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Source    | [Noto Sans](https://github.com/notofonts/latin-greek-cyrillic) 2.015 via [google/fonts](https://github.com/google/fonts) `47d54ca1` |
| Licence   | SIL OFL 1.1 (`assets/fonts/OFL.txt`)                                                                                                |
| Generator | `python3 tool/skribble_noto/build.py` (see [`tool/skribble_noto/README.md`](../../tool/skribble_noto/README.md))                    |
| Registry  | `tool/asset_sources.txt`                                                                                                            |

Generation is deterministic: the same Noto sources and pinned Python libraries rebuild byte-identical files. Noto is a trademark of Google LLC.
