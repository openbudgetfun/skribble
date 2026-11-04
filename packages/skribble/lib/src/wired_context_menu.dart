import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';
import 'wired_theme_scope.dart';

/// A hand-drawn context menu, corresponding to `CupertinoContextMenu`.
///
/// Long-pressing [child], or right-clicking it with a mouse, opens a menu of
/// [actions] on the theme's paper,
/// below the child, or above it when there is no room below. The menu is a
/// modal route: it stays inside the screen's safe area, traps focus, and
/// closes on a tap outside it, the Escape key, or the system back gesture.
/// Activating an action closes the menu, then calls its
/// [WiredContextMenuAction.onPressed].
class WiredContextMenu extends HookWidget {
  /// The widget that triggers the context menu on long press.
  final Widget child;

  /// The action items shown in the context menu.
  final List<WiredContextMenuAction> actions;

  /// Name of the open menu for screen readers. Defaults to `Menu`.
  final String? semanticLabel;

  /// Creates a context menu that opens [actions] when [child] is
  /// long-pressed.
  const WiredContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: GestureDetector(
        onLongPress: () => _showMenu(context),
        // A right-click or a two-finger trackpad tap on desktop and web.
        onSecondaryTap: () => _showMenu(context),
        child: child,
      ),
    );
  }

  void _showMenu(BuildContext context) {
    // The long-press can land after the widget has been unmounted; there is
    // nothing to anchor a menu to in that case.
    if (!context.mounted) return;
    final navigator = Navigator.maybeOf(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (navigator == null ||
        renderBox == null ||
        !renderBox.attached ||
        !renderBox.hasSize) {
      return;
    }
    final overlay = navigator.overlay?.context.findRenderObject() as RenderBox?;
    final anchor =
        renderBox.localToGlobal(Offset.zero, ancestor: overlay) &
        renderBox.size;
    // The route is built under the navigator, above any theme the menu's
    // owner sits in, so it carries that theme along.
    final theme = WiredTheme.of(context);

    navigator.push(
      RawDialogRoute<void>(
        barrierColor: const Color(0x42000000),
        barrierLabel: 'Dismiss menu',
        transitionDuration: const Duration(milliseconds: 150),
        transitionBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        // Routes sit outside the page's text style, so the menu starts a
        // plain one for the theme to fill in.
        pageBuilder: (routeContext, _, _) => DefaultTextStyle(
          style: const TextStyle(fontSize: 14),
          child: WiredThemeScope(
            data: theme,
            child: _WiredContextMenuOverlay(
              anchor: anchor,
              actions: actions,
              semanticLabel: semanticLabel ?? 'Menu',
            ),
          ),
        ),
      ),
    );
  }
}

/// The space kept between the menu and the screen's safe edges.
const double _kScreenMargin = 8;

/// The gap between the long-pressed widget and the menu.
const double _kAnchorGap = 8;

class _WiredContextMenuOverlay extends HookWidget {
  final Rect anchor;
  final List<WiredContextMenuAction> actions;
  final String semanticLabel;

  const _WiredContextMenuOverlay({
    required this.anchor,
    required this.actions,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final safe =
        MediaQuery.paddingOf(context) + MediaQuery.viewInsetsOf(context);

    void activate(WiredContextMenuAction action) {
      Navigator.of(context).pop();
      action.onPressed?.call();
    }

    final menu = Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
        child: IntrinsicWidth(
          child: Stack(
            children: [
              // Paper first, then the ink on top of it, so the hand-drawn
              // edge stays visible in light and dark themes.
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    borderRadius: BorderRadius.circular(12),
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.solidFiller,
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      _WiredContextMenuItem(
                        action: actions[i],
                        autofocus: i == 0,
                        onActivate: () => activate(actions[i]),
                      ),
                      if (i < actions.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: theme.inkExtent,
                            child: WiredCanvas(
                              painter: WiredLineBase(
                                strokeWidth: theme.strokeWidth,
                                x1: 0,
                                y1: 0,
                                x2: double.infinity,
                                y2: 0,
                                borderColor: theme.borderColor.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              fillerType: RoughFilter.noFiller,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return CustomSingleChildLayout(
      delegate: _ContextMenuLayout(
        anchor: anchor,
        safe: safe,
        textDirection: Directionality.of(context),
      ),
      child: menu,
    );
  }
}

/// Places the menu under its anchor, or above it when the space below is
/// short, and keeps it within the safe area of the screen.
class _ContextMenuLayout extends SingleChildLayoutDelegate {
  _ContextMenuLayout({
    required this.anchor,
    required this.safe,
    required this.textDirection,
  });

  final Rect anchor;
  final EdgeInsets safe;
  final TextDirection textDirection;

  Rect _bounds(Size size) => Rect.fromLTRB(
    safe.left + _kScreenMargin,
    safe.top + _kScreenMargin,
    size.width - safe.right - _kScreenMargin,
    size.height - safe.bottom - _kScreenMargin,
  );

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final bounds = _bounds(constraints.biggest);
    return BoxConstraints.loose(
      Size(math.max(0, bounds.width), math.max(0, bounds.height)),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final bounds = _bounds(size);
    final below = anchor.bottom + _kAnchorGap;
    final above = anchor.top - _kAnchorGap - childSize.height;
    final double top;
    if (below + childSize.height <= bounds.bottom) {
      top = below;
    } else if (above >= bounds.top) {
      top = above;
    } else {
      top = bounds.bottom - childSize.height;
    }
    final start = textDirection == TextDirection.rtl
        ? anchor.right - childSize.width
        : anchor.left;
    final maxLeft = math.max(bounds.left, bounds.right - childSize.width);
    return Offset(
      start.clamp(bounds.left, maxLeft),
      top.clamp(
        bounds.top,
        math.max(bounds.top, bounds.bottom - childSize.height),
      ),
    );
  }

  @override
  bool shouldRelayout(_ContextMenuLayout oldDelegate) =>
      anchor != oldDelegate.anchor ||
      safe != oldDelegate.safe ||
      textDirection != oldDelegate.textDirection;
}

/// One row of the menu: an icon and a label that respond to taps, Enter,
/// and Space.
class _WiredContextMenuItem extends HookWidget {
  const _WiredContextMenuItem({
    required this.action,
    required this.autofocus,
    required this.onActivate,
  });

  final WiredContextMenuAction action;
  final bool autofocus;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final focused = useState(false);
    final color = action.isDestructive ? theme.errorColor : theme.textColor;

    return Semantics(
      button: true,
      child: FocusableActionDetector(
        autofocus: autofocus,
        onShowFocusHighlight: (value) => focused.value = value,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onActivate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onActivate,
          child: ColoredBox(
            color: focused.value
                ? theme.borderColor.withValues(alpha: 0.08)
                : const Color(0x00000000),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (action.icon case final icon?) ...[
                    WiredIcon(icon: icon, size: 18, color: color),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      action.label,
                      style: TextStyle(color: color, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An action item for [WiredContextMenu].
class WiredContextMenuAction {
  /// The item's label.
  final String label;

  /// Optional icon shown before [label].
  final IconData? icon;

  /// Called after the menu closes when the item is activated.
  final VoidCallback? onPressed;

  /// Whether the action destroys something, drawn in the theme's
  /// `errorColor`.
  final bool isDestructive;

  /// Creates a context menu action.
  const WiredContextMenuAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  });
}
