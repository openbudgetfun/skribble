import 'package:flutter/widgets.dart';

import 'generated/skribble_glyphs.g.dart';
import 'wired_activatable.dart';
import 'wired_icon.dart';

/// The hand-drawn close mark at the end of a deletable chip.
///
/// Internal to the library and deliberately not exported from the package
/// barrel. It is its own labelled button, so a screen reader can reach the
/// delete action separately from the chip, and a keyboard user can focus it
/// and press Enter or Space.
class WiredChipDeleteButton extends StatelessWidget {
  /// Creates the delete button for a chip.
  const WiredChipDeleteButton({
    super.key,
    required this.onDeleted,
    required this.color,
    this.semanticLabel,
  });

  /// Called when the mark is tapped or activated from the keyboard.
  final VoidCallback onDeleted;

  /// The colour of the close mark.
  final Color color;

  /// The label read for the button. Defaults to `Delete`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: semanticLabel ?? 'Delete',
      child: WiredActivatable(
        onActivate: onDeleted,
        child: WiredSvgIcon(
          data: SkribbleGlyphs.close,
          size: 16,
          color: color,
          weight: 300,
        ),
      ),
    );
  }
}
