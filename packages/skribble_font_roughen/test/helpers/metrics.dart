import 'dart:typed_data';

import 'package:skribble_font_roughen/src/truetype_font.dart';

/// Advance widths remain stable even when changed outlines need new bearings.
List<int> advances(TrueTypeFont font) {
  final count = ByteData.sublistView(font.tables['hhea']!).getUint16(34);
  final data = ByteData.sublistView(font.tables['hmtx']!);
  return [for (var i = 0; i < count; i++) data.getUint16(i * 4)];
}
