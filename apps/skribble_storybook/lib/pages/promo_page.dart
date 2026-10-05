import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/promo/promo_reel.dart';

/// Plays skribble's promotional reel on a loop, scaled to fit the screen.
class PromoPage extends HookWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clock = useAnimationController(duration: kPromoDuration);
    useEffect(() {
      clock.repeat();
      return null;
    }, [clock]);
    final seconds =
        kPromoDuration.inMicroseconds / Duration.microsecondsPerSecond;
    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('The reel'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: FittedBox(
            child: SizedBox.square(
              dimension: 540,
              child: AnimatedBuilder(
                animation: clock,
                builder: (context, _) => PromoReel(time: clock.value * seconds),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
