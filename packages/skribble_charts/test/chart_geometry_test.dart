import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';

void main() {
  test('viewport maps candle centers and inverses fractional indices', () {
    final viewport = WiredChartViewport(
      firstVisible: 10.25,
      visibleCount: 20,
      width: 400,
    );
    expect(viewport.xForIndex(10.25), 10);
    for (final index in [-100.0, 0.0, 10.25, 15.75, 100.0]) {
      expect(
        viewport.indexForX(viewport.xForIndex(index)),
        closeTo(index, 1e-12),
      );
    }
    expect(
      () => WiredChartViewport(firstVisible: 0, visibleCount: 0, width: 100),
      throwsArgumentError,
    );
    expect(
      () => WiredChartViewport(
        firstVisible: double.nan,
        visibleCount: 1,
        width: 100,
      ),
      throwsArgumentError,
    );
    expect(
      () => WiredChartViewport(firstVisible: 0, visibleCount: 1, width: -1),
      throwsArgumentError,
    );
  });

  test('linear mapping preserves endpoints and relative precision', () {
    final minimum = WiredChartDecimal.parse('100000000000000000000.000000001');
    final maximum = WiredChartDecimal.parse('100000000000000000000.000000003');
    final middle = WiredChartDecimal.parse('100000000000000000000.000000002');
    final transform = WiredChartPriceTransform(
      min: minimum,
      max: maximum,
      top: 10,
      bottom: 210,
    );
    expect(transform.yForPrice(minimum), 210);
    expect(transform.yForPrice(maximum), 10);
    expect(transform.yForPrice(middle), 110);
    expect(transform.priceForY(110), middle);
    expect(transform.priceForY(210), minimum);
    expect(transform.priceForY(10), maximum);
  });

  test(
    'linear coordinates tolerate both overflowing and underflowing magnitudes',
    () {
      for (final exponent in [-500, 500]) {
        final min = WiredChartDecimal.parse('1e$exponent');
        final max = WiredChartDecimal.parse('3e$exponent');
        final middle = WiredChartDecimal.parse('2e$exponent');
        final transform = WiredChartPriceTransform(
          min: min,
          max: max,
          top: 0,
          bottom: 100,
        );
        expect(transform.yForPrice(middle), 50);
        expect(transform.priceForY(50), middle);
      }
    },
  );

  test('flat prices render at center and inverse remains constant', () {
    final price = WiredChartDecimal.parse('12.34');
    final transform = WiredChartPriceTransform(
      min: price,
      max: price,
      top: 0,
      bottom: 100,
    );
    expect(transform.yForPrice(price), 50);
    expect(transform.priceForY(2), price);
  });

  test('linear inverse remains monotonic through zero', () {
    final transform = WiredChartPriceTransform(
      min: WiredChartDecimal.fromInt(-100),
      max: WiredChartDecimal.fromInt(100),
      top: 0,
      bottom: 200,
    );
    for (var price = -200; price <= 200; price++) {
      final value = WiredChartDecimal.fromInt(price);
      final y = transform.yForPrice(value);
      expect(y, closeTo(100 - price, 1e-10));
      expect(
        (transform.priceForY(y) - value).abs().toDouble(),
        lessThan(1e-10),
      );
    }
  });

  test('logarithmic coordinates space ratios evenly', () {
    final transform = WiredChartPriceTransform(
      min: WiredChartDecimal.fromInt(1),
      max: WiredChartDecimal.fromInt(100),
      top: 0,
      bottom: 100,
      scale: WiredChartPriceScale.logarithmic,
    );
    expect(
      transform.yForPrice(WiredChartDecimal.fromInt(10)),
      closeTo(50, 1e-10),
    );
    expect(transform.priceForY(50).toDouble(), closeTo(10, 1e-10));
    expect(transform.priceForY(100), WiredChartDecimal.fromInt(1));
    expect(transform.priceForY(0), WiredChartDecimal.fromInt(100));
    expect(
      () => transform.yForPrice(WiredChartDecimal.zero),
      throwsArgumentError,
    );
  });

  test('logarithmic mapping handles values outside double range', () {
    final transform = WiredChartPriceTransform(
      min: WiredChartDecimal.parse('1e500'),
      max: WiredChartDecimal.parse('1e502'),
      top: 0,
      bottom: 100,
      scale: WiredChartPriceScale.logarithmic,
    );
    expect(
      transform.yForPrice(WiredChartDecimal.parse('1e501')),
      closeTo(50, 1e-9),
    );
    expect(
      transform.priceForY(50).ratio(WiredChartDecimal.parse('1e501')),
      closeTo(1, 1e-10),
    );
  });

  test('percentage labels retain exact subtraction around large baselines', () {
    final reference = WiredChartDecimal.parse('100000000000000000000');
    final transform = WiredChartPriceTransform(
      min: reference,
      max: reference * WiredChartDecimal.fromInt(2),
      top: 0,
      bottom: 100,
      reference: reference,
      scale: WiredChartPriceScale.percentage,
    );
    expect(transform.valueForPrice(reference), 0);
    expect(
      transform.valueForPrice(reference * WiredChartDecimal.parse('1.5')),
      50,
    );
    expect(transform.yForPrice(reference * WiredChartDecimal.parse('1.5')), 50);
  });

  test('invalid scale bounds and coordinates fail before drawing', () {
    final zero = WiredChartDecimal.zero;
    final one = WiredChartDecimal.fromInt(1);
    expect(
      () => WiredChartPriceTransform(min: one, max: zero, top: 0, bottom: 100),
      throwsArgumentError,
    );
    expect(
      () => WiredChartPriceTransform(min: zero, max: one, top: 0, bottom: 0),
      throwsArgumentError,
    );
    expect(
      () => WiredChartPriceTransform(
        min: zero,
        max: one,
        top: double.nan,
        bottom: 100,
      ),
      throwsArgumentError,
    );
    expect(
      () => WiredChartPriceTransform(
        min: zero,
        max: one,
        top: 0,
        bottom: 100,
        scale: WiredChartPriceScale.logarithmic,
      ),
      throwsArgumentError,
    );
    expect(
      () => WiredChartPriceTransform(
        min: zero,
        max: one,
        top: 0,
        bottom: 100,
        scale: WiredChartPriceScale.percentage,
      ),
      throwsArgumentError,
    );
    expect(
      () => WiredChartPriceTransform(
        min: zero,
        max: one,
        top: 0,
        bottom: 100,
        reference: zero,
        scale: WiredChartPriceScale.percentage,
      ),
      throwsArgumentError,
    );
    final transform = WiredChartPriceTransform(
      min: zero,
      max: one,
      top: 0,
      bottom: 100,
    );
    expect(() => transform.priceForY(double.infinity), throwsArgumentError);
  });
}
