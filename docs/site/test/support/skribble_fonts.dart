import 'dart:io';

import 'package:flutter/services.dart';

/// Loads every bundled skribble font family from the repository, so text in
/// tests and rendered frames uses the real typefaces instead of the test
/// font. Run from a package two levels below the repository root.
Future<void> loadSkribbleFonts() async {
  const root = '../../packages/skribble_font_recursive';
  String? family;
  final families = <String, List<String>>{};
  for (final line in File('$root/pubspec.yaml').readAsLinesSync()) {
    final name = RegExp(r'^\s*- family:\s*(\S+)').firstMatch(line);
    if (name != null) {
      family = name.group(1);
      families[family!] = [];
      continue;
    }
    final asset = RegExp(r'asset:\s*(\S+)').firstMatch(line);
    if (asset != null && family != null) families[family]!.add(asset.group(1)!);
  }
  for (final MapEntry(key: name, value: assets) in families.entries) {
    final loader = FontLoader('packages/skribble_font_recursive/$name');
    for (final asset in assets) {
      final bytes = File('$root/$asset').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}
