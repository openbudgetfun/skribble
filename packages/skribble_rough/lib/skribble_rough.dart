/// The pure-Dart hand-drawn rendering engine behind skribble.
///
/// A `Generator` combines a seeded `DrawConfig` with a `Filler` to produce
/// `Drawable` shapes: rectangles, ellipses, lines, polygons, arcs, and
/// curves that wobble like they were drawn by hand. The same seed always
/// produces the same shape.
///
/// Nothing here depends on Flutter or `dart:ui`, so the engine runs in
/// command-line tools, servers, and web frameworks such as Jaspr. Turn a
/// drawable into SVG with `RoughSvg` (scalable centrelines) or `DrawableInk`
/// (pen-shaped ink at a fixed size). `package:skribble` paints the same
/// drawables on a Flutter canvas.
///
/// ```dart
/// final generator = Generator(
///   DrawConfig.build(seed: 7),
///   RoughFillStyle.hachure.filler(
///     FillerConfig.build(drawConfig: DrawConfig.build(seed: 7)),
///   ),
/// );
/// final svg = RoughSvg.fromDrawable(generator.rectangle(4, 4, 192, 92));
/// print(svg.toPathElements());
/// ```
library;

export 'src/config.dart';
export 'src/core.dart';
export 'src/entities.dart';
export 'src/filler.dart';
export 'src/generator.dart';
export 'src/geometry.dart';
export 'src/ink_stroke.dart';
export 'src/pen.dart';
export 'src/renderer.dart';
export 'src/svg.dart';
