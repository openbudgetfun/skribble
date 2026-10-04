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

  const WiredCanvas({
    super.key,
    required this.painter,
    required this.fillerType,
    this.drawConfig,
    this.fillerConfig,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuilds of an ancestor re-enter build with identical inputs; allocating
    // a fresh Filler/WiredPainter each time would force shouldRepaint true and
    // discard the painter's cached geometry. Memoize on the identity of the
    // config inputs so a stable painter keeps its prepared RoughDrawing across
    // rebuilds.
    final effectiveFillerConfig = fillerConfig ?? FillerConfig.defaultConfig;
    final Filler filler = useMemoized(
      () => _filters[fillerType]!.call(effectiveFillerConfig),
      [fillerType, effectiveFillerConfig],
    );
    // The theme's DrawConfig is a stable per-theme instance (see
    // WiredThemeData.drawConfig), so this read is cheap; memoizing the painter
    // on it (not on context) keeps the same WiredPainter across rebuilds.
    final resolvedDrawConfig = drawConfig ?? WiredTheme.of(context).drawConfig;
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
