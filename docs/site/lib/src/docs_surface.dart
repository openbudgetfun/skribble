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

/// A rough rounded outline that groups related content without a fill.
RoughBoxDecoration docsFrame(BuildContext context, {double radius = 12}) {
  final config = WiredTheme.of(context).drawConfig;

  return RoughBoxDecoration(
    shape: RoughBoxShape.roundedRectangle,
    borderRadius: BorderRadius.circular(radius),
    drawConfig: config,
    borderStyle: const RoughDrawingStyle(color: docsRule, width: 1.6),
  );
}

/// Hairline colour shared by frames, table rules, and the header edge.
const Color docsRule = Color(0xffd9cdc1);

/// Secondary copy: groups, breadcrumbs, hints, and quiet labels.
const Color docsQuietInk = Color(0xff796c7a);

/// Keyboard-accessible documentation action without a permanent underline.
class DocsAction extends HookWidget {
  /// Creates a compact action, optionally representing a selected link.
  const DocsAction({
    required this.onPressed,
    required this.child,
    this.selected,
    this.link = false,
    this.dense = false,
    super.key,
  });

  /// Invoked by pointer, keyboard, or accessibility activation.
  final VoidCallback onPressed;

  /// The visible label.
  final Widget child;

  /// Whether this action represents the current choice, or null for an action
  /// that does not participate in a selection.
  final bool? selected;

  /// Whether the action navigates to a document.
  final bool link;

  /// Whether to use the compact 36-pixel height for dense lists and segmented
  /// choices instead of the standard 44-pixel target.
  final bool dense;

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
            constraints: BoxConstraints(minHeight: dense ? 36 : 44),
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 10 : 12,
              vertical: dense ? 6 : 9,
            ),
            decoration: selected == true || hovered.value || focused.value
                ? docsSurface(
                    context,
                    color: selected == true
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
