import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../motion/wired_draw.dart';
import '../motion/wired_ink_response.dart';
import '../rough/skribble_rough.dart';
import '../wired_theme.dart';
import 'wired_painter.dart';
import 'wired_painter_base.dart';

/// A widget that paints a hand-drawn shape using a `WiredPainterBase`.
///
/// Combines a rough-drawing painter with a filler type and optional
/// configuration to render sketchy graphics via `CustomPaint`.
///
/// See also:
///  * `WiredPainter`, the `CustomPainter` that drives the rendering.
///  * `WiredPainterBase`, the abstract class painters implement.
class WiredCanvas extends HookWidget {
  final WiredPainterBase painter;
  final DrawConfig? drawConfig;
  final FillerConfig? fillerConfig;
  final RoughFilter fillerType;
  final Size? size;

  /// Varies the hand behind this shape's ink: the same seed always draws the
  /// same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

  const WiredCanvas({
    super.key,
    required this.painter,
    required this.fillerType,
    this.drawConfig,
    this.fillerConfig,
    this.size,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuilds of an ancestor re-enter build with identical inputs; allocating
    // a fresh Filler/WiredPainter each time would force shouldRepaint true and
    // discard the painter's cached geometry. Memoize on the identity of the
    // config inputs so a stable painter keeps its prepared RoughDrawing across
    // rebuilds.
    // The theme's DrawConfig is a stable per-theme instance (see
    // WiredThemeData.drawConfig), so this read is cheap; memoizing the painter
    // on it (not on context) keeps the same WiredPainter across rebuilds.
    final themeDrawConfig = drawConfig ?? WiredTheme.of(context).drawConfig;
    // A seeded copy is built once per (theme config, seed) pair: rebuilding
    // with the same seed must reuse the prepared geometry, not redraw it.
    final resolvedDrawConfig = useMemoized(
      () =>
          seed == null ? themeDrawConfig : themeDrawConfig.copyWith(seed: seed),
      [themeDrawConfig, seed],
    );
    // Fill strokes follow the outline's hand unless a config says otherwise,
    // so hachure is as tidy as the border around it and stays inside it. The
    // copy owns its random stream, so the fill never depends on how much of
    // the outline's stream another shape used first.
    final effectiveFillerConfig = useMemoized(
      () =>
          fillerConfig ??
          FillerConfig.build(drawConfig: resolvedDrawConfig.copyWith()),
      [fillerConfig, resolvedDrawConfig],
    );
    final Filler filler = useMemoized(
      () => _filters[fillerType]!.call(effectiveFillerConfig),
      [fillerType, effectiveFillerConfig],
    );
    final progress = WiredDrawTransition.progressOf(context);
    final pressure = WiredInkResponse.pressureOf(context);
    final wiredPainter = useMemoized(
      () => WiredPainter(
        resolvedDrawConfig,
        filler,
        painter,
        progress: progress,
        pressure: pressure,
      ),
      [resolvedDrawConfig, filler, painter, progress, pressure],
    );
    return CustomPaint(
      size: size ?? Size.infinite,
      painter: wiredPainter,
    );
  }
}

final Map<RoughFilter, Filler Function(FillerConfig)> _filters =
    <RoughFilter, Filler Function(FillerConfig)>{
      RoughFilter.noFiller: NoFiller.new,
      RoughFilter.hachureFiller: HachureFiller.new,
      RoughFilter.zigZagFiller: ZigZagFiller.new,
      RoughFilter.hatchFiller: HatchFiller.new,
      RoughFilter.dotFiller: DotFiller.new,
      RoughFilter.dashedFiller: DashedFiller.new,
      RoughFilter.solidFiller: SolidFiller.new,
    };

/// The fill pattern used by a [WiredCanvas].
///
/// Each value maps to a [Filler] subclass in the rough engine.
enum RoughFilter {
  noFiller,
  hachureFiller,
  zigZagFiller,
  hatchFiller,
  dotFiller,
  dashedFiller,
  solidFiller,
}
