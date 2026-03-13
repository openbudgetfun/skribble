import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

class WiredProgress extends HookWidget {
  final double value;
  final AnimationController controller;

  static const double _progressHeight = 20.0;

  const WiredProgress({super.key, required this.controller, this.value = 0.0});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final tween = useMemoized(() => Tween<double>(begin: 0, end: 1));
    final animation = useAnimation(
      tween.animate(CurvedAnimation(parent: controller, curve: Curves.easeIn)),
    );
    final width = useState<double>(0.0);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.findRenderObject() != null) {
          final box = context.findRenderObject()! as RenderBox;
          width.value = box.size.width;
          tween.begin = value;
        }
      });
      return null;
    }, const []);

    return buildWiredElement(
      child: Stack(
        children: [
          SizedBox(
            height: _progressHeight,
            width: width.value * animation,
            child: WiredCanvas(
              painter: WiredRectangleBase(fillColor: theme.borderColor),
              fillerType: RoughFilter.hachureFiller,
              fillerConfig: FillerConfig.build(hachureGap: 1.5),
            ),
          ),
          SizedBox(
            height: _progressHeight,
            width: width.value,
            child: WiredCanvas(
              painter: WiredRectangleBase(),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: _progressHeight,
            color: Colors.transparent,
            value: animation,
          ),
        ],
      ),
    );
  }
}
