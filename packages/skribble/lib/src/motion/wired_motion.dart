import 'package:flutter/widgets.dart';

/// Cascading permission for decorative ink motion.
///
/// A disabled ancestor or the platform's reduced-motion preference always wins.
/// This controls Skribble ink; it does not disable consumer-owned animations.
class WiredMotion extends InheritedWidget {
  /// Creates a motion boundary. Use false to settle all ink in this subtree.
  const WiredMotion({super.key, this.enabled = true, required super.child});

  /// Whether this boundary permits ink motion.
  final bool enabled;

  /// Resolves every ancestor and the platform accessibility preference.
  static bool enabledOf(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return false;
    var enabled = true;
    context.visitAncestorElements((element) {
      if (element is InheritedElement && element.widget is WiredMotion) {
        context.dependOnInheritedElement(element);
        enabled = enabled && (element.widget as WiredMotion).enabled;
      }
      return enabled;
    });
    return enabled;
  }

  @override
  bool updateShouldNotify(WiredMotion oldWidget) =>
      enabled != oldWidget.enabled;
}
