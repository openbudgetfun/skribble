import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A hand-drawn color picker with a grid of selectable color swatches.
///
/// Each swatch is rendered as a sketchy circle with hachure fill.
class WiredColorPicker extends HookWidget {
  /// The currently selected color.
  final Color selectedColor;

  /// Called when a color is selected.
  final ValueChanged<Color>? onColorChanged;

  /// The list of available colors.
  final List<Color> colors;

  /// Size of each color swatch.
  final double swatchSize;

  /// Spacing between swatches.
  final double spacing;

  /// Number of swatches per row.
  final int crossAxisCount;

  const WiredColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    this.colors = const [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ],
    this.swatchSize = 36,
    this.spacing = 8,
    this.crossAxisCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Stack(
        children: [
          // Outer border
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(12),
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final color in colors)
                  _ColorSwatch(
                    color: color,
                    isSelected: color.value == selectedColor.value,
                    size: swatchSize,
                    onTap: onColorChanged != null
                        ? () => onColorChanged!(color)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends HookWidget {
  final Color color;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sketchy circle swatch
            WiredCanvas(
              painter: WiredCircleBase(
                fillColor: color,
                strokeWidth: isSelected ? 3 : 1.5,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.hachureFiller,
              fillerConfig: FillerConfig.build(hachureGap: 2.0),
            ),
            // Check mark for selected
            if (isSelected)
              WiredIcon(
                icon: Icons.check,
                color: _contrastColor(color),
                size: size * 0.5,
                fillStyle: WiredIconFillStyle.solid,
                strokeWidth: 1.2,
              ),
          ],
        ),
      ),
    );
  }

  Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
