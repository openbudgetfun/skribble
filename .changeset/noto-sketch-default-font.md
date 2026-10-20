---
skribble: major
---

# Skribble Noto Sketch is the default typeface

`WiredThemeData.font` now defaults to `WiredFont.notoSketch`, and `skribbleFontFamily` is `'SkribbleNotoSketch'`, registered by the `skribble_font_noto_sketch` package. Noto Sketch keeps the same lettering at every roughness level and draws each Latin letter three ways so repeated letters never look stamped. An app that only installed `skribble_font_recursive` would fall back to the platform font, so install the new package, or keep the Recursive lettering explicitly:

```dart
// Install the new default:
//   flutter pub add skribble_font_noto_sketch

// Or keep the previous Recursive Casual lettering, which follows roughness:
WiredThemeData(font: WiredFont.casual)

// A bare TextStyle using skribbleFontFamily now needs the Noto Sketch package:
TextStyle(fontFamily: skribbleFontFamily, package: 'skribble_font_noto_sketch')
```
