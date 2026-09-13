import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Drives the thumb travel shared by `WiredSwitch` and
/// `WiredCupertinoSwitch`.
///
/// Internal to the library and deliberately not exported from the package
/// barrel. The returned value moves from [begin] to [end] when [value]
/// flips, using the 200ms ease-in-out curve both switches use.
double useWiredThumbOffset({
  required bool value,
  required double begin,
  required double end,
}) {
  final controller = useAnimationController(
    duration: const Duration(milliseconds: 200),
    initialValue: value ? 1.0 : 0.0,
  );
  final animation = useAnimation(
    Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    ),
  );

  useEffect(() {
    unawaited(value ? controller.forward() : controller.reverse());
    return null;
  }, [value]);

  return animation;
}
