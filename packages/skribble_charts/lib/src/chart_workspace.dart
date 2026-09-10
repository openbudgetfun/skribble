import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_theme.dart';

/// An immutable, versioned chart layout without market data or edit history.
///
/// Capture a workspace when saving a user's layout. On load, obtain the same
/// instrument's candles first, then [restore] navigation and drawings. Supply
/// [series], [scale], [overlays], [panes], and [handDrawn] to the chart widget.
/// The host owns storage, market transport, and controller lifetimes.
@immutable
final class WiredChartWorkspace {
  const WiredChartWorkspace._({
    required this.instrument,
    required this.series,
    required this.scale,
    required this.overlays,
    required this.panes,
    required this.handDrawn,
    required this.percentageReference,
    required this.firstVisibleTime,
    required this.firstVisibleFraction,
    required this.visibleCount,
    required this.visibleCandleCount,
    required this.selectedTime,
    required this.annotations,
    required this.selectedAnnotationId,
  });

  /// Captures [controller] navigation and [annotations] with widget options.
  ///
  /// The options default to hand-drawn candlesticks on a linear scale without
  /// indicators. Lists are copied and each indicator and pane is validated.
  /// Invalid options throw [FormatException] without changing either controller.
  factory WiredChartWorkspace.capture(
    WiredChartController controller,
    WiredChartAnnotations annotations, {
    WiredPriceSeries series = WiredPriceSeries.candlesticks,
    WiredChartPriceScale scale = WiredChartPriceScale.linear,
    List<WiredChartIndicator> overlays = const [],
    List<WiredChartPane> panes = const [],
    bool handDrawn = true,
  }) {
    if (controller.isDisposed || annotations.isDisposed) {
      throw StateError('Cannot capture a workspace from disposed controllers.');
    }

    final candles = controller.candles;
    final first = controller.firstVisible.floor();
    final selection = controller.selectedIndex;

    return WiredChartWorkspace.fromJson({
      'version': 1,
      'instrument': {
        'id': controller.instrument.id,
        'priceDecimals': controller.instrument.priceDecimals,
        'volumeDecimals': controller.instrument.volumeDecimals,
      },
      'series': series.name,
      'scale': scale.name,
      'overlays': overlays.map((indicator) => indicator.toJson()).toList(),
      'panes': panes.map(_paneToJson).toList(),
      'handDrawn': handDrawn,
      'percentageReference': controller.percentageReference?.toString(),
      'viewport': {
        'time': candles.isEmpty ? null : candles[first].time.toIso8601String(),
        'fraction': controller.firstVisible - first,
        'visibleCount': controller.visibleCount,
        'visibleCandleCount': math.min(
          candles.length - first,
          (controller.firstVisible - first + controller.visibleCount).ceil(),
        ),
      },
      'selectedTime': selection == null
          ? null
          : candles[selection].time.toIso8601String(),
      'annotations': annotations.exportDocument(),
    });
  }

  /// Validates and decodes a version-1 workspace from a JSON object.
  ///
  /// Malformed data, unknown enum values and versions, invalid indicator
  /// parameters, duplicate drawing IDs, and invalid numbers throw
  /// [FormatException]. UTC timestamps use the canonical Dart ISO format,
  /// including milliseconds or microseconds as needed to preserve the instant.
  factory WiredChartWorkspace.fromJson(Object? value) {
    final json = _object(value, 'workspace');
    final version = json['version'];

    if (version is! int || version != 1) {
      throw const FormatException('Unsupported chart workspace version.');
    }

    final instrument = _readInstrument(json['instrument']);
    final series = _enum(json['series'], WiredPriceSeries.values, 'series');
    final scale = _enum(json['scale'], WiredChartPriceScale.values, 'scale');
    final overlays = _list(json['overlays'], 'overlays')
        .map(
          (value) => WiredChartIndicator.fromJson(_object(value, 'indicator')),
        )
        .toList(growable: false);
    final panes = _list(
      json['panes'],
      'panes',
    ).map(_readPane).toList(growable: false);
    final handDrawn = json['handDrawn'];
    final viewport = _object(json['viewport'], 'viewport');
    final firstVisibleTime = _nullableTime(viewport, 'time');
    final fraction = _number(viewport['fraction'], 'fraction');
    final visibleCount = _number(viewport['visibleCount'], 'visibleCount');
    final visibleCandleCount = viewport['visibleCandleCount'];
    final percentageReference = _readPercentageReference(json);
    final selectedTime = _nullableTime(json, 'selectedTime');
    final drawings = _readAnnotations(json['annotations']);
    final totalWeight = panes.fold<double>(
      0,
      (total, pane) => total + pane.weight,
    );

    if (handDrawn is! bool) {
      throw const FormatException('handDrawn must be a boolean.');
    }

    if (fraction < 0 || fraction >= 1) {
      throw const FormatException('Viewport fraction must be in [0, 1).');
    }

    if (visibleCount < 1 || visibleCount > 1000000) {
      throw const FormatException('visibleCount must be in [1, 1000000].');
    }

    if (visibleCandleCount is! int ||
        visibleCandleCount < 0 ||
        visibleCandleCount > (fraction + visibleCount).ceil()) {
      throw const FormatException('visibleCandleCount must fit the viewport.');
    }

    if ((firstVisibleTime == null) != (visibleCandleCount == 0)) {
      throw const FormatException(
        'Viewport anchor and visible candle count must agree.',
      );
    }

    if (scale == WiredChartPriceScale.percentage &&
        firstVisibleTime != null &&
        percentageReference == null) {
      throw const FormatException(
        'A nonempty percentage chart requires a positive reference.',
      );
    }

    if (firstVisibleTime == null && (fraction != 0 || selectedTime != null)) {
      throw const FormatException(
        'An empty viewport cannot have a fractional anchor or candle selection.',
      );
    }

    if (!totalWeight.isFinite) {
      throw const FormatException('Total pane weight must be finite.');
    }

    return WiredChartWorkspace._(
      instrument: instrument,
      series: series,
      scale: scale,
      overlays: List.unmodifiable(overlays),
      panes: List.unmodifiable(panes),
      handDrawn: handDrawn,
      percentageReference: percentageReference,
      firstVisibleTime: firstVisibleTime,
      firstVisibleFraction: fraction,
      visibleCount: visibleCount,
      visibleCandleCount: visibleCandleCount,
      selectedTime: selectedTime,
      annotations: drawings.annotations,
      selectedAnnotationId: drawings.selectedId,
    );
  }

  /// Decodes [source] with [WiredChartWorkspace.fromJson] validation.
  factory WiredChartWorkspace.decode(String source) =>
      WiredChartWorkspace.fromJson(jsonDecode(source));

  /// The saved market identity and exact price and volume display precision.
  final WiredChartInstrument instrument;

  /// The price-series rendering mode to pass to the chart widget.
  final WiredPriceSeries series;

  /// The price-axis policy to pass to the chart widget.
  final WiredChartPriceScale scale;

  /// Validated immutable indicator descriptions sharing the price pane.
  final List<WiredChartIndicator> overlays;

  /// Validated immutable lower-pane descriptions, in paint order.
  final List<WiredChartPane> panes;

  /// Whether the chart style should draw decorative hand-drawn texture.
  final bool handDrawn;

  /// Exact positive percentage baseline, independent of loaded history order.
  ///
  /// Null means no baseline had been established. Restoring a null baseline
  /// retains the target controller's reference established during data loading.
  final WiredChartDecimal? percentageReference;

  /// Timestamp of the candle slot at the viewport's left boundary.
  ///
  /// Null means the workspace was captured without candles. Using a timestamp
  /// instead of an index keeps this coordinate stable when history is prepended.
  final DateTime? firstVisibleTime;

  /// The fractional offset within [firstVisibleTime]'s candle slot, in [0, 1).
  final double firstVisibleFraction;

  /// Number of candle slots across the saved viewport, including fractions.
  final double visibleCount;

  /// Number of actual candles intersecting the viewport when it was captured.
  ///
  /// This may be less than [visibleCount] when a new instrument has little data.
  /// Restore requires at least this many candles from the saved anchor. A full
  /// captured viewport cannot silently restore into a partially loaded dataset.
  final int visibleCandleCount;

  /// The selected candle's timestamp, or null for no inspection selection.
  final DateTime? selectedTime;

  /// Immutable drawings in paint order, with exact decimal market coordinates.
  final List<WiredChartAnnotation> annotations;

  /// Selected drawing ID, or null for no drawing selection.
  final String? selectedAnnotationId;

  /// Encodes widget options, market coordinates, and annotations as version 1.
  ///
  /// Price coordinates are decimal strings. UTC timestamps preserve microseconds.
  /// Only layout quantities such as pane weights and candle-slot fractions use
  /// floating-point JSON numbers. Market candles and edit history are omitted.
  Map<String, Object?> toJson() => {
    'version': 1,
    'instrument': {
      'id': instrument.id,
      'priceDecimals': instrument.priceDecimals,
      'volumeDecimals': instrument.volumeDecimals,
    },
    'series': series.name,
    'scale': scale.name,
    'overlays': overlays.map((indicator) => indicator.toJson()).toList(),
    'panes': panes.map(_paneToJson).toList(),
    'handDrawn': handDrawn,
    'percentageReference': percentageReference?.toString(),
    'viewport': {
      'time': firstVisibleTime?.toIso8601String(),
      'fraction': firstVisibleFraction,
      'visibleCount': visibleCount,
      'visibleCandleCount': visibleCandleCount,
    },
    'selectedTime': selectedTime?.toIso8601String(),
    'annotations': {
      'version': 1,
      'annotations': annotations
          .map((annotation) => annotation.toJson())
          .toList(),
      'selectedId': selectedAnnotationId,
    },
  };

  /// Serializes [toJson] to a JSON string suitable for host-owned storage.
  String encode() => jsonEncode(toJson());

  /// Restores navigation and drawings after validating the complete target.
  ///
  /// The target [controller] must describe the same instrument and display
  /// precision. Saved anchor and selection timestamps must exist in its data,
  /// with enough trailing candles to preserve the viewport and its captured
  /// [visibleCandleCount]. A chart captured with fewer bars than viewport slots
  /// can restore that same sparse view; a previously full view requires all of
  /// its visible bars. Missing history or
  /// incompatible price data throws [ArgumentError] before either owner changes.
  /// Load the required history and retry. An originally empty viewport restores
  /// to the beginning of the target's data.
  ///
  /// [annotations] receives an immutable copy and its edit history is cleared.
  /// Widget options remain on this workspace for the host to apply. Each owner
  /// notifies its own listeners; this is not a cross-controller event transaction.
  void restore({
    required WiredChartController controller,
    required WiredChartAnnotations annotations,
  }) {
    if (controller.isDisposed || annotations.isDisposed) {
      throw StateError('Cannot restore a workspace into disposed controllers.');
    }

    final target = controller.instrument;

    if (target.id != instrument.id ||
        target.priceDecimals != instrument.priceDecimals ||
        target.volumeDecimals != instrument.volumeDecimals) {
      throw ArgumentError(
        'Workspace instrument and precision must match the target controller.',
      );
    }

    final candles = controller.candles;
    final anchorTime = firstVisibleTime;
    final first = anchorTime == null
        ? 0.0
        : _indexForTime(candles, anchorTime, 'viewport') + firstVisibleFraction;
    final selectionTime = selectedTime;
    final selection = selectionTime == null
        ? null
        : _indexForTime(candles, selectionTime, 'selection');
    final maximumFirst = math.max(0, candles.length - visibleCount);

    if (first > maximumFirst ||
        candles.length - first.floor() < visibleCandleCount) {
      throw ArgumentError(
        'Load more trailing candles to restore the viewport.',
      );
    }

    _validatePriceData(
      candles,
      first,
      percentageReference ?? controller.percentageReference,
    );
    final reference = percentageReference;

    if (reference != null) {
      controller.setPercentageReference(reference);
    }

    controller
      ..setViewport(first, visibleCount)
      ..selectIndex(selection);
    annotations.replaceAll(
      this.annotations,
      selectedId: selectedAnnotationId,
    );
  }

  void _validatePriceData(
    List<WiredChartCandle> candles,
    double first,
    WiredChartDecimal? reference,
  ) {
    if (scale == WiredChartPriceScale.logarithmic) {
      final end = math.min(candles.length, (first + visibleCount).ceil());

      for (var index = first.floor(); index < end; index++) {
        if (candles[index].low <= WiredChartDecimal.zero) {
          throw ArgumentError('Logarithmic visible prices must be positive.');
        }
      }
    }

    if (scale == WiredChartPriceScale.percentage &&
        candles.isNotEmpty &&
        reference == null) {
      throw ArgumentError(
        'Percentage reference price must be established before restore.',
      );
    }

    final hasIndicators =
        overlays.isNotEmpty || panes.any((pane) => pane is WiredIndicatorPane);

    if (hasIndicators) {
      for (final candle in candles) {
        if (!candle.close.toDouble().isFinite) {
          throw ArgumentError(
            'Indicator close prices must fit a finite double.',
          );
        }
      }
    }
  }
}

Map<String, Object?> _paneToJson(WiredChartPane pane) => switch (pane) {
  WiredVolumePane() => {'type': 'volume', 'weight': pane.weight},
  WiredIndicatorPane() => {
    'type': 'indicator',
    'weight': pane.weight,
    'indicator': pane.indicator.toJson(),
  },
};

WiredChartPane _readPane(Object? value) {
  final json = _object(value, 'pane');
  final weight = _number(json['weight'], 'weight');

  if (weight <= 0) {
    throw const FormatException('Pane weight must be positive.');
  }

  return switch (json['type']) {
    'volume' => WiredVolumePane(weight: weight),
    'indicator' => WiredIndicatorPane(
      indicator: WiredChartIndicator.fromJson(
        _object(json['indicator'], 'indicator'),
      ),
      weight: weight,
    ),
    _ => throw const FormatException('Unknown chart pane type.'),
  };
}

WiredChartInstrument _readInstrument(Object? value) {
  final json = _object(value, 'instrument');
  final id = json['id'];
  final priceDecimals = json['priceDecimals'];
  final volumeDecimals = json['volumeDecimals'];

  if (id is! String || id.trim().isEmpty) {
    throw const FormatException('Instrument id must be a nonempty string.');
  }

  if (priceDecimals is! int || priceDecimals < 0 || priceDecimals > 1000) {
    throw const FormatException(
      'priceDecimals must be an integer in [0, 1000].',
    );
  }

  if (volumeDecimals is! int || volumeDecimals < 0 || volumeDecimals > 1000) {
    throw const FormatException(
      'volumeDecimals must be an integer in [0, 1000].',
    );
  }

  return WiredChartInstrument(
    id: id,
    priceDecimals: priceDecimals,
    volumeDecimals: volumeDecimals,
  );
}

({List<WiredChartAnnotation> annotations, String? selectedId}) _readAnnotations(
  Object? value,
) {
  final editor = WiredChartAnnotations();

  // Reuse the annotation document boundary so workspace and standalone drawing
  // restores enforce the same version, coordinate, and selection contracts.
  try {
    editor.restore(value);

    return (annotations: editor.annotations, selectedId: editor.selectedId);
  } finally {
    editor.dispose();
  }
}

int _indexForTime(List<WiredChartCandle> candles, DateTime time, String name) {
  var low = 0;
  var high = candles.length;

  while (low < high) {
    final middle = low + (high - low) ~/ 2;

    if (candles[middle].time.isBefore(time)) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }

  if (low >= candles.length || candles[low].time != time) {
    throw ArgumentError.value(
      time,
      name,
      'Saved timestamp is missing in data.',
    );
  }

  return low;
}

T _enum<T extends Enum>(Object? value, List<T> values, String name) {
  for (final item in values) {
    if (item.name == value) {
      return item;
    }
  }

  throw FormatException('Unknown $name: $value.');
}

WiredChartDecimal? _readPercentageReference(Map<String, Object?> json) {
  if (!json.containsKey('percentageReference')) {
    throw const FormatException('percentageReference is required.');
  }

  final value = json['percentageReference'];

  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw const FormatException(
      'percentageReference must be a decimal string or null.',
    );
  }

  final reference = WiredChartDecimal.parse(value);

  if (reference <= WiredChartDecimal.zero) {
    throw const FormatException('percentageReference must be positive.');
  }

  return reference;
}

Map<String, Object?> _object(Object? value, String name) {
  if (value is! Map<String, Object?>) {
    throw FormatException('$name must be a JSON object.');
  }

  return value;
}

List<Object?> _list(Object? value, String name) {
  if (value is! List<Object?>) {
    throw FormatException('$name must be a list.');
  }

  return value;
}

double _number(Object? value, String name) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$name must be a finite number.');
  }

  return value.toDouble();
}

DateTime? _nullableTime(Map<String, Object?> json, String name) {
  if (!json.containsKey(name)) {
    throw FormatException('$name is required.');
  }

  final value = json[name];

  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw FormatException('$name must be a UTC timestamp or null.');
  }

  final time = DateTime.tryParse(value);

  if (time == null || !time.isUtc || time.toIso8601String() != value) {
    throw FormatException('$name must be a canonical UTC timestamp.');
  }

  return time;
}
