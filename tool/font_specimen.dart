import 'dart:io';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';

/// Writes comparison specimens for all four bundled font styles.
Future<void> main() async {
  for (final variant in FontVariant.values) {
    final suffix = variant.fullNameSuffix.replaceAll(' ', '');
    final result = await VisualDiff(
      originalPath:
          'packages/skribble/tool/font/RecursiveSansCslSt-$suffix.ttf',
      roughenedPath: 'packages/skribble/assets/fonts/Skribble-$suffix.ttf',
      outputPath: '.screenshots/font/$suffix.html',
      sampleText: 'Little plans, big days.\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789 & @ # £ € ¥ + − × ÷\nÀ bientôt! Café, piñata, naïve, über.',
      fontSize: 32,
    ).compare();
    stdout.writeln(
      '$suffix: ${result.differenceCount} changed points; ${result.outputPath}',
    );
  }
}
