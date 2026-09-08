import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:skribble_emoji_gen/svg_shapes.dart';
import 'package:xml/xml.dart';

/// Generates the curated rough icon catalog from its checked-in SVG manifest.
Future<void> main(List<String> arguments) async {
  final manifest = File(
    'packages/skribble_icons/tool/skribble_icons.manifest.json',
  );
  final data =
      jsonDecode(await manifest.readAsString()) as Map<String, Object?>;
  final icons = data['icons']! as List<Object?>;
  final output = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln('const Map<int, WiredSvgIconData> kSkribbleCustomIconsRough = {');

  for (final item in icons.cast<Map<String, Object?>>()) {
    final source = p.normalize(
      p.join(manifest.parent.path, item['svgPath']! as String),
    );
    final root = XmlDocument.parse(File(source).readAsStringSync()).rootElement;
    final viewBox = root.getAttribute('viewBox')!.split(RegExp(r'[ ,]+'));
    final shapes = extractShapes(source);
    output
      ..writeln('  ${item['codePoint']}: WiredSvgIconData(')
      ..writeln(
        '    width: ${viewBox[2]}, height: ${viewBox[3]}, primitives: [',
      );

    for (final shape in shapes) {
      output.writeln(
        "      WiredSvgPrimitive.path('${shape.data}', fillRule: WiredSvgFillRule.${shape.evenOdd ? 'evenOdd' : 'nonZero'}),",
      );
    }
    output.writeln('  ]),');
  }
  output.writeln('};');
  final destination = File(
    'packages/skribble_icons/lib/src/generated/skribble_icons_rough.g.dart',
  );
  await destination.writeAsString(output.toString());
  stdout.writeln(
    'Generated ${icons.length} custom icons in their source viewBox.',
  );
}
