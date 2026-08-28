import 'dart:math' as math;

import '../wired_svg_icon_data.dart';

/// A utility for optimizing pre-computed icon maps.
///
/// This class provides methods for reducing the memory footprint
/// of pre-computed icon maps by:
/// - Removing duplicate primitives
/// - Simplifying path data
/// - Compressing coordinate precision
///
/// ## Example
///
/// ```dart
/// final optimizer = IconOptimizer();
/// final optimized = optimizer.optimize(iconData);
/// print('Saved ${iconData.estimatedSize - optimized.estimatedSize} bytes');
/// ```
class IconOptimizer {
  /// The decimal precision for coordinate values.
  final int precision;

  /// Creates an icon optimizer with the specified precision.
  const IconOptimizer({this.precision = 2});

  /// Optimizes a single [WiredSvgIconData] by reducing its size.
  ///
  /// Returns a new [WiredSvgIconData] with optimized primitives.
  WiredSvgIconData optimize(WiredSvgIconData iconData) {
    final optimizedPrimitives = iconData.primitives
        .map(_optimizePrimitive)
        .toList();

    return WiredSvgIconData(
      width: iconData.width,
      height: iconData.height,
      primitives: optimizedPrimitives,
    );
  }

  /// Optimizes a map of icons by reducing each icon's size.
  ///
  /// Returns a new map with optimized icons.
  Map<int, WiredSvgIconData> optimizeMap(Map<int, WiredSvgIconData> icons) {
    final optimized = <int, WiredSvgIconData>{};

    for (final entry in icons.entries) {
      optimized[entry.key] = optimize(entry.value);
    }

    return optimized;
  }

  /// Estimates the memory size of an icon in bytes.
  int estimateSize(WiredSvgIconData iconData) {
    int size = 0;

    // Width and height (8 bytes each)
    size += 16;

    // Primitives
    for (final primitive in iconData.primitives) {
      size += _estimatePrimitiveSize(primitive);
    }

    return size;
  }

  /// Estimates the total memory size of an icon map in bytes.
  int estimateMapSize(Map<int, WiredSvgIconData> icons) {
    int totalSize = 0;

    for (final icon in icons.values) {
      totalSize += estimateSize(icon);
    }

    return totalSize;
  }

  WiredSvgPrimitive _optimizePrimitive(WiredSvgPrimitive primitive) {
    return switch (primitive) {
      WiredSvgPathPrimitive() => _optimizePath(primitive),
      WiredSvgCirclePrimitive() => _optimizeCircle(primitive),
      WiredSvgEllipsePrimitive() => _optimizeEllipse(primitive),
    };
  }

  WiredSvgPrimitive _optimizePath(WiredSvgPrimitive primitive) {
    if (primitive is! WiredSvgPathPrimitive) return primitive;

    // Simplify path by reducing coordinate precision
    final simplified = _simplifyPathData(primitive.data);

    return WiredSvgPrimitive.path(simplified);
  }

  WiredSvgPrimitive _optimizeCircle(WiredSvgPrimitive primitive) {
    // Circles are already compact
    return primitive;
  }

  WiredSvgPrimitive _optimizeEllipse(WiredSvgPrimitive primitive) {
    // Ellipses are already compact
    return primitive;
  }

  String _simplifyPathData(String pathData) {
    final buffer = StringBuffer();
    final chars = pathData.split('');
    int i = 0;

    while (i < chars.length) {
      final char = chars[i];

      // If it's a letter (command), add it
      if (_isCommand(char)) {
        buffer.write(char);
        i++;
      }
      // If it's a digit, dot, or minus, parse the number
      else if (_isDigit(char) || char == '.' || char == '-') {
        final numberStr = _parseNumber(chars, i);
        final number = double.tryParse(numberStr);

        if (number != null) {
          // Round to specified precision
          final rounded = _roundToPrecision(number, precision);
          buffer.write(rounded);
        } else {
          buffer.write(numberStr);
        }

        i += numberStr.length;
      }
      // Skip whitespace and commas
      else if (char == ' ' || char == ',') {
        buffer.write(' ');
        i++;
      } else {
        buffer.write(char);
        i++;
      }
    }

    return buffer.toString();
  }

  String _parseNumber(List<String> chars, int start) {
    final buffer = StringBuffer();
    int i = start;

    // Handle negative sign
    if (i < chars.length && chars[i] == '-') {
      buffer.write(chars[i]);
      i++;
    }

    // Parse digits before decimal
    while (i < chars.length && _isDigit(chars[i])) {
      buffer.write(chars[i]);
      i++;
    }

    // Parse decimal point and digits after
    if (i < chars.length && chars[i] == '.') {
      buffer.write(chars[i]);
      i++;

      while (i < chars.length && _isDigit(chars[i])) {
        buffer.write(chars[i]);
        i++;
      }
    }

    return buffer.toString();
  }

  bool _isCommand(String char) {
    return 'MmLlHhVvCcSsQqTtAaZz'.contains(char);
  }

  bool _isDigit(String char) {
    return '0123456789'.contains(char);
  }

  double _roundToPrecision(double value, int precision) {
    final factor = math.pow(10, precision).toDouble();
    return (value * factor).round() / factor;
  }

  int _estimatePrimitiveSize(WiredSvgPrimitive primitive) {
    return switch (primitive) {
      WiredSvgPathPrimitive(:final data) => data.length + 8,
      WiredSvgCirclePrimitive() => 24, // cx, cy, r (8 bytes each)
      WiredSvgEllipsePrimitive() => 32, // cx, cy, rx, ry (8 bytes each)
    };
  }
}

/// Extension methods for [WiredSvgIconData] size estimation.
extension WiredSvgIconDataExtension on WiredSvgIconData {
  /// Estimates the memory size of this icon in bytes.
  int get estimatedSize {
    return IconOptimizer().estimateSize(this);
  }
}
