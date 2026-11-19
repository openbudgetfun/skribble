import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_curves.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'motion/wired_motion.dart';
import 'rough/skribble_rough.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';
import 'wired_tooltip.dart';

/// A floating action button: a hand-drawn circle washed with the theme's
/// `accentColor`, with its icon in the theme's `onAccentColor`.
///
/// Mirrors Material's `FloatingActionButton`, including its
/// [WiredFloatingActionButton.small], [WiredFloatingActionButton.large],
/// and [WiredFloatingActionButton.extended] forms.
class WiredFloatingActionButton extends HookWidget {
  /// The icon drawn in the middle of the button, or before the label of an
  /// extended button.
  final IconData? icon;

  /// The label of an extended button, beside [icon]. Null for the circular
  /// forms.
  final Widget? label;

  /// Called when the button is tapped or activated with Enter or Space.
  /// Null disables the button and removes it from focus traversal.
  final VoidCallback? onPressed;

  /// The width and height of the hand-drawn circle. The minimum height of
  /// an extended button.
  final double size;

  /// The size of the glyph. Defaults to 43% of [size], or 24 on an
  /// extended button.
  final double? iconSize;

  /// The icon colour. Defaults to [foregroundColor], then to whichever of
  /// the theme's ink and paper reads better on the wash.
  final Color? iconColor;

  /// The icon and label colour, mirroring Material's
  /// `FloatingActionButton.foregroundColor`. [iconColor] wins for the icon.
  final Color? foregroundColor;

  /// The wash inside the ink, such as `theme.accentAt(2)`. Defaults to the
  /// theme's `accentColor`. Mirrors Material's
  /// `FloatingActionButton.backgroundColor`.
  final Color? backgroundColor;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Text shown in a hand-drawn tooltip on long press or hover, and read by
  /// screen readers.
  final String? tooltip;

  /// Wraps the button in a [Hero] with this tag, so it flies between
  /// routes. Null, the default, adds no hero, so several buttons on one
  /// screen never clash.
  final Object? heroTag;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  /// Whether to focus this button when nothing else is focused.
  final bool autofocus;

  /// An optional focus node for the button.
  final FocusNode? focusNode;

  /// Whether an extended button shows its label. Turning it off springs
  /// the button back to a circle around [icon], as Material's
  /// `FloatingActionButton.extended` does when a list scrolls.
  final bool isExtended;

  /// The space between the icon and the label of an extended button.
  final double extendedIconLabelSpacing;

  /// The padding inside an extended button. Defaults to 16 at the sides,
  /// or 20 at the end when there is no icon.
  final EdgeInsetsGeometry? extendedPadding;

  /// Creates a 56 pixel hand-drawn floating action button.
  const WiredFloatingActionButton({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.size = 56.0,
    this.iconSize,
    this.iconColor,
    this.foregroundColor,
    this.backgroundColor,
    this.semanticLabel,
    this.tooltip,
    this.heroTag,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : label = null,
       isExtended = false,
       extendedIconLabelSpacing = 8,
       extendedPadding = null;

  /// Creates a 40 pixel floating action button, mirroring Material's
  /// `FloatingActionButton.small`.
  const WiredFloatingActionButton.small({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.iconSize = 20,
    this.iconColor,
    this.foregroundColor,
    this.backgroundColor,
    this.semanticLabel,
    this.tooltip,
    this.heroTag,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : size = 40,
       label = null,
       isExtended = false,
       extendedIconLabelSpacing = 8,
       extendedPadding = null;

  /// Creates a 96 pixel floating action button, mirroring Material's
  /// `FloatingActionButton.large`.
  const WiredFloatingActionButton.large({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.iconSize = 36,
    this.iconColor,
    this.foregroundColor,
    this.backgroundColor,
    this.semanticLabel,
    this.tooltip,
    this.heroTag,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
  }) : size = 96,
       label = null,
       isExtended = false,
       extendedIconLabelSpacing = 8,
       extendedPadding = null;

  /// Creates a hand-drawn pill holding an optional [icon] and a [label],
  /// mirroring Material's `FloatingActionButton.extended`.
  ///
  /// The pill is at least 56 pixels tall and grows with larger text.
  const WiredFloatingActionButton.extended({
    super.key,
    required Widget this.label,
    this.icon,
    this.onPressed,
    this.iconSize,
    this.iconColor,
    this.foregroundColor,
    this.backgroundColor,
    this.semanticLabel,
    this.tooltip,
    this.heroTag,
    this.inkInteraction,
    this.autofocus = false,
    this.focusNode,
    this.isExtended = true,
    this.extendedIconLabelSpacing = 8,
    this.extendedPadding,
  }) : size = 56;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final enabled = onPressed != null;
    final wash = backgroundColor ?? theme.accentColor;
    final foreground = foregroundColor ?? theme.onColor(wash);
    final glyphColor = iconColor ?? foreground;

    Widget button = WiredInkResponse(
      interaction: inkInteraction,
      builder: (context, states) {
        final Widget face;
        if (label == null) {
          face = SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                WiredCanvas(
                  painter: WiredCircleBase(
                    strokeWidth: theme.strokeWidth,
                    diameterRatio: 0.9,
                    fillColor: wash,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.solidFiller,
                ),
                WiredIcon(
                  icon: icon!,
                  color: glyphColor,
                  size: iconSize ?? size * 0.43,
                ),
              ],
            ),
          );
        } else {
          face = _ExtendedFace(
            icon: icon,
            label: label!,
            isExtended: isExtended,
            wash: wash,
            foreground: foreground,
            iconColor: glyphColor,
            iconSize: iconSize ?? 24,
            minHeight: size,
            spacing: extendedIconLabelSpacing,
            padding: extendedPadding,
          );
        }
        return MergeSemantics(
          child: Semantics(
            label: semanticLabel,
            button: true,
            enabled: enabled,
            child: _withTooltip(
              tooltip,
              buildWiredElement(
                child: WiredActivatable(
                  onActivate: onPressed,
                  states: states,
                  autofocus: autofocus,
                  focusNode: focusNode,
                  child: face,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (heroTag != null) button = Hero(tag: heroTag!, child: button);
    return button;
  }
}

/// Wraps [child] in a hand-drawn tooltip when [message] is set. Inside the
/// button's merged semantics, so the tooltip is read as part of the button.
Widget _withTooltip(String? message, Widget child) =>
    message == null ? child : WiredTooltip(message: message, child: child);

/// The pill face of an extended floating action button.
class _ExtendedFace extends HookWidget {
  const _ExtendedFace({
    required this.icon,
    required this.label,
    required this.isExtended,
    required this.wash,
    required this.foreground,
    required this.iconColor,
    required this.iconSize,
    required this.minHeight,
    required this.spacing,
    required this.padding,
  });

  final IconData? icon;
  final Widget label;
  final bool isExtended;
  final Color wash;
  final Color foreground;
  final Color iconColor;
  final double iconSize;
  final double minHeight;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final animate = WiredMotion.enabledOf(context);
    final collapsed = !isExtended && icon != null;
    final glyph = icon == null
        ? null
        : WiredIcon(icon: icon!, color: iconColor, size: iconSize);
    final effectivePadding = collapsed
        ? EdgeInsets.zero
        : padding ??
              EdgeInsetsDirectional.only(
                start: 16,
                end: icon == null ? 20 : 16,
              );

    return Container(
      constraints: BoxConstraints(minHeight: minHeight, minWidth: minHeight),
      padding: effectivePadding,
      decoration: RoughBoxDecoration(
        seed: 3,
        progress: WiredDrawTransition.progressOf(context),
        pressure: WiredInkResponse.pressureOf(context),
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderRadius: BorderRadius.circular(minHeight / 2),
        borderStyle: RoughDrawingStyle(
          width: theme.strokeWidth,
          color: theme.borderColor,
        ),
        fillStyle: RoughDrawingStyle(color: wash),
        filler: SolidFiller(FillerConfig.build(drawConfig: theme.drawConfig)),
      ),
      child: AnimatedSize(
        duration: animate ? const Duration(milliseconds: 360) : Duration.zero,
        curve: WiredCurves.springy,
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          // The label keeps the ink padding above and below it.
          padding: EdgeInsets.symmetric(vertical: kWiredInkPadding.top),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // A collapsed button centres its icon in the circle.
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ?glyph,
              if (!collapsed) ...[
                if (glyph != null) SizedBox(width: spacing),
                Flexible(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: label,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
