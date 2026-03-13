import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn wrapper around Flutter's [Autocomplete].
class WiredAutocomplete<T extends Object> extends HookWidget {
  final List<T> options;
  final String Function(T option) displayStringForOption;
  final ValueChanged<T>? onSelected;
  final TextEditingValue? initialValue;
  final String? hintText;
  final String? labelText;
  final double optionsMaxHeight;
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
                    child: SizedBox(
                      height: 48,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WiredCanvas(
                              painter: WiredRectangleBase(
                                fillColor: theme.fillColor,
                              ),
                              fillerType: RoughFilter.noFiller,
                            ),
                          ),
                          TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: hintText ?? 'Start typing...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
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
                          borderRadius: BorderRadius.circular(12),
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
