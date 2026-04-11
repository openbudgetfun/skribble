import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_benchmark/widgets/frame_timer.dart';
import 'package:skribble_benchmark/widgets/precomputed_icon.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Returns the list of icon data from [kSkribbleCustomIcons].
List<WiredSvgIconData> _getIconDataList() {
  return kSkribbleCustomIcons.values.toList(growable: false);
}

/// Icon data for a given index, cycling through the 30 available icons.
WiredSvgIconData _iconAt(List<WiredSvgIconData> icons, int index) {
  return icons[index % icons.length];
}

const _gridCounts = [10, 30, 50, 100, 200];

/// Benchmark page that renders a grid of N icons with each approach.
class GridBenchPage extends HookWidget {
  const GridBenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = useMemoized(_getIconDataList);
    final activeTab = useState(0);
    final gridCountIndex = useState(1); // default 30
    final gridCount = _gridCounts[gridCountIndex.value];

    final runtimeTimer = useFrameTimer(maxFrames: 60);
    final precomputedTimer = useFrameTimer(maxFrames: 60);

    // Force rebuilds to generate frame timings when collecting.
    final rebuildTicker = useState(0);
    useEffect(
      () {
        if (runtimeTimer.isCollecting || precomputedTimer.isCollecting) {
          void scheduleRebuild() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (runtimeTimer.isCollecting ||
                  precomputedTimer.isCollecting) {
                rebuildTicker.value++;
                scheduleRebuild();
              }
            });
          }

          scheduleRebuild();
        }
        return null;
      },
      [runtimeTimer.isCollecting, precomputedTimer.isCollecting],
    );

    rebuildTicker.value;

    if (icons.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grid Bench')),
        body: const Center(child: Text('No icon data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Grid Bench')),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Runtime')),
                    ButtonSegment(value: 1, label: Text('Pre-computed')),
                  ],
                  selected: {activeTab.value},
                  onSelectionChanged: (selected) {
                    activeTab.value = selected.first;
                    runtimeTimer.reset();
                    precomputedTimer.reset();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Icons: '),
                    Expanded(
                      child: Slider(
                        value: gridCountIndex.value.toDouble(),
                        max: (_gridCounts.length - 1).toDouble(),
                        divisions: _gridCounts.length - 1,
                        label: '$gridCount',
                        onChanged: (value) {
                          gridCountIndex.value = value.round();
                          runtimeTimer.reset();
                          precomputedTimer.reset();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$gridCount',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        if (activeTab.value == 0) {
                          runtimeTimer.startCollecting();
                        } else {
                          precomputedTimer.startCollecting();
                        }
                      },
                      child: Text(
                        _collectButtonLabel(
                          activeTab.value == 0
                              ? runtimeTimer
                              : precomputedTimer,
                          activeTab.value == 0 ? 'Runtime' : 'Pre-computed',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: activeTab.value == 0
                          ? runtimeTimer.reset
                          : precomputedTimer.reset,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: activeTab.value == 0
                ? _RuntimeGrid(icons: icons, count: gridCount)
                : _PrecomputedGrid(icons: icons, count: gridCount),
          ),
          // Stats
          SingleChildScrollView(
            child: activeTab.value == 0
                ? FrameTimingStatsCard(
                    title: 'Runtime ($gridCount icons)',
                    stats: runtimeTimer.stats,
                  )
                : FrameTimingStatsCard(
                    title: 'Pre-computed ($gridCount icons)',
                    stats: precomputedTimer.stats,
                  ),
          ),
        ],
      ),
    );
  }

  String _collectButtonLabel(
    ({
      FrameTimingStats stats,
      List<dynamic> timings,
      VoidCallback reset,
      bool isCollecting,
      VoidCallback startCollecting,
      VoidCallback stopCollecting,
    }) timer,
    String label,
  ) {
    if (timer.isCollecting) {
      return 'Collecting... (${timer.timings.length}/60)';
    }
    return 'Measure $label';
  }
}

class _RuntimeGrid extends HookWidget {
  const _RuntimeGrid({required this.icons, required this.count});

  final List<WiredSvgIconData> icons;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final data = _iconAt(icons, index);
        return WiredSvgIcon(data: data, size: 40);
      },
    );
  }
}

class _PrecomputedGrid extends HookWidget {
  const _PrecomputedGrid({required this.icons, required this.count});

  final List<WiredSvgIconData> icons;
  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final data = _iconAt(icons, index);
        return PrecomputedIcon(data: data, size: 40);
      },
    );
  }
}
