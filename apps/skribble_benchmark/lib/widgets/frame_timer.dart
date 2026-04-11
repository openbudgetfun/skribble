import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Collected frame timing statistics.
class FrameTimingStats {
  const FrameTimingStats({
    required this.frameCount,
    required this.avgBuildMicros,
    required this.avgRasterMicros,
    required this.p50BuildMicros,
    required this.p95BuildMicros,
    required this.p99BuildMicros,
    required this.maxBuildMicros,
    required this.p50RasterMicros,
    required this.p95RasterMicros,
    required this.p99RasterMicros,
    required this.maxRasterMicros,
    required this.jankFrames,
  });

  final int frameCount;
  final double avgBuildMicros;
  final double avgRasterMicros;
  final double p50BuildMicros;
  final double p95BuildMicros;
  final double p99BuildMicros;
  final double maxBuildMicros;
  final double p50RasterMicros;
  final double p95RasterMicros;
  final double p99RasterMicros;
  final double maxRasterMicros;
  final int jankFrames;

  double get avgBuildMs => avgBuildMicros / 1000;
  double get avgRasterMs => avgRasterMicros / 1000;
  double get p50BuildMs => p50BuildMicros / 1000;
  double get p95BuildMs => p95BuildMicros / 1000;
  double get p99BuildMs => p99BuildMicros / 1000;
  double get maxBuildMs => maxBuildMicros / 1000;
  double get p50RasterMs => p50RasterMicros / 1000;
  double get p95RasterMs => p95RasterMicros / 1000;
  double get p99RasterMs => p99RasterMicros / 1000;
  double get maxRasterMs => maxRasterMicros / 1000;
  double get avgTotalMs => avgBuildMs + avgRasterMs;
  double get p95TotalMs => p95BuildMs + p95RasterMs;
}

/// Computes percentile from a sorted list.
double _percentile(List<int> sorted, double p) {
  if (sorted.isEmpty) return 0;
  final index = ((p / 100) * (sorted.length - 1)).round();
  return sorted[index].toDouble();
}

/// Computes [FrameTimingStats] from collected [FrameTiming] entries.
FrameTimingStats computeStats(List<FrameTiming> timings) {
  if (timings.isEmpty) {
    return const FrameTimingStats(
      frameCount: 0,
      avgBuildMicros: 0,
      avgRasterMicros: 0,
      p50BuildMicros: 0,
      p95BuildMicros: 0,
      p99BuildMicros: 0,
      maxBuildMicros: 0,
      p50RasterMicros: 0,
      p95RasterMicros: 0,
      p99RasterMicros: 0,
      maxRasterMicros: 0,
      jankFrames: 0,
    );
  }

  final buildDurations = <int>[];
  final rasterDurations = <int>[];
  var jankFrames = 0;

  for (final timing in timings) {
    final buildMicros = timing.buildDuration.inMicroseconds;
    final rasterMicros = timing.rasterDuration.inMicroseconds;
    buildDurations.add(buildMicros);
    rasterDurations.add(rasterMicros);
    if (buildMicros + rasterMicros > 16000) {
      jankFrames++;
    }
  }

  buildDurations.sort();
  rasterDurations.sort();

  final avgBuild =
      buildDurations.fold<int>(0, (sum, v) => sum + v) / buildDurations.length;
  final avgRaster =
      rasterDurations.fold<int>(0, (sum, v) => sum + v) /
      rasterDurations.length;

  return FrameTimingStats(
    frameCount: timings.length,
    avgBuildMicros: avgBuild,
    avgRasterMicros: avgRaster,
    p50BuildMicros: _percentile(buildDurations, 50),
    p95BuildMicros: _percentile(buildDurations, 95),
    p99BuildMicros: _percentile(buildDurations, 99),
    maxBuildMicros: buildDurations.last.toDouble(),
    p50RasterMicros: _percentile(rasterDurations, 50),
    p95RasterMicros: _percentile(rasterDurations, 95),
    p99RasterMicros: _percentile(rasterDurations, 99),
    maxRasterMicros: rasterDurations.last.toDouble(),
    jankFrames: jankFrames,
  );
}

/// Hook that collects frame timings using [SchedulerBinding].
///
/// Returns a record containing the current stats, the collected timings list,
/// and a reset callback.
({
  FrameTimingStats stats,
  List<FrameTiming> timings,
  VoidCallback reset,
  bool isCollecting,
  VoidCallback startCollecting,
  VoidCallback stopCollecting,
})
useFrameTimer({int maxFrames = 120}) {
  final timings = useState(<FrameTiming>[]);
  final isCollecting = useState(false);

  final callbackRef = useRef<TimingsCallback?>(null);

  void stopCollecting() {
    if (callbackRef.value != null) {
      SchedulerBinding.instance.removeTimingsCallback(callbackRef.value!);
      callbackRef.value = null;
    }
    isCollecting.value = false;
  }

  void startCollecting() {
    stopCollecting();
    timings.value = [];
    isCollecting.value = true;

    void callback(List<FrameTiming> newTimings) {
      final current = List<FrameTiming>.of(timings.value)
        ..addAll(newTimings);
      if (current.length >= maxFrames) {
        timings.value = current.take(maxFrames).toList();
        stopCollecting();
      } else {
        timings.value = current;
      }
    }

    callbackRef.value = callback;
    SchedulerBinding.instance.addTimingsCallback(callback);
  }

  void reset() {
    stopCollecting();
    timings.value = [];
  }

  useEffect(
    () {
      return stopCollecting;
    },
    const [],
  );

  return (
    stats: computeStats(timings.value),
    timings: timings.value,
    reset: reset,
    isCollecting: isCollecting.value,
    startCollecting: startCollecting,
    stopCollecting: stopCollecting,
  );
}

/// A card widget that displays [FrameTimingStats].
class FrameTimingStatsCard extends HookWidget {
  const FrameTimingStatsCard({
    required this.title,
    required this.stats,
    super.key,
  });

  final String title;
  final FrameTimingStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (stats.frameCount == 0)
              const Text('No data collected yet.')
            else ...[
              Text('Frames collected: ${stats.frameCount}'),
              Text('Jank frames (>16ms): ${stats.jankFrames}'),
              const Divider(),
              _buildRow('Build avg', stats.avgBuildMs),
              _buildRow('Build P50', stats.p50BuildMs),
              _buildRow('Build P95', stats.p95BuildMs),
              _buildRow('Build P99', stats.p99BuildMs),
              _buildRow('Build max', stats.maxBuildMs),
              const Divider(),
              _buildRow('Raster avg', stats.avgRasterMs),
              _buildRow('Raster P50', stats.p50RasterMs),
              _buildRow('Raster P95', stats.p95RasterMs),
              _buildRow('Raster P99', stats.p99RasterMs),
              _buildRow('Raster max', stats.maxRasterMs),
              const Divider(),
              _buildRow('Total avg', stats.avgTotalMs),
              _buildRow('Total P95', stats.p95TotalMs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double valueMs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${valueMs.toStringAsFixed(2)} ms'),
        ],
      ),
    );
  }
}
