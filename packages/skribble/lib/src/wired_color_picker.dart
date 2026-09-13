import 'package:flutter/widgets.dart';
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
  ///
  /// Defaults to the Material palette swatches, written as raw ARGB values so
  /// this file keeps a widgets-only import; the values match `Colors.red`,
  /// `Colors.pink`, and so on. A `MaterialColor` such as `Colors.blue` still
  /// compares equal to its entry because `Color` equality uses the resolved
  /// value.
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
      Color(0xFFF44336), // Colors.red
      Color(0xFFE91E63), // Colors.pink
      Color(0xFF9C27B0), // Colors.purple
      Color(0xFF673AB7), // Colors.deepPurple
      Color(0xFF3F51B5), // Colors.indigo
      Color(0xFF2196F3), // Colors.blue
      Color(0xFF03A9F4), // Colors.lightBlue
      Color(0xFF00BCD4), // Colors.cyan
      Color(0xFF009688), // Colors.teal
      Color(0xFF4CAF50), // Colors.green
      Color(0xFF8BC34A), // Colors.lightGreen
      Color(0xFFCDDC39), // Colors.lime
      Color(0xFFFFEB3B), // Colors.yellow
      Color(0xFFFFC107), // Colors.amber
      Color(0xFFFF9800), // Colors.orange
      Color(0xFFFF5722), // Colors.deepOrange
      Color(0xFF795548), // Colors.brown
      Color(0xFF9E9E9E), // Colors.grey
      Color(0xFF607D8B), // Colors.blueGrey
      Color(0xFF000000), // Colors.black
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
                strokeWidth: theme.strokeWidth,
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
                icon: _checkIcon,
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
    return color.computeLuminance() > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }
}

/// `Icons.check` as a raw codepoint so this file stays widgets-only.
const IconData _checkIcon = IconData(0xe156, fontFamily: 'MaterialIcons');
