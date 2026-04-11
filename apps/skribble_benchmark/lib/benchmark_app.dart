import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:skribble_benchmark/benchmarks/grid_bench.dart';
import 'package:skribble_benchmark/benchmarks/scroll_bench.dart';
import 'package:skribble_benchmark/benchmarks/single_icon_bench.dart';

/// Root widget for the Skribble icon rendering benchmark app.
class BenchmarkApp extends HookWidget {
  const BenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skribble Benchmark',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const _BenchmarkHome(),
    );
  }
}

class _BenchmarkHome extends HookWidget {
  const _BenchmarkHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skribble Benchmarks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Icon Rendering Performance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Compare runtime roughening (WiredSvgIcon) versus '
            'pre-computed path drawing (direct canvas.drawPath).',
          ),
          const SizedBox(height: 24),
          _BenchmarkCard(
            title: 'Single Icon',
            description:
                'Renders one icon with each approach and measures '
                'build + paint time over 100 consecutive frames.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SingleIconBenchPage(),
              ),
            ),
          ),
          _BenchmarkCard(
            title: 'Grid of Icons',
            description:
                'Renders a grid of N icons (10-200) with each approach. '
                'Collects 60 frame timings and reports avg, P95, and '
                'total paint duration.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GridBenchPage(),
              ),
            ),
          ),
          _BenchmarkCard(
            title: 'Scrolling List',
            description:
                'A ListView with 500 icon+text items. Measures frame '
                'times during active scrolling, jank frames, and '
                'avg/P95 durations.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ScrollBenchPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenchmarkCard extends HookWidget {
  const _BenchmarkCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
