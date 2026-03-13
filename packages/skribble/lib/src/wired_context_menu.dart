import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn context menu, corresponding to [CupertinoContextMenu].
///
/// Shows a set of action items in a hand-drawn overlay when long-pressed.
class WiredContextMenu extends HookWidget {
  /// The widget that triggers the context menu on long press.
  final Widget child;

  /// The action items shown in the context menu.
  final List<WiredContextMenuAction> actions;

  const WiredContextMenu({
    super.key,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: GestureDetector(
        onLongPress: () => _showMenu(context),
        child: child,
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _WiredContextMenuOverlay(
        position: offset,
        childSize: renderBox.size,
        actions: actions,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _WiredContextMenuOverlay extends StatelessWidget {
  final Offset position;
  final Size childSize;
  final List<WiredContextMenuAction> actions;
  final VoidCallback onDismiss;

  const _WiredContextMenuOverlay({
    required this.position,
    required this.childSize,
    required this.actions,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final menuTop = position.dy + childSize.height + 8;
    final menuLeft = position.dx;

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black26,
        child: Stack(
          children: [
            Positioned(
              left: menuLeft,
              top: menuTop,
              child: SizedBox(
                width: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: WiredCanvas(
                        painter: WiredRoundedRectangleBase(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < actions.length; i++) ...[
                            InkWell(
                              onTap: () {
                                onDismiss();
                                actions[i].onPressed?.call();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    if (actions[i].icon != null) ...[
                                      Icon(
                                        actions[i].icon,
                                        size: 18,
                                        color: actions[i].isDestructive
                                            ? Colors.red
                                            : textColor,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Text(
                                        actions[i].label,
                                        style: TextStyle(
                                          color: actions[i].isDestructive
                                              ? Colors.red
                                              : textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i < actions.length - 1)
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An action item for [WiredContextMenu].
class WiredContextMenuAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const WiredContextMenuAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  });
}
