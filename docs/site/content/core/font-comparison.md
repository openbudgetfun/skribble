---
title: Compare the lettering
description: Compare original and roughened Recursive Casual and Sans Linear at real reading sizes.
---

# About these specimens

Both families come from Recursive 1.085. Casual has a distinctive shape before any roughening; Sans Linear starts with straighter, more conventional forms. This experiment keeps Casual as the library font while letting you compare the alternative.

Each pair uses the same generator, strength, weight, style, and size. Gentle uses strength 18, Playful 27, and Expressive 36 per 1,000 font units. Regular, bold, italic, and bold italic are separate source fonts. No synthetic bold or italic is needed.

The original row loads the untouched source fonts, including their hinting. Roughened fonts have newly written outlines. A difference from the original therefore includes both outline changes and the removal of source hinting.

On a narrow screen, each Casual specimen appears immediately above its matching Linear specimen. Use 14 or 16 px to judge body text, and a larger size to inspect the pen-like contour changes.

## Reproduce the comparison

Run from the repository root:

```bash
dart run tool/docs_font_comparison.dart
dart run tool/docs_font_comparison.dart --check
```

The comparison assets belong to the documentation app. They do not add font downloads to apps that depend on Skribble. The OFL license and pinned source provenance are retained with the fonts.
