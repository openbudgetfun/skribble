import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A font-based icon widget for Skribble icons.
///
/// Renders icons using a TTF icon font instead of SVG paths.
/// This approach is more efficient for large icon sets as it
/// uses the same rendering pipeline as Flutter's built-in [Icon] widget.
///
/// ## Example
///
/// ```dart
/// SkribbleIconFont(
///   icon: SkribbleIconFontData(0xe001),
///   size: 24,
///   color: Colors.blue,
/// )
/// ```
class SkribbleIconFont extends HookWidget {
  /// The icon data containing the codepoint and font information.
  final SkribbleIconFontData icon;

  /// The size of the icon in logical pixels.
  final double? size;

  /// The color of the icon. Defaults to theme text color.
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Creates a font-based Skribble icon.
  const SkribbleIconFont({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = size ?? iconTheme.size ?? 24.0;
    final effectiveColor = color ?? iconTheme.color;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: Center(
          child: Text(
            String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontFamily: icon.fontFamily,
              fontSize: effectiveSize,
              color: effectiveColor,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for font-based Skribble icons.
///
/// Contains the codepoint and font family information needed
/// to render an icon from a TTF icon font.
class SkribbleIconFontData {
  /// The Unicode codepoint for the icon glyph.
  final int codePoint;

  /// The font family name containing the icon glyph.
  final String fontFamily;

  /// The font package containing the icon font file.
  final String? fontPackage;

  /// Creates icon font data.
  const SkribbleIconFontData(
    this.codePoint, {
    this.fontFamily = 'SkribbleIcons',
    this.fontPackage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkribbleIconFontData &&
          runtimeType == other.runtimeType &&
          codePoint == other.codePoint &&
          fontFamily == other.fontFamily &&
          fontPackage == other.fontPackage;

  @override
  int get hashCode => Object.hash(codePoint, fontFamily, fontPackage);

  @override
  String toString() =>
      'SkribbleIconFontData(0x${codePoint.toRadixString(16)}, $fontFamily)';
}

/// A collection of font-based Skribble icons.
///
/// This class provides access to all Skribble icons rendered
/// via a TTF icon font. The font must be included in the
/// project's assets.
///
/// ## Usage
///
/// ```dart
/// // In pubspec.yaml:
/// flutter:
///   fonts:
///     - family: SkribbleIcons
///       fonts:
///         - asset: packages/skribble_icons/assets/fonts/SkribbleIcons.ttf
///
/// // In code:
/// SkribbleIconFont(
///   icon: SkribbleIconFontIcons.home,
///   size: 24,
/// )
/// ```
class SkribbleIconFontIcons {
  SkribbleIconFontIcons._();

  /// Home icon.
  static const home = SkribbleIconFontData(0xe001);

  /// Search icon.
  static const search = SkribbleIconFontData(0xe002);

  /// Settings icon.
  static const settings = SkribbleIconFontData(0xe003);

  /// Person icon.
  static const person = SkribbleIconFontData(0xe004);

  /// Heart icon.
  static const heart = SkribbleIconFontData(0xe005);

  /// Star icon.
  static const star = SkribbleIconFontData(0xe006);

  /// Bell (notification) icon.
  static const bell = SkribbleIconFontData(0xe007);

  /// Mail icon.
  static const mail = SkribbleIconFontData(0xe008);

  /// Calendar icon.
  static const calendar = SkribbleIconFontData(0xe009);

  /// Camera icon.
  static const camera = SkribbleIconFontData(0xe00a);

  /// Check icon.
  static const check = SkribbleIconFontData(0xe00b);

  /// Close icon.
  static const close = SkribbleIconFontData(0xe00c);

  /// Add icon.
  static const add = SkribbleIconFontData(0xe00d);

  /// Remove icon.
  static const remove = SkribbleIconFontData(0xe00e);

  /// Edit icon.
  static const edit = SkribbleIconFontData(0xe00f);

  /// Delete icon.
  static const delete = SkribbleIconFontData(0xe010);

  /// Share icon.
  static const share = SkribbleIconFontData(0xe011);

  /// Bookmark icon.
  static const bookmark = SkribbleIconFontData(0xe012);

  /// Download icon.
  static const download = SkribbleIconFontData(0xe013);

  /// Upload icon.
  static const upload = SkribbleIconFontData(0xe014);
}
