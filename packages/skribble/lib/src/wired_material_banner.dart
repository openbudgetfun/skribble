import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A hand-drawn banner corresponding to Flutter's [MaterialBanner].
///
/// Displays a persistent message at the top of the screen with
/// sketchy hand-drawn borders and optional actions.
class WiredMaterialBanner extends HookWidget {
  /// The content of the banner.
  final Widget content;

  /// The leading widget, typically an [Icon] or a WiredAvatar.
  final Widget? leading;

  /// Action buttons at the end of the banner.
  final List<Widget> actions;

  /// Background color of the banner.
  final Color? backgroundColor;

  /// Content text style.
  final TextStyle? contentTextStyle;

  /// Padding around the content.
  final EdgeInsetsGeometry? padding;

  /// Padding around the leading widget.
  final EdgeInsetsGeometry? leadingPadding;

  /// Whether to force actions below the content.
  final bool forceActionsBelow;

  /// Called when the banner is dismissed via overscroll.
  final VoidCallback? onVisible;

  const WiredMaterialBanner({
    super.key,
    required this.content,
    this.leading,
    this.actions = const [],
    this.backgroundColor,
    this.contentTextStyle,
    this.padding,
    this.leadingPadding,
    this.forceActionsBelow = false,
    this.onVisible,
  });

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      onVisible?.call();
      return null;
    }, const []);

    final bgColor = backgroundColor ?? filledColor;

    return buildWiredElement(
      child: Stack(
        children: [
          // Sketchy border
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRectangleBase(fillColor: bgColor),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Container(
            color: bgColor.withValues(alpha: 0.95),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildLayout(),
          ),
          // Bottom border line
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 3,
            child: WiredCanvas(
              painter: WiredLineBase(x1: 0, y1: 1, x2: double.maxFinite, y2: 1),
              fillerType: RoughFilter.noFiller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    if (forceActionsBelow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null)
                Padding(
                  padding: leadingPadding ?? const EdgeInsets.only(right: 16),
                  child: leading,
                ),
              Expanded(
                child: DefaultTextStyle(
                  style:
                      contentTextStyle ??
                      const TextStyle(color: textColor, fontSize: 14),
                  child: content,
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        if (leading != null)
          Padding(
            padding: leadingPadding ?? const EdgeInsets.only(right: 16),
            child: leading,
          ),
        Expanded(
          child: DefaultTextStyle(
            style:
                contentTextStyle ??
                const TextStyle(color: textColor, fontSize: 14),
            child: content,
          ),
        ),
        if (actions.isNotEmpty) ...actions,
      ],
    );
  }
}

/// Shows a [WiredMaterialBanner] using [ScaffoldMessenger].
ScaffoldFeatureController<MaterialBanner, MaterialBannerClosedReason>
showWiredMaterialBanner(
  BuildContext context, {
  required Widget content,
  Widget? leading,
  List<Widget> actions = const [],
  Color? backgroundColor,
  VoidCallback? onVisible,
}) {
  return ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: const SizedBox.shrink(),
      actions: const [SizedBox.shrink()],
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      overflowAlignment: OverflowBarAlignment.end,
    ),
  );
}
