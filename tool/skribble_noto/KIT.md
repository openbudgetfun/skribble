# Skribble Noto font kit

Every [Google Noto](https://fonts.google.com/noto) script, redrawn by hand with a round pen. One zip per level:

- `SkribbleNoto-Kit-<version>.zip`: Soft, the calm default.
- `SkribbleNotoSketch-Kit-<version>.zip`: Sketch, a marker on paper.
- `SkribbleNotoLively-Kit-<version>.zip`: Lively, the most playful.

Each zip holds one Regular file per script, named `<Level><Script>-Regular.ttf`. The Latin, Greek and Cyrillic file has no script name (`SkribbleNoto-Regular.ttf`); Japanese is `SkribbleNotoJP-Regular.ttf`, Arabic `SkribbleNotoArabic-Regular.ttf`, and so on.

## On a computer

Open a `.ttf` and choose **Install** (macOS Font Book, Windows, or most Linux desktops). The installed family is `Skribble Noto <Script>`, for example `Skribble Noto Sketch Arabic`.

## On the web

```css
@font-face { font-family: "Skribble Noto"; src: url(SkribbleNoto-Regular.ttf); }
@font-face { font-family: "Skribble Noto JP"; src: url(SkribbleNotoJP-Regular.ttf); }

body { font-family: "Skribble Noto", "Skribble Noto JP", sans-serif; }
```

## In Flutter

The `skribble_font_noto`, `skribble_font_noto_sketch` and `skribble_font_noto_lively` packages already bundle Latin, Greek and Cyrillic. Add only the scripts your app needs, as your own font families, and list them as fallbacks:

```yaml
flutter:
  fonts:
    - family: SkribbleNotoJP
      fonts:
        - asset: fonts/SkribbleNotoJP-Regular.ttf
```

```dart
WiredTheme(
  data: WiredThemeData(font: WiredFont.noto),
  child: DefaultTextStyle.merge(
    style: const TextStyle(fontFamilyFallback: ['SkribbleNotoJP']),
    child: const MyApp(),
  ),
)
```

Chinese, Japanese and Korean files are large (15 to 27 MB each), so bundle only the ones you ship.

## Licence

SIL Open Font License 1.1, in `OFL.txt`. Built from Noto by the skribble project: https://github.com/openbudgetfun/skribble. Noto is a trademark of Google LLC.
