import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_navigation_indicator.dart';
import 'wired_theme.dart';

/// When a [WiredNavigationBar] shows its destinations' labels. Mirrors
/// Material's `NavigationDestinationLabelBehavior`.
///
/// A hidden label is still read by screen readers and shown as a tooltip
/// when the destination has one.
enum WiredNavigationDestinationLabelBehavior {
  /// Every destination shows its label.
  alwaysShow,

  /// Only the selected destination shows its label, which keeps five or
  /// more destinations uncluttered on a narrow phone.
  onlyShowSelected,

  /// No destination shows its label.
  alwaysHide,
}

/// A navigation bar destination.
class WiredNavigationDestination {
  /// <!-- {=dartDestinationIcon|trim|linePrefix:"  /// "} -->
  /// The icon shown when this destination is not selected.
  /// <!-- {/dartDestinationIcon} -->
  final IconData icon;

  /// <!-- {=dartDestinationSelectedIcon|trim|linePrefix:"  /// "} -->
  /// The icon shown when this destination is selected. Defaults to [icon].
  /// <!-- {/dartDestinationSelectedIcon} -->
  final IconData? selectedIcon;

  /// The destination's label, also read by screen readers.
  final String label;

  /// <!-- {=dartDestinationTooltip|trim|linePrefix:"  /// "} -->
  /// Read by screen readers as the destination's tooltip. Defaults to
  /// [label] when the label is hidden, so an icon-only destination still
  /// says what it is.
  /// <!-- {/dartDestinationTooltip} -->
  final String? tooltip;

  /// Whether the destination can be selected. A disabled destination dims
  /// its icon and label, ignores taps, and leaves focus traversal.
  final bool enabled;

  /// <!-- {=dartDestinationBadge|trim|linePrefix:"  /// "} -->
  /// A hand-drawn badge over the icon's top corner: `''` draws a dot, and
  /// any other text, such as a count, draws a pill around it. Null shows
  /// no badge.
  /// <!-- {/dartDestinationBadge} -->
  final String? badge;

  /// <!-- {=dartDestinationColor|trim|linePrefix:"  /// "} -->
  /// The wash behind this destination's icon when it is selected, such as
  /// `theme.accentAt(i)`. Wins over the bar's indicator colour.
  /// <!-- {/dartDestinationColor} -->
  final Color? color;

  /// Draws this destination as the bar's one loud action: its icon always
  /// sits on a wash of [color] (or the theme's `accentColor`), selected or
  /// not, so a "create" or "compose" tab stands out from the rest.
  final bool isPrimaryAction;

  /// Creates a navigation bar destination.
  const WiredNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
    this.enabled = true,
    this.badge,
    this.color,
    this.isPrimaryAction = false,
  });
}

/// Material 3 style navigation bar with hand-drawn rounded rect indicators.
///
/// Mirrors Material's `NavigationBar`. The destinations share the bar's
/// width equally. The bar is at least [height] tall and grows with larger
/// text. It pads itself above the home indicator of notched phones. Each
/// destination takes keyboard focus and is announced as a selectable
/// button.
///
/// When a destination is selected, its wash pops in on a spring and its
/// ink draws itself on. Both settle at once when motion is off.
class WiredNavigationBar extends HookWidget {
  /// The destinations, in order.
  final List<WiredNavigationDestination> destinations;

  /// The index of the selected destination.
  final int selectedIndex;

  /// Called with a destination's index when it is tapped or activated.
  final ValueChanged<int>? onDestinationSelected;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// When the destinations show their labels. Defaults to
  /// [WiredNavigationDestinationLabelBehavior.alwaysShow].
  final WiredNavigationDestinationLabelBehavior labelBehavior;

  /// The bar's minimum height, not counting its top line or the bottom
  /// safe area. It grows past this when larger text needs the room.
  final double height;

  /// The paper behind the bar. Defaults to transparent, so the page shows
  /// through.
  final Color? backgroundColor;

  /// <!-- {=dartNavigationIndicatorColor|trim|linePrefix:"  /// "} -->
  /// The wash behind the selected destination. Defaults to the theme's
  /// `markerColor`, or to `theme.accentAt(index)` when [colorCoded] is
  /// true.
  /// <!-- {/dartNavigationIndicatorColor} -->
  final Color? indicatorColor;

  /// <!-- {=dartNavigationColorCoded|trim|linePrefix:"  /// "} -->
  /// Gives each destination its own wash from the theme's accents, so the
  /// indicator changes colour as it moves: `theme.accentAt(index)`.
  /// <!-- {/dartNavigationColorCoded} -->
  final bool colorCoded;

  /// <!-- {=dartNavigationAnimationDuration|trim|linePrefix:"  /// "} -->
  /// How long a newly selected destination's wash takes to pop in and draw
  /// its ink. [Duration.zero] switches instantly.
  /// <!-- {/dartNavigationAnimationDuration} -->
  final Duration animationDuration;

  /// Creates a navigation bar with hand-drawn selection indicators.
  const WiredNavigationBar({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.semanticLabel,
    this.labelBehavior = WiredNavigationDestinationLabelBehavior.alwaysShow,
    this.height = 80,
    this.backgroundColor,
    this.indicatorColor,
    this.colorCoded = false,
    this.animationDuration = kWiredNavigationIndicatorDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel ?? 'Navigation bar',
      child: ColoredBox(
        color: backgroundColor ?? const Color(0x00000000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            SafeArea(
              top: false,
              child: ConstrainedBox(
                // At least [height] tall, and taller when the labels grow.
                constraints: BoxConstraints(minHeight: height),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < destinations.length; i++)
                        Expanded(
                          child: _buildDestination(
                            destinations[i],
                            i,
                            i == selectedIndex,
                            theme,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestination(
    WiredNavigationDestination dest,
    int index,
    bool selected,
    WiredThemeData theme,
  ) {
    final wash =
        dest.color ??
        (dest.isPrimaryAction ? theme.accentColor : null) ??
        indicatorColor ??
        (colorCoded ? theme.accentAt(index) : theme.markerColor);
    final washed = selected || dest.isPrimaryAction;
    final showLabel = switch (labelBehavior) {
      WiredNavigationDestinationLabelBehavior.alwaysShow => true,
      WiredNavigationDestinationLabelBehavior.onlyShowSelected => selected,
      WiredNavigationDestinationLabelBehavior.alwaysHide => false,
    };
    final dim = !dest.enabled;
    final iconColor = dim
        ? theme.disabledTextColor.withValues(alpha: 0.5)
        : washed
        ? theme.onColor(wash)
        : theme.disabledTextColor;
    final labelColor = dim
        ? theme.disabledTextColor.withValues(alpha: 0.5)
        : selected
        ? theme.textColor
        : theme.disabledTextColor;

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      // Only a disabled destination reports its enabled state.
      enabled: dest.enabled ? null : false,
      inMutuallyExclusiveGroup: true,
      // A hidden label is still announced.
      label: showLabel ? null : dest.label,
      tooltip: dest.tooltip ?? (showLabel ? null : dest.label),
      child: WiredActivatable(
        enabled: dest.enabled,
        onActivate: () => onDestinationSelected?.call(index),
        // Transparent paint makes the whole cell respond to a tap.
        child: ColoredBox(
          color: const Color(0x00000000),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WiredNavigationIndicator(
                visible: washed,
                color: wash,
                width: 64,
                height: 34,
                radius: 17,
                duration: animationDuration,
                seed: index + 1,
                child: WiredNavigationIcon(
                  icon: selected ? (dest.selectedIcon ?? dest.icon) : dest.icon,
                  color: iconColor,
                  badge: dest.badge,
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    dest.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: labelColor,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
