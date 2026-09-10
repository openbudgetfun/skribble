import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_feed.dart';

void main() {
  late WiredChartController controller;
  late WiredChartFeed feed;
  late StreamController<WiredChartCandle> stream;
  setUp(() {
    controller = WiredChartController(
      instrument: WiredChartInstrument(id: 'SOL-USDC'),
    );
    feed = WiredChartFeed(controller: controller);
    stream = StreamController<WiredChartCandle>.broadcast();
  });
  tearDown(() async {
    feed.dispose();
    controller.dispose();
    await stream.close();
  });

  test(
    'snapshot and buffered live updates commit atomically with revisions',
    () async {
      final snapshot = Completer<List<WiredChartCandle>>();
      var notifications = 0;
      controller.addListener(() => notifications++);
      final connected = feed.connect(
        loadSnapshot: () => snapshot.future,
        updates: stream.stream,
      );
      await _flush();
      expect(feed.status, WiredChartFeedStatus.connecting);
      stream
        ..add(_candle(1, revision: 2, price: 5))
        ..add(_candle(2));
      await _flush();
      expect(controller.candles, isEmpty);
      snapshot.complete([_candle(0), _candle(1, revision: 1)]);
      await connected;
      expect(controller.candles, hasLength(3));
      expect(controller.candles[1].close, WiredChartDecimal.fromInt(5));
      expect(notifications, 1);
      expect(feed.status, WiredChartFeedStatus.live);
      stream.add(_candle(3));
      await _flush();
      expect(controller.candles, hasLength(4));
      expect(notifications, 2);
    },
  );

  test('stale reconnect snapshot cannot replace newer known candles', () async {
    controller.mergeCandles([_candle(0, revision: 10, price: 9)]);
    await feed.connect(
      loadSnapshot: () async => [_candle(0, revision: 1)],
      updates: stream.stream,
    );
    expect(controller.candles.single.close, WiredChartDecimal.fromInt(9));
  });

  test(
    'disconnect invalidates pending snapshot and detaches listener',
    () async {
      final snapshot = Completer<List<WiredChartCandle>>();
      final connected = feed.connect(
        loadSnapshot: () => snapshot.future,
        updates: stream.stream,
      );
      await _flush();
      await feed.disconnect();
      expect(stream.hasListener, isFalse);
      await connected;
      expect(snapshot.isCompleted, isFalse);
      snapshot.complete([_candle(0)]);
      await connected;
      expect(controller.candles, isEmpty);
      expect(feed.status, WiredChartFeedStatus.disconnected);
    },
  );

  test(
    'reconnect generation ignores old snapshot and old stream events',
    () async {
      final oldSnapshot = Completer<List<WiredChartCandle>>();
      final nextStream = StreamController<WiredChartCandle>();
      final oldConnection = feed.connect(
        loadSnapshot: () => oldSnapshot.future,
        updates: stream.stream,
      );
      await _flush();
      await feed.connect(
        loadSnapshot: () async => [_candle(10)],
        updates: nextStream.stream,
      );
      oldSnapshot.complete([_candle(0)]);
      stream.add(_candle(1));
      nextStream.add(_candle(11));
      await oldConnection;
      await _flush();
      expect(controller.candles.map((c) => c.time), [
        _candle(10).time,
        _candle(11).time,
      ]);
      await feed.disconnect();
      await nextStream.close();
    },
  );

  test('obsolete snapshot errors do not fail the current connection', () async {
    final snapshot = Completer<List<WiredChartCandle>>();
    final oldConnection = feed.connect(
      loadSnapshot: () => snapshot.future,
      updates: stream.stream,
    );
    await _flush();
    await feed.connect(
      loadSnapshot: () async => [_candle(10)],
      updates: const Stream.empty(),
    );
    snapshot.completeError(StateError('Obsolete network response'));
    await oldConnection;
    expect(feed.error, isNull);
    expect(controller.candles.single.time, _candle(10).time);
  });

  test('snapshot failure is observable and cancels its stream', () async {
    final error = StateError('History unavailable');
    await expectLater(
      feed.connect(
        loadSnapshot: () => Future.error(error),
        updates: stream.stream,
      ),
      throwsA(same(error)),
    );
    expect(feed.status, WiredChartFeedStatus.failed);
    expect(feed.error, same(error));
    expect(feed.errorStackTrace, isNotNull);
    expect(stream.hasListener, isFalse);
  });

  test('live stream failure is observable and stops further updates', () async {
    await feed.connect(
      loadSnapshot: () async => [_candle(0)],
      updates: stream.stream,
    );
    final error = StateError('Socket lost');
    stream.addError(error, StackTrace.current);
    await _flush();
    expect(feed.status, WiredChartFeedStatus.failed);
    expect(feed.error, same(error));
    stream.add(_candle(1));
    await _flush();
    expect(controller.candles, hasLength(1));
    expect(stream.hasListener, isFalse);
  });

  test(
    'stream failure during snapshot prevents partial snapshot commit',
    () async {
      final snapshot = Completer<List<WiredChartCandle>>();
      final connected = feed.connect(
        loadSnapshot: () => snapshot.future,
        updates: stream.stream,
      );
      final expectation = expectLater(connected, throwsStateError);
      await _flush();
      stream.addError(
        StateError('Socket failed while loading'),
        StackTrace.current,
      );
      await _flush();
      await expectation;
      expect(snapshot.isCompleted, isFalse);
      snapshot.complete([_candle(0)]);
      expect(controller.candles, isEmpty);
      expect(feed.status, WiredChartFeedStatus.failed);
    },
  );

  test(
    'normal stream completion before snapshot still commits history',
    () async {
      final snapshot = Completer<List<WiredChartCandle>>();
      final connected = feed.connect(
        loadSnapshot: () => snapshot.future,
        updates: stream.stream,
      );
      await _flush();
      stream.add(_candle(1));
      await stream.close();
      snapshot.complete([_candle(0)]);
      await connected;
      expect(controller.candles, hasLength(2));
      expect(feed.status, WiredChartFeedStatus.closed);
    },
  );

  test('normal live stream completion exposes closed state', () async {
    await feed.connect(loadSnapshot: () async => [], updates: stream.stream);
    await stream.close();
    expect(feed.status, WiredChartFeedStatus.closed);
  });

  test('bounded buffering fails without applying partial history', () async {
    final bounded = WiredChartFeed(
      controller: controller,
      maxBufferedUpdates: 1,
    );
    final snapshot = Completer<List<WiredChartCandle>>();
    final connected = bounded.connect(
      loadSnapshot: () => snapshot.future,
      updates: stream.stream,
    );
    final expectation = expectLater(connected, throwsStateError);
    await _flush();
    stream
      ..add(_candle(0))
      ..add(_candle(1));
    await _flush();
    expect(bounded.status, WiredChartFeedStatus.failed);
    await expectation;
    expect(snapshot.isCompleted, isFalse);
    snapshot.complete([_candle(2)]);
    expect(controller.candles, isEmpty);
    bounded.dispose();
  });

  test(
    'disposed feeds ignore delayed completion and cannot reconnect',
    () async {
      final disposable = WiredChartFeed(controller: controller);
      final snapshot = Completer<List<WiredChartCandle>>();
      final connected = disposable.connect(
        loadSnapshot: () => snapshot.future,
        updates: stream.stream,
      );
      await _flush();
      disposable.dispose();
      snapshot.complete([_candle(0)]);
      await connected;
      expect(controller.candles, isEmpty);
      await expectLater(
        disposable.connect(
          loadSnapshot: () async => [],
          updates: const Stream.empty(),
        ),
        throwsStateError,
      );
      await expectLater(disposable.disconnect(), throwsStateError);
    },
  );

  test(
    'disconnect called from data listener cannot be overwritten by live status',
    () async {
      controller.addListener(() => unawaited(feed.disconnect()));
      await feed.connect(
        loadSnapshot: () async => [_candle(0)],
        updates: stream.stream,
      );
      expect(feed.status, WiredChartFeedStatus.disconnected);
    },
  );

  test('invalid buffer capacity is rejected', () {
    expect(
      () => WiredChartFeed(controller: controller, maxBufferedUpdates: 0),
      throwsRangeError,
    );
  });

  test('snapshot listeners can synchronously emit a live correction', () async {
    final synchronous = StreamController<WiredChartCandle>(sync: true);
    var emitted = false;
    controller.addListener(() {
      if (emitted) return;
      emitted = true;
      synchronous.add(_candle(0, revision: 1, price: 9));
    });
    await feed.connect(
      loadSnapshot: () async => [_candle(0)],
      updates: synchronous.stream,
    );
    expect(controller.candles.single.close, WiredChartDecimal.fromInt(9));
    expect(feed.status, WiredChartFeedStatus.live);
    await feed.disconnect();
    await synchronous.close();
  });

  test('disconnect joins cancellation already started by reconnect', () async {
    final cancelled = Completer<void>();
    final previous = StreamController<WiredChartCandle>(
      onCancel: () => cancelled.future,
    );
    await feed.connect(loadSnapshot: () async => [], updates: previous.stream);
    final reconnect = feed.connect(
      loadSnapshot: () async => [_candle(1)],
      updates: stream.stream,
    );
    var disconnected = false;
    final disconnect = feed.disconnect().then((_) => disconnected = true);
    await _flush();
    expect(disconnected, isFalse);
    cancelled.complete();
    await disconnect;
    await reconnect;
    expect(controller.candles, isEmpty);
    expect(feed.status, WiredChartFeedStatus.disconnected);
    await previous.close();
  });

  test('disconnect reports cancellation failure during reconnect', () async {
    final cancelled = Completer<void>();
    final previous = StreamController<WiredChartCandle>(
      onCancel: () => cancelled.future,
    );
    await feed.connect(loadSnapshot: () async => [], updates: previous.stream);
    final reconnect = feed.connect(
      loadSnapshot: () async => [],
      updates: stream.stream,
    );
    final expectation = expectLater(feed.disconnect(), throwsStateError);
    cancelled.completeError(StateError('Cancellation failed'));
    await expectation;
    await reconnect;
    expect(feed.status, WiredChartFeedStatus.failed);
    expect(feed.error, isStateError);
    await previous.close();
  });

  for (final reconnect in [false, true]) {
    test(
      'synchronous cancellation reentry joins cleanup (reconnect=$reconnect)',
      () async {
        final cleanup = Completer<void>();
        Future<void>? nestedDisconnect;
        var nestedFinished = false;
        final previous = StreamController<WiredChartCandle>(
          onCancel: () {
            nestedDisconnect = feed.disconnect().then(
              (_) => nestedFinished = true,
            );
            return cleanup.future;
          },
        );
        await feed.connect(
          loadSnapshot: () async => [],
          updates: previous.stream,
        );
        final operation = reconnect
            ? feed.connect(
                loadSnapshot: () async => [_candle(1)],
                updates: stream.stream,
              )
            : feed.disconnect();
        await _flush();
        expect(nestedFinished, isFalse);
        expect(feed.status, WiredChartFeedStatus.disconnected);
        cleanup.complete();
        await operation;
        await nestedDisconnect;
        expect(nestedFinished, isTrue);
        expect(controller.candles, isEmpty);
        expect(feed.status, WiredChartFeedStatus.disconnected);
        await previous.close();
      },
    );
  }

  test(
    'onCancel can reconnect without obsolete disconnect replacing its status',
    () async {
      final cleanup = Completer<void>();
      Future<void>? reconnect;
      final previous = StreamController<WiredChartCandle>(
        onCancel: () {
          reconnect = feed.connect(
            loadSnapshot: () async => [_candle(10)],
            updates: stream.stream,
          );
          return cleanup.future;
        },
      );
      await feed.connect(
        loadSnapshot: () async => [],
        updates: previous.stream,
      );
      final disconnect = feed.disconnect();
      await _flush();
      expect(feed.status, WiredChartFeedStatus.connecting);
      cleanup.complete();
      await disconnect;
      await reconnect;
      expect(feed.status, WiredChartFeedStatus.live);
      expect(controller.candles.single.time, _candle(10).time);
      await previous.close();
    },
  );

  test(
    'synchronous snapshot failures cancel the attached subscription',
    () async {
      await expectLater(
        feed.connect(
          loadSnapshot: () => throw StateError('Synchronous loader failure'),
          updates: stream.stream,
        ),
        throwsStateError,
      );
      expect(feed.status, WiredChartFeedStatus.failed);
      expect(stream.hasListener, isFalse);
    },
  );

  test(
    'cancellation failures reach the caller and observable error state',
    () async {
      final failing = StreamController<WiredChartCandle>(
        onCancel: () => Future<void>.error(StateError('Cancellation failed')),
      );
      await feed.connect(loadSnapshot: () async => [], updates: failing.stream);
      await expectLater(feed.disconnect(), throwsStateError);
      expect(feed.status, WiredChartFeedStatus.failed);
      expect(feed.error, isStateError);
      await failing.close();
    },
  );
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

WiredChartCandle _candle(int index, {int revision = 0, int price = 1}) =>
    WiredChartCandle(
      time: DateTime.utc(2026).add(Duration(minutes: index)),
      open: WiredChartDecimal.fromInt(price),
      high: WiredChartDecimal.fromInt(price),
      low: WiredChartDecimal.fromInt(price),
      close: WiredChartDecimal.fromInt(price),
      revision: revision,
    );
