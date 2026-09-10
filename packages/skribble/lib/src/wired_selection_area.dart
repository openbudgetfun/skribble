import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_text_button.dart';
import 'wired_theme.dart';

/// Enables selection across rich text, paragraphs, and scrollable descendants.
///
/// Uses Flutter's selection system with Wired handles and a localized context
/// menu. Interactive examples can opt out with [SelectionContainer.disabled].
class WiredSelectionArea extends HookWidget {
  /// Creates a selectable region with hand-drawn selection controls.
  const WiredSelectionArea({
    super.key,
    required this.child,
    this.focusNode,
    this.onSelectionChanged,
  });

  /// Content whose participating text widgets can be selected together.
  final Widget child;

  /// Optional caller-owned focus node, which this widget never disposes.
  final FocusNode? focusNode;

  /// Reports the plain text represented by the current selection.
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final ownedFocus = useFocusNode();
    final theme = WiredTheme.of(context);

    return DefaultSelectionStyle(
      selectionColor: theme.borderColor.withValues(alpha: .2),
      cursorColor: theme.borderColor,
      child: SelectableRegion(
        focusNode: focusNode ?? ownedFocus,
        selectionControls: _WiredSelectionControls(theme.borderColor),
        onSelectionChanged: onSelectionChanged,
        contextMenuBuilder: (context, state) => _WiredSelectionMenu(
          anchors: state.contextMenuAnchors,
          items: state.contextMenuButtonItems,
          theme: theme,
        ),
        child: child,
      ),
    );
  }
}

class _WiredSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  _WiredSelectionControls(this.color);

  final Color color;

  @override
  Size getHandleSize(double textLineHeight) => const Size(24, 24);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      Offset(12, type == TextSelectionHandleType.left ? 24 : 0);

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox.square(
      dimension: 24,
      child: WiredCanvas(
        painter: WiredCircleBase(
          borderColor: color,
          fillColor: color,
          diameterRatio: .7,
        ),
        fillerType: RoughFilter.solidFiller,
      ),
    ),
  );
}

class _WiredSelectionMenu extends HookWidget {
  const _WiredSelectionMenu({
    required this.anchors,
    required this.items,
    required this.theme,
  });

  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> items;
  final WiredThemeData theme;

  @override
  Widget build(BuildContext context) {
    final labels = WidgetsLocalizations.of(context);

    return CustomSingleChildLayout(
      delegate: TextSelectionToolbarLayoutDelegate(
        anchorAbove: anchors.primaryAnchor,
        anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      ),
      child: ExcludeFocus(
        child: WiredTheme(
          data: theme,
          child: DecoratedBox(
            decoration: RoughBoxDecoration(
              drawConfig: theme.drawConfig,
              borderStyle: RoughDrawingStyle(
                color: theme.borderColor,
                width: 2,
              ),
              fillStyle: RoughDrawingStyle(
                color: theme.textColor.computeLuminance() > .5
                    ? const Color(0xff252130)
                    : const Color(0xfffffcf4),
              ),
              filler: SolidFiller(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final item in items)
                    if (item.type == ContextMenuButtonType.copy ||
                        item.type == ContextMenuButtonType.selectAll)
                      WiredTextButton(
                        onPressed: item.onPressed,
                        child: Text(
                          item.type == ContextMenuButtonType.copy
                              ? labels.copyButtonLabel
                              : labels.selectAllButtonLabel,
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
