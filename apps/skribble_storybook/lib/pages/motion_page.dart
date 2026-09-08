import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

import '../testing/motion_keys.dart';

/// An interactive pen study driven entirely by standard Flutter animations.
class WiredMotionPage extends StatefulWidget {
  const WiredMotionPage({super.key});

  @override
  State<WiredMotionPage> createState() => _WiredMotionPageState();
}

class _WiredMotionPageState extends State<WiredMotionPage>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
    value: 1,
  );
  late final Animation<double> _ink = _controller.drive(
    CurveTween(curve: Curves.easeInOutCubic),
  );
  bool _enabled = true;
  bool _slow = false;
  int _notes = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final systemReduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final motion = _enabled && !systemReduced;
    return WiredMotion(
      enabled: _enabled,
      child: WiredScaffold(
        appBar: WiredAppBar(title: const Text('Ink in motion')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PEN STUDY / 01',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: theme.borderColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    key: MotionKeys.title,
                    'A little ink,\na little life.',
                    style: TextStyle(
                      fontSize: 42,
                      height: 1.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Watch the outline find its way. Then the shading settles in.',
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 28),
                  RepaintBoundary(
                    key: MotionKeys.preview,
                    child: WiredDrawTransition(
                      progress: _ink,
                      child: SizedBox(
                        width: double.infinity,
                        child: WiredCard(
                          height: null,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final paper = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'a note to your future self',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 18),
                                    const Text(
                                      'Make something\nworth keeping.',
                                      style: TextStyle(
                                        fontSize: 30,
                                        height: 1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Small ideas deserve a good beginning.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 20),
                                    WiredFilledButton(
                                      key: MotionKeys.action,
                                      onPressed: () => setState(() {
                                        _notes++;
                                      }),
                                      child: const Text('Keep this idea'),
                                    ),
                                  ],
                                );
                                final swatches = SizedBox(
                                  width: 190,

                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 136,
                                        child: WiredCanvas(
                                          painter: WiredCircleBase(
                                            borderColor: theme.borderColor,
                                            fillColor: const Color(0xffd69b35),
                                            strokeWidth: 3,
                                          ),
                                          fillerType: RoughFilter.hatchFiller,
                                          fillerConfig: FillerConfig.build(
                                            hachureGap: 7,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'a pocketful of sunshine',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 20,
                                        child: WiredCanvas(
                                          painter: WiredLineBase(
                                            x1: 24,
                                            y1: 10,
                                            x2: 170,
                                            y2: 10,
                                            strokeWidth: 2.4,
                                            borderColor: theme.borderColor,
                                          ),
                                          fillerType: RoughFilter.noFiller,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (constraints.maxWidth < 600) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      paper,
                                      const SizedBox(height: 20),
                                      Center(child: swatches),
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: paper),
                                    const SizedBox(width: 28),
                                    swatches,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      WiredFilledButton(
                        key: MotionKeys.replay,
                        onPressed: motion
                            ? () {
                                _controller.forward(from: 0);
                              }
                            : null,
                        child: const Text('Draw it again'),
                      ),
                      WiredOutlinedButton(
                        key: MotionKeys.reverse,
                        onPressed: motion
                            ? () {
                                _controller.reverse(from: 1);
                              }
                            : null,
                        child: const Text('Unwind the ink'),
                      ),
                      WiredOutlinedButton(
                        key: MotionKeys.half,
                        onPressed: motion
                            ? () {
                                _controller.value = .5;
                              }
                            : null,
                        child: const Text('Hold halfway'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Column(
                      children: [
                        WiredSlider(
                          key: MotionKeys.scrub,
                          value: _controller.value,
                          semanticLabel: 'Pen progress',
                          onChanged: motion
                              ? (value) {
                                  _controller.value = value;
                                  return true;
                                }
                              : null,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            key: MotionKeys.status,
                            !motion
                                ? 'Motion off · every line is complete'
                                : 'Pen ${(100 * _controller.value).round()}% · $_notes ideas kept',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WiredCheckbox(
                            key: MotionKeys.enabled,
                            value: _enabled,
                            onChanged: (value) => setState(() {
                              _enabled = value ?? false;
                              if (value != true) _controller.value = 1;
                            }),
                            semanticLabel: 'Animate ink',
                          ),
                          const SizedBox(width: 8),
                          const Flexible(child: Text('Animate ink')),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WiredCheckbox(
                            key: MotionKeys.slow,
                            value: _slow,
                            onChanged: (value) => setState(() {
                              _slow = value ?? false;
                              _controller.duration = Duration(
                                milliseconds: value == true ? 2400 : 850,
                              );
                            }),
                            semanticLabel: 'Slow pen',
                          ),
                          const SizedBox(width: 8),
                          const Flexible(child: Text('Slow pen')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Press a little harder.',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hover, focus, or press a button. Its pen grows a little bolder, then relaxes. The paper stays still.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 18,
                    runSpacing: 14,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      WiredButton(
                        onPressed: () {},
                        child: const Text('A small hello'),
                      ),
                      WiredElevatedButton(
                        onPressed: () {},
                        child: const Text('Paper & pencil'),
                      ),
                      WiredTextButton(
                        onPressed: () {},
                        child: const Text('One more line'),
                      ),
                      const WiredOutlinedButton(child: Text('Resting pen')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Your timing, your tools.',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use WiredDraw for a one-time entrance, or pass any Animation<double> to WiredDrawTransition. Replay, reverse, stagger, and use your favourite hooks. Reduced-motion settings are respected automatically.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
