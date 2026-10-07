import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

import '../reel_kit.dart';

/// "Drawn by a pen": a pencil draws an app outline by outline, the camera
/// leans in on the ink, then the same controls are shown at three
/// roughnesses and on night paper. 22 seconds.
class DrawnByAPenReel extends StatelessWidget {
  /// Draws the reel at [time] seconds.
  const DrawnByAPenReel({required this.time, super.key});

  /// Seconds since the reel began.
  final double time;

  /// How long the reel runs.
  static const Duration duration = Duration(seconds: 22);

  @override
  Widget build(BuildContext context) {
    final t = time;
    final night = t < 18.2 ? span(t, 15, 15.8) : 1 - span(t, 18, 18.6);
    final day = WiredThemeData.cuddly();
    final dark = WiredThemeData.cuddly(brightness: Brightness.dark);
    return ReelStage(
      theme: night >= .5 ? dark : day,
      paper: Color.lerp(day.fillColor, dark.fillColor, night),
      child: Builder(
        builder: (context) {
          final portrait = isPortrait(context);
          final size = portrait ? 48.0 : 52.0;
          final caption = Stack(
            alignment: Alignment.center,
            children: [
              Scene(t, .3, 3.3, child: Caption(['Every border,'], size: size)),
              Scene(
                t,
                3.2,
                4.9,
                child: Caption(['every control,'], size: size),
              ),
              Scene(t, 4.8, 6.4, child: Caption(['every emoji,'], size: size)),
              Scene(
                t,
                6.3,
                8.2,
                child: Caption([
                  'drawn live\nby a ',
                  MarkerWord('pen.', progress: ease(span(t, 6.8, 7.4))),
                ], size: size),
              ),
              Scene(
                t,
                8.1,
                11.6,
                child: Caption([
                  'Ink that ',
                  MarkerWord('tapers', progress: ease(span(t, 8.8, 9.3))),
                  ' and ',
                  MarkerWord('swells', progress: ease(span(t, 9.4, 9.9))),
                  ', like a real pen.',
                ], size: size * .82),
              ),
              Scene(
                t,
                15.2,
                18.4,
                child: Caption([
                  'Day paper.\n',
                  MarkerWord('Night ink.', progress: ease(span(t, 16.2, 16.8))),
                ], size: size),
              ),
            ],
          );
          final zoom = ease(span(t, 8.2, 9.2)) - ease(span(t, 11, 11.6));
          final visual = ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Scene(
                  t,
                  .6,
                  11.8,
                  child: FittedBox(
                    child: Transform(
                      transform: _zoomOn(_button.center, zoom),
                      child: _PenFrame(t, drawn: false),
                    ),
                  ),
                ),
                Scene(
                  t,
                  15.2,
                  18.4,
                  child: FittedBox(child: _PenFrame(t, drawn: true)),
                ),
              ],
            ),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              if (t < 18.6)
                Padding(
                  padding: portrait
                      ? const EdgeInsets.fromLTRB(30, 70, 30, 50)
                      : const EdgeInsets.fromLTRB(50, 36, 36, 36),
                  child: portrait
                      ? Column(
                          children: [
                            SizedBox(height: 210, child: caption),
                            const SizedBox(height: 10),
                            Expanded(child: visual),
                          ],
                        )
                      : Row(
                          children: [
                            SizedBox(width: 400, child: caption),
                            const SizedBox(width: 30),
                            Expanded(child: visual),
                          ],
                        ),
                ),
              Scene(
                t,
                11.6,
                15.3,
                child: Padding(
                  padding: portrait
                      ? const EdgeInsets.fromLTRB(30, 70, 30, 50)
                      : const EdgeInsets.fromLTRB(40, 40, 40, 36),
                  child: Column(
                    children: [
                      SizedBox(
                        height: portrait ? 210 : 120,
                        child: Center(
                          child: Caption([
                            if (portrait)
                              'Gentle, playful,\nor '
                            else
                              'Gentle, playful, or ',
                            MarkerWord(
                              'expressive.',
                              progress: ease(span(t, 13.2, 13.8)),
                            ),
                          ], size: size * .9),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: _Trio(t, portrait: portrait)),
                    ],
                  ),
                ),
              ),
              Scene(t, 18.4, 22.4, child: EndCard(t, 18.5)),
            ],
          );
        },
      ),
    );
  }
}

/// The frame is laid out in a fixed 400 by 600 space; [FittedBox] scales it.
const Size _frame = Size(400, 600);
const Rect _avatar = Rect.fromLTWH(22, 22, 60, 60);
const Rect _input = Rect.fromLTWH(22, 104, 356, 52);
const Rect _list = Rect.fromLTWH(22, 172, 356, 164);
const Rect _switch = Rect.fromLTWH(306, 352, 72, 34);
const Rect _slider = Rect.fromLTWH(22, 404, 356, 44);
const Rect _button = Rect.fromLTWH(22, 470, 190, 56);

/// Leans in on [focus] by [amount] (0 to 1): it slides to the frame's centre
/// as the frame grows almost three times larger.
Matrix4 _zoomOn(Offset focus, double amount) {
  final centre = _frame.center(Offset.zero);
  final point = Offset.lerp(centre, focus, amount)!;
  final scale = 1 + 1.9 * amount;
  return Matrix4.identity()
    ..translateByDouble(centre.dx, centre.dy, 0, 1)
    ..scaleByDouble(scale, scale, 1, 1)
    ..translateByDouble(-point.dx, -point.dy, 0, 1);
}

/// Each outline and the seconds the pen spends on it.
const List<(Rect, double, double)> _strokes = [
  (Rect.fromLTWH(0, 0, 400, 600), 1.0, 2.4),
  (_avatar, 2.4, 2.9),
  (_input, 3.3, 3.9),
  (_list, 3.9, 4.8),
  (_switch, 4.8, 5.2),
  (_slider, 5.2, 5.7),
  (_button, 5.7, 6.2),
];

class _PenFrame extends StatelessWidget {
  const _PenFrame(this.t, {required this.drawn});

  final double t;

  /// Whether to show everything already drawn, with no pen.
  final bool drawn;

  double _progress(int index) {
    if (drawn) return 1;
    final (_, start, end) = _strokes[index];
    return ease(span(t, start, end));
  }

  Offset? _tip() {
    if (drawn) return null;
    for (final (rect, start, end) in _strokes) {
      if (t >= start && t <= end) {
        // The outline finishes at 65% of a draw transition.
        final p = (ease(span(t, start, end)) / .65).clamp(0.0, 1.0);
        if (rect == _avatar) {
          final angle = -math.pi / 2 + p * math.pi * 2;
          return rect.center + Offset(math.cos(angle), math.sin(angle)) * 30;
        }
        return aroundRect(rect, p);
      }
    }
    // Writing the greeting.
    if (t > 2.9 && t < 3.3) return Offset(96 + 170 * span(t, 2.9, 3.3), 52);
    // Lifting off the page.
    if (t > 6.2 && t < 6.9) {
      return Offset.lerp(
        _button.bottomRight,
        const Offset(470, 700),
        easeOut(span(t, 6.2, 6.9)),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    // Ink leads: what sits inside an outline fades in as the pen starts it.
    Widget draw(int index, Widget child) => Opacity(
      opacity: math.min(1, _progress(index) * 4),
      child: WiredDrawTransition(
        progress: AlwaysStoppedAnimation(_progress(index)),
        child: child,
      ),
    );
    final tip = _tip();
    final text = drawn ? 1.0 : span(t, 2.9, 3.3);
    return SizedBox.fromSize(
      size: _frame,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: draw(
              0,
              const WiredCard(height: null, child: SizedBox.expand()),
            ),
          ),
          Positioned.fromRect(
            rect: _avatar,
            child: draw(
              1,
              const WiredAvatar(
                radius: 30,
                child: WiredEmoji('🦊', size: 38),
              ),
            ),
          ),
          Positioned(
            left: 98,
            top: 26,
            child: Opacity(
              opacity: text,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WiredEmojiText(
                    'Hi, Sam 👋',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Three little things today',
                    style: TextStyle(
                      fontSize: 17,
                      color: theme.disabledTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fromRect(
            rect: _input,
            child: draw(2, const WiredInput(hintText: 'Add a plan…')),
          ),
          Positioned.fromRect(
            rect: _list,
            child: draw(
              3,
              WiredCard(
                height: null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      for (final (emoji, label, done) in const [
                        ('☕', 'Slow coffee', true),
                        ('📚', 'Read a chapter', false),
                        ('🚲', 'Ride to the park', false),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              WiredCheckbox(value: done, onChanged: (_) {}),
                              const SizedBox(width: 12),
                              WiredEmojiText(
                                '$emoji  $label',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            top: 354,
            child: Opacity(
              opacity: drawn ? 1 : span(t, 4.8, 5.1),
              child: const WiredEmojiText(
                'Golden hour 🌇',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Positioned.fromRect(
            rect: _switch,
            child: draw(4, WiredSwitch(value: true, onChanged: (_) {})),
          ),
          Positioned.fromRect(
            rect: _slider,
            child: draw(5, WiredSlider(value: .62, onChanged: (_) => true)),
          ),
          Positioned(
            left: _button.left,
            top: _button.top,
            child: draw(
              6,
              WiredButton(
                onPressed: () {},
                child: const WiredEmojiText(
                  'All done ✅',
                  style: TextStyle(fontSize: 21),
                ),
              ),
            ),
          ),
          if (tip != null) Pencil(tip: tip, size: 110),
        ],
      ),
    );
  }
}

/// The same small controls at each roughness.
class _Trio extends StatelessWidget {
  const _Trio(this.t, {required this.portrait});

  final double t;
  final bool portrait;

  @override
  Widget build(BuildContext context) {
    final panels = [
      for (final (index, level) in WiredRoughness.values.indexed)
        WiredTheme(
          data: WiredThemeData.cuddly(roughnessLevel: level),
          child: WiredDrawTransition(
            progress: AlwaysStoppedAnimation(
              ease(span(t, 11.9 + index * .45, 12.9 + index * .45)),
            ),
            child: SizedBox(
              width: 250,
              child: WiredCard(
                height: null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        switch (level) {
                          WiredRoughness.gentle => 'Gentle',
                          WiredRoughness.playful => 'Playful',
                          WiredRoughness.expressive => 'Expressive',
                        },
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          WiredCheckbox(value: true, onChanged: (_) {}),
                          const SizedBox(width: 10),
                          const Text('Inked', style: TextStyle(fontSize: 19)),
                          const Spacer(),
                          WiredSwitch(value: true, onChanged: (_) {}),
                        ],
                      ),
                      const SizedBox(height: 8),
                      WiredSlider(value: .55, onChanged: (_) => true),
                      const SizedBox(height: 8),
                      WiredButton(
                        onPressed: () {},
                        child: const Text('Press me'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    return FittedBox(
      child: portrait
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final panel in panels) ...[
                  panel,
                  const SizedBox(height: 18),
                ],
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final panel in panels) ...[
                  panel,
                  const SizedBox(width: 18),
                ],
              ],
            ),
    );
  }
}
