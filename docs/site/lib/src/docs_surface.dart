import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// A quiet paper surface with corners drawn by the surrounding Wired theme.
RoughBoxDecoration docsSurface(
  BuildContext context, {
  required Color color,
  bool focused = false,
  double radius = 8,
}) {
  final config = WiredTheme.of(context).drawConfig;

  return RoughBoxDecoration(
    shape: RoughBoxShape.roundedRectangle,
    borderRadius: BorderRadius.circular(radius),
    drawConfig: config,
    filler: SolidFiller(FillerConfig.build(drawConfig: config)),
    fillStyle: RoughDrawingStyle(color: color),
    borderStyle: RoughDrawingStyle(
      color: focused ? const Color(0xff34283f) : const Color(0x00000000),
      width: focused ? 1.5 : 0,
    ),
  );
}

/// Keyboard-accessible documentation action without a permanent underline.
class DocsAction extends HookWidget {
  /// Creates a compact action, optionally representing a selected link.
  const DocsAction({
    required this.onPressed,
    required this.child,
    this.selected = false,
    this.link = false,
    super.key,
  });

  /// Invoked by pointer, keyboard, or accessibility activation.
  final VoidCallback onPressed;

  /// The visible label.
  final Widget child;

  /// Whether this action represents the current choice.
  final bool selected;

  /// Whether the action navigates to a document.
  final bool link;

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    final hovered = useState(false);

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => focused.value = value,
      onShowHoverHighlight: (value) => hovered.value = value,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onPressed();
            return null;
          },
        ),
      },
      child: Semantics(
        button: !link,
        link: link,
        selected: selected,
        onTap: onPressed,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: selected || hovered.value || focused.value
                ? docsSurface(
                    context,
                    color: selected
                        ? const Color(0xfff6dfd5)
                        : hovered.value
                        ? const Color(0xffeee9f0)
                        : const Color(0x00000000),
                    focused: focused.value,
                  )
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}
