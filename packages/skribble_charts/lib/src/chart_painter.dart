import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart'
    show FillerConfig, HachureFiller, PointD;
import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_theme.dart';

/// Cached layout and exact coordinate conversion used by chart and gestures.
///
/// Candle lists must be immutable snapshots in ascending timestamp order. An
/// indicator is calculated once per snapshot, so viewport changes only scan the
/// visible portion of history. The cache does not retain obsolete snapshots.
final class ChartScene {
  /// Lays out the chart, its lower [panes], and visible price bounds.
  ///
  /// [firstVisible] and [visibleCount] are candle-index coordinates. [size] is
  /// finite and nonnegative. Indicators in [overlays] share the price scale;
  /// indicators in [panes] have independent scales. [annotations] use market
  /// coordinates. [textStyle] customizes readable axis labels.
  factory ChartScene({
    required List<WiredChartCandle> candles,
    required WiredChartInstrument instrument,
    required double firstVisible,
    required double visibleCount,
    required Size size,
    required WiredPriceSeries series,
    required WiredChartPriceScale scale,
    required WiredChartStyle style,
    WiredChartDecimal? percentageReference,
    List<WiredChartIndicator> overlays = const [],
    List<WiredChartPane> panes = const [],
    List<WiredChartAnnotation> annotations = const [],
    TextStyle? textStyle,
  }) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width < 0 ||
        size.height < 0) {
      throw ArgumentError.value(
        size,
        'size',
        'Must be finite and nonnegative.',
      );
    }

    if (!style.roughness.isFinite ||
        style.roughness < 0 ||
        style.roughness > 2) {
      throw ArgumentError.value(
        style.roughness,
        'roughness',
        'Must be between zero and two.',
      );
    }

    for (final pane in panes) {
      if (!pane.weight.isFinite || pane.weight <= 0) {
        throw ArgumentError.value(
          pane.weight,
          'weight',
          'Must be finite and positive.',
        );
      }
    }

    final plotWidth = math.max<double>(
      1,
      size.width - (size.width >= 180 ? 82 : 12),
    );
    final plotHeight = math.max<double>(
      1,
      size.height - (size.height >= 80 ? 28 : 4),
    );
    final left = size.width >= 180 ? 10.0 : 0.0;
    final top = size.height >= 80 ? 12.0 : 0.0;
    final usableHeight = math.max<double>(1, plotHeight - top);
    final mainHeight = panes.isEmpty ? usableHeight : usableHeight * 0.65;
    final priceRect = Rect.fromLTWH(left, top, plotWidth, mainHeight);
    final paneRects = <Rect>[];
    final weight = panes.fold<double>(0, (total, pane) => total + pane.weight);
    var paneTop = priceRect.bottom;

    for (final pane in panes) {
      final height = usableHeight * 0.35 * pane.weight / weight;
      paneRects.add(Rect.fromLTWH(left, paneTop, plotWidth, height));
      paneTop += height;
    }

    final viewport = WiredChartViewport(
      firstVisible: firstVisible,
      visibleCount: visibleCount,
      width: plotWidth,
    );
    final start = math.max(0, firstVisible.floor());
    final end = math.min(candles.length, (firstVisible + visibleCount).ceil());
    final buckets = _visibleBuckets(candles, start, end, plotWidth);
    final cache = _indicatorCache[candles] ??=
        <WiredChartIndicator, WiredIndicatorResult>{};
    final results = <WiredChartIndicator, WiredIndicatorResult>{};
    final indicators = <WiredChartIndicator>[
      ...overlays,
      for (final pane in panes)
        if (pane is WiredIndicatorPane) pane.indicator,
    ];
    final missing = indicators.where(
      (indicator) => !cache.containsKey(indicator),
    );
    cache.addAll(calculateWiredChartIndicators(candles, missing));

    for (final indicator in indicators) {
      results[indicator] = cache[indicator]!;
    }

    var minPrice = buckets.isNotEmpty
        ? buckets.first.low
        : WiredChartDecimal.fromInt(1);
    var maxPrice = buckets.isNotEmpty
        ? buckets.first.high
        : WiredChartDecimal.fromInt(2);

    for (final bucket in buckets) {
      if (bucket.low < minPrice) minPrice = bucket.low;
      if (bucket.high > maxPrice) maxPrice = bucket.high;
    }

    for (final indicator in overlays) {
      for (final line in results[indicator]!.lines) {
        for (final index in _valueIndices(line.values, buckets)) {
          final value = line.values[index];
          if (value == null || !value.isFinite) continue;
          if (scale == WiredChartPriceScale.logarithmic && value <= 0) continue;
          final price = WiredChartDecimal.parse(value.toString());
          if (price < minPrice) minPrice = price;
          if (price > maxPrice) maxPrice = price;
        }
      }
    }

    if (scale == WiredChartPriceScale.logarithmic &&
        minPrice <= WiredChartDecimal.zero) {
      throw ArgumentError(
        'A logarithmic price scale requires positive visible prices.',
      );
    }

    // Add breathing room in pixels rather than extending decimal bounds.
    // Even source prices at the maximum supported precision remain drawable.
    final inset = priceRect.height * (0.06 / 1.12);
    final transform = WiredChartPriceTransform(
      min: minPrice,
      max: maxPrice,
      top: priceRect.top + inset,
      bottom: priceRect.bottom - inset,
      scale: scale,
      reference: candles.isEmpty
          ? WiredChartDecimal.fromInt(1)
          : percentageReference,
    );

    return ChartScene._(
      candles: candles,
      instrument: instrument,
      viewport: viewport,
      priceRect: priceRect,
      paneRects: List.unmodifiable(paneRects),
      transform: transform,
      series: series,
      scale: scale,
      style: style,
      overlays: overlays,
      panes: panes,
      annotations: annotations,
      textStyle: textStyle ?? const TextStyle(fontSize: 11),
      results: results,
      start: start,
      end: end,
      size: size,
      buckets: buckets,
    );
  }

  ChartScene._({
    required this.candles,
    required this.instrument,
    required this.viewport,
    required this.priceRect,
    required this.paneRects,
    required this.transform,
    required this.series,
    required this.scale,
    required this.style,
    required this.overlays,
    required this.panes,
    required this.annotations,
    required this.textStyle,
    required this.results,
    required this.start,
    required this.end,
    required this.size,
    required this._buckets,
  });

  final List<_CandleBucket> _buckets;

  /// Number of price envelopes painted after reducing subpixel candle density.
  /// At most one bucket per logical horizontal pixel, plus partial edge buckets.
  int get visibleBucketCount => _buckets.length;

  /// Original indices preserving first, last, minimum, and maximum values in
  /// each subpixel bucket. Pointer inspection continues to use source candles.
  List<int> sampledValueIndices(List<double?> values) =>
      _valueIndices(values, _buckets);

  List<int> get _priceIndices => [
    if (start > 0 && start <= candles.length) start - 1,
    for (final bucket in _buckets) ...bucket.priceIndices,
    if (end >= 0 && end < candles.length) end,
  ];

  static final _indicatorCache =
      Expando<Map<WiredChartIndicator, WiredIndicatorResult>>(
        'chart indicators',
      );

  /// Immutable data snapshot used by the scene.
  final List<WiredChartCandle> candles;

  /// Instrument identity and axis precision.
  final WiredChartInstrument instrument;

  /// Horizontal scale in logical pixels relative to [priceRect].
  final WiredChartViewport viewport;

  /// Price drawing bounds, excluding axes.
  final Rect priceRect;

  /// Bounds of each configured lower pane.
  final List<Rect> paneRects;

  /// Exact price conversion shared by rendering and gestures.
  final WiredChartPriceTransform transform;

  /// Price drawing representation.
  final WiredPriceSeries series;

  /// Vertical price scale policy.
  final WiredChartPriceScale scale;

  /// Palette and hand-drawn settings.
  final WiredChartStyle style;

  /// Indicators overlaid on the main price pane.
  final List<WiredChartIndicator> overlays;

  /// Lower pane configuration.
  final List<WiredChartPane> panes;

  /// Drawings anchored in time and price coordinates.
  final List<WiredChartAnnotation> annotations;

  /// Typography for axes and drawing labels.
  final TextStyle textStyle;

  /// Indicator results cached for this immutable snapshot.
  final Map<WiredChartIndicator, WiredIndicatorResult> results;

  /// First potentially visible candle index.
  final int start;

  /// Exclusive end of the visible candle range.
  final int end;

  /// Overall chart size, including axes.
  final Size size;

  /// Converts a candle index to a chart-relative horizontal position.
  double xForIndex(double index) => priceRect.left + viewport.xForIndex(index);

  /// Interpolates a timestamp across actual candle intervals, including gaps.
  double xForTime(DateTime time) {
    if (candles.isEmpty) return priceRect.left;
    if (candles.length == 1) return xForIndex(0);
    var lo = 0;
    var hi = candles.length - 1;
    final target = time.microsecondsSinceEpoch;

    while (lo + 1 < hi) {
      final mid = (lo + hi) ~/ 2;
      if (candles[mid].time.microsecondsSinceEpoch <= target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }

    final a = candles[lo].time.microsecondsSinceEpoch;
    final b = candles[lo + 1].time.microsecondsSinceEpoch;
    return xForIndex(lo + (target - a) / (b - a));
  }

  /// Converts a chart-relative horizontal position to an interpolated UTC time.
  DateTime timeForX(double x) {
    if (candles.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    if (candles.length == 1) return candles.first.time;
    final index =
        (x - priceRect.left) / priceRect.width * viewport.visibleCount +
        viewport.firstVisible -
        0.5;
    final base = index.floor().clamp(0, candles.length - 2);
    final a = candles[base].time.microsecondsSinceEpoch;
    final b = candles[base + 1].time.microsecondsSinceEpoch;
    return DateTime.fromMicrosecondsSinceEpoch(
      a + ((b - a) * (index - base)).round(),
      isUtc: true,
    );
  }

  /// Converts a vertical chart position to an exact decimal approximation.
  WiredChartDecimal priceForY(double y) {
    if (!y.isFinite) throw ArgumentError.value(y, 'y', 'Must be finite');
    return transform.priceForY(y.clamp(transform.top, transform.bottom));
  }

  /// Converts an exact source price to its chart-relative position.
  double yForPrice(WiredChartDecimal price) => transform.yForPrice(price);

  /// Finds the candle slot under [x], or null outside the available plot data.
  int? indexForX(double x) {
    if (x < priceRect.left || x > priceRect.right) return null;
    final index =
        ((x - priceRect.left) / priceRect.width * viewport.visibleCount +
                viewport.firstVisible)
            .floor();
    return index < 0 || index >= candles.length ? null : index;
  }

  /// Converts a persisted annotation anchor into chart-relative pixels.
  Offset positionForAnchor(WiredChartAnchor anchor) =>
      Offset(xForTime(anchor.time), yForPrice(anchor.price));
}

/// Draws price series, axes, indicator panes, and persisted annotations.
///
/// Decorative paths never change an OHLC boundary. Text and grids remain crisp.
/// Pointer inspection and selected drawing handles are painted by the widget.
final class ChartPainter extends CustomPainter {
  /// Creates a painter for an immutable [scene].
  ChartPainter(this.scene);

  /// Layout, data, and presentation being painted.
  final ChartScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = scene.style.background,
    );
    if (size.width < 24 || size.height < 24) return;
    _grid(canvas);
    canvas
      ..save()
      ..clipRect(scene.priceRect);

    if (scene.candles.isNotEmpty) {
      switch (scene.series) {
        case WiredPriceSeries.candlesticks:
        case WiredPriceSeries.bars:
          for (final bucket in scene._buckets) {
            _candle(canvas, bucket);
          }
        case WiredPriceSeries.line:
        case WiredPriceSeries.area:
          _priceLine(canvas);
      }
      var colorIndex = 0;
      for (final indicator in scene.overlays) {
        final result = scene.results[indicator]!;
        for (final line in result.lines) {
          _indicatorLine(
            canvas,
            line.values,
            scene.style.indicatorColor(colorIndex++),
            (value) {
              if (scene.scale == WiredChartPriceScale.logarithmic &&
                  value <= 0) {
                return null;
              }
              return scene.yForPrice(WiredChartDecimal.parse(value.toString()));
            },
          );
        }
      }
      for (final annotation in scene.annotations) {
        _annotation(canvas, annotation);
      }
    }
    canvas.restore();

    for (var index = 0; index < scene.panes.length; index++) {
      _pane(canvas, index);
    }
    _axes(canvas);

    if (scene.candles.isEmpty) {
      _text(
        canvas,
        'No market data',
        Offset(scene.priceRect.center.dx - 44, scene.priceRect.center.dy - 8),
      );
    }
  }

  void _grid(Canvas canvas) {
    final paint = Paint()
      ..color = scene.style.grid
      ..strokeWidth = 0.6;
    for (var step = 0; step <= 4; step++) {
      final y =
          scene.transform.top +
          (scene.transform.bottom - scene.transform.top) * step / 4;
      canvas.drawLine(
        Offset(scene.priceRect.left, y),
        Offset(scene.priceRect.right, y),
        paint,
      );
    }
    final bottom = scene.paneRects.isEmpty
        ? scene.priceRect.bottom
        : scene.paneRects.last.bottom;
    final count = math.max(1, (scene.priceRect.width / 105).floor());
    for (var step = 0; step <= count; step++) {
      final x = scene.priceRect.left + scene.priceRect.width * step / count;
      canvas.drawLine(Offset(x, scene.priceRect.top), Offset(x, bottom), paint);
    }
  }

  void _candle(Canvas canvas, _CandleBucket candle) {
    final x = scene.xForIndex(candle.centerIndex);
    final width = math.max(
      0.8,
      math.min(
        22,
        scene.priceRect.width /
            scene.viewport.visibleCount *
            (candle.end - candle.start) *
            0.68,
      ),
    );
    final open = scene.yForPrice(candle.open);
    final close = scene.yForPrice(candle.close);
    final high = scene.yForPrice(candle.high);
    final low = scene.yForPrice(candle.low);
    final color = candle.isBullish ? scene.style.rise : scene.style.fall;
    final ink = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, high), Offset(x, low), ink);

    if (scene.series == WiredPriceSeries.bars) {
      canvas
        ..drawLine(Offset(x - width / 2, open), Offset(x, open), ink)
        ..drawLine(Offset(x, close), Offset(x + width / 2, close), ink);
      return;
    }

    final body = Rect.fromLTRB(
      x - width / 2,
      math.min(open, close),
      x + width / 2,
      math.max(open, close),
    );
    if (body.height == 0) {
      canvas.drawLine(body.topLeft, body.topRight, ink);
      return;
    }
    canvas
      ..drawRect(body, Paint()..color = scene.style.background)
      ..drawRect(
        body,
        Paint()
          ..color = color.withValues(
            alpha: scene.style.handDrawn ? 0.10 : 0.24,
          ),
      );
    final seed = _seed(
      scene.instrument.id,
      scene.candles[candle.start].time.microsecondsSinceEpoch,
    );

    if (scene.style.handDrawn && width >= 4 && body.height >= 3) {
      _hatch(canvas, body, color, seed);
    }

    // Only the side interiors wander. All four corners, price boundaries, and
    // wick endpoints retain exactly the same coordinates as crisp rendering.
    canvas
      ..drawLine(body.topLeft, body.topRight, ink)
      ..drawLine(body.bottomLeft, body.bottomRight, ink);
    _side(canvas, body.topLeft, body.bottomLeft, ink, seed);
    _side(canvas, body.topRight, body.bottomRight, ink, seed + 1);
  }

  void _side(Canvas canvas, Offset start, Offset end, Paint paint, int seed) {
    if (!scene.style.handDrawn || (end - start).distance < 3) {
      canvas.drawLine(start, end, paint);
      return;
    }
    final amount = scene.style.roughness * ((seed % 101) / 50 - 1);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + amount,
        start.dy + (end.dy - start.dy) / 3,
        end.dx - amount,
        start.dy + (end.dy - start.dy) * 2 / 3,
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, paint);
  }

  void _hatch(Canvas canvas, Rect rect, Color color, int seed) {
    final config = FillerConfig.build(hachureAngle: -45, hachureGap: 4.5);
    final lines = HachureFiller(config).buildFillLines([
      PointD(0, 0),
      PointD(rect.width, 0),
      PointD(rect.width, rect.height),
      PointD(0, rect.height),
    ], config);
    final ink = Paint()
      ..color = color.withValues(alpha: 0.64)
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;
    canvas
      ..save()
      ..clipRect(rect)
      ..translate(rect.left, rect.top);
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final drift =
          scene.style.roughness * (((seed + index * 29) % 101) / 50 - 1);
      final path = Path()
        ..moveTo(line.source.x, line.source.y)
        ..quadraticBezierTo(
          (line.source.x + line.target.x) / 2 + drift,
          (line.source.y + line.target.y) / 2,
          line.target.x,
          line.target.y,
        );
      canvas.drawPath(path, ink);
    }
    canvas.restore();
  }

  void _priceLine(Canvas canvas) {
    final path = Path();
    final indices = scene._priceIndices;
    if (indices.isEmpty) return;
    final start = indices.first;
    final first = Offset(
      scene.xForIndex(start.toDouble()),
      scene.yForPrice(scene.candles[start].close),
    );
    path.moveTo(first.dx, first.dy);
    for (final index in indices.skip(1)) {
      path.lineTo(
        scene.xForIndex(index.toDouble()),
        scene.yForPrice(scene.candles[index].close),
      );
    }
    if (scene.series == WiredPriceSeries.area) {
      final fill = Path.from(path)
        ..lineTo(
          scene.xForIndex(indices.last.toDouble()),
          scene.priceRect.bottom,
        )
        ..lineTo(first.dx, scene.priceRect.bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()..color = scene.style.rise.withValues(alpha: 0.13),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = scene.style.rise
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _indicatorLine(
    Canvas canvas,
    List<double?> values,
    Color color,
    double? Function(double) yForValue,
  ) {
    final path = Path();
    var connected = false;
    for (final index in [
      if (scene.start > 0 && scene.start <= values.length) scene.start - 1,
      ...scene.sampledValueIndices(values),
      if (scene.end >= 0 && scene.end < values.length) scene.end,
    ]) {
      final value = values[index];
      final y = value == null || !value.isFinite ? null : yForValue(value);
      if (y == null || !y.isFinite) {
        connected = false;
        continue;
      }
      final x = scene.xForIndex(index.toDouble());
      if (connected) {
        path.lineTo(x, y);
      } else {
        path.moveTo(x, y);
        connected = true;
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35,
    );
  }

  void _pane(Canvas canvas, int index) {
    final pane = scene.panes[index];
    final rect = scene.paneRects[index];
    String upperLabel;
    String lowerLabel;
    canvas
      ..drawLine(
        rect.topLeft,
        rect.topRight,
        Paint()
          ..color = scene.style.grid
          ..strokeWidth = 0.8,
      )
      ..save()
      ..clipRect(rect);
    final content = Rect.fromLTRB(
      rect.left,
      rect.top + math.min(20, rect.height * 0.25),
      rect.right,
      rect.bottom - math.min(5, rect.height * 0.1),
    );
    switch (pane) {
      case WiredVolumePane():
        final maximum = _volume(canvas, content);
        upperLabel = _compactNumber(maximum.toDouble());
        lowerLabel = '0';
        _text(
          canvas,
          scene.visibleBucketCount < scene.end - scene.start
              ? 'Volume · peak'
              : 'Volume',
          rect.topLeft + const Offset(4, 3),
          fontSize: 10,
        );
      case WiredIndicatorPane():
        final result = scene.results[pane.indicator]!;
        final samples = <double>[
          for (final line in result.lines)
            for (final i in scene.sampledValueIndices(line.values))
              if (line.values[i] case final double value when value.isFinite)
                value,
          if (result.histogram case final histogram?)
            for (final i in scene.sampledValueIndices(histogram))
              if (histogram[i] case final double value when value.isFinite)
                value,
        ];
        var min = samples.isEmpty ? 0.0 : samples.reduce(math.min);
        var max = samples.isEmpty ? 1.0 : samples.reduce(math.max);
        if (result.histogram != null) {
          min = math.min(0, min);
          max = math.max(0, max);
        }
        upperLabel = _compactNumber(max);
        lowerLabel = _compactNumber(min);
        final magnitude = math.max(min.abs(), max.abs());
        final normalizedMin = magnitude == 0 ? 0.0 : min / magnitude;
        final normalizedMax = magnitude == 0 ? 0.0 : max / magnitude;
        double yForValue(double value) {
          if (min == max) return content.center.dy;
          final fraction =
              (value / magnitude - normalizedMin) /
              (normalizedMax - normalizedMin);
          return content.bottom - content.height * (0.08 + fraction * 0.84);
        }
        if (result.histogram case final histogram?) {
          final width = math.max(
            0.8,
            math.min(22, rect.width / scene.viewport.visibleCount * 0.68),
          );
          final zero = yForValue(0);
          for (final i in scene.sampledValueIndices(histogram)) {
            final value = histogram[i];
            if (value == null || !value.isFinite) continue;
            final y = yForValue(value);
            canvas.drawRect(
              Rect.fromLTRB(
                scene.xForIndex(i.toDouble()) - width / 2,
                math.min(y, zero),
                scene.xForIndex(i.toDouble()) + width / 2,
                math.max(y, zero),
              ),
              Paint()
                ..color = (value >= 0 ? scene.style.rise : scene.style.fall)
                    .withValues(alpha: 0.40),
            );
          }
        }
        for (var line = 0; line < result.lines.length; line++) {
          _indicatorLine(
            canvas,
            result.lines[line].values,
            scene.style.indicatorColor(line),
            yForValue,
          );
        }
        _text(
          canvas,
          pane.indicator.label,
          rect.topLeft + const Offset(4, 3),
          fontSize: 10,
        );
    }
    canvas.restore();
    if (scene.size.width >= 180 && rect.height >= 35) {
      final maxWidth = math.max<double>(0, scene.size.width - rect.right - 9);
      _text(
        canvas,
        upperLabel,
        Offset(rect.right + 7, content.top),
        fontSize: 10,
        maxWidth: maxWidth,
      );
      _text(
        canvas,
        lowerLabel,
        Offset(rect.right + 7, content.bottom - 10),
        fontSize: 10,
        maxWidth: maxWidth,
      );
    }
  }

  WiredChartDecimal _volume(Canvas canvas, Rect rect) {
    var maximum = WiredChartDecimal.zero;
    for (final bucket in scene._buckets) {
      if (bucket.peakVolume > maximum) {
        maximum = bucket.peakVolume;
      }
    }
    if (maximum.isZero) return maximum;
    for (final candle in scene._buckets) {
      final width = math.max<double>(
        0.8,
        math.min(
          22,
          rect.width /
              scene.viewport.visibleCount *
              (candle.end - candle.start) *
              0.68,
        ),
      );
      final x = scene.xForIndex(candle.centerIndex);
      final y = rect.bottom - candle.peakVolume.ratio(maximum) * rect.height;
      canvas.drawRect(
        Rect.fromLTRB(x - width / 2, y, x + width / 2, rect.bottom),
        Paint()
          ..color = (candle.isBullish ? scene.style.rise : scene.style.fall)
              .withValues(alpha: 0.40),
      );
    }
    return maximum;
  }

  String _compactNumber(double value) {
    if (!value.isFinite) return '—';
    if (value.abs() >= 1e9) return value.toStringAsExponential(2);
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    if (value != 0 && value.abs() < 0.01) return value.toStringAsExponential(2);
    return value.toStringAsFixed(2);
  }

  void _annotation(Canvas canvas, WiredChartAnnotation annotation) {
    // A saved drawing can leave the valid domain after switching price scales.
    // It stays in the document and becomes visible again on a linear scale.
    if (scene.scale == WiredChartPriceScale.logarithmic &&
        annotation.anchors.any(
          (anchor) => anchor.price <= WiredChartDecimal.zero,
        )) {
      return;
    }
    final points = annotation.anchors.map(scene.positionForAnchor).toList();
    if (points.any((point) => !point.dx.isFinite || !point.dy.isFinite)) return;
    final ink = Paint()
      ..color = scene.style.foreground.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    switch (annotation) {
      case WiredChartTrendLine():
        canvas.drawLine(points[0], points[1], ink);
      case WiredChartHorizontalLine():
        canvas.drawLine(
          Offset(scene.priceRect.left, points[0].dy),
          Offset(scene.priceRect.right, points[0].dy),
          ink,
        );
      case WiredChartRectangle():
        final rect = Rect.fromPoints(points[0], points[1]);
        canvas
          ..drawRect(
            rect,
            Paint()..color = scene.style.foreground.withValues(alpha: 0.035),
          )
          ..drawRect(rect, ink);
      case WiredChartText():
        break;
      case WiredChartFibonacci():
        final left = math.min(points[0].dx, points[1].dx);
        final right = math.max(points[0].dx, points[1].dx);
        for (final level in WiredChartFibonacci.levels) {
          final price = annotation.anchors[0].price.interpolate(
            annotation.anchors[1].price,
            level,
          );
          final y = scene.yForPrice(price);
          canvas.drawLine(
            Offset(left, y),
            Offset(right, y),
            ink..color = scene.style.foreground.withValues(alpha: 0.45),
          );
          _text(
            canvas,
            '${(level * 100).toStringAsFixed(1)}%',
            Offset(left + 3, y - 12),
            fontSize: 9,
          );
        }
    }
    if (annotation.label.isNotEmpty) {
      _text(canvas, annotation.label, points[0] + const Offset(4, -16));
    }
  }

  void _axes(Canvas canvas) {
    if (scene.size.width < 180 || scene.size.height < 80) return;
    for (var step = 0; step <= 4; step++) {
      if (scene.transform.min == scene.transform.max && step != 2) continue;
      final y =
          scene.transform.top +
          (scene.transform.bottom - scene.transform.top) * step / 4;
      final price = scene.priceForY(y);
      final label = scene.scale == WiredChartPriceScale.percentage
          ? '${scene.transform.valueForPrice(price).toStringAsFixed(2)}%'
          : _formatPrice(price);
      _text(
        canvas,
        label,
        Offset(scene.priceRect.right + 7, y - 6),
        maxWidth: math.max(0, scene.size.width - scene.priceRect.right - 9),
      );
    }
    if (scene.candles.isEmpty) return;
    final count = math.max(1, (scene.priceRect.width / 105).floor());
    final bottom = scene.paneRects.isEmpty
        ? scene.priceRect.bottom
        : scene.paneRects.last.bottom;
    final interval = scene.candles.length < 2
        ? Duration.zero
        : scene.candles.last.time.difference(scene.candles.first.time) ~/
              (scene.candles.length - 1);
    final firstTime = scene.timeForX(scene.priceRect.left);
    final lastTime = scene.timeForX(scene.priceRect.right);
    final crossesDay =
        firstTime.year != lastTime.year ||
        firstTime.month != lastTime.month ||
        firstTime.day != lastTime.day;
    for (var step = 0; step < count; step++) {
      final x =
          scene.priceRect.left + scene.priceRect.width * (step + 0.5) / count;
      final time = scene.timeForX(x);
      final date =
          '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
      final clock =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final label = interval.inHours >= 24
          ? date
          : crossesDay
          ? '$date $clock'
          : clock;
      _text(
        canvas,
        label,
        Offset(x - (label.length > 5 ? 32 : 16), bottom + 8),
        fontSize: 10,
      );
    }
    _text(
      canvas,
      'UTC',
      Offset(scene.priceRect.right + 7, bottom + 8),
      fontSize: 9,
    );
  }

  String _formatPrice(WiredChartDecimal price) {
    final fixed = price.toStringAsFixed(scene.instrument.priceDecimals);
    if (fixed.length <= 11) return fixed;
    final digits = price.coefficient.abs().toString();
    final significant = digits.padRight(4, '0').substring(0, 4);
    final exponent = digits.length - price.scale - 1;
    return '${price.isNegative ? '-' : ''}${significant[0]}.${significant.substring(1)}e$exponent';
  }

  void _text(
    Canvas canvas,
    String text,
    Offset position, {
    double? fontSize,
    double maxWidth = double.infinity,
  }) {
    TextPainter(
        text: TextSpan(
          text: text,
          style: scene.textStyle.copyWith(
            color: scene.style.foreground,
            fontSize: fontSize,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )
      ..layout(maxWidth: maxWidth)
      ..paint(canvas, position)
      ..dispose();
  }

  static int _seed(String instrument, int timestamp) {
    var seed = timestamp % 2147483647;
    for (final unit in instrument.codeUnits) {
      seed = (seed * 31 + unit) % 2147483647;
    }
    return seed;
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      !identical(scene, oldDelegate.scene);
}

// Cache aligned power-of-two intervals, so panning normally only scans new
// edge intervals. Each immutable snapshot owns bounded weakly-held caches.
const _bucketCacheLimit = 8192;
final _candleBucketCache = Expando<LinkedHashMap<(int, int), _CandleBucket>>();
final _valueBucketCache = Expando<LinkedHashMap<(int, int), List<int>>>();

List<_CandleBucket> _visibleBuckets(
  List<WiredChartCandle> candles,
  int start,
  int end,
  double width,
) {
  if (start >= end) return const [];
  var span = 1;
  while ((end - start) / span > math.max(1, width)) {
    span *= 2;
  }
  final cache = _candleBucketCache[candles] ??= LinkedHashMap();
  final buckets = <_CandleBucket>[];
  for (var index = start; index < end;) {
    final next = math.min(end, (index ~/ span + 1) * span);
    final key = (index, next);
    final bucket = span == 1
        ? _CandleBucket.read(candles, index, next)
        : cache.remove(key) ?? _CandleBucket.read(candles, index, next);
    if (span > 1) {
      cache[key] = bucket;
      if (cache.length > _bucketCacheLimit) cache.remove(cache.keys.first);
    }
    buckets.add(bucket);
    index = next;
  }
  return buckets;
}

List<int> _valueIndices(List<double?> values, List<_CandleBucket> buckets) {
  final cache = _valueBucketCache[values] ??= LinkedHashMap();
  final indices = <int>[];
  for (final bucket in buckets) {
    final start = bucket.start;
    final end = math.min(bucket.end, values.length);
    if (start >= end) continue;
    if (end - start == 1) {
      indices.add(start);
      continue;
    }
    final key = (start, end);
    var summary = cache.remove(key);
    if (summary == null) {
      int? minimum;
      int? maximum;
      for (var index = start; index < end; index++) {
        final value = values[index];
        if (value == null) continue;
        if (minimum == null || value < values[minimum]!) minimum = index;
        if (maximum == null || value > values[maximum]!) maximum = index;
      }
      summary = {start, end - 1, ?minimum, ?maximum}.toList()..sort();
    }
    cache[key] = summary;
    if (cache.length > _bucketCacheLimit) cache.remove(cache.keys.first);
    indices.addAll(summary);
  }
  return indices;
}

final class _CandleBucket {
  _CandleBucket(
    this.start,
    this.end,
    this.open,
    this.close,
    this.high,
    this.low,
    this.peakVolume,
    this.priceIndices,
  );

  factory _CandleBucket.read(
    List<WiredChartCandle> candles,
    int start,
    int end,
  ) {
    var high = candles[start].high;
    var low = candles[start].low;
    var volume = candles[start].volume;
    var minimumClose = start;
    var maximumClose = start;
    for (var index = start + 1; index < end; index++) {
      final candle = candles[index];
      if (candle.high > high) high = candle.high;
      if (candle.low < low) low = candle.low;
      if (candle.volume > volume) volume = candle.volume;
      if (candle.close < candles[minimumClose].close) minimumClose = index;
      if (candle.close > candles[maximumClose].close) maximumClose = index;
    }
    return _CandleBucket(
      start,
      end,
      candles[start].open,
      candles[end - 1].close,
      high,
      low,
      volume,
      {start, end - 1, minimumClose, maximumClose}.toList()..sort(),
    );
  }

  final int start;
  final int end;
  final WiredChartDecimal open;
  final WiredChartDecimal close;
  final WiredChartDecimal high;
  final WiredChartDecimal low;
  final WiredChartDecimal peakVolume;
  final List<int> priceIndices;
  bool get isBullish => close >= open;
  double get centerIndex => (start + end - 1) / 2;
}
