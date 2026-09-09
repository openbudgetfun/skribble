import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';

/// A small, working composition that introduces the library through play.
class Playground extends HookWidget {
  /// Creates the homepage's live component composition.
  const Playground({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = useState(false);
    final checked = useState(true);
    final replay = useState(0);
    final narrow = MediaQuery.sizeOf(context).width < 650;
    final note = WiredTheme(
      data: WiredTheme.of(context).copyWith(
        fillColor: const Color(0xffeadbb6),
        borderColor: const Color(0xff6a4e25),
      ),
      child: WiredDraw(
        key: ValueKey(replay.value),
        child: WiredCard(
          height: null,
          fill: true,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A tiny plan for today',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    WiredCheckbox(
                      semanticLabel: 'Make something delightful',
                      value: checked.value,
                      onChanged: (value) => checked.value = value ?? false,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: ExcludeSemantics(
                        child: Text('Make something delightful'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Leave a little room for the unexpected.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                WiredTheme(
                  data: WiredTheme.of(context)
                      .copyWith(fillColor: const Color(0xffe87960)),
                  child: WiredFilledButton(
                    key: DocsKeys.saveIdea,
                    fillColor: const Color(0xffe87960),
                    foregroundColor: const Color(0xff34283f),
                    inkInteraction: WiredInkInteraction.redraw,
                    onPressed: () => saved.value = !saved.value,
                    child: Text(
                      saved.value
                          ? 'Lovely. It’s saved!'
                          : 'Keep this little idea',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A little less perfect.\nA lot more personality.',
            style: TextStyle(
              fontSize: narrow ? 36 : 52,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: narrow ? -1.4 : -1.8,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hand-drawn Flutter components for apps that feel like someone cared.',
            style: TextStyle(
              fontSize: 19,
              height: 1.5,
              color: Color(0xff796c7a),
            ),
          ),
          const SizedBox(height: 32),
          note,
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Real widgets. Go on, try them.',
                  style: TextStyle(fontSize: 12, color: Color(0xff796c7a)),
                ),
              ),
              WiredTextButton(
                key: DocsKeys.replay,
                onPressed: () => replay.value++,
                child: const Text('Draw it again'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Replays ink without removing content or changing the layout.
class MotionPlayground extends HookWidget {
  /// Creates a live, accessible motion example.
  const MotionPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    final replay = useState(0);
    final enabled = useState(true);

    return Column(
      children: [
        WiredMotion(
          enabled: enabled.value,
          child: WiredTheme(
            data: WiredTheme.of(context)
                .copyWith(fillColor: const Color(0xffb6c79b)),
            child: WiredDraw(
              key: ValueKey(replay.value),
              child: const WiredCard(
                fill: true,
                child: Center(
                  child: Text(
                    'Watch the ink find its way.',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            WiredButton(
              onPressed: () => replay.value++,
              child: const Text('Replay the drawing'),
            ),
            WiredCheckbox(
              semanticLabel: 'Allow decorative motion',
              value: enabled.value,
              onChanged: (value) => enabled.value = value ?? false,
            ),
            const ExcludeSemantics(child: Text('Allow decorative motion')),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
