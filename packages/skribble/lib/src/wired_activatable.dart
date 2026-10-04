import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
    final resolvedNode = focusNode ?? useFocusNode();
    final isFocused = useState(false);
    final isHovered = useState(false);

    // Rebuild when the node's primary focus changes so the ring repaints even
    // if the caller owns the node and we never see a focus callback.
    useEffect(() {
      void listener() => isFocused.value = resolvedNode.hasFocus;
      resolvedNode.addListener(listener);
      return () => resolvedNode.removeListener(listener);
    }, [resolvedNode]);

    final canActivate = enabled && onActivate != null;

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
          clipBehavior: Clip.none,
          children: [
            child,
            if (isFocused.value)
              Positioned.fill(
                child: IgnorePointer(child: _FocusRing(color: _ringColor)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Ink color for the focus ring. Kept theme-independent so the wrapper never
/// rebuilds against theme churn; the ring reads as a pen outline regardless.
const Color _ringColor = Color(0xCC34283F);

class _FocusRing extends StatelessWidget {
  const _FocusRing({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
