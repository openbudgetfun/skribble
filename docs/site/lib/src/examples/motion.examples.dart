part of 'catalog.dart';

/// @docs-example ink-reveal
Widget _inkReveal(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final replay = useState(0);
    return Column(
      children: [
        WiredDraw(
          key: ValueKey(replay.value),
          child: WiredCard(child: Text(settings.label)),
        ),
        const SizedBox(height: 16),
        WiredOutlinedButton(
          onPressed: () => replay.value++,
          child: const Text('Draw again'),
        ),
      ],
    );
  },
);

/// @docs-example ink-progress
Widget _inkProgress(ExampleSettings settings) => WiredDrawTransition(
  progress: AlwaysStoppedAnimation(settings.amount),
  child: WiredCard(child: Text(settings.label)),
);
