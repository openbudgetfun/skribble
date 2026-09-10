import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_data.dart';

void main() {
  group('WiredChartDecimal', () {
    test('parses and normalizes exact decimal and scientific inputs', () {
      for (final (input, output) in [
        ('001.2300', '1.23'),
        ('-0.000', '0'),
        ('.125', '0.125'),
        ('1.', '1'),
        ('+1.25e3', '1250'),
        ('-2E-3', '-0.002'),
        ('99999999999999999999.000000001', '99999999999999999999.000000001'),
      ]) {
        expect(WiredChartDecimal.parse(input).toString(), output);
      }
    });

    test('rejects malformed, nonfinite, and unbounded inputs', () {
      for (final input in [
        '',
        '.',
        '+',
        'e2',
        '1.2.3',
        'NaN',
        'Infinity',
        ' 1',
        '1 ',
        '1e1001',
        '1e-1001',
        '1e999999999999999999999',
        '${'1' * 2001}.0',
      ]) {
        expect(
          () => WiredChartDecimal.parse(input),
          throwsFormatException,
          reason: input,
        );
      }
      expect(() => WiredChartDecimal(BigInt.one, -1), throwsRangeError);
      expect(() => WiredChartDecimal(BigInt.one, 1001), throwsRangeError);
    });

    test('equality and hashes ignore trailing zero precision', () {
      final a = WiredChartDecimal.parse('1.0');
      final b = WiredChartDecimal.fromInt(1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect({a, b}, hasLength(1));
    });

    test('canonical decimal strings roundtrip at supported boundaries', () {
      for (final input in [
        '1e1000',
        '-1e1000',
        '1e-1000',
        '-1e-1000',
        '${'9' * 1000}e1000',
      ]) {
        final value = WiredChartDecimal.parse(input);
        expect(WiredChartDecimal.parse(value.toString()), value);
      }
      expect(
        () => WiredChartDecimal(BigInt.from(10).pow(2000), 0),
        throwsArgumentError,
      );
    });

    test('arithmetic preserves precision beyond double range', () {
      final origin = WiredChartDecimal.parse(
        '100000000000000000000000000000000.000000001',
      );
      final tick = WiredChartDecimal.parse('0.000000001');
      expect(origin + tick - origin, tick);
      expect(origin - origin, WiredChartDecimal.zero);
      expect(-tick, WiredChartDecimal.parse('-0.000000001'));
      expect((-tick).abs(), tick);
      expect(
        tick * WiredChartDecimal.fromInt(3),
        WiredChartDecimal.parse('0.000000003'),
      );
      expect(origin > tick, isTrue);
      expect(tick < origin, isTrue);
      expect(tick <= tick, isTrue);
      expect(origin >= origin, isTrue);
    });

    test('fixed formatting rounds halves away from zero without doubles', () {
      for (final (input, digits, output) in [
        ('1.235', 2, '1.24'),
        ('-1.235', 2, '-1.24'),
        ('-1.234', 2, '-1.23'),
        ('9.999', 2, '10.00'),
        ('-0.004', 2, '0.00'),
        ('0', 3, '0.000'),
        ('9007199254740993.125', 2, '9007199254740993.13'),
        ('1.5', 0, '2'),
        ('-1.5', 0, '-2'),
      ]) {
        expect(WiredChartDecimal.parse(input).toStringAsFixed(digits), output);
      }
      expect(
        () => WiredChartDecimal.zero.toStringAsFixed(-1),
        throwsRangeError,
      );
    });

    test('ratios handle operands beyond double magnitude', () {
      expect(
        WiredChartDecimal.parse('1e500')
            .ratio(WiredChartDecimal.parse('2e500')),
        0.5,
      );
      expect(
        WiredChartDecimal.parse('1e-500')
            .ratio(WiredChartDecimal.parse('2e-500')),
        0.5,
      );
      expect(
        WiredChartDecimal.parse('-1e500')
            .ratio(WiredChartDecimal.parse('2e500')),
        -0.5,
      );
      expect(
        WiredChartDecimal.parse('1e-15').ratio(WiredChartDecimal.fromInt(1)),
        1e-15,
      );
      expect(WiredChartDecimal.zero.ratio(WiredChartDecimal.fromInt(1)), 0);
      expect(
        () => WiredChartDecimal.fromInt(1).ratio(WiredChartDecimal.zero),
        throwsArgumentError,
      );
    });

    test('exact comparisons hold around machine integer precision', () {
      final a = WiredChartDecimal.parse('9007199254740992.000000001');
      final b = WiredChartDecimal.parse('9007199254740992.000000002');
      expect(a.compareTo(b), lessThan(0));
      expect(a.toDouble(), b.toDouble());
      expect((b - a).toString(), '0.000000001');
    });
  });

  group('WiredChartCandle', () {
    test('normalizes UTC, defaults volume, and has value equality', () {
      final time = DateTime(2026);
      final a = _candle(time: time);
      final b = _candle(time: time.toUtc());
      expect(a.time.isUtc, isTrue);
      expect(a.time, time.toUtc());
      expect(a.volume, WiredChartDecimal.zero);
      expect(a.isBullish, isTrue);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('validates OHLC ordering, volume, revision in production paths', () {
      expect(() => _candle(open: 5), throwsArgumentError);
      expect(() => _candle(close: 5), throwsArgumentError);
      expect(() => _candle(low: 5), throwsArgumentError);
      expect(() => _candle(high: 0), throwsArgumentError);
      expect(() => _candle(volume: -1), throwsArgumentError);
      expect(() => _candle(revision: -1), throwsRangeError);
      expect(_candle(open: 3, close: 1).isBullish, isFalse);
      expect(_candle(open: 2, high: 2, low: 2).isBullish, isTrue);
    });
  });

  test('instrument validates identity and display precision', () {
    expect(WiredChartInstrument(id: 'SOL').priceDecimals, 2);
    expect(() => WiredChartInstrument(id: ' '), throwsArgumentError);
    expect(
      () => WiredChartInstrument(id: 'SOL', priceDecimals: -1),
      throwsRangeError,
    );
    expect(
      () => WiredChartInstrument(id: 'SOL', volumeDecimals: 1001),
      throwsRangeError,
    );
  });
}

WiredChartCandle _candle({
  DateTime? time,
  int open = 1,
  int high = 3,
  int low = 1,
  int close = 2,
  int volume = 0,
  int revision = 0,
}) => WiredChartCandle(
  time: time ?? DateTime.utc(2026),
  open: WiredChartDecimal.fromInt(open),
  high: WiredChartDecimal.fromInt(high),
  low: WiredChartDecimal.fromInt(low),
  close: WiredChartDecimal.fromInt(close),
  volume: WiredChartDecimal.fromInt(volume),
  revision: revision,
);
