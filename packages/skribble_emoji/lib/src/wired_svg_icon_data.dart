// Re-export SVG icon primitives from the skribble package so that generated
// emoji map files can use a stable relative import path.
export 'package:skribble/skribble.dart'
    show
        WiredSvgCirclePrimitive,
        WiredSvgEllipsePrimitive,
        WiredSvgFillRule,
        WiredSvgIconData,
        WiredSvgPathPrimitive,
        WiredSvgPrimitive;
