import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// The hand-drawn back arrow at the start of every storybook page's app bar.
///
/// `WiredAppBar` adds no back button of its own, and a desktop window has no
/// system back gesture, so each page pushed over the home page puts this in
/// its `leading` slot. It takes keyboard focus like any button.
class StorybookBackButton extends HookWidget {
  /// Creates the back button.
  const StorybookBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return WiredButton(
      semanticLabel: 'Back',
      onPressed: () => Navigator.maybePop(context),
      child: const SkribbleIcon(data: SkribbleGlyphs.arrowLeft, size: 20),
    );
  }
}
