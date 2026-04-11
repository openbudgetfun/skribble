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

/// Icon data for a given index, cycling through available icons.
WiredSvgIconData _iconAt(List<WiredSvgIconData> icons, int index) {
  return icons[index % icons.length];
}

/// Icon label names, cycling through the custom icons.
const _iconNames = [
  'home', 'search', 'settings', 'star', 'heart',
  'user', 'menu', 'close', 'check', 'plus',
  'minus', 'arrow_left', 'arrow_right', 'arrow_up', 'arrow_down',
  'edit', 'delete', 'share', 'copy', 'mail',
  'phone', 'camera', 'image', 'calendar', 'clock',
  'lock', 'unlock', 'eye', 'eye_off', 'notification',
];

const _itemCount = 500;

/// Benchmark page with a scrolling list of 500 icon+text items.
class ScrollBenchPage extends HookWidget {
  const ScrollBenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = useMemoized(_getIconDataList);
    final activeTab = useState(0);

    final runtimeTimer = useFrameTimer();
    final precomputedTimer = useFrameTimer();

    if (icons.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scroll Bench')),
        body: const Center(child: Text('No icon data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Bench'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: activeTab.value == 0
                ? 'Measure Runtime'
                : 'Measure Pre-computed',
            onPressed: () {
              if (activeTab.value == 0) {
                runtimeTimer.startCollecting();
              } else {
                precomputedTimer.startCollecting();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: 'Stop',
            onPressed: () {
              runtimeTimer.stopCollecting();
              precomputedTimer.stopCollecting();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              runtimeTimer.reset();
              precomputedTimer.reset();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Runtime')),
                    ButtonSegment(value: 1, label: Text('Pre-computed')),
                  ],
                  selected: {activeTab.value},
                  onSelectionChanged: (selected) {
                    activeTab.value = selected.first;
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  _statusText(
                    activeTab.value == 0 ? runtimeTimer : precomputedTimer,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Scrollable list
          Expanded(
            child: activeTab.value == 0
                ? _RuntimeList(icons: icons)
                : _PrecomputedList(icons: icons),
          ),
          // Stats
          SingleChildScrollView(
            child: activeTab.value == 0
                ? FrameTimingStatsCard(
                    title: 'Runtime (scroll)',
                    stats: runtimeTimer.stats,
                  )
                : FrameTimingStatsCard(
                    title: 'Pre-computed (scroll)',
                    stats: precomputedTimer.stats,
                  ),
          ),
        ],
      ),
    );
  }

  String _statusText(
    ({
      FrameTimingStats stats,
      List<dynamic> timings,
      VoidCallback reset,
      bool isCollecting,
      VoidCallback startCollecting,
      VoidCallback stopCollecting,
    }) timer,
  ) {
    if (timer.isCollecting) {
      return 'Collecting frame timings... '
          '(${timer.timings.length}/120) - scroll now!';
    }
    if (timer.stats.frameCount > 0) {
      return '${timer.stats.frameCount} frames collected. '
          'Tap play to re-measure.';
    }
    return 'Tap play, then scroll to collect frame timings.';
  }
}

class _RuntimeList extends HookWidget {
  const _RuntimeList({required this.icons});

  final List<WiredSvgIconData> icons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _itemCount,
      itemBuilder: (context, index) {
        final data = _iconAt(icons, index);
        final name = _iconNames[index % _iconNames.length];
        return ListTile(
          leading: WiredSvgIcon(data: data, size: 32),
          title: Text('$name (item $index)'),
          subtitle: const Text('Runtime roughened'),
        );
      },
    );
  }
}

class _PrecomputedList extends HookWidget {
  const _PrecomputedList({required this.icons});

  final List<WiredSvgIconData> icons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _itemCount,
      itemBuilder: (context, index) {
        final data = _iconAt(icons, index);
        final name = _iconNames[index % _iconNames.length];
        return ListTile(
          leading: PrecomputedIcon(data: data, size: 32),
          title: Text('$name (item $index)'),
          subtitle: const Text('Pre-computed paths'),
        );
      },
    );
  }
}
