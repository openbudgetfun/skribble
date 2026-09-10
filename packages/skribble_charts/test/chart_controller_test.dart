import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';

void main() {
  late WiredChartController controller;
  setUp(() {
    controller = WiredChartController(
      instrument: WiredChartInstrument(id: 'SOL-USDC'),
      candles: List.generate(100, _candle),
      visibleCount: 20,
    );
  });
  tearDown(() => controller.dispose());

  test('starts at latest with immutable sorted unique data', () {
    expect(controller.firstVisible, 80);
    expect(controller.isFollowingLatest, isTrue);
    expect(controller.visibleCount, 20);
    expect(() => controller.candles.add(_candle(101)), throwsUnsupportedError);
    final reversed = WiredChartController(
      instrument: controller.instrument,
      candles: [_candle(3), _candle(1), _candle(3, revision: 2), _candle(2)],
    );
    expect(
      reversed.candles.map((c) => c.time),
      [1, 2, 3].map((i) => _candle(i).time),
    );
    expect(reversed.candles.last.revision, 2);
    reversed.dispose();
  });

  test('prepending history preserves fractional timestamp and selection', () {
    controller
      ..setViewport(10.25, 20)
      ..selectIndex(13);
    final selectedTime = controller.candles[13].time;
    final anchorTime = controller.candles[10].time;
    controller.mergeCandles(List.generate(30, (i) => _candle(i - 30)));
    expect(controller.firstVisible, 40.25);
    expect(
      controller.candles[controller.firstVisible.floor()].time,
      anchorTime,
    );
    expect(controller.selectedIndex, 43);
    expect(controller.candles[controller.selectedIndex!].time, selectedTime);
    expect(controller.isFollowingLatest, isFalse);
  });

  test('live append follows only when already at latest', () {
    controller.mergeCandles([_candle(100)]);
    expect(controller.firstVisible, 81);
    controller
      ..pan(-20)
      ..mergeCandles([_candle(101)]);
    expect(controller.firstVisible, 61);
    controller.scrollToLatest();
    expect(controller.firstVisible, 82);
    expect(controller.isFollowingLatest, isTrue);
  });

  test('revisions reject stale updates and duplicates notify once', () {
    var notifications = 0;
    controller
      ..addListener(() => notifications++)
      ..mergeCandles([_candle(99, revision: 3, price: 5)]);
    expect(controller.dataRevision, 1);
    expect(notifications, 1);
    controller
      ..mergeCandles([_candle(99, revision: 2, price: 8)])
      ..mergeCandles([_candle(99, revision: 3, price: 5)])
      ..mergeCandles([]);
    expect(controller.dataRevision, 1);
    expect(notifications, 1);
    controller.mergeCandles([_candle(99, revision: 3, price: 6)]);
    expect(controller.candles.last.close, WiredChartDecimal.fromInt(6));
    expect(controller.dataRevision, 2);
  });

  test(
    'batch duplicate resolution chooses highest revision then last equal',
    () {
      controller.mergeCandles([
        _candle(99, revision: 2, price: 2),
        _candle(99, revision: 5, price: 5),
        _candle(99, revision: 3, price: 3),
        _candle(99, revision: 5, price: 7),
      ]);
      expect(controller.candles.last.close, WiredChartDecimal.fromInt(7));
      expect(controller.candles, hasLength(100));
    },
  );

  test('history correction never disturbs viewport and keeps selection', () {
    controller
      ..setViewport(12.5, 30)
      ..selectIndex(2)
      ..mergeCandles([_candle(2, revision: 1, price: 12)]);
    expect(controller.firstVisible, 12.5);
    expect(controller.selectedIndex, 2);
    expect(controller.dataRevision, 1);
  });

  test('zoom keeps anchor fixed until history bounds require clamping', () {
    controller
      ..setViewport(40, 20)
      ..zoom(2, anchorFraction: 0.25);
    expect(controller.visibleCount, 10);
    expect(controller.firstVisible, 42.5);
    expect(controller.firstVisible + controller.visibleCount * 0.25, 45);
    controller.zoom(0.5, anchorFraction: 0.25);
    expect(controller.firstVisible, 40);
    expect(controller.visibleCount, 20);
    controller.pan(-1000);
    expect(controller.firstVisible, 0);
    controller.pan(1000);
    expect(controller.firstVisible, 80);
  });

  test('selection and viewport changes do not change data revision', () {
    controller.selectTime(_candle(50).time);
    expect(controller.selectedIndex, 50);
    controller.selectTime(_candle(999).time);
    expect(controller.selectedIndex, isNull);
    controller
      ..pan(-1)
      ..zoom(2);
    expect(controller.dataRevision, 0);
  });

  test('replacement clears missing selection and handles empty data', () {
    controller
      ..selectIndex(50)
      ..setViewport(25, 20)
      ..replaceCandles([_candle(1), _candle(2)]);
    expect(controller.selectedIndex, isNull);
    expect(controller.firstVisible, 0);
    controller
      ..selectIndex(1)
      ..replaceCandles([]);
    expect(controller.candles, isEmpty);
    expect(controller.selectedIndex, isNull);
    expect(controller.firstVisible, 0);
    controller.mergeCandles([_candle(10)]);
    expect(controller.candles, hasLength(1));
  });

  test('iterable failure leaves a merge atomic', () {
    Iterable<WiredChartCandle> broken() sync* {
      yield _candle(101);
      throw StateError('Network decode failure');
    }

    expect(() => controller.mergeCandles(broken()), throwsStateError);
    expect(controller.candles, hasLength(100));
    expect(controller.dataRevision, 0);
  });

  test('invalid navigation is rejected before changing state', () {
    for (final count in [0.0, -1.0, double.nan, double.infinity, 1000001.0]) {
      expect(() => controller.setViewport(0, count), throwsArgumentError);
    }
    expect(() => controller.setViewport(double.nan, 10), throwsArgumentError);
    expect(() => controller.zoom(0), throwsArgumentError);
    expect(() => controller.zoom(double.infinity), throwsArgumentError);
    expect(() => controller.zoom(2, anchorFraction: -0.1), throwsArgumentError);
    expect(() => controller.selectIndex(-1), throwsRangeError);
    expect(() => controller.selectIndex(100), throwsRangeError);
    expect(controller.firstVisible, 80);
  });

  test('mutations after disposal fail consistently', () {
    final disposed = WiredChartController(instrument: controller.instrument)
      ..dispose();
    expect(() => disposed.mergeCandles([]), throwsStateError);
    expect(() => disposed.replaceCandles([]), throwsStateError);
    expect(() => disposed.pan(1), throwsStateError);
    expect(() => disposed.zoom(1), throwsStateError);
    expect(() => disposed.selectIndex(null), throwsStateError);
    expect(disposed.scrollToLatest, throwsStateError);
    expect(disposed.dispose, throwsStateError);
  });

  test('percentage baseline stays exact across prepend, correction, replacement and clearing', () {
    final reference = controller.percentageReference;
    controller
      ..mergeCandles([_candle(-1, price: 20)])
      ..mergeCandles([_candle(0, revision: 2, price: 30)])
      ..replaceCandles([_candle(2, price: 40)])
      ..replaceCandles([])
      ..mergeCandles([_candle(3, price: 50)]);

    expect(reference, WiredChartDecimal.fromInt(1));
    expect(controller.percentageReference, reference);
  });

  test('percentage baseline initializes on first positive initial close', () {
    final empty = WiredChartController(instrument: controller.instrument);
    addTearDown(empty.dispose);
    expect(empty.percentageReference, isNull);
    empty.mergeCandles([_candle(0, price: -1)]);
    expect(empty.percentageReference, isNull);
    empty.replaceCandles([_candle(1, price: 10)]);
    expect(empty.percentageReference, WiredChartDecimal.fromInt(10));
    empty.replaceCandles([_candle(2, price: 20)]);
    expect(empty.percentageReference, WiredChartDecimal.fromInt(10));
  });

  test(
    'explicit percentage reference notifies without changing data revision',
    () {
      final exact = WiredChartDecimal.parse('0.000000000000000000123456789');
      final explicit = WiredChartController(
        instrument: controller.instrument,
        candles: [_candle(0, price: 10)],
        percentageReference: exact,
      );
      addTearDown(explicit.dispose);
      var notifications = 0;
      explicit.addListener(() => notifications++);
      expect(explicit.percentageReference, exact);
      explicit.setPercentageReference(exact);
      expect(notifications, 0);
      explicit.setPercentageReference(WiredChartDecimal.fromInt(12));
      expect(notifications, 1);
      expect(explicit.dataRevision, 0);
      expect(explicit.percentageReference, WiredChartDecimal.fromInt(12));
    },
  );

  test(
    'invalid percentage references fail before construction or mutation',
    () {
      final original = controller.percentageReference;
      var notifications = 0;
      controller.addListener(() => notifications++);

      for (final invalid in [
        WiredChartDecimal.zero,
        WiredChartDecimal.fromInt(-1),
      ]) {
        expect(
          () => WiredChartController(
            instrument: controller.instrument,
            percentageReference: invalid,
          ),
          throwsArgumentError,
        );
        expect(
          () => controller.setPercentageReference(invalid),
          throwsArgumentError,
        );
        expect(controller.percentageReference, original);
      }

      expect(notifications, 0);
      final disposed = WiredChartController(instrument: controller.instrument)
        ..dispose();
      expect(
        () => disposed.setPercentageReference(WiredChartDecimal.fromInt(1)),
        throwsStateError,
      );
    },
  );

  test('large history merges remain sorted without overwriting newer data', () {
    controller.mergeCandles(List.generate(20000, (i) => _candle(i - 10000)));
    expect(controller.candles, hasLength(20000));
    expect(controller.candles.first.time, _candle(-10000).time);
    expect(controller.candles.last.time, _candle(9999).time);
  });
}

WiredChartCandle _candle(int index, {int revision = 0, int price = 1}) =>
    WiredChartCandle(
      time: DateTime.utc(2026).add(Duration(minutes: index)),
      open: WiredChartDecimal.fromInt(price),
      high: WiredChartDecimal.fromInt(price),
      low: WiredChartDecimal.fromInt(price),
      close: WiredChartDecimal.fromInt(price),
      revision: revision,
    );
