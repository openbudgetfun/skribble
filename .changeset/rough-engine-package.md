---
skribble: patch
skribble_rough: minor
---

# Move the rough engine into the pure-Dart skribble_rough package

The Flutter-free half of the rough engine (`DrawConfig`, `Generator`, the fillers, `RoughPen`, `InkStroke`, `DrawableInk`, geometry, and the op-set data structures) now lives in the new `skribble_rough` package, which depends on nothing but the Dart SDK. Command-line tools, servers, and web frameworks can draw the same seeded shapes as the Flutter widgets without pulling in Flutter.

`skribble` depends on `skribble_rough` and re-exports exactly the names it exported before, so `import 'package:skribble/skribble.dart'` keeps working unchanged. The `dart:ui` painting layer (`RoughDrawing`, the `Rough` canvas extension, and `RoughBoxDecoration`) stays in `skribble`. Code that imported the engine's private `package:skribble/src/rough/...` files should import `package:skribble_rough/skribble_rough.dart` instead.
