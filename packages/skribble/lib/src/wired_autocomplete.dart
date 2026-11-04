import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn wrapper around Flutter's [Autocomplete].
class WiredAutocomplete<T extends Object> extends HookWidget {
  /// Every option the field can suggest.
  final List<T> options;

  /// The text shown for, and matched against, each option.
  final String Function(T option) displayStringForOption;

  /// Called with the option the user picks.
  final ValueChanged<T>? onSelected;

  /// The field's starting text.
  final TextEditingValue? initialValue;

  /// Hint shown while the field is empty. Defaults to `Start typing...`.
  final String? hintText;

  /// A label written before the field.
  final String? labelText;

  /// The tallest the options list grows before it scrolls.
  final double optionsMaxHeight;

  /// The width of the options list.
  final double optionsWidth;

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
                            style: TextStyle(color: theme.textColor),
                            cursorColor: theme.borderColor,
                            decoration: InputDecoration(
                              // Desktop's compact density would take 4 pixels off each side of
                              // the padding, bringing text within the ink's breathing room.
                              visualDensity: VisualDensity.standard,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: hintText ?? 'Start typing...',
                              hintStyle: TextStyle(
                                color: theme.disabledTextColor,
                              ),
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
                    // The options float over the page, so they sit on the
                    // theme's paper instead of showing what is beneath.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.fillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
