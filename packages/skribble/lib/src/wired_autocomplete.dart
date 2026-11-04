import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn wrapper around Flutter's [Autocomplete].
class WiredAutocomplete<T extends Object> extends HookWidget {
  /// Every option the field can suggest.
  ///
  /// An option is suggested when its display string contains the typed text,
  /// ignoring case. Nothing is suggested while the field is empty.
  final List<T> options;

  /// Turns an option into the text that is matched and shown in the list.
  final String Function(T option) displayStringForOption;

  /// Called with the option the user picks.
  final ValueChanged<T>? onSelected;

  /// The text the field starts with. See [Autocomplete.initialValue].
  final TextEditingValue? initialValue;

  /// Placeholder text shown while the field is empty. Defaults to
  /// 'Start typing...'.
  final String? hintText;

  /// A label shown before the field. Null shows no label.
  final String? labelText;

  /// The tallest the options list grows, in logical pixels, before it
  /// scrolls. Defaults to 220.
  final double optionsMaxHeight;

  /// The width of the options list in logical pixels. Defaults to 320.
  final double optionsWidth;

  /// Creates a hand-drawn autocomplete field.
  const WiredAutocomplete({
    super.key,
    required this.options,
    required this.displayStringForOption,
    this.onSelected,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.optionsMaxHeight = 220,
    this.optionsWidth = 320,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Autocomplete<T>(
        initialValue: initialValue,
        displayStringForOption: displayStringForOption,
        optionsBuilder: (textEditingValue) {
          final query = textEditingValue.text.trim().toLowerCase();
          if (query.isEmpty) return <T>[];

          return options.where((option) {
            return displayStringForOption(option).toLowerCase().contains(query);
          });
        },
        onSelected: onSelected,
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
              return Row(
                children: [
                  if (labelText != null) ...[
                    Text(labelText!),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WiredCanvas(
                              painter: WiredRectangleBase(
                                strokeWidth: theme.strokeWidth,
                                fillColor: theme.fillColor,
                                borderColor: theme.borderColor,
                              ),
                              fillerType: RoughFilter.noFiller,
                            ),
                          ),
                          TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: hintText ?? 'Start typing...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => onFieldSubmitted(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
        optionsViewBuilder: (context, onSelected, displayedOptions) {
          if (displayedOptions.isEmpty) return const SizedBox.shrink();

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: optionsWidth,
                constraints: BoxConstraints(maxHeight: optionsMaxHeight),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: WiredCanvas(
                        painter: WiredRoundedRectangleBase(
                          strokeWidth: theme.strokeWidth,
                          borderRadius: BorderRadius.circular(12),
                          borderColor: theme.borderColor,
                        ),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                    ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      children: displayedOptions.map((option) {
                        final label = displayStringForOption(option);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(color: theme.textColor),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
