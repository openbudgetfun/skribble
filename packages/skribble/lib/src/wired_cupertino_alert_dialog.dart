import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A hand-drawn alert dialog corresponding to [CupertinoAlertDialog].
///
/// Provides the same title/content/actions API as [CupertinoAlertDialog]
/// with a sketchy hand-drawn rounded rectangle border.
class WiredCupertinoAlertDialog extends HookWidget {
  /// The title of the dialog.
  final Widget? title;

  /// The content of the dialog, typically descriptive text.
  final Widget? content;

  /// The action buttons at the bottom of the dialog.
  final List<Widget> actions;

  /// Scroll controller for the content.
  final ScrollController? scrollController;

  /// Scroll controller for the actions.
  final ScrollController? actionScrollController;

  const WiredCupertinoAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
    this.scrollController,
    this.actionScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 270, minWidth: 270),
          child: Stack(
            children: [
              // Sketchy border
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              // Content
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title + content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            DefaultTextStyle(
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              child: title!,
                            ),
                          if (title != null && content != null)
                            const SizedBox(height: 4),
                          if (content != null)
                            DefaultTextStyle(
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              child: content!,
                            ),
                        ],
                      ),
                    ),
                    // Separator
                    if (actions.isNotEmpty)
                      SizedBox(
                        height: 2,
                        child: WiredCanvas(
                          painter: WiredLineBase(
                            x1: 0,
                            y1: 1,
                            x2: double.maxFinite,
                            y2: 1,
                          ),
                          fillerType: RoughFilter.noFiller,
                        ),
                      ),
                    // Actions
                    if (actions.isNotEmpty)
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            for (var i = 0; i < actions.length; i++) ...[
                              if (i > 0)
                                SizedBox(
                                  width: 2,
                                  child: WiredCanvas(
                                    painter: WiredLineBase(
                                      x1: 1,
                                      y1: 0,
                                      x2: 1,
                                      y2: double.maxFinite,
                                    ),
                                    fillerType: RoughFilter.noFiller,
                                  ),
                                ),
                              Expanded(child: actions[i]),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dialog action button corresponding to [CupertinoDialogAction].
///
/// Provides a tappable action button within [WiredCupertinoAlertDialog].
class WiredCupertinoDialogAction extends StatelessWidget {
  /// The label of the action.
  final Widget child;

  /// Called when the action is tapped.
  final VoidCallback? onPressed;

  /// Whether this is the default (bold) action.
  final bool isDefaultAction;

  /// Whether this is a destructive (red) action.
  final bool isDestructiveAction;

  const WiredCupertinoDialogAction({
    super.key,
    required this.child,
    this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: isDestructiveAction
                  ? Colors.red
                  : CupertinoColors.activeBlue,
              fontSize: 17,
              fontWeight: isDefaultAction ? FontWeight.w600 : FontWeight.w400,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Shows a [WiredCupertinoAlertDialog] as a modal dialog.
Future<T?> showWiredCupertinoDialog<T>({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget> actions = const [],
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => WiredCupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions,
    ),
  );
}
