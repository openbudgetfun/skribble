---
skribble: patch
---

# Narrow Material imports in files that only needed widgets-layer APIs

Several files in `packages/skribble/lib` imported `package:flutter/material.dart` (or `flutter/cupertino.dart`) only for APIs that also exist in `flutter/widgets.dart` or `dart:ui`. They now import the narrowest correct dependency, and the Material dependency audit tool classifies `lib/src/compat/` as the sanctioned compatibility layer instead of counting it as rewrite debt.

No public API or rendering behaviour changes.
