import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon_button.dart';
import 'wired_theme.dart';

/// A hand-drawn expansion panel list, corresponding to Flutter's `ExpansionPanelList`.
///
/// Displays a list of expansion panels with hand-drawn borders and
/// organic expand/collapse animations.
///
/// ## Example
///
/// ```dart
/// WiredExpansionPanelList(
///   children: [
///     WiredExpansionPanel(
///       headerBuilder: (context, isExpanded) => Text('Panel 1'),
///       body: Text('Content 1'),
///     ),
///     WiredExpansionPanel(
///       headerBuilder: (context, isExpanded) => Text('Panel 2'),
///       body: Text('Content 2'),
///     ),
///   ],
/// )
/// ```
class WiredExpansionPanelList extends HookWidget {
  /// The expansion panels to display.
  final List<WiredExpansionPanel> children;

  /// The callback when a panel is expanded or collapsed.
  final void Function(int, bool)? expansionCallback;

  /// The semantic label for accessibility.
  final String? semanticLabel;

  /// Creates a hand-drawn expansion panel list.
  const WiredExpansionPanelList({
    super.key,
    required this.children,
    this.expansionCallback,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final expandedPanels = useState<Set<int>>({});

    return Semantics(
      label: semanticLabel ?? 'Expansion panel list',
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              SizedBox(
                height: theme.inkExtent,
                child: WiredCanvas(
                  painter: WiredLineBase(
                    strokeWidth: theme.strokeWidth,
                    x1: 0,
                    y1: 0,
                    x2: double.infinity,
                    y2: 0,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            _buildPanel(
              context,
              children[i],
              i,
              expandedPanels,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    WiredExpansionPanel panel,
    int index,
    ValueNotifier<Set<int>> expandedPanels,
    WiredThemeData theme,
  ) {
    final isExpanded = expandedPanels.value.contains(index);

    void toggle() {
      final newExpanded = Set<int>.from(expandedPanels.value);
      if (isExpanded) {
        newExpanded.remove(index);
      } else {
        newExpanded.add(index);
      }
      expandedPanels.value = newExpanded;
      expansionCallback?.call(index, !isExpanded);
    }

    return Container(
      decoration: RoughBoxDecoration(
        progress: WiredDrawTransition.progressOf(context),
        pressure: WiredInkResponse.pressureOf(context),
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.rectangle,
        borderStyle: RoughDrawingStyle(
          width: theme.strokeWidth,
          color: theme.borderColor,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: panel.canTapOnHeader ? toggle : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: panel.headerBuilder(context, isExpanded),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: panel.canTapOnHeader
                        ? Icon(Icons.expand_more, color: theme.textColor)
                        : WiredIconButton(
                            icon: Icons.expand_more,
                            iconColor: theme.textColor,
                            onPressed: toggle,
                            semanticLabel: isExpanded
                                ? 'Collapse panel'
                                : 'Expand panel',
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: panel.body,
            ),
        ],
      ),
    );
  }
}

/// A single expansion panel for use with [WiredExpansionPanelList].
class WiredExpansionPanel {
  /// The builder for the panel header.
  final Widget Function(BuildContext, bool) headerBuilder;

  /// The body content of the panel.
  final Widget body;

  /// Whether tapping the header toggles the panel.
  ///
  /// When false, a separate expand button remains available.
  final bool canTapOnHeader;

  /// Creates an expansion panel.
  const WiredExpansionPanel({
    required this.headerBuilder,
    required this.body,
    this.canTapOnHeader = true,
  });
}
