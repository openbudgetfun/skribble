import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Every bundled doodle and fill pattern with stable, changeable seeds.
class WiredDrawingPage extends HookWidget {
  /// Creates the drawing gallery.
  const WiredDrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = useState(1);
    return WiredScaffold(
      appBar: WiredAppBar(title: const Text('Doodles and fills')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          WiredButton(
            onPressed: () => seed.value++,
            child: const Text('Draw another'),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final kind in WiredDoodleKind.values)
                SizedBox(
                  width: 160,
                  child: Column(
                    children: [
                      WiredDraw(
                        key: ValueKey((kind, seed.value)),
                        child: WiredDoodle(
                          kind: kind,
                          seed: seed.value,
                          size: 140,
                          fillColor: WiredPalette.peach,
                          semanticLabel: kind.name,
                        ),
                      ),
                      Text(kind.name),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Every fill pattern'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final fill in RoughFilter.values)
                Column(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 100,
                      child: WiredCanvas(
                        drawConfig: WiredTheme.of(context).drawConfig
                            .copyWith(seed: seed.value),
                        painter: WiredRoundedRectangleBase(
                          borderRadius: BorderRadius.circular(12),
                          borderColor: WiredTheme.of(context).borderColor,
                          fillColor: WiredPalette.peach,
                        ),
                        fillerType: fill,
                      ),
                    ),
                    Text(fill.name),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
