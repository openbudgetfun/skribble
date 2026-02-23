import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../rough/skribble_rough.dart';

import 'wired_painter.dart';
import 'wired_painter_base.dart';

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
    final Filler filler = _filters[fillerType]!.call(
      fillerConfig ?? FillerConfig.defaultConfig,
    );
    return CustomPaint(
      size: size ?? Size.infinite,
      painter: WiredPainter(
        drawConfig ?? DrawConfig.defaultValues,
        filler,
        painter,
      ),
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

enum RoughFilter {
  noFiller,
  hachureFiller,
  zigZagFiller,
  hatchFiller,
  dotFiller,
  dashedFiller,
  solidFiller,
}
