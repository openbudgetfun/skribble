import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';
import 'package:skribble_charts/src/chart_workspace.dart';

void main() {
  late WiredChartController controller;
  late WiredChartAnnotations annotations;

  setUp(() {
    controller =
        WiredChartController(
            instrument: WiredChartInstrument(
              id: 'SOL-USDC',
              priceDecimals: 9,
              volumeDecimals: 6,
            ),
            candles: List.generate(100, _candle),
            visibleCount: 20,
          )
          ..setViewport(10.25, 20.5)
          ..selectIndex(15);
    annotations = WiredChartAnnotations()
      ..add(_drawing('support'))
      ..select('support');
  });

  tearDown(() {
    if (!controller.isDisposed) {
      controller.dispose();
    }

    if (!annotations.isDisposed) {
      annotations.dispose();
    }
  });

  test(
    'captures exact coordinates, instrument precision, and default options',
    () {
      final workspace = WiredChartWorkspace.capture(controller, annotations);

      expect(workspace.instrument.id, 'SOL-USDC');
      expect(workspace.instrument.priceDecimals, 9);
      expect(workspace.instrument.volumeDecimals, 6);
      expect(workspace.series, WiredPriceSeries.candlesticks);
      expect(workspace.scale, WiredChartPriceScale.linear);
      expect(workspace.handDrawn, isTrue);
      expect(workspace.overlays, isEmpty);
      expect(workspace.panes, isEmpty);
      expect(workspace.firstVisibleTime, _candle(10).time);
      expect(workspace.firstVisibleFraction, 0.25);
      expect(workspace.visibleCount, 20.5);
      expect(workspace.visibleCandleCount, 21);
      expect(workspace.percentageReference, WiredChartDecimal.fromInt(1000));
      expect(workspace.selectedTime, _candle(15).time);
      expect(workspace.selectedAnnotationId, 'support');
      expect(
        workspace.annotations.single.toJson(),
        _drawing('support').toJson(),
      );
      expect(
        workspace.annotations.single.anchors.single.price.toString(),
        '0.000000000000000000123456789',
      );
    },
  );

  test(
    'round trips all options, indicator kinds, pane weights, and drawings',
    () {
      const indicators = <WiredChartIndicator>[
        WiredSma(period: 7),
        WiredEma(period: 11),
        WiredRsi(period: 9),
        WiredMacd(fastPeriod: 3, slowPeriod: 8, signalPeriod: 5),
        WiredBollingerBands(period: 12, deviations: 1.75),
      ];
      final workspace = WiredChartWorkspace.capture(
        controller,
        annotations,
        series: WiredPriceSeries.area,
        scale: WiredChartPriceScale.logarithmic,
        overlays: indicators,
        panes: const [
          WiredVolumePane(weight: 0.5),
          WiredIndicatorPane(indicator: WiredRsi(period: 4), weight: 2.25),
          WiredIndicatorPane(indicator: WiredMacd(), weight: 1.5),
        ],
        handDrawn: false,
      );
      final restored = WiredChartWorkspace.decode(workspace.encode());

      expect(restored.toJson(), workspace.toJson());
      expect(restored.series, WiredPriceSeries.area);
      expect(restored.scale, WiredChartPriceScale.logarithmic);
      expect(restored.handDrawn, isFalse);
      expect(
        restored.overlays.map((value) => value.toJson()),
        indicators.map((value) => value.toJson()),
      );
      expect(restored.panes.map((pane) => pane.weight), [0.5, 2.25, 1.5]);
      expect(restored.panes[0], isA<WiredVolumePane>());
      expect(restored.panes[1], isA<WiredIndicatorPane>());
      expect(workspace.encode(), contains('2026-09-10T00:10:01.234123Z'));
      expect(
        workspace.encode(),
        contains('"price":"0.000000000000000000123456789"'),
      );
      expect(workspace.toJson().containsKey('candles'), isFalse);
      expect(workspace.toJson().containsKey('history'), isFalse);
    },
  );

  for (final series in WiredPriceSeries.values) {
    for (final scale in WiredChartPriceScale.values) {
      test('${series.name}/${scale.name} survives encode and decode', () {
        final saved = WiredChartWorkspace.capture(
          controller,
          annotations,
          series: series,
          scale: scale,
        );
        final restored = WiredChartWorkspace.decode(saved.encode());

        expect(restored.series, series);
        expect(restored.scale, scale);
        expect(restored.toJson(), saved.toJson());
      });
    }
  }

  test('capture detaches input lists and drawings from subsequent editing', () {
    final overlays = <WiredChartIndicator>[const WiredSma()];
    final panes = <WiredChartPane>[const WiredVolumePane()];
    final workspace = WiredChartWorkspace.capture(
      controller,
      annotations,
      overlays: overlays,
      panes: panes,
    );
    overlays.clear();
    panes.clear();
    annotations.remove('support');
    controller.setViewport(50, 5);

    expect(workspace.overlays, hasLength(1));
    expect(workspace.panes, hasLength(1));
    expect(workspace.annotations, hasLength(1));
    expect(workspace.firstVisibleTime, _candle(10).time);
    expect(workspace.overlays.clear, throwsUnsupportedError);
    expect(workspace.panes.clear, throwsUnsupportedError);
    expect(workspace.annotations.clear, throwsUnsupportedError);
  });

  test(
    'capture rejects invalid typed indicator descriptions and pane totals',
    () {
      expect(
        () => WiredChartWorkspace.capture(
          controller,
          annotations,
          overlays: const [WiredSma(period: 0)],
        ),
        throwsFormatException,
      );
      expect(
        () => WiredChartWorkspace.capture(
          controller,
          annotations,
          panes: const [WiredIndicatorPane(indicator: WiredRsi(period: -1))],
        ),
        throwsFormatException,
      );
      expect(
        () => WiredChartWorkspace.capture(
          controller,
          annotations,
          panes: const [WiredVolumePane(weight: double.infinity)],
        ),
        throwsFormatException,
      );
      expect(
        () => WiredChartWorkspace.capture(
          controller,
          annotations,
          panes: const [
            WiredVolumePane(weight: 1e308),
            WiredVolumePane(weight: 1e308),
          ],
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'restore reapplies view and selections without replacing market data',
    () {
      final saved = WiredChartWorkspace.capture(controller, annotations);
      final candles = controller.candles;
      controller
        ..setViewport(60, 10)
        ..selectIndex(null);
      annotations
        ..remove('support')
        ..add(_drawing('new'));
      saved.restore(controller: controller, annotations: annotations);

      expect(controller.firstVisible, 10.25);
      expect(controller.visibleCount, 20.5);
      expect(controller.selectedIndex, 15);
      expect(identical(controller.candles, candles), isTrue);
      expect(annotations.annotations.single.id, 'support');
      expect(annotations.selectedId, 'support');
      expect(annotations.canUndo, isFalse);
      expect(annotations.canRedo, isFalse);
    },
  );

  test('prepended history preserves timestamp, fractional view, and screen position', () {
    final saved = WiredChartWorkspace.capture(controller, annotations);
    final originalView = WiredChartViewport(
      firstVisible: controller.firstVisible,
      visibleCount: controller.visibleCount,
      width: 640,
    );
    final selectedX = originalView.xForIndex(
      controller.selectedIndex!.toDouble(),
    );
    controller
      ..mergeCandles(List.generate(30, (index) => _candle(index - 30)))
      ..scrollToLatest()
      ..selectIndex(null);
    saved.restore(controller: controller, annotations: annotations);
    final restoredView = WiredChartViewport(
      firstVisible: controller.firstVisible,
      visibleCount: controller.visibleCount,
      width: 640,
    );

    expect(controller.firstVisible, 40.25);
    expect(
      controller.candles[controller.firstVisible.floor()].time,
      saved.firstVisibleTime,
    );
    expect(controller.selectedIndex, 45);
    expect(
      controller.candles[controller.selectedIndex!].time,
      saved.selectedTime,
    );
    expect(
      restoredView.xForIndex(controller.selectedIndex!.toDouble()),
      selectedX,
    );
    expect(controller.isFollowingLatest, isFalse);
  });

  test('percentage labels retain an exact baseline through prepend and fresh restore', () {
    final saved = WiredChartWorkspace.decode(
      WiredChartWorkspace.capture(
        controller,
        annotations,
        scale: WiredChartPriceScale.percentage,
      ).encode(),
    );
    final selectedPrice = controller.candles[15].close;
    final originalPercent = _percentageScene(controller).transform
        .valueForPrice(selectedPrice);
    controller.mergeCandles(List.generate(30, (index) => _candle(index - 30)));

    expect(
      _percentageScene(controller).transform.valueForPrice(selectedPrice),
      originalPercent,
    );
    expect(originalPercent, 1.5);
    final reopened = WiredChartController(
      instrument: controller.instrument,
      candles: controller.candles,
    );
    addTearDown(reopened.dispose);
    expect(reopened.percentageReference, WiredChartDecimal.fromInt(970));
    saved.restore(controller: reopened, annotations: annotations);

    expect(reopened.percentageReference, WiredChartDecimal.fromInt(1000));
    expect(
      _percentageScene(reopened).transform.valueForPrice(selectedPrice),
      originalPercent,
    );
    expect(reopened.firstVisible, 40.25);
  });

  test(
    'saved explicit reference is exact and survives source price corrections',
    () {
      final reference = WiredChartDecimal.parse(
        '0.000000000000000000123456789',
      );
      controller.setPercentageReference(reference);
      final saved = WiredChartWorkspace.decode(
        WiredChartWorkspace.capture(controller, annotations).encode(),
      );
      controller
        ..replaceCandles(
          List.generate(100, (index) => _candle(index, price: 500)),
        )
        ..setPercentageReference(WiredChartDecimal.fromInt(500));
      saved.restore(controller: controller, annotations: annotations);

      expect(
        saved.toJson()['percentageReference'],
        '0.000000000000000000123456789',
      );
      expect(saved.percentageReference, reference);
      expect(controller.percentageReference, reference);
    },
  );

  test('an uninitialized saved reference retains the target data baseline', () {
    final empty = WiredChartController(instrument: controller.instrument);
    addTearDown(empty.dispose);
    final saved = WiredChartWorkspace.capture(
      empty,
      annotations,
      scale: WiredChartPriceScale.percentage,
    );

    expect(saved.toJson()['percentageReference'], isNull);
    saved.restore(controller: controller, annotations: annotations);
    expect(controller.percentageReference, WiredChartDecimal.fromInt(1000));
    expect(controller.firstVisible, 0);
  });

  test('restore without a percentage baseline rejects nonpositive initial data atomically', () {
    final empty = WiredChartController(instrument: controller.instrument);
    addTearDown(empty.dispose);
    final saved = WiredChartWorkspace.capture(
      empty,
      annotations,
      scale: WiredChartPriceScale.percentage,
    );
    final target = WiredChartController(
      instrument: controller.instrument,
      candles: List.generate(100, (index) => _candle(index, price: -1)),
    )..setViewport(10, 20);
    addTearDown(target.dispose);

    expect(
      () => saved.restore(controller: target, annotations: annotations),
      throwsArgumentError,
    );
    expect(target.firstVisible, 10);
    expect(target.percentageReference, isNull);
    expect(annotations.canUndo, isTrue);
  });

  test('a full viewport starting at zero rejects partial trailing history atomically', () {
    controller
      ..setViewport(0, 20)
      ..selectIndex(null);
    final saved = WiredChartWorkspace.capture(controller, annotations);
    controller
      ..replaceCandles(List.generate(10, _candle))
      ..setViewport(0, 5)
      ..setPercentageReference(WiredChartDecimal.fromInt(700));
    var notifications = 0;
    controller.addListener(() => notifications++);

    expect(saved.visibleCandleCount, 20);
    expect(
      () => saved.restore(controller: controller, annotations: annotations),
      throwsArgumentError,
    );
    expect(controller.firstVisible, 0);
    expect(controller.visibleCount, 5);
    expect(controller.percentageReference, WiredChartDecimal.fromInt(700));
    expect(annotations.canUndo, isTrue);
    expect(notifications, 0);
  });

  test('sparse captured history restores but cannot lose its existing visible bars', () {
    controller
      ..replaceCandles(List.generate(8, _candle))
      ..setViewport(0, 60)
      ..selectIndex(null);
    final saved = WiredChartWorkspace.decode(
      WiredChartWorkspace.capture(controller, annotations).encode(),
    );
    controller.setViewport(0, 5);
    saved.restore(controller: controller, annotations: annotations);

    expect(saved.visibleCandleCount, 8);
    expect(controller.visibleCount, 60);
    controller
      ..replaceCandles(List.generate(7, _candle))
      ..setViewport(0, 5);
    expect(
      () => saved.restore(controller: controller, annotations: annotations),
      throwsArgumentError,
    );
    expect(controller.visibleCount, 5);
  });

  test('milliseconds and microseconds use exact UTC timestamps on restore', () {
    for (final micros in [0, 123]) {
      controller
        ..replaceCandles(
          List.generate(100, (index) => _candle(index, micros: micros)),
        )
        ..setViewport(10.25, 20.5)
        ..selectIndex(15);
      final saved = WiredChartWorkspace.decode(
        WiredChartWorkspace.capture(controller, annotations).encode(),
      );
      controller.scrollToLatest();
      saved.restore(controller: controller, annotations: annotations);

      expect(controller.firstVisible, 10.25);
      expect(controller.selectedIndex, 15);
      expect(saved.firstVisibleTime, _candle(10, micros: micros).time);
      expect(saved.firstVisibleTime!.isUtc, isTrue);
    }
  });

  test(
    'an empty saved chart restores to the beginning and clears selections',
    () {
      controller.replaceCandles([]);
      final saved = WiredChartWorkspace.capture(controller, annotations);

      expect(saved.firstVisibleTime, isNull);
      expect(saved.firstVisibleFraction, 0);
      expect(saved.selectedTime, isNull);
      controller
        ..replaceCandles(List.generate(100, _candle))
        ..selectIndex(20);
      saved.restore(controller: controller, annotations: annotations);

      expect(controller.firstVisible, 0);
      expect(controller.visibleCount, 20.5);
      expect(controller.selectedIndex, isNull);
      expect(
        WiredChartWorkspace.decode(saved.encode()).toJson(),
        saved.toJson(),
      );
    },
  );

  test(
    'unknown instrument or precision rejects restore before changing owners',
    () {
      final saved = WiredChartWorkspace.capture(controller, annotations);
      final originals = annotations.exportDocument();
      final instruments = [
        WiredChartInstrument(
          id: 'BTC-USDC',
          priceDecimals: 9,
          volumeDecimals: 6,
        ),
        WiredChartInstrument(
          id: 'SOL-USDC',
          priceDecimals: 8,
          volumeDecimals: 6,
        ),
        WiredChartInstrument(
          id: 'SOL-USDC',
          priceDecimals: 9,
          volumeDecimals: 5,
        ),
      ];

      for (final instrument in instruments) {
        final target = WiredChartController(
          instrument: instrument,
          candles: controller.candles,
        );
        addTearDown(target.dispose);
        final original = target.firstVisible;
        var notifications = 0;
        target.addListener(() => notifications++);
        expect(
          () => saved.restore(controller: target, annotations: annotations),
          throwsArgumentError,
        );
        expect(target.firstVisible, original);
        expect(target.visibleCount, 60);
        expect(target.selectedIndex, isNull);
        expect(notifications, 0);
        expect(annotations.exportDocument(), originals);
        expect(annotations.canUndo, isTrue);
      }
    },
  );

  test(
    'missing anchor or selected candle fails without restoring either owner',
    () {
      final saved = WiredChartWorkspace.capture(controller, annotations);

      for (final missing in [10, 15]) {
        controller
          ..replaceCandles(
            List.generate(
              100,
              _candle,
            ).where((candle) => candle.time != _candle(missing).time),
          )
          ..setViewport(40, 10);
        var notifications = 0;
        void listener() => notifications++;
        controller.addListener(listener);
        expect(
          () => saved.restore(controller: controller, annotations: annotations),
          throwsArgumentError,
        );
        expect(controller.firstVisible, 40);
        expect(controller.visibleCount, 10);
        expect(annotations.selectedId, 'support');
        expect(annotations.canUndo, isTrue);
        expect(notifications, 0);
        controller.removeListener(listener);
      }
    },
  );

  test(
    'insufficient trailing data fails instead of silently clamping saved view',
    () {
      final saved = WiredChartWorkspace.capture(controller, annotations);
      controller
        ..replaceCandles(List.generate(25, _candle))
        ..setViewport(1, 3);

      expect(
        () => saved.restore(controller: controller, annotations: annotations),
        throwsArgumentError,
      );
      expect(controller.firstVisible, 1);
      expect(controller.visibleCount, 3);
      expect(annotations.canUndo, isTrue);
    },
  );

  test(
    'logarithmic rejects nonpositive data while percentage retains positive reference',
    () {
      final logarithmic = WiredChartWorkspace.capture(
        controller,
        annotations,
        scale: WiredChartPriceScale.logarithmic,
      );
      final percentage = WiredChartWorkspace.capture(
        controller,
        annotations,
        scale: WiredChartPriceScale.percentage,
      );
      controller
        ..replaceCandles(
          List.generate(100, (index) => _candle(index, price: -5)),
        )
        ..setViewport(50, 10);

      expect(
        () => logarithmic.restore(
          controller: controller,
          annotations: annotations,
        ),
        throwsArgumentError,
      );
      expect(controller.firstVisible, 50);
      expect(controller.visibleCount, 10);
      expect(annotations.canUndo, isTrue);
      percentage.restore(controller: controller, annotations: annotations);
      expect(controller.firstVisible, 10.25);
      expect(controller.percentageReference, WiredChartDecimal.fromInt(1000));
    },
  );

  test(
    'indicator-incompatible extreme source prices reject restore atomically',
    () {
      final saved = WiredChartWorkspace.capture(
        controller,
        annotations,
        overlays: const [WiredSma()],
      );
      final extreme = WiredChartDecimal.parse('1e999');
      controller
        ..replaceCandles(
          List.generate(
            100,
            (index) => WiredChartCandle(
              time: _candle(index).time,
              open: extreme,
              high: extreme,
              low: extreme,
              close: extreme,
            ),
          ),
        )
        ..setViewport(50, 10);

      expect(
        () => saved.restore(controller: controller, annotations: annotations),
        throwsArgumentError,
      );
      expect(controller.firstVisible, 50);
      expect(controller.visibleCount, 10);
      expect(annotations.canUndo, isTrue);
    },
  );

  test(
    'disposed destination owners reject capture and restore before mutation',
    () {
      final saved = WiredChartWorkspace.capture(controller, annotations);
      final deadAnnotations = WiredChartAnnotations()..dispose();
      final deadController = WiredChartController(
        instrument: controller.instrument,
      )..dispose();
      controller.setViewport(50, 10);

      expect(
        () =>
            saved.restore(controller: controller, annotations: deadAnnotations),
        throwsStateError,
      );
      expect(controller.firstVisible, 50);
      expect(controller.visibleCount, 10);
      expect(
        () =>
            saved.restore(controller: deadController, annotations: annotations),
        throwsStateError,
      );
      expect(annotations.canUndo, isTrue);
      expect(
        () => WiredChartWorkspace.capture(controller, deadAnnotations),
        throwsStateError,
      );
      expect(
        () => WiredChartWorkspace.capture(deadController, annotations),
        throwsStateError,
      );
    },
  );

  group('document validation', () {
    late Map<String, Object?> valid;

    setUp(
      () =>
          valid = WiredChartWorkspace.capture(controller, annotations).toJson(),
    );

    test(
      'rejects unsupported versions, missing fields, and unknown enum values',
      () {
        final invalid = <Object?>[
          null,
          <Object?>[],
          'workspace',
          <String, Object?>{},
          {...valid, 'version': null},
          {...valid, 'version': 2},
          {...valid, 'version': 1.0},
          {...valid, 'version': '1'},
          {...valid, 'series': 'heikinAshi'},
          {...valid, 'series': 0},
          {...valid, 'scale': 'unknown'},
          {...valid, 'handDrawn': 1},
          {...valid, 'overlays': <String, Object?>{}},
          {...valid, 'panes': <String, Object?>{}},
          {...valid, 'viewport': null},
          {...valid, 'annotations': null},
        ];
        for (final document in invalid) {
          expect(
            () => WiredChartWorkspace.fromJson(document),
            throwsFormatException,
          );
        }
        for (final key in valid.keys) {
          final incomplete = {...valid}..remove(key);
          expect(
            () => WiredChartWorkspace.fromJson(incomplete),
            throwsFormatException,
            reason: key,
          );
        }
        expect(() => WiredChartWorkspace.decode('{'), throwsFormatException);
      },
    );

    test('validates instrument fields without numeric coercion', () {
      final instrument = _object(valid['instrument']);
      for (final malformed in <Object?>[
        null,
        <String, Object?>{},
        {...instrument, 'id': ''},
        {...instrument, 'id': '  '},
        {...instrument, 'id': 1},
        {...instrument, 'priceDecimals': -1},
        {...instrument, 'priceDecimals': 1001},
        {...instrument, 'priceDecimals': 2.0},
        {...instrument, 'volumeDecimals': -1},
        {...instrument, 'volumeDecimals': 1001},
        {...instrument, 'volumeDecimals': '2'},
      ]) {
        expect(
          () =>
              WiredChartWorkspace.fromJson({...valid, 'instrument': malformed}),
          throwsFormatException,
        );
      }
    });

    test(
      'validates persisted exact references and actual visible candle counts',
      () {
        final viewport = _object(valid['viewport']);

        for (final reference in <Object?>[0.1, '0', '-1', 'NaN', 'invalid']) {
          expect(
            () => WiredChartWorkspace.fromJson({
              ...valid,
              'percentageReference': reference,
            }),
            throwsFormatException,
          );
        }

        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'scale': 'percentage',
            'percentageReference': null,
          }),
          throwsFormatException,
        );

        for (final count in <Object?>[
          null,
          -1,
          0,
          22,
          2.5,
          double.infinity,
          '20',
        ]) {
          expect(
            () => WiredChartWorkspace.fromJson({
              ...valid,
              'viewport': {...viewport, 'visibleCandleCount': count},
            }),
            throwsFormatException,
          );
        }
      },
    );

    test('rejects nonfinite and out-of-range viewport quantities', () {
      final viewport = _object(valid['viewport']);
      for (final fraction in <Object?>[
        -0.1,
        1,
        double.nan,
        double.infinity,
        '0',
        null,
      ]) {
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'viewport': {...viewport, 'fraction': fraction},
          }),
          throwsFormatException,
        );
      }
      for (final count in <Object?>[
        0,
        -1,
        1000001,
        double.nan,
        double.infinity,
        '20',
        null,
      ]) {
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'viewport': {...viewport, 'visibleCount': count},
          }),
          throwsFormatException,
        );
      }
      for (final count in [1, 1000000]) {
        expect(
          WiredChartWorkspace.fromJson({
            ...valid,
            'viewport': {
              ...viewport,
              'visibleCount': count,
              'visibleCandleCount': 1,
            },
          }).visibleCount,
          count,
        );
      }
    });

    test('rejects malformed, overflowing, non-UTC, and incomplete dates', () {
      final viewport = _object(valid['viewport']);
      for (final timestamp in <Object?>[
        123,
        '',
        '2026-02-30T00:00:00.000Z',
        '2026-09-10T00:00:00.000',
        '2026-09-10T00:00:00.000+01:00',
        'not-a-date',
      ]) {
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'viewport': {...viewport, 'time': timestamp},
          }),
          throwsFormatException,
        );
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'selectedTime': timestamp,
          }),
          throwsFormatException,
        );
      }
      expect(
        () => WiredChartWorkspace.fromJson({
          ...valid,
          'viewport': const {'time': null, 'fraction': 0.5, 'visibleCount': 20},
          'selectedTime': null,
        }),
        throwsFormatException,
      );
      expect(
        () => WiredChartWorkspace.fromJson({
          ...valid,
          'viewport': const {'time': null, 'fraction': 0, 'visibleCount': 20},
        }),
        throwsFormatException,
      );
    });

    test('rejects invalid indicator parameters and unknown pane types', () {
      for (final indicator in <Object?>[
        null,
        {'type': 'unknown'},
        {'type': 'sma', 'period': 0},
        {'type': 'ema', 'period': 2.0},
        {'type': 'rsi', 'period': -1},
        {'type': 'macd', 'fastPeriod': 3, 'slowPeriod': 8},
        {'type': 'bollingerBands', 'period': 20, 'deviations': double.infinity},
      ]) {
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'overlays': [indicator],
          }),
          throwsFormatException,
        );
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'panes': [
              {'type': 'indicator', 'weight': 1, 'indicator': indicator},
            ],
          }),
          throwsFormatException,
        );
      }
      for (final pane in <Object?>[
        null,
        {'type': 'unknown', 'weight': 1},
        {'type': 'volume', 'weight': 0},
        {'type': 'volume', 'weight': -1},
        {'type': 'volume', 'weight': double.nan},
        {'type': 'volume', 'weight': double.infinity},
        {'type': 'volume', 'weight': '1'},
      ]) {
        expect(
          () => WiredChartWorkspace.fromJson({
            ...valid,
            'panes': [pane],
          }),
          throwsFormatException,
        );
      }
    });

    test(
      'duplicate drawings and bad nested coordinates never mutate live owners',
      () {
        final originalAnnotations = annotations.exportDocument();
        final annotation = annotations.annotations.single.toJson();
        final drawingDocument = _object(valid['annotations']);
        final invalid = [
          {...drawingDocument, 'version': 2},
          {
            ...drawingDocument,
            'annotations': [annotation, annotation],
          },
          {...drawingDocument, 'selectedId': 'missing'},
          {
            ...drawingDocument,
            'annotations': [
              {
                ...annotation,
                'anchors': [
                  {'time': _candle(5).time.toIso8601String(), 'price': 0.1},
                ],
              },
            ],
          },
        ];
        var controllerNotifications = 0;
        var annotationNotifications = 0;
        controller.addListener(() => controllerNotifications++);
        annotations.addListener(() => annotationNotifications++);

        for (final malformed in invalid) {
          expect(
            () => WiredChartWorkspace.fromJson({
              ...valid,
              'annotations': malformed,
            }).restore(controller: controller, annotations: annotations),
            throwsFormatException,
          );
          expect(controller.firstVisible, 10.25);
          expect(controller.visibleCount, 20.5);
          expect(controller.selectedIndex, 15);
          expect(annotations.exportDocument(), originalAnnotations);
          expect(annotations.canUndo, isTrue);
        }
        expect(controllerNotifications, 0);
        expect(annotationNotifications, 0);
      },
    );

    test('decoded and encoded maps are detached from the saved workspace', () {
      final saved = WiredChartWorkspace.fromJson(valid);
      final expected = saved.encode();
      _object(valid['viewport'])['fraction'] = 0.75;
      _object(valid['instrument'])['id'] = 'changed';
      valid.clear();
      final exported = saved.toJson();
      _object(exported['annotations']).clear();
      _object(exported['viewport']).clear();

      expect(saved.encode(), expected);
      expect(jsonDecode(expected), saved.toJson());
    });
  });
}

WiredChartCandle _candle(int index, {int micros = 123, int? price}) {
  final close = WiredChartDecimal.fromInt(price ?? 1000 + index);

  return WiredChartCandle(
    time: DateTime.utc(2026, 9, 10, 0, index, 1, 234, micros),
    open: close,
    high: close + WiredChartDecimal.fromInt(2),
    low: close - WiredChartDecimal.fromInt(2),
    close: close,
    volume: WiredChartDecimal.parse('123456789.000000123456789'),
  );
}

WiredChartHorizontalLine _drawing(String id) => WiredChartHorizontalLine(
  id: id,
  anchor: WiredChartAnchor(
    time: _candle(5).time,
    price: WiredChartDecimal.parse('0.000000000000000000123456789'),
  ),
  label: 'Support',
);

Map<String, Object?> _object(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw StateError('Expected fixture JSON object.');
}

ChartScene _percentageScene(WiredChartController controller) => ChartScene(
  candles: controller.candles,
  instrument: controller.instrument,
  firstVisible: controller.firstVisible,
  visibleCount: controller.visibleCount,
  size: const Size(640, 360),
  series: WiredPriceSeries.candlesticks,
  scale: WiredChartPriceScale.percentage,
  percentageReference: controller.percentageReference,
  style: const WiredChartStyle(),
);
