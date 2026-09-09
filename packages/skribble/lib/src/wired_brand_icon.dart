import 'generated/brand_rough_icons.g.dart';
import 'wired_svg_icon_data.dart';

/// Curated Simple Icons artwork for use with WiredSvgIcon.
///
/// These vector paths use the ambient roughness and icon fill style.
/// Source artwork and attribution live in `tool/brands`.
enum WiredBrandIcon {
  /// GitHub's mark.
  github(0xf001),

  /// The Dart language mark.
  dart(0xf002),

  /// The Flutter mark.
  flutter(0xf003),

  /// The Figma mark.
  figma(0xf004);

  const WiredBrandIcon(this._codePoint);
  final int _codePoint;

  /// Vector artwork, ready for a WiredSvgIcon.
  WiredSvgIconData get data => kBrandRoughIcons[_codePoint]!;
}
