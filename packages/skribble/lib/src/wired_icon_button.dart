import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';
import 'wired_tooltip.dart';

/// The look of a [WiredIconButton], picked by its constructor.
enum _Variant { standard, filled, filledTonal, outlined }

/// An icon button with a hand-drawn circle border.
///
/// Mirrors Material's `IconButton`, including its
/// [WiredIconButton.filled], [WiredIconButton.filledTonal], and
/// [WiredIconButton.outlined] forms and the toggle behaviour of
/// [isSelected] and [selectedIcon]. The overall frame is [size] and the
/// glyph is [iconSize], which defaults to half of the frame; [color] and
/// [iconColor] are interchangeable, with [color] taking precedence so
/// Material's parameter name works when migrating.
///
/// Built on `package:flutter/widgets.dart` alone: the button handles its
/// own taps, hover, keyboard focus, and Enter or Space activation.
class WiredIconButton extends HookWidget {
  /// The icon to draw.
  final IconData icon;

  /// Called when the button is tapped. Null disables the button: it leaves
  /// focus traversal, reports itself disabled, and dims its default glyph.
  final VoidCallback? onPressed;

  /// The width and height of the hand-drawn circle frame.
  final double size;

  /// The size of the glyph. Defaults to half of [size].
  ///
  /// Mirrors Material's `IconButton.iconSize`.
  final double? iconSize;

  /// The glyph color. Defaults to [color], then to whichever of the
  /// theme's ink and paper reads better on the wash, or to the theme's
  /// disabled text color when [onPressed] is null.
  final Color? iconColor;

  /// The glyph color, mirroring Material's `IconButton.color`.
  ///
  /// Takes precedence over [iconColor] when both are set.
  final Color? color;

  /// The wash inside the circle of a filled, tonal, or selected button,
  /// such as `theme.accentAt(3)`. Defaults to the theme's `accentColor` for
  /// [WiredIconButton.filled] and its `markerColor` otherwise.
  final Color? fillColor;

  /// Whether the button is toggled on, mirroring Material's
  /// `IconButton.isSelected`. Null, the default, makes an ordinary button.
  ///
  /// A selected button draws [selectedIcon] on a wash and is announced as
  /// selected. An unselected filled or tonal button drops its wash and
  /// keeps only the ring.
  final bool? isSelected;

  /// The icon drawn while [isSelected] is true. Defaults to [icon].
  final IconData? selectedIcon;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Text shown in a hand-drawn tooltip on long press or hover, and read by
  /// screen readers. Mirrors Material's `IconButton.tooltip`.
  final String? tooltip;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  /// Whether to focus this button when nothing else is focused.
  final bool autofocus;

  /// An optional focus node for the button.
  final FocusNode? focusNode;

  final _Variant _variant;

  /// Creates an icon button. The circle frame defaults to 48 logical pixels.
  const WiredIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconSize,
    this.iconColor,
    this.color,
    this.fillColor,
    this.isSelected,
    this.selectedIcon,
    this.semanticLabel,
    this.tooltip,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : _variant = _Variant.standard;

  /// Creates an icon button washed with the theme's `accentColor`, for the
  /// one loud action in a toolbar. Mirrors Material's `IconButton.filled`.
  const WiredIconButton.filled({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconSize,
    this.iconColor,
    this.color,
    this.fillColor,
    this.isSelected,
    this.selectedIcon,
    this.semanticLabel,
    this.tooltip,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : _variant = _Variant.filled;

  /// Creates an icon button washed with the theme's `markerColor`: a
  /// softer emphasis than [WiredIconButton.filled]. Mirrors Material's
  /// `IconButton.filledTonal`.
  const WiredIconButton.filledTonal({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconSize,
    this.iconColor,
    this.color,
    this.fillColor,
    this.isSelected,
    this.selectedIcon,
    this.semanticLabel,
    this.tooltip,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : _variant = _Variant.filledTonal;

  /// Creates an outlined icon button. Mirrors Material's
  /// `IconButton.outlined`.
  ///
  /// Every skribble icon button already draws its ring, so this looks like
  /// the default constructor; it exists so Material code ports unchanged.
  const WiredIconButton.outlined({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconSize,
    this.iconColor,
    this.color,
    this.fillColor,
    this.isSelected,
    this.selectedIcon,
    this.semanticLabel,
    this.tooltip,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : _variant = _Variant.outlined;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final enabled = onPressed != null;
    final selected = isSelected ?? false;
    final effectiveIconSize = iconSize ?? size * 0.5;

    // Filled and tonal buttons are washed unless toggled off; the others
    // only when toggled on.
    final washed = switch (_variant) {
      _Variant.filled || _Variant.filledTonal => isSelected ?? true,
      _Variant.standard || _Variant.outlined => selected,
    };
    final Color? wash = washed
        ? fillColor ??
              (_variant == _Variant.filled
                  ? theme.accentColor
                  : theme.markerColor)
        : null;
    // A disabled wash fades, so the button still reads as its variant.
    final paintedWash = wash == null || enabled
        ? wash
        : wash.withValues(alpha: 0.35);

    final effectiveIconColor =
        color ??
        iconColor ??
        (!enabled
            ? theme.disabledTextColor
            : wash != null
            ? theme.onColor(wash)
            : theme.textColor);

    return WiredInkResponse(
      interaction: inkInteraction,
      builder: (context, states) => MergeSemantics(
        child: Semantics(
          label: semanticLabel,
          button: true,
          enabled: enabled,
          selected: isSelected,
          child: _withTooltip(
            tooltip,
            buildWiredElement(
              child: WiredActivatable(
                onActivate: onPressed,
                states: states,
                autofocus: autofocus,
                focusNode: focusNode,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: WiredCanvas(
                          painter: WiredCircleBase(
                            strokeWidth: theme.strokeWidth,
                            diameterRatio: 0.85,
                            fillColor: paintedWash ?? const Color(0x00000000),
                            borderColor: theme.borderColor,
                          ),
                          fillerType: paintedWash == null
                              ? RoughFilter.noFiller
                              : RoughFilter.solidFiller,
                        ),
                      ),
                      ExcludeSemantics(
                        excluding: semanticLabel != null,
                        child: WiredIcon(
                          icon: selected ? (selectedIcon ?? icon) : icon,
                          color: effectiveIconColor,
                          size: effectiveIconSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps [child] in a hand-drawn tooltip when [message] is set. Inside the
/// button's merged semantics, so the tooltip is read as part of the button.
Widget _withTooltip(String? message, Widget child) =>
    message == null ? child : WiredTooltip(message: message, child: child);
