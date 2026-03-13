import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An expandable tile with a hand-drawn border.
class WiredExpansionTile extends HookWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;

  const WiredExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.children = const [],
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isExpanded = useState(initiallyExpanded);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => isExpanded.value = !isExpanded.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 16)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle(
                        style: TextStyle(color: theme.textColor, fontSize: 16),
                        child: title,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: TextStyle(
                            color: theme.disabledTextColor,
                            fontSize: 14,
                          ),
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded.value ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, color: theme.textColor),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 1,
          child: WiredCanvas(
            painter: WiredLineBase(x1: 0, y1: 0, x2: double.infinity, y2: 0),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        if (isExpanded.value)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
      ],
    );
  }
}
