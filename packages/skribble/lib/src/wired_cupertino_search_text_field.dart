import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'canvas/wired_painter_base.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn search text field corresponding to Flutter's
/// `CupertinoSearchTextField`.
///
/// A rounded, stadium-shaped input with a hand-drawn rough border and a
/// sketchy magnifier glyph prefix. Supports [placeholder], [onChanged],
/// [onSubmitted], and optional custom [prefixWidget] / [suffixWidget].
///
/// The input uses `EditableText` directly, keeping the widget on
/// `flutter/widgets` only.
///
/// ## Example
///
/// ```dart
/// WiredCupertinoSearchTextField(
///   placeholder: 'Search widgets',
///   onSubmitted: (query) => runSearch(query),
/// )
/// ```
class WiredCupertinoSearchTextField extends HookWidget {
  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// Style for the placeholder text.
  final TextStyle? placeholderStyle;

  /// Style for the input text.
  final TextStyle? style;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (done/search key).
  final ValueChanged<String>? onSubmitted;

  /// A widget displayed before the text, defaults to the sketchy
  /// magnifier glyph.
  final Widget? prefixWidget;

  /// A widget displayed after the text.
  final Widget? suffixWidget;

  /// Whether the field is enabled. Disabled fields ignore input and
  /// render at reduced opacity.
  final bool enabled;

  /// Whether to request focus on first build.
  final bool autofocus;

  /// Focus node for the field. One is created automatically when null.
  final FocusNode? focusNode;

  /// Text input action. Defaults to `TextInputAction.search`.
  final TextInputAction? textInputAction;

  /// Height of the field. Defaults to 36 like the iOS search field.
  final double height;

  /// Border radius of the field. Defaults to a stadium shape matching
  /// [height].
  final BorderRadius? borderRadius;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  /// Creates a hand-drawn Cupertino-style search text field.
  const WiredCupertinoSearchTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.placeholderStyle,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.prefixWidget,
    this.suffixWidget,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.height = 36,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final ownedController = useTextEditingController();
    final effectiveController = controller ?? ownedController;
    final effectiveFocusNode = focusNode ?? useFocusNode();
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    // Rebuild on every text change so the placeholder can hide/show.
    useListenable(effectiveController);

    final showPlaceholder =
        placeholder != null && effectiveController.text.isEmpty;

    return Semantics(
      label: semanticLabel,
      textField: true,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: IgnorePointer(
          ignoring: !enabled,
          child: Stack(
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: effectiveBorderRadius,
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: height,
                  child: Row(
                    children: [
                      prefixWidget ?? const _SearchGlyph(),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: height - 10,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              if (showPlaceholder)
                                Text(
                                  placeholder!,
                                  style:
                                      placeholderStyle ??
                                      TextStyle(
                                        color: theme.disabledTextColor,
                                        fontSize: 17,
                                      ),
                                ),
                              EditableText(
                                controller: effectiveController,
                                focusNode: effectiveFocusNode,
                                autofocus: autofocus,
                                readOnly: !enabled,
                                style:
                                    style ??
                                    TextStyle(
                                      color: theme.textColor,
                                      fontSize: 17,
                                    ),
                                cursorColor: theme.borderColor,
                                backgroundCursorColor: theme.disabledTextColor,
                                onChanged: enabled ? onChanged : null,
                                onSubmitted: enabled ? onSubmitted : null,
                                textInputAction:
                                    textInputAction ?? TextInputAction.search,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (suffixWidget != null) ...[
                        const SizedBox(width: 6),
                        suffixWidget!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Default prefix glyph: a hand-drawn magnifying glass drawn with the
/// rough engine (a wobbly circle plus a short handle line).
class _SearchGlyph extends HookWidget {
  const _SearchGlyph();

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 18,
      height: 18,
      child: WiredCanvas(
        painter: _RoughMagnifierPainter(borderColor: theme.disabledTextColor),
        fillerType: RoughFilter.noFiller,
      ),
    );
  }
}

/// Paints a rough magnifier: circle lens plus a diagonal handle.
class _RoughMagnifierPainter extends WiredPainterBase {
  final Color borderColor;

  _RoughMagnifierPainter({required this.borderColor});

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final generator = Generator(drawConfig, filler);

    final lens = generator.circle(
      size.width * 0.38,
      size.height * 0.38,
      size.shortestSide * 0.62,
    );
    canvas.drawRough(
      lens,
      WiredBase.pathPainter(1.4, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );

    final handle = generator.line(
      size.width * 0.62,
      size.height * 0.62,
      size.width * 0.92,
      size.height * 0.92,
    );
    canvas.drawRough(
      handle,
      WiredBase.pathPainter(1.4, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}
