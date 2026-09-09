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
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  /// The visible provider and data attribution.
  final String text;

  /// Called when the badge is activated.
  final VoidCallback? onTap;

  /// An optional accessibility label that replaces [text].
  final String? semanticLabel;

  /// Space around the attribution text.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final content = Padding(
      padding: padding,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
        excludeSemantics: true,
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
                    borderColor: theme.borderColor.withValues(alpha: 0.65),
                    strokeWidth: 1,
                  ),
                ),
              ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
