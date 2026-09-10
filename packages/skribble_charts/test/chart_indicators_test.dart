import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_indicators.dart';

void main() {
  group('WiredSma', () {
    test('uses a rolling window and leaves its warmup empty', () {
      final result = const WiredSma(period: 3).calculate(
        _candles(['1', '2', '3', '4', '5']),
      );

      expect(result.lines, hasLength(1));
      expect(result.lines.single.label, 'SMA 3');
      expect(result.lines.single.values, [null, null, 2, 3, 4]);
      expect(result.histogram, isNull);
    });

    test('returns aligned nulls when there is not enough history', () {
      final values = const WiredSma(
        period: 4,
      ).calculate(_candles(['8', '9', '10'])).lines.single.values;

      expect(values, [null, null, null]);
    });

    test('a corrected candle affects only windows that contain it', () {
      final original = const WiredSma(
        period: 3,
      ).calculate(_candles(['1', '2', '3', '4', '5', '6', '7']));
      final corrected = const WiredSma(
        period: 3,
      ).calculate(_candles(['1', '2', '3', '40', '5', '6', '7']));

      expect(original.lines.single.values, [null, null, 2, 3, 4, 5, 6]);
      expect(
        corrected.lines.single.values,
        [null, null, 2, 15, 16, 17, 6],
      );
    });

    test('period one follows every close', () {
      final values = const WiredSma(
        period: 1,
      ).calculate(_candles(['2.5', '-3', '9.25'])).lines.single.values;

      expect(values, [2.5, -3, 9.25]);
    });
  });

  group('WiredEma', () {
    test(
      'uses an SMA seed and standard two-over-period-plus-one smoothing',
      () {
        final values =
            const WiredEma(
                  period: 3,
                )
                .calculate(_candles(['1', '2', '3', '4', '5', '6']))
                .lines
                .single
                .values;

        expect(values, [null, null, 2, 3, 4, 5]);
      },
    );

    test('returns aligned nulls when there is not enough history', () {
      final values = const WiredEma(
        period: 3,
      ).calculate(_candles(['1', '2'])).lines.single.values;

      expect(values, [null, null]);
    });

    test('period one follows every close without warmup', () {
      final values = const WiredEma(
        period: 1,
      ).calculate(_candles(['4', '2', '7'])).lines.single.values;

      expect(values, [4, 2, 7]);
    });
  });

  group('WiredRsi', () {
    test('matches the published Wilder smoothing example', () {
      final closes = _candles([
        '44.34',
        '44.09',
        '44.15',
        '43.61',
        '44.33',
        '44.83',
        '45.10',
        '45.42',
        '45.84',
        '46.08',
        '45.89',
        '46.03',
        '45.61',
        '46.28',
        '46.28',
        '46.00',
        '46.03',
        '46.41',
        '46.22',
        '45.64',
        '46.21',
      ]);
      final values = const WiredRsi().calculate(closes).lines.single.values;

      _expectValuesClose(values, [
        ...List<double?>.filled(14, null),
        70.4641350211,
        66.2496185536,
        66.4809418347,
        69.3468531629,
        66.2947126589,
        57.9150206701,
        62.8807183099,
      ]);
    });

    test('uses neutral 50 for a flat market', () {
      final values = const WiredRsi(
        period: 3,
      ).calculate(_candles(['7', '7', '7', '7', '7'])).lines.single.values;

      expect(values, [null, null, null, 50, 50]);
    });

    test('uses the bounded extremes for one-way markets', () {
      final rising = const WiredRsi(
        period: 2,
      ).calculate(_candles(['1', '2', '3', '4'])).lines.single.values;
      final falling = const WiredRsi(
        period: 2,
      ).calculate(_candles(['4', '3', '2', '1'])).lines.single.values;

      expect(rising, [null, null, 100, 100]);
      expect(falling, [null, null, 0, 0]);
    });

    test('needs one more candle than its change period', () {
      final values = const WiredRsi(
        period: 3,
      ).calculate(_candles(['1', '2', '3'])).lines.single.values;

      expect(values, [null, null, null]);
    });
  });

  group('WiredMacd', () {
    test('aligns SMA-seeded MACD, signal, and histogram values', () {
      final result = const WiredMacd(
        fastPeriod: 2,
        slowPeriod: 3,
        signalPeriod: 2,
      ).calculate(_candles(['1', '2', '3', '2', '5', '4', '6', '8']));

      expect(result.lines.map((line) => line.label), ['MACD', 'Signal']);
      _expectValuesClose(result.lines[0].values, [
        null,
        null,
        0.5,
        1 / 6,
        5 / 9,
        29 / 108,
        301 / 648,
        2627 / 3888,
      ]);
      _expectValuesClose(result.lines[1].values, [
        null,
        null,
        null,
        1 / 3,
        13 / 27,
        55 / 162,
        137 / 324,
        3449 / 5832,
      ]);
      _expectValuesClose(result.histogram!, [
        null,
        null,
        null,
        -1 / 6,
        2 / 27,
        -23 / 324,
        1 / 24,
        983 / 11664,
      ]);
    });

    test('returns aligned nulls before both averages and signal are ready', () {
      final result = const WiredMacd(
        fastPeriod: 3,
        slowPeriod: 5,
        signalPeriod: 2,
      ).calculate(_candles(['1', '2', '3', '4']));

      expect(result.lines[0].values, [null, null, null, null]);
      expect(result.lines[1].values, [null, null, null, null]);
      expect(result.histogram, [null, null, null, null]);
    });

    test('supports equal average periods as a zero oscillator', () {
      final result = const WiredMacd(
        fastPeriod: 2,
        slowPeriod: 2,
        signalPeriod: 2,
      ).calculate(_candles(['1', '4', '2', '8']));

      expect(result.lines[0].values, [null, 0, 0, 0]);
      expect(result.lines[1].values, [null, null, 0, 0]);
      expect(result.histogram, [null, null, 0, 0]);
    });
  });

  group('WiredBollingerBands', () {
    test('uses population standard deviation and aligned warmup', () {
      final result = const WiredBollingerBands(
        period: 3,
      ).calculate(_candles(['1', '2', '3', '4']));
      final distance = 2 * math.sqrt(2 / 3);

      _expectValuesClose(result.lines[0].values, [
        null,
        null,
        2 + distance,
        3 + distance,
      ]);
      expect(result.lines[1].values, [null, null, 2, 3]);
      _expectValuesClose(result.lines[2].values, [
        null,
        null,
        2 - distance,
        3 - distance,
      ]);
    });

    test('keeps variance stable when prices have a large shared offset', () {
      final result =
          const WiredBollingerBands(
            period: 3,
            deviations: 1,
          ).calculate(
            _candles([
              '1000000000001',
              '1000000000002',
              '1000000000003',
              '1000000000004',
            ]),
          );
      final deviation = math.sqrt(2 / 3);

      expect(result.lines[1].values[2], 1000000000002);
      expect(result.lines[1].values[3], 1000000000003);
      expect(
        result.lines[0].values[3],
        closeTo(1000000000003 + deviation, 0.0002),
      );
      expect(
        result.lines[2].values[3],
        closeTo(1000000000003 - deviation, 0.0002),
      );
    });

    test('zero deviations collapses all three lines to the mean', () {
      final result = const WiredBollingerBands(
        period: 2,
        deviations: 0,
      ).calculate(_candles(['1', '3', '5']));

      for (final line in result.lines) {
        expect(line.values, [null, 2, 4]);
      }
    });

    test(
      'flat input does not produce NaN from a negative rounding residue',
      () {
        final values = const WiredBollingerBands(
          period: 2,
        ).calculate(_candles(['0.1', '0.1', '0.1', '0.1']));

        for (final line in values.lines) {
          _expectValuesClose(line.values, [null, 0.1, 0.1, 0.1]);
        }
      },
    );
  });

  group('causality and scale', () {
    final indicators = <WiredChartIndicator>[
      const WiredSma(period: 5),
      const WiredEma(period: 5),
      const WiredRsi(period: 5),
      const WiredMacd(fastPeriod: 3, slowPeriod: 5, signalPeriod: 2),
      const WiredBollingerBands(period: 5),
    ];
    final values = [
      for (var index = 0; index < 60; index++)
        (100 + math.sin(index / 3) * 5 + index * 0.2).toStringAsFixed(8),
    ];

    for (final indicator in indicators) {
      test('${indicator.runtimeType} never reads future candles', () {
        final complete = indicator.calculate(_candles(values));
        final prefix = indicator.calculate(_candles(values.take(37).toList()));

        expect(complete.lines, hasLength(prefix.lines.length));

        for (var index = 0; index < prefix.lines.length; index++) {
          expect(
            complete.lines[index].values.take(37),
            prefix.lines[index].values,
          );
        }

        if (prefix.histogram case final prefixHistogram?) {
          expect(complete.histogram!.take(37), prefixHistogram);
        }
      });

      test('${indicator.runtimeType} recalculates a historical correction', () {
        final correctedValues = [...values]..[30] = '140';
        final original = indicator.calculate(_candles(values));
        final corrected = indicator.calculate(_candles(correctedValues));

        for (var line = 0; line < original.lines.length; line++) {
          expect(
            corrected.lines[line].values.take(30),
            original.lines[line].values.take(30),
          );
        }

        final changed = [
          for (var line = 0; line < original.lines.length; line++)
            for (var index = 30; index < values.length; index++)
              if (original.lines[line].values[index] !=
                  corrected.lines[line].values[index])
                index,
        ];
        expect(changed, isNotEmpty);
      });
    }

    test('all indicators process a long series with aligned output', () {
      final candles = _candles([
        for (var index = 0; index < 20000; index++)
          (100 + math.sin(index / 17) + index / 1000).toStringAsFixed(8),
      ]);

      for (final indicator in indicators) {
        final result = indicator.calculate(candles);

        for (final line in result.lines) {
          expect(line.values, hasLength(candles.length));
          expect(line.values.last, isA<double>());
        }

        expect(result.histogram, anyOf(isNull, hasLength(candles.length)));
      }
    });
  });

  group('shared projection', () {
    test('matches independent calculations and deduplicates configs', () {
      final candles = _candles([
        '100',
        '102',
        '99',
        '104',
        '107',
        '103',
        '110',
        '108',
      ]);
      const indicators = <WiredChartIndicator>[
        WiredSma(period: 3),
        WiredEma(period: 3),
        WiredRsi(period: 3),
        WiredMacd(fastPeriod: 2, slowPeriod: 3, signalPeriod: 2),
      ];

      final results = calculateWiredChartIndicators(candles, [
        ...indicators,
        const WiredSma(period: 3),
      ]);

      expect(results.keys, indicators);
      for (final indicator in indicators) {
        final direct = indicator.calculate(candles);
        final shared = results[indicator]!;

        expect(
          shared.lines.map((line) => line.label),
          direct.lines.map((line) => line.label),
        );
        expect(
          shared.lines.map((line) => line.values),
          direct.lines.map((line) => line.values),
        );
        expect(shared.histogram, direct.histogram);
      }
    });

    test('validates every config before projecting candle values', () {
      final candles = _candles(['1e-999']);

      expect(
        () => calculateWiredChartIndicators(candles, const [
          WiredSma(period: 1),
          WiredRsi(period: 0),
        ]),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'period')
              .having((error) => error.invalidValue, 'invalidValue', 0),
        ),
      );
    });
  });

  group('validation', () {
    test('rejects non-positive periods during calculation', () {
      final candles = _candles(['1', '2']);
      final invalid = <WiredChartIndicator>[
        const WiredSma(period: 0),
        const WiredEma(period: -1),
        const WiredRsi(period: 0),
        const WiredMacd(fastPeriod: 0),
        const WiredMacd(slowPeriod: -2),
        const WiredMacd(signalPeriod: 0),
        const WiredBollingerBands(period: -1),
      ];

      for (final indicator in invalid) {
        expect(() => indicator.calculate(candles), throwsArgumentError);
      }
    });

    test('rejects negative and non-finite band multipliers', () {
      final candles = _candles(['1']);

      for (final deviations in [
        -1.0,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => WiredBollingerBands(
            deviations: deviations,
          ).calculate(candles),
          throwsArgumentError,
        );
      }
    });

    test('reports a close that cannot be represented as a finite double', () {
      final candles = _candles(['1e999']);

      expect(
        () => const WiredSma(period: 1).calculate(candles),
        throwsA(
          isA<ArgumentError>()
              .having(
                (error) => error.name,
                'name',
                'candles[0].close',
              )
              .having(
                (error) => error.message,
                'message',
                contains('finite double'),
              ),
        ),
      );
    });
  });

  group('serialization', () {
    test('round-trips every indicator and custom parameter', () {
      final indicators = <WiredChartIndicator>[
        const WiredSma(period: 7),
        const WiredEma(period: 8),
        const WiredRsi(period: 9),
        const WiredMacd(
          fastPeriod: 5,
          slowPeriod: 11,
          signalPeriod: 4,
        ),
        const WiredBollingerBands(period: 13, deviations: 2.5),
      ];

      for (final indicator in indicators) {
        final decoded = WiredChartIndicator.fromJson(indicator.toJson());

        expect(decoded.runtimeType, indicator.runtimeType);
        expect(decoded, indicator);
        expect(decoded.hashCode, indicator.hashCode);
        expect(decoded.toJson(), indicator.toJson());
      }
    });

    test('different indicator parameters are unequal', () {
      expect(const WiredSma(period: 5), isNot(const WiredSma(period: 6)));
      expect(const WiredEma(period: 5), isNot(const WiredEma(period: 6)));
      expect(const WiredRsi(period: 5), isNot(const WiredRsi(period: 6)));
      expect(
        const WiredMacd(fastPeriod: 5),
        isNot(const WiredMacd(fastPeriod: 6)),
      );
      expect(
        const WiredBollingerBands(),
        isNot(const WiredBollingerBands(deviations: 3)),
      );
    });

    test('uses stable type tags and complete default values', () {
      expect(const WiredSma().toJson(), {'type': 'sma', 'period': 20});
      expect(const WiredEma().toJson(), {'type': 'ema', 'period': 20});
      expect(const WiredRsi().toJson(), {'type': 'rsi', 'period': 14});
      expect(const WiredMacd().toJson(), {
        'type': 'macd',
        'fastPeriod': 12,
        'slowPeriod': 26,
        'signalPeriod': 9,
      });
      expect(const WiredBollingerBands().toJson(), {
        'type': 'bollingerBands',
        'period': 20,
        'deviations': 2.0,
      });
    });

    test('rejects missing, unknown, and mistyped configurations', () {
      final invalid = <Map<String, Object?>>[
        {},
        {'type': 3},
        {'type': 'unknown'},
        {'type': 'sma'},
        {'type': 'sma', 'period': 0},
        {'type': 'ema', 'period': 2.5},
        {'type': 'rsi', 'period': '14'},
        {
          'type': 'macd',
          'fastPeriod': 12,
          'slowPeriod': 26,
          'signalPeriod': -1,
        },
        {'type': 'bollingerBands', 'period': 20},
        {
          'type': 'bollingerBands',
          'period': 20,
          'deviations': double.nan,
        },
      ];

      for (final json in invalid) {
        expect(
          () => WiredChartIndicator.fromJson(json),
          throwsFormatException,
        );
      }
    });
  });

  group('result values', () {
    test('defensively copy lines, values, and histograms', () {
      final values = <double?>[1, null];
      final sourceLine = WiredIndicatorLine(label: 'Test', values: values);
      final lines = [sourceLine];
      final histogram = <double?>[2, null];
      final result = WiredIndicatorResult(
        lines: lines,
        histogram: histogram,
      );

      values[0] = 9;
      lines.clear();
      histogram[0] = 8;

      expect(sourceLine.values, [1, null]);
      expect(result.lines, [sourceLine]);
      expect(result.histogram, [2, null]);
      expect(() => sourceLine.values.add(3), throwsUnsupportedError);
      expect(result.lines.clear, throwsUnsupportedError);
      expect(() => result.histogram!.add(3), throwsUnsupportedError);
    });

    test('exposes concise default legend labels', () {
      expect(const WiredSma().label, 'SMA 20');
      expect(const WiredEma().label, 'EMA 20');
      expect(const WiredRsi().label, 'RSI 14');
      expect(const WiredMacd().label, 'MACD 12, 26, 9');
      expect(
        const WiredBollingerBands().label,
        'Bollinger Bands 20, 2.0',
      );
    });
  });
}

List<WiredChartCandle> _candles(List<String> closes) => [
  for (var index = 0; index < closes.length; index++)
    _candle(closes[index], index),
];

WiredChartCandle _candle(String close, int index) {
  final value = WiredChartDecimal.parse(close);

  return WiredChartCandle(
    time: DateTime.utc(2026).add(Duration(minutes: index)),
    open: value,
    high: value,
    low: value,
    close: value,
  );
}

void _expectValuesClose(
  List<double?> actual,
  List<double?> expected, {
  double tolerance = 1e-9,
}) {
  expect(actual, hasLength(expected.length));

  for (var index = 0; index < expected.length; index++) {
    final expectedValue = expected[index];

    if (expectedValue == null) {
      expect(actual[index], isNull, reason: 'index $index');
    } else {
      expect(
        actual[index],
        closeTo(expectedValue, tolerance),
        reason: 'index $index',
      );
    }
  }
}
