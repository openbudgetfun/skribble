import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:skribble_charts/src/chart_data.dart';

/// Owns timestamp-keyed data, navigation, and selection for one instrument.
///
/// Callers own market transport and must dispose externally created controllers.
/// Historical merges preserve the visible timestamp; appends follow the latest
/// candle only while the viewport was already at the latest candle.
class WiredChartController extends ChangeNotifier {
  /// Creates a chart with sorted, deduplicated [candles] and [visibleCount] bars.
  ///
  /// [percentageReference] must be positive when supplied. When omitted, the
  /// first positive initial close becomes the persistent percentage baseline.
  WiredChartController({
    required this.instrument,
    Iterable<WiredChartCandle> candles = const [],
    double visibleCount = 60,
    WiredChartDecimal? percentageReference,
  }) {
    _validateCount(visibleCount);
    if (percentageReference != null) {
      _validatePercentageReference(percentageReference);
    }
    _visibleCount = visibleCount;
    _candles = UnmodifiableListView(_normalize(candles));
    _percentageReference = percentageReference;
    _initializePercentageReference();
    _firstVisible = _maximumFirst;
  }

  /// Instrument whose timestamps and prices this controller represents.
  final WiredChartInstrument instrument;
  List<WiredChartCandle> _candles = const [];
  double _firstVisible = 0;
  double _visibleCount = 60;
  int? _selectedIndex;
  int _dataRevision = 0;
  bool _disposed = false;
  WiredChartDecimal? _percentageReference;

  /// The exact, positive baseline used for percentage labels.
  ///
  /// An omitted constructor reference initializes from the first candle's close
  /// once that close is positive. Empty or nonpositive initial data leaves it
  /// null. Once established, data merges, corrections, and replacements retain
  /// it. Use [setPercentageReference] to change the baseline deliberately.
  WiredChartDecimal? get percentageReference => _percentageReference;

  /// Immutable, ascending, timestamp-unique candle data.
  List<WiredChartCandle> get candles => _candles;

  /// Fractional index at the viewport's left boundary.
  double get firstVisible => _firstVisible;

  /// Number of candle slots across the viewport, including fractional slots.
  double get visibleCount => _visibleCount;

  /// Selected candle, or null when inspection is inactive.
  int? get selectedIndex => _selectedIndex;

  /// Whether a live append will keep the newest candle visible.
  bool get isFollowingLatest => (_firstVisible - _maximumFirst).abs() < 1e-9;

  /// Increments only when accepted candle data changes.
  int get dataRevision => _dataRevision;

  /// Whether this controller has released its listeners and rejects mutations.
  bool get isDisposed => _disposed;

  double get _maximumFirst => math.max(0, _candles.length - _visibleCount);

  void _checkAlive() {
    if (_disposed) throw StateError('WiredChartController has been disposed');
  }

  static void _validateCount(double count) {
    if (!count.isFinite || count < 1 || count > 1000000) {
      throw ArgumentError.value(
        count,
        'count',
        'Must be finite and between 1 and 1000000',
      );
    }
  }

  static void _validatePercentageReference(WiredChartDecimal reference) {
    if (reference <= WiredChartDecimal.zero) {
      throw ArgumentError.value(
        reference,
        'percentageReference',
        'Must be positive',
      );
    }
  }

  void _initializePercentageReference() {
    if (_percentageReference == null &&
        _candles.isNotEmpty &&
        _candles.first.close > WiredChartDecimal.zero) {
      _percentageReference = _candles.first.close;
    }
  }

  /// Changes the percentage baseline to the positive exact [reference].
  ///
  /// This is a display policy change: it notifies listeners without changing
  /// [dataRevision]. Equal references are a no-op. Zero and negative values throw
  /// [ArgumentError] before mutation, including in release builds.
  void setPercentageReference(WiredChartDecimal reference) {
    _checkAlive();
    _validatePercentageReference(reference);

    if (reference == _percentageReference) {
      return;
    }

    _percentageReference = reference;
    notifyListeners();
  }

  static List<WiredChartCandle> _normalize(Iterable<WiredChartCandle> values) {
    final byTime = <DateTime, WiredChartCandle>{};
    for (final candle in values) {
      final existing = byTime[candle.time];
      if (existing == null || candle.revision >= existing.revision) {
        byTime[candle.time] = candle;
      }
    }
    return byTime.values.toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  static int _lowerBound(List<WiredChartCandle> values, DateTime time) {
    var low = 0;
    var high = values.length;
    while (low < high) {
      final middle = low + (high - low) ~/ 2;
      if (values[middle].time.isBefore(time)) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low;
  }

  /// Merges a history page or live updates atomically.
  ///
  /// The highest revision wins per timestamp. Equal revisions use the latest
  /// supplied value. Replayed identical data does not notify or change revision.
  void mergeCandles(Iterable<WiredChartCandle> updates) {
    _checkAlive();
    final incoming = _normalize(updates);
    if (incoming.isEmpty) return;
    if (incoming.length == 1) {
      _mergeOne(incoming.single);

      return;
    }
    final merged = <WiredChartCandle>[];
    var existingIndex = 0;
    var incomingIndex = 0;
    while (existingIndex < _candles.length && incomingIndex < incoming.length) {
      final existing = _candles[existingIndex];
      final next = incoming[incomingIndex];
      final comparison = existing.time.compareTo(next.time);
      if (comparison < 0) {
        merged.add(existing);
        existingIndex++;
      } else if (comparison > 0) {
        merged.add(next);
        incomingIndex++;
      } else {
        merged.add(next.revision >= existing.revision ? next : existing);
        existingIndex++;
        incomingIndex++;
      }
    }
    merged
      ..addAll(_candles.skip(existingIndex))
      ..addAll(incoming.skip(incomingIndex));
    _applyCandles(merged);
  }

  void _mergeOne(WiredChartCandle update) {
    final index = _lowerBound(_candles, update.time);

    if (index < _candles.length && _candles[index].time == update.time) {
      final existing = _candles[index];

      if (update.revision < existing.revision || update == existing) {
        return;
      }

      final changed = _candles.toList(growable: false)..[index] = update;
      _applyCandles(changed, knownChanged: true);

      return;
    }

    final changed = _candles.toList()..insert(index, update);
    _applyCandles(changed, knownChanged: true);
  }

  /// Replaces the full snapshot; selected and visible timestamps are retained
  /// where possible. Revision counters in the new snapshot are authoritative.
  void replaceCandles(Iterable<WiredChartCandle> candles) {
    _checkAlive();
    _applyCandles(_normalize(candles));
  }

  void _applyCandles(
    List<WiredChartCandle> values, {
    bool knownChanged = false,
  }) {
    if (!knownChanged && listEquals(_candles, values)) return;
    final following = isFollowingLatest;
    final selectedTime = _selectedIndex == null
        ? null
        : _candles[_selectedIndex!].time;
    final anchorIndex = _firstVisible.floor();
    final anchorTime = anchorIndex < _candles.length
        ? _candles[anchorIndex].time
        : null;
    final fraction = _firstVisible - anchorIndex;
    _candles = UnmodifiableListView(values);
    _initializePercentageReference();
    _dataRevision++;
    if (following) {
      _firstVisible = _maximumFirst;
    } else if (anchorTime != null) {
      _firstVisible = (_lowerBound(_candles, anchorTime) + fraction)
          .clamp(0, _maximumFirst)
          .toDouble();
    } else {
      _firstVisible = _firstVisible.clamp(0, _maximumFirst).toDouble();
    }
    if (selectedTime != null) {
      final index = _lowerBound(_candles, selectedTime);
      _selectedIndex =
          index < _candles.length && _candles[index].time == selectedTime
          ? index
          : null;
    }
    notifyListeners();
  }

  /// Sets viewport boundaries, clamping [first] to available history.
  void setViewport(double first, double count) {
    _checkAlive();
    _validateCount(count);
    if (!first.isFinite) {
      throw ArgumentError.value(first, 'first', 'Must be finite');
    }
    final clamped = first
        .clamp(0, math.max(0, _candles.length - count))
        .toDouble();
    if (clamped == _firstVisible && count == _visibleCount) return;
    _firstVisible = clamped;
    _visibleCount = count;
    notifyListeners();
  }

  /// Moves [deltaBars] toward newer data; negative values move into history.
  void pan(double deltaBars) =>
      setViewport(_firstVisible + deltaBars, _visibleCount);

  /// Zooms around [anchorFraction]. Factors above one zoom in.
  void zoom(double factor, {double anchorFraction = 0.5}) {
    _checkAlive();
    if (!factor.isFinite || factor <= 0) {
      throw ArgumentError.value(
        factor,
        'factor',
        'Must be finite and positive',
      );
    }
    if (!anchorFraction.isFinite || anchorFraction < 0 || anchorFraction > 1) {
      throw ArgumentError.value(
        anchorFraction,
        'anchorFraction',
        'Must be between zero and one',
      );
    }
    final count = (_visibleCount / factor).clamp(1, 1000000).toDouble();
    final anchor = _firstVisible + _visibleCount * anchorFraction;
    setViewport(anchor - count * anchorFraction, count);
  }

  /// Returns to following live appends at the current zoom.
  void scrollToLatest() => setViewport(_maximumFirst, _visibleCount);

  /// Selects an existing candle or clears inspection with null.
  void selectIndex(int? index) {
    _checkAlive();
    if (index != null && (index < 0 || index >= _candles.length)) {
      throw RangeError.index(index, _candles, 'index');
    }
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Selects an exact timestamp; missing timestamps clear selection.
  void selectTime(DateTime time) {
    _checkAlive();
    final utc = time.toUtc();
    final index = _lowerBound(_candles, utc);
    selectIndex(
      index < _candles.length && _candles[index].time == utc ? index : null,
    );
  }

  @override
  void dispose() {
    _checkAlive();
    _disposed = true;
    super.dispose();
  }
}
