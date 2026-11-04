import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// Keyboard, focus, and hover chrome for hand-rolled tappable controls.
///
/// Material controls (which `WiredButtonBase` wraps) get focus, keyboard
/// activation, and pointer states for free. Widgets built directly on
/// `GestureDetector` do not. This wrapper supplies the missing layers without
/// pulling in Material, so a sketchy control stays activatable from a
/// keyboard and traversable by focus even before its Material wrapper is
/// retired.
///
/// It is deliberately internal (not exported from the barrel): the public
/// widgets own their own semantics and simply forward an activation callback.
class WiredActivatable extends HookWidget {
  /// Creates the wrapper.
  ///
  /// When [enabled] is false, the control is dropped from focus traversal and
  /// ignores keyboard and pointer activation.
  const WiredActivatable({
    super.key,
    required this.child,
    this.onActivate,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// The control being wrapped.
  final Widget child;

  /// Called on tap, Space, or Enter. Null behaves like [enabled] `false`.
  final VoidCallback? onActivate;

  /// Whether the control can be activated or focused.
  final bool enabled;

  /// Whether to focus this control when nothing else is focused.
  final bool autofocus;

  /// An optional externally supplied focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final canActivate = enabled && onActivate != null;
    // The detector below owns `canRequestFocus`. `useFocusNode` would reset it
    // on every rebuild, so a control that cannot be activated would flip its
    // node on each rebuild and notify listeners, scheduling another frame.
    final ownNode = useMemoized(
      () => FocusNode(debugLabel: 'WiredActivatable'),
    );
    useEffect(() => ownNode.dispose, [ownNode]);
    final resolvedNode = focusNode ?? ownNode;
    final isFocused = useState(false);
    final isHovered = useState(false);

    // Rebuild when the node's primary focus changes so the ring repaints even
    // if the caller owns the node and we never see a focus callback.
    useEffect(() {
      void listener() => isFocused.value = resolvedNode.hasFocus;
      resolvedNode.addListener(listener);
      return () => resolvedNode.removeListener(listener);
    }, [resolvedNode]);

    return FocusableActionDetector(
      enabled: canActivate,
      focusNode: resolvedNode,
      autofocus: autofocus,
      mouseCursor: canActivate
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowFocusHighlight: (v) => isFocused.value = v,
      onShowHoverHighlight: (v) => isHovered.value = v,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            onActivate?.call();
            return null;
          },
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (intent) {
            onActivate?.call();
            return null;
          },
        ),
      },
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: GestureDetector(
        onTap: canActivate ? onActivate : null,
        // Decorative overlay only; the actual control paints beneath it.
        child: Stack(
          // The wrapper is transparent to layout: the control receives the
          // same constraints it would without it, so a row can stretch it.
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            child,
            if (isFocused.value)
              // Drawn just outside the control so it never sits on top of
              // the control's own outline.
              const Positioned(
                left: -_ringGap,
                top: -_ringGap,
                right: -_ringGap,
                bottom: -_ringGap,
                child: IgnorePointer(child: WiredFocusRing()),
              ),
          ],
        ),
      ),
    );
  }
}

/// How far the focus ring sits outside the focused control.
const double _ringGap = 4;

/// The hand-drawn outline that marks keyboard focus on a skribble control.
///
/// Internal to the library. It is a sketchy rounded rectangle in the theme's
/// border colour, so it stays visible on dark paper as well as light, and
/// reads as the same pen as the control it surrounds. Size it with a
/// `Positioned` a few pixels outside the control.
class WiredFocusRing extends StatelessWidget {
  /// Creates a focus ring.
  const WiredFocusRing({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return WiredCanvas(
      painter: WiredRoundedRectangleBase(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        strokeWidth: theme.strokeWidth,
        borderColor: theme.borderColor,
      ),
      // Its own wobble, so the ring does not trace the control's outline.
      seed: 7,
      fillerType: RoughFilter.noFiller,
    );
  }
}
