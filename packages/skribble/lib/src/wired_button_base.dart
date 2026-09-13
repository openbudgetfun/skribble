import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_element.dart';
import 'wired_paint.dart';

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
        final surface = Container(
          height: kWiredButtonHeight,
          decoration: decorationBuilder(context),
          child: SizedBox(
            height: double.infinity,
            child: TextButton(
              statesController: states,
              style: textStyle,
              onPressed: onPressed,
              child: child,
            ),
          ),
        );
        final background = backgroundBuilder?.call(context);

        return Semantics(
          label: semanticLabel,
          button: true,
          enabled: onPressed != null,
          child: buildWiredElement(
            child: background == null
                ? surface
                : Stack(children: [background, surface]),
          ),
        );
      },
    );
  }
}
