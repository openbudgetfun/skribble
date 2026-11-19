import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_curves.dart';
import 'motion/wired_motion.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_fit_text.dart';
import 'wired_navigation_indicator.dart';
import 'wired_theme.dart';

/// Which labels a compact [WiredNavigationRail] shows under its icons.
/// Mirrors Material's `NavigationRailLabelType`.
///
/// An extended rail always shows every label beside its icon. A hidden
/// label is still read by screen readers.
enum WiredNavigationRailLabelType {
  /// No labels, only icons.
  none,

  /// Only the selected destination's label.
  selected,

  /// Every destination's label.
  all,
}

/// A destination for the navigation rail.
class WiredNavigationRailDestination {
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

  /// Whether the destination is disabled. A disabled destination dims its
  /// icon and label, ignores taps, and leaves focus traversal. Mirrors
  /// Material's `NavigationRailDestination.disabled`.
  final bool disabled;

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

  /// Creates a navigation rail destination.
  const WiredNavigationRailDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
    this.disabled = false,
    this.badge,
    this.color,
  });
}

/// A vertical navigation rail with hand-drawn selection indicators.
///
/// Mirrors Material's `NavigationRail`. A compact rail is [minWidth] wide
/// with labels under the icons; an [extended] rail is [minExtendedWidth]
/// wide with each label beside its icon, and springs between the two
/// widths. Each destination takes keyboard focus, so the arrow keys move
/// between them and Enter or Space selects one, and is announced as a
/// selectable button.
class WiredNavigationRail extends HookWidget {
  /// The destinations, top to bottom.
  final List<WiredNavigationRailDestination> destinations;

  /// The index of the selected destination, or null for none.
  final int? selectedIndex;

  /// Called with a destination's index when it is tapped or activated.
  final ValueChanged<int>? onDestinationSelected;

  /// A widget above the destinations, such as a menu button or a floating
  /// action button.
  final Widget? leading;

  /// A widget at the bottom of the rail.
  final Widget? trailing;

  /// Whether the rail is extended: wider, with each label beside its icon.
  /// Changing it springs the rail between [minWidth] and
  /// [minExtendedWidth].
  final bool extended;

  /// Which labels a compact rail shows. Defaults to
  /// [WiredNavigationRailLabelType.all]. An extended rail shows every label.
  final WiredNavigationRailLabelType labelType;

  /// Where the destinations sit in the space between [leading] and
  /// [trailing]: -1 at the top, 0 in the centre, and 1 at the bottom.
  /// Ignored when the rail has no bounded height or is [scrollable].
  final double groupAlignment;

  /// The width of a compact rail, not counting its divider line.
  final double minWidth;

  /// The width of an extended rail, not counting its divider line.
  final double minExtendedWidth;

  /// The paper behind the rail. Defaults to transparent.
  final Color? backgroundColor;

  /// <!-- {=dartNavigationIndicatorColor|trim|linePrefix:"  /// "} -->
  /// The wash behind the selected destination. Defaults to the theme's
  /// `markerColor`, or to `theme.accentAt(index)` when [colorCoded] is
  /// true.
  /// <!-- {/dartNavigationIndicatorColor} -->
  final Color? indicatorColor;

  /// Whether the selected destination sits on a wash. When false, only its
  /// ink and bold label mark it.
  final bool useIndicator;

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

  /// Whether the destinations scroll when they do not fit the rail's
  /// height, rather than overflowing.
  final bool scrollable;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a vertical navigation rail, 72 logical pixels wide by default.
  const WiredNavigationRail({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.extended = false,
    this.labelType = WiredNavigationRailLabelType.all,
    this.groupAlignment = -1,
    this.minWidth = 72,
    this.minExtendedWidth = 256,
    this.backgroundColor,
    this.indicatorColor,
    this.useIndicator = true,
    this.colorCoded = false,
    this.animationDuration = kWiredNavigationIndicatorDuration,
    this.scrollable = false,
    this.semanticLabel,
  }) : assert(groupAlignment >= -1 && groupAlignment <= 1);

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final animate = WiredMotion.enabledOf(context);
    final group = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: extended
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < destinations.length; i++)
          _buildDestination(destinations[i], i, i == selectedIndex, theme),
      ],
    );

    Widget rail = AnimatedContainer(
      width: extended ? minExtendedWidth : minWidth,
      duration: animate ? animationDuration : Duration.zero,
      curve: WiredCurves.springy,
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bounded = constraints.hasBoundedHeight;
          final body = scrollable && bounded
              ? SingleChildScrollView(child: group)
              : group;
          return Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (leading != null) ...[
                const SizedBox(height: 8),
                leading!,
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              if (bounded)
                Expanded(
                  child: Align(
                    alignment: Alignment(
                      extended ? -1 : 0,
                      scrollable ? -1 : groupAlignment,
                    ),
                    child: body,
                  ),
                )
              else
                body,
              if (trailing != null) ...[trailing!, const SizedBox(height: 8)],
            ],
          );
        },
      ),
    );

    rail = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        rail,
        SizedBox(
          width: theme.inkExtent,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: 0,
              y2: double.infinity,
              strokeWidth: theme.strokeWidth,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      ],
    );

    if (semanticLabel == null) return rail;
    return Semantics(container: true, label: semanticLabel, child: rail);
  }

  Widget _buildDestination(
    WiredNavigationRailDestination dest,
    int index,
    bool selected,
    WiredThemeData theme,
  ) {
    final wash =
        dest.color ??
        indicatorColor ??
        (colorCoded ? theme.accentAt(index) : theme.markerColor);
    final washed = selected && useIndicator;
    final dimmed = theme.disabledTextColor.withValues(alpha: 0.5);
    final iconColor = dest.disabled
        ? dimmed
        : washed
        ? theme.onColor(wash)
        : selected
        ? theme.textColor
        : theme.disabledTextColor;
    final labelColor = dest.disabled
        ? dimmed
        : selected
        ? theme.textColor
        : theme.disabledTextColor;
    final icon = WiredNavigationIcon(
      icon: selected ? (dest.selectedIcon ?? dest.icon) : dest.icon,
      color: iconColor,
      badge: dest.badge,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // While the rail springs open it is briefly too narrow for a label
        // beside the icon, so it keeps the compact layout until there is
        // room.
        final wide = extended && constraints.maxWidth >= 120;
        final showLabel =
            wide ||
            switch (labelType) {
              WiredNavigationRailLabelType.none => false,
              WiredNavigationRailLabelType.selected => selected,
              WiredNavigationRailLabelType.all => true,
            };

        // A label on the wash of an extended rail takes the wash's ink.
        Widget label(double fontSize, {bool onWash = false}) => WiredFitText(
          dest.label,
          style: TextStyle(
            fontSize: fontSize,
            color: onWash && washed && !dest.disabled
                ? theme.onColor(wash)
                : labelColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        );

        final Widget content;
        if (wide) {
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: WiredNavigationIndicator(
              visible: washed,
              color: wash,
              height: 48,
              radius: 24,
              duration: animationDuration,
              seed: index + 1,
              padding: kWiredInkPadding.copyWith(left: 16, right: 16),
              child: Row(
                children: [
                  icon,
                  // A count badge overhangs the icon's end, so the label
                  // steps further away from it.
                  SizedBox(
                    width: dest.badge?.isNotEmpty ?? false ? 24 : 12,
                  ),
                  Flexible(child: label(14, onWash: true)),
                ],
              ),
            ),
          );
        } else {
          content = ConstrainedBox(
            // At least 56 tall, and taller when the label grows.
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: minWidth,
              minHeight: 56,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WiredNavigationIndicator(
                  visible: washed,
                  color: wash,
                  width: 56,
                  height: 40,
                  radius: 20,
                  duration: animationDuration,
                  seed: index + 1,
                  child: icon,
                ),
                if (showLabel) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: label(11),
                  ),
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Semantics(
            container: true,
            button: true,
            selected: selected,
            // Only a disabled destination reports its enabled state.
            enabled: dest.disabled ? false : null,
            inMutuallyExclusiveGroup: true,
            label: showLabel ? null : dest.label,
            tooltip: dest.tooltip ?? (showLabel ? null : dest.label),
            child: WiredActivatable(
              enabled: !dest.disabled,
              onActivate: () => onDestinationSelected?.call(index),
              // Transparent paint makes the whole cell respond to a tap.
              child: ColoredBox(
                color: const Color(0x00000000),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}
