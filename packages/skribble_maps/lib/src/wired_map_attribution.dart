import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// A compact, hand-drawn attribution badge for a map data source.
///
/// Map providers usually require visible attribution. Keep this widget on top
/// of the map and connect [onTap] to the provider's attribution page when the
/// source terms require a link.
class WiredMapAttribution extends HookWidget {
  /// Creates a map attribution badge.
  const WiredMapAttribution({
    required this.text,
    super.key,
    this.onTap,
    this.semanticLabel,
    this.padding = kWiredInkPadding,
  });

  /// The visible provider and data attribution.
  ///
  /// It wraps onto as many lines as it needs; constrain the badge's width to
  /// choose where it breaks.
  final String text;

  /// Called when the badge is activated.
  final VoidCallback? onTap;

  /// An optional accessibility label that replaces [text].
  final String? semanticLabel;

  /// Space between the attribution text and the hand-drawn outline.
  ///
  /// Defaults to [kWiredInkPadding], the breathing room every skribble
  /// control keeps between its content and its ink.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final focused = useState(false);
    final content = Padding(
      padding: padding,
      // Providers require the whole credit, so it wraps instead of being
      // cut short with an ellipsis.
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.textColor,
          fontFamily: theme.fontFamily,
          package: theme.fontPackage,
          fontSize: 10,
          height: 1.15,
        ),
      ),
    );

    return buildWiredElement(
      child: Semantics(
        label: semanticLabel ?? text,
        link: onTap != null,
        button: onTap != null,
        // The gesture detector's tap action is excluded with its subtree, so
        // screen readers activate the badge through this one.
        onTap: onTap,
        excludeSemantics: true,
        child: FocusableActionDetector(
          enabled: onTap != null,
          mouseCursor: onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onShowFocusHighlight: (value) => focused.value = value,
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: WiredCanvas(
                    fillerType: RoughFilter.solidFiller,
                    painter: WiredRoundedRectangleBase(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      fillColor: theme.fillColor.withValues(alpha: 0.9),
                      // A keyboard-focused badge draws a full-strength line.
                      borderColor: focused.value
                          ? theme.borderColor
                          : theme.borderColor.withValues(alpha: 0.65),
                      strokeWidth: focused.value ? 2.5 : 1,
                    ),
                  ),
                ),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
