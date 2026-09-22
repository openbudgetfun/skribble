import 'dart:convert';
import 'dart:io';

/// Adds static entrypoints so GitHub Pages can reload extensionless routes.
void main(List<String> args) {
  final output = Directory('build/web');

  if (args.contains('--defer-fonts')) {
    deferComparisonFonts(output);
  }

  final bootstrap = File('${output.path}/index.html').readAsStringSync();
  final pages = Directory('content')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'));

  for (final page in pages) {
    final route = page.path
        .substring('content/'.length)
        .replaceFirst(RegExp(r'\.md$'), '')
        .replaceFirst(RegExp(r'(^|/)index$'), '');
    if (route.isEmpty) continue;
    final target = File('${output.path}/$route/index.html');
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(bootstrap);
  }

  File('${output.path}/404.html').writeAsStringSync(bootstrap);
}

/// Keeps reading faces in the startup manifest and saves specimens for later.
void deferComparisonFonts(Directory output) {
  final assets = Directory('${output.path}/assets');
  final manifest = File('${assets.path}/FontManifest.json');
  final deferred = File('${assets.path}/DeferredFontManifest.json');
  final families = (jsonDecode(manifest.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final startup = <Map<String, dynamic>>[];
  final comparison = <Map<String, dynamic>>[];

  for (final family in families) {
    final name = family['family'] as String;
    final fonts = (family['fonts'] as List).cast<Map<String, dynamic>>();
    final isSkribble = name.startsWith('packages/skribble_font_recursive/');
    final isOriginal = name.startsWith('Recursive') &&
        name.endsWith('Original');

    if (!isSkribble && !isOriginal) {
      startup.add(family);
      continue;
    }

    final isReadingFamily = name.startsWith(
          'packages/skribble_font_recursive/Skribble',
        ) &&
        !name.contains('Linear') &&
        !name.contains('Variable');

    if (isReadingFamily) {
      final isCasual = !name.contains('Mono');
      // Ordinary docs typography uses these faces. The comparison page loads
      // the remaining weights and styles when it needs them.
      final readingFaces = fonts.where((font) {
        final weight = font['weight'];
        final italic = font['style'] == 'italic';
        return weight == 400 ||
            weight == 700 ||
            (isCasual && !italic &&
                (weight == 500 || weight == 600 || weight == 800));
      }).toList();
      startup.add({...family, 'fonts': readingFaces});
      final remainingFaces = fonts
          .where((font) => !readingFaces.contains(font))
          .toList();
      if (remainingFaces.isNotEmpty) {
        comparison.add({...family, 'fonts': remainingFaces});
      }
    } else {
      comparison.add(family);
    }
  }

  if (comparison.isEmpty && deferred.existsSync()) return;

  manifest.writeAsStringSync(jsonEncode(startup));
  deferred.writeAsStringSync(jsonEncode(comparison));
}
