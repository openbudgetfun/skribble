import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';

/// Observable lifecycle of an optional chart transport connection.
enum WiredChartFeedStatus {
  /// No stream is attached.
  disconnected,

  /// Live events are buffered while the initial snapshot loads.
  connecting,

  /// The snapshot is committed and new events update the chart.
  live,

  /// The attached stream completed normally.
  closed,

  /// Snapshot loading, buffering, or transport failed; see the feed's error.
  failed,
}

/// Coordinates a history snapshot with live events supplied by an application.
///
/// This class does not open network connections or retry automatically. Connect
/// again with a new snapshot loader and stream to reconnect. Revisions prevent
/// stale snapshots from overwriting newer candles already in the controller.
/// Dispose this feed before disposing its [controller].
final class WiredChartFeed extends ChangeNotifier {
  /// Creates a feed with a bounded [maxBufferedUpdates] during snapshot loading.
  WiredChartFeed({required this.controller, this.maxBufferedUpdates = 10000}) {
    if (maxBufferedUpdates <= 0) {
      throw RangeError.value(
        maxBufferedUpdates,
        'maxBufferedUpdates',
        'Must be positive',
      );
    }
  }

  /// Destination of accepted candle updates; the caller retains ownership.
  final WiredChartController controller;

  /// Maximum pending live events before a connection fails explicitly.
  final int maxBufferedUpdates;
  Future<void> Function()? _cancelSubscription;
  Future<void>? _cancellation;
  Completer<List<WiredChartCandle>>? _pendingSnapshot;
  WiredChartFeedStatus _status = WiredChartFeedStatus.disconnected;
  Object? _error;
  StackTrace? _errorStackTrace;
  int _generation = 0;
  bool _disposed = false;

  /// Current connection status.
  WiredChartFeedStatus get status => _status;

  /// Latest connection failure, retained until reconnecting or disconnecting.
  Object? get error => _error;

  /// Stack trace accompanying [error].
  StackTrace? get errorStackTrace => _errorStackTrace;

  bool _current(int generation) => !_disposed && generation == _generation;

  void _checkAlive() {
    if (_disposed) throw StateError('WiredChartFeed has been disposed');
  }

  void _setStatus(WiredChartFeedStatus value) {
    _status = value;
    notifyListeners();
  }

  void _fail(Object error, StackTrace stackTrace) {
    _error = error;
    _errorStackTrace = stackTrace;
    final pending = _pendingSnapshot;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(error, stackTrace);
    }
    _setStatus(WiredChartFeedStatus.failed);
  }

  void _interruptSnapshot() {
    final pending = _pendingSnapshot;
    _pendingSnapshot = null;
    if (pending != null && !pending.isCompleted) pending.complete(const []);
  }

  // Reconnect removes the subscription immediately, but disconnect must still
  // join its asynchronous cancellation instead of returning early.
  Future<void> _cancelActive() {
    final cancel = _cancelSubscription;
    _cancelSubscription = null;
    if (cancel == null) return _cancellation ?? Future<void>.value();
    final completion = Completer<void>();
    final cancellation = completion.future;
    _cancellation = cancellation;
    void clear() {
      if (identical(_cancellation, cancellation)) _cancellation = null;
    }

    unawaited(
      cancellation.then((_) => clear(), onError: (Object _) => clear()),
    );
    // onCancel may synchronously reconnect or disconnect. Those calls must see
    // the same pending cleanup before the transport's callback starts.
    unawaited(
      Future<void>.sync(cancel).then(
        completion.complete,
        onError: completion.completeError,
      ),
    );
    return cancellation;
  }

  /// Subscribes to [updates] before calling [loadSnapshot], buffering live data.
  ///
  /// Snapshot and buffered events merge in one controller notification. Missing
  /// historical candles remain available. Reconnect/disconnect invalidates old
  /// completions. Initial failures set [status] and complete this future with an
  /// error; later stream failures are exposed through [error] and notifications.
  Future<void> connect({
    required Future<List<WiredChartCandle>> Function() loadSnapshot,
    required Stream<WiredChartCandle> updates,
  }) async {
    _checkAlive();
    final generation = ++_generation;
    _interruptSnapshot();
    final previousCancellation = _cancelActive();
    if (!_current(generation)) return;
    final pending = Completer<List<WiredChartCandle>>();
    _pendingSnapshot = pending;
    // A synchronous custom stream can fail during listen, before the await
    // below is installed. Keep that error handled until connect observes it.
    pending.future.ignore();
    final buffer = <WiredChartCandle>[];
    var streamClosed = false;
    _error = null;
    _errorStackTrace = null;
    _setStatus(WiredChartFeedStatus.connecting);

    try {
      await previousCancellation;
      if (!_current(generation)) return;
      _cancelSubscription = updates
          .listen(
            (candle) {
              if (!_current(generation) ||
                  _status == WiredChartFeedStatus.failed) {
                return;
              }
              if (_status == WiredChartFeedStatus.connecting) {
                if (buffer.length >= maxBufferedUpdates) {
                  _fail(
                    StateError(
                      'Live update buffer exceeded $maxBufferedUpdates events',
                    ),
                    StackTrace.current,
                  );
                  unawaited(_cancelReportingFailure());
                  return;
                }
                buffer.add(candle);
                return;
              }
              try {
                controller.mergeCandles([candle]);
              } on Object catch (error, stackTrace) {
                _fail(error, stackTrace);
                unawaited(_cancelReportingFailure());
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              if (_current(generation)) _fail(error, stackTrace);
            },
            onDone: () {
              if (!_current(generation) ||
                  _status == WiredChartFeedStatus.failed) {
                return;
              }
              streamClosed = true;
              if (_status != WiredChartFeedStatus.connecting) {
                _setStatus(WiredChartFeedStatus.closed);
              }
            },
            cancelOnError: true,
          )
          .cancel;
      unawaited(
        Future<List<WiredChartCandle>>.sync(loadSnapshot).then(
          (snapshot) {
            if (!pending.isCompleted) pending.complete(snapshot);
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!pending.isCompleted) pending.completeError(error, stackTrace);
          },
        ),
      );
      final snapshot = await pending.future;
      if (!_current(generation)) return;
      _pendingSnapshot = null;
      if (_status == WiredChartFeedStatus.failed) {
        Error.throwWithStackTrace(_error!, _errorStackTrace!);
      }
      final initial = [...snapshot, ...buffer];
      buffer.clear();
      // Commit the phase before merge notifies controller listeners. A listener
      // may emit synchronously; that event must update the committed snapshot,
      // rather than enter a buffer that is about to be discarded.
      _status = streamClosed
          ? WiredChartFeedStatus.closed
          : WiredChartFeedStatus.live;
      controller.mergeCandles(initial);
      if (!_current(generation)) return;
      if (_status == WiredChartFeedStatus.failed) {
        Error.throwWithStackTrace(_error!, _errorStackTrace!);
      }
      notifyListeners();
    } on Object catch (error, stackTrace) {
      if (!_current(generation)) return;
      _pendingSnapshot = null;
      if (_status != WiredChartFeedStatus.failed) _fail(error, stackTrace);
      if (!_current(generation)) return;
      await _cancelReportingFailure();
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Detaches immediately, invalidating in-flight snapshot completions.
  ///
  /// The returned future waits for stream cancellation. Cancellation failures
  /// set [error] and also complete the returned future with an error.
  Future<void> disconnect() async {
    _checkAlive();
    final generation = ++_generation;
    _interruptSnapshot();
    final cancellation = _cancelActive();
    if (_current(generation)) {
      _error = null;
      _errorStackTrace = null;
      _setStatus(WiredChartFeedStatus.disconnected);
    }
    try {
      await cancellation;
    } on Object catch (error, stackTrace) {
      if (_current(generation)) _fail(error, stackTrace);
      rethrow;
    }
  }

  // A failed connection already reports its original failure. Report secondary
  // cancellation failures through Flutter's error channel as well.
  Future<void> _cancelReportingFailure() async {
    try {
      await _cancelActive();
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'skribble_charts',
          context: ErrorDescription(
            'while cancelling a chart feed subscription',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _checkAlive();
    _disposed = true;
    _generation++;
    _interruptSnapshot();
    final cancellation = _cancelActive();
    unawaited(
      cancellation.catchError((Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'skribble_charts',
            context: ErrorDescription(
              'while disposing a chart feed subscription',
            ),
          ),
        );
      }),
    );
    super.dispose();
  }
}
