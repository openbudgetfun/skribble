import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Renders every sampled icon of each generated catalog to its own PNG tile
/// plus an HTML gallery, so the baked geometry can be reviewed in a browser
/// with real text labels.
///
/// Writing ~750 files per run is review work, not CI work, so this is a no-op
/// unless ICON_GALLERY is set:
///
/// ```sh
/// ICON_GALLERY=1 flutter test test/icon_gallery_test.dart
/// ```
void main() {
  testWidgets('render icon catalog tiles', (tester) async {
    if (!Platform.environment.containsKey('ICON_GALLERY')) {
      return;
    }
    // Material identifier lookups go through the registered catalog.
    registerSkribbleIcons();

    const outRoot = '../../.screenshots/icons';
    Directory(outRoot).createSync(recursive: true);

    const sets = <String, WiredSvgIconData? Function(String)>{
      'curated': lookupSkribbleCuratedIconByIdentifier,
      'simple': lookupSimpleIconByIdentifier,
      'lucide': lookupLucideIconByIdentifier,
      'bxs': lookupBxsIconByIdentifier,
      'cib': lookupCibIconByIdentifier,
      'material': lookupMaterialRoughIconByIdentifier,
    };
    final totals = <String, int>{
      'curated': skribbleCuratedIconCount,
      'simple': simpleIconCount,
      'lucide': lucideIconCount,
      'bxs': bxsIconCount,
      'cib': cibIconCount,
      'material': skribbleMaterialIconCount,
    };
    const samples = <String, int>{
      'curated': 30,
      'simple': 144,
      'lucide': 144,
      'bxs': 144,
      'cib': 144,
      'material': 144,
    };

    for (final entry in sets.entries) {
      final setName = entry.key;
      final lookup = entry.value;
      final all = switch (setName) {
        'curated' => skribbleCuratedIconIdentifiers,
        'simple' => simpleIconIdentifiers,
        'lucide' => lucideIconIdentifiers,
        'bxs' => bxsIconIdentifiers,
        'cib' => cibIconIdentifiers,
        _ => materialRoughIconIdentifiers,
      }..sort();

      // Material declares a few identifiers whose codepoint has no geometry
      // (the unresolved baseline), so sample only identifiers that resolve.
      final resolvable = [
        for (final id in all)
          if (lookup(id) != null) id,
      ];
      final wanted = samples[setName]!;
      final step = resolvable.length / wanted;
      final identifiers = [
        for (var i = 0; i < wanted; i++) resolvable[(i * step).floor()],
      ];

      final setDir = Directory('$outRoot/$setName')..createSync(recursive: true);

      // One pump per set; each cell carries its own RepaintBoundary so the
      // capture loop below only pays for toImage.
      await tester.binding.setSurfaceSize(const Size(120, 120));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WiredTheme(
            data: WiredThemeData(),
            child: Stack(
              children: [
                for (var i = 0; i < identifiers.length; i++)
                  RepaintBoundary(
                    key: ValueKey('tile-$i'),
                    child: Container(
                      color: const Color(0xFFFBF8F1),
                      alignment: Alignment.center,
                      child: WiredSvgIcon(
                        data: lookup(identifiers[i])!,
                        size: 48,
                        color: const Color(0xFF2B2930),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.binding.runAsync(() async {
        for (var i = 0; i < identifiers.length; i++) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(ValueKey('tile-$i'), skipOffstage: false),
          );
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '${setDir.path}/${identifiers[i].replaceAll('/', '_')}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        }
      });

      final html = StringBuffer()
        ..writeln('<!DOCTYPE html><html><head><meta charset="utf-8">')
        ..writeln('<title>$setName icons</title><style>')
        ..writeln(
          'body{font-family:system-ui;margin:24px;background:#fffdf6;'
          'color:#2b2930}',
        )
        ..writeln('.grid{display:flex;flex-wrap:wrap;gap:12px}')
        ..writeln(
          '.card{width:110px;text-align:center;font-size:11px;'
          'border:1px dashed #a39aad;border-radius:6px;padding:8px 4px;}',
        )
        ..writeln('.card img{width:48px;height:48px}')
        ..writeln(
          '.card div{overflow:hidden;text-overflow:ellipsis; '
          'white-space:nowrap}',
        )
        ..writeln('</style></head><body>')
        ..writeln(
          '<h1>$setName</h1><p>${identifiers.length} of '
          '${totals[setName]} identifiers, sampled evenly from the sorted '
          'list.</p><div class="grid">',
      );
      for (final id in identifiers) {
        html.writeln(
          '<div class="card"><img src="$setName/'
          '${Uri.encodeComponent(id.replaceAll('/', '_'))}.png" '
          'alt="$id"><div>$id</div></div>',
        );
      }
      html
        ..writeln('</div></body></html>')
        ..writeln();
      File('$outRoot/$setName.html').writeAsStringSync(html.toString());

      stdout.writeln(
        'wrote $setName: ${identifiers.length} tiles of ${totals[setName]}',
      );
      expect(identifiers, isNotEmpty);
    }
  });
}
