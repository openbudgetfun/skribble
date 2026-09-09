import 'dart:io';

/// Adds static entrypoints so GitHub Pages can reload extensionless routes.
void main() {
  final output = Directory('build/web');
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
