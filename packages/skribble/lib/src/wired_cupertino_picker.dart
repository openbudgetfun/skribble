import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn picker wheel, corresponding to Flutter's [CupertinoPicker].
///
/// Wraps [CupertinoPicker] with a sketchy border and selection highlight.
/// Supports mouse dragging as well as the surrounding scroll policy's input
/// devices. Labels use the Wired theme's font family and roughness variant;
/// explicit text styles on children still take precedence.
class WiredCupertinoPicker extends HookWidget {
  /// The list of items to display in the picker.
  final List<Widget> children;

  /// Called when the selected item changes.
  final ValueChanged<int> onSelectedItemChanged;

  /// Height of each item in the picker.
  final double itemExtent;

  /// Total height of the picker widget.
  final double height;

  /// Initial selected item index.
  final int initialItem;

  const WiredCupertinoPicker({
    super.key,
    required this.children,
    required this.onSelectedItemChanged,
    this.itemExtent = 40,
    this.height = 200,
    this.initialItem = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final controller = useMemoized(
      () => FixedExtentScrollController(initialItem: initialItem),
    );

    useEffect(() => controller.dispose, [controller]);

    return buildWiredElement(
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  strokeWidth: theme.strokeWidth,
                  borderRadius: BorderRadius.circular(12),
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            // Selection highlight at center
            Center(
              child: SizedBox(
                height: itemExtent,
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            ),
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ...ScrollConfiguration.of(context).dragDevices,
                  PointerDeviceKind.mouse,
                },
              ),
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: itemExtent,
                onSelectedItemChanged: onSelectedItemChanged,
                selectionOverlay: const SizedBox.shrink(),
                backgroundColor: const Color(0x00000000),
                children: [
                  for (final child in children)
                    Center(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 16,
                          // Qualify the family without inheriting a package
                          // prefix into a child's explicit custom font.
                          fontFamily: TextStyle(
                            fontFamily: theme.fontFamily,
                            package: theme.fontPackage,
                          ).fontFamily,
                        ),
                        child: child,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
