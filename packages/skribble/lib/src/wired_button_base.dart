import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_element.dart';
import 'wired_paint.dart';

/// The padding every rectangular skribble button shares. The surface around
/// the button owns the minimum height, so the ink's own inset is included.
///
/// The density is pinned to standard: Material's adaptive density on
/// desktop platforms takes 8 pixels off the vertical padding, which left a
/// label at large text scales touching the ink on macOS, Windows, and Linux.
final ButtonStyle _layout = TextButton.styleFrom(
  padding: kWiredButtonPadding,
  minimumSize: const Size(64, 0),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.standard,
);

/// Gives a skribble button exactly one semantics node.
///
/// Internal to the library. The Material control that [control] builds
/// already reports the button role, its enabled state, and its tap and focus
/// actions; this merges them with [label] so assistive technology meets one
/// labelled button rather than an empty wrapper around an unlabelled one.
/// [control] receives [labelChild] to render. When [label] is set, the
/// child's own text is excluded so a screen reader does not announce both.
Widget wiredButtonSemantics({
  required String? label,
  required bool enabled,
  required Widget labelChild,
  required Widget Function(Widget labelChild) control,
}) {
  return MergeSemantics(
    child: Semantics(
      label: label,
      button: true,
      enabled: enabled,
      child: control(
        label == null ? labelChild : ExcludeSemantics(child: labelChild),
      ),
    ),
  );
}

/// Shared construction for the Skribble button family.
///
/// Internal to the library and deliberately not exported from the package
/// barrel. It carries the fields every button exposes and builds the common
/// `WiredInkResponse` > `Semantics` > `RepaintBoundary` chrome so each public
/// button only has to describe its ink decoration and label style.
abstract class WiredButtonBase extends HookWidget {
  /// Creates a button base with the family's shared parameters.
  const WiredButtonBase({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.inkInteraction,
    this.seed,
  });

  /// The button label.
  final Widget child;

  /// Called when the button is tapped.
  ///
  /// When null, the button is disabled: taps are ignored and the label is
  /// styled with the disabled foreground of the concrete button.
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  /// Varies the hand behind this button's ink. The same seed always draws
  /// the same wobble, so a row of same-sized buttons needs different seeds to
  /// stop them reading as copies of each other. Null uses the decoration
  /// default.
  final int? seed;

  /// Builds the shared button chrome around [decorationBuilder].
  ///
  /// Both builders run inside the ink response so their decorations can read
  /// the control's draw progress and pen pressure from the nearest ancestors.
  /// [backgroundBuilder] paints behind the decorated surface; elevated
  /// buttons use it for the offset shadow.
  Widget buildWiredButton({
    required RoughBoxDecoration Function(BuildContext context)
    decorationBuilder,
    required ButtonStyle textStyle,
    Widget Function(BuildContext context)? backgroundBuilder,
  }) {
    return WiredInkResponse(
      interaction: inkInteraction,
      builder: (context, states) {
        // The button is at least kWiredButtonHeight tall and grows with its
        // label, so larger text never crowds the ink.
        final background = backgroundBuilder?.call(context);

        return wiredButtonSemantics(
          label: semanticLabel,
          enabled: onPressed != null,
          labelChild: child,
          control: (label) {
            final surface = Container(
              constraints: const BoxConstraints(minHeight: kWiredButtonHeight),
              decoration: decorationBuilder(context),
              child: TextButton(
                statesController: states,
                style: textStyle.merge(_layout),
                onPressed: onPressed,
                child: label,
              ),
            );

            return buildWiredElement(
              child: background == null
                  ? surface
                  : Stack(children: [background, surface]),
            );
          },
        );
      },
    );
  }
}
