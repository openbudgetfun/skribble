<!-- Shared dartdoc content for the skribble library sources. Consumer
     blocks live inside `///` comments and use a linePrefix transformer
     matching the comment indentation, e.g.
     `{=dartSemanticLabelOptional|trim|linePrefix:"  /// "}`. Run
     `mdt update` (fix:docs) after editing providers here.

     dprint.json excludes this file so the line breaks below survive:
     each provider line becomes one `///` line, and the Dart lints keep
     those lines within 80 columns. Wrap new providers at 74 characters. -->

<!-- {@dartSemanticLabelOptional} -->

Optional semantic label for accessibility.

<!-- {/dartSemanticLabelOptional} -->

<!-- {@dartSemanticLabel} -->

Semantic label for accessibility.

<!-- {/dartSemanticLabel} -->

<!-- The `seed` parameter of widgets that draw their own ink. -->
<!-- {@dartInkSeed} -->

Varies the hand behind this widget's ink. The same seed always draws
the same wobble, so neighbouring shapes of the same size need different
seeds to stop them reading as copies of each other. Null keeps the
theme's seed.

<!-- {/dartInkSeed} -->

<!-- `operator ==` on the base painters in wired_painter_bases.dart. -->
<!-- {@dartPainterValueEquality} -->

Value equality: WiredCanvas memoizes its painter and skips repainting
only when equal-valued delegates compare equal, so callers may construct
painters inline in build.

<!-- {/dartPainterValueEquality} -->

<!-- The `borderRadius` parameter of the rectangular buttons. -->
<!-- {@dartRoughBorderRadius} -->

Corner radii drawn with the theme's roughness. Use [BorderRadius.zero]
for square corners.

<!-- {/dartRoughBorderRadius} -->

<!-- Hachure fill parameters of the icon widgets and painters. -->
<!-- {@dartHachureGap} -->

Distance between hachure strokes, in logical pixels.

<!-- {/dartHachureGap} -->

<!-- {@dartHachureAngle} -->

Angle of hachure strokes, in degrees.

<!-- {/dartHachureAngle} -->

<!-- {@dartChipLabel} -->

The chip's label, usually a [Text].

<!-- {/dartChipLabel} -->

<!-- {@dartTileShowDivider} -->

Whether a hand-drawn line is drawn below the tile. Defaults to true.

<!-- {/dartTileShowDivider} -->

<!-- {@dartDestinationIcon} -->

The icon shown when this destination is not selected.

<!-- {/dartDestinationIcon} -->

<!-- {@dartDestinationSelectedIcon} -->

The icon shown when this destination is selected. Defaults to [icon].

<!-- {/dartDestinationSelectedIcon} -->
