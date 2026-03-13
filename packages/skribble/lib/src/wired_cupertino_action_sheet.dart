import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A hand-drawn action sheet corresponding to [CupertinoActionSheet].
///
/// Provides the same title/message/actions/cancelButton API as
/// [CupertinoActionSheet] with sketchy hand-drawn rounded rectangle
/// borders.
class WiredCupertinoActionSheet extends HookWidget {
  /// The optional title at the top of the action sheet.
  final Widget? title;

  /// Optional descriptive message below the title.
  final Widget? message;

  /// The action buttons.
  final List<Widget> actions;

  /// The cancel button at the bottom, separated by a gap.
  final Widget? cancelButton;

  /// Scroll controller for the actions list.
  final ScrollController? actionScrollController;

  /// Scroll controller for the message section.
  final ScrollController? messageScrollController;

  const WiredCupertinoActionSheet({
    super.key,
    this.title,
    this.message,
    this.actions = const [],
    this.cancelButton,
    this.actionScrollController,
    this.messageScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main section: title + message + actions
              Stack(
                children: [
                  Positioned.fill(
                    child: WiredCanvas(
                      painter: WiredRoundedRectangleBase(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      fillerType: RoughFilter.noFiller,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title + message
                        if (title != null || message != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (title != null)
                                  DefaultTextStyle(
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    child: title!,
                                  ),
                                if (title != null && message != null)
                                  const SizedBox(height: 4),
                                if (message != null)
                                  DefaultTextStyle(
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.6),
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                    child: message!,
                                  ),
                              ],
                            ),
                          ),
                        // Separator before actions
                        if ((title != null || message != null) &&
                            actions.isNotEmpty)
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
                        // Action buttons
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0)
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
                          actions[i],
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              // Cancel button
              if (cancelButton != null) ...[
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Positioned.fill(
                      child: WiredCanvas(
                        painter: WiredRoundedRectangleBase(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: cancelButton,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An action button for [WiredCupertinoActionSheet],
/// corresponding to [CupertinoActionSheetAction].
class WiredCupertinoActionSheetAction extends HookWidget {
  /// The label of the action.
  final Widget child;

  /// Called when the action is tapped.
  final VoidCallback onPressed;

  /// Whether this is the default (bold) action.
  final bool isDefaultAction;

  /// Whether this is a destructive (red) action.
  final bool isDestructiveAction;

  const WiredCupertinoActionSheetAction({
    super.key,
    required this.child,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: isDestructiveAction
                  ? Colors.red
                  : CupertinoColors.activeBlue,
              fontSize: 20,
              fontWeight: isDefaultAction ? FontWeight.w600 : FontWeight.w400,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Shows a [WiredCupertinoActionSheet] as a modal bottom sheet.
Future<T?> showWiredCupertinoActionSheet<T>({
  required BuildContext context,
  Widget? title,
  Widget? message,
  List<Widget> actions = const [],
  Widget? cancelButton,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => WiredCupertinoActionSheet(
      title: title,
      message: message,
      actions: actions,
      cancelButton: cancelButton,
    ),
  );
}
