import 'dart:ui';

import '../rough/skribble_rough.dart';

abstract class WiredPainterBase {
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  );
}
