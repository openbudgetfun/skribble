// Material dependency audit for the Skribble design system.
//
// Scans packages/skribble/lib for imports of package:flutter/material.dart and
// package:flutter/cupertino.dart and classifies how each file uses them:
//
//   skin      – wraps/extends a Material or Cupertino widget (transition debt;
//               must be rewritten to reach a zero-Material endgame)
//   helpers   – only uses theme/geometry/constants (e.g. ThemeData, EdgeInsets,
//               Colors) with no Material widget in the public surface
//
// Usage (from the repo root):
//   dart run tool/audit_material_dependencies.dart            # human table
//   dart run tool/audit_material_dependencies.dart --json     # machine output
//
// The zero-Material endgame: packages/skribble must import only
// flutter/widgets.dart and below, making Skribble a peer of
// package:material_ui / package:cupertino_ui instead of a skin over them.

// CLI audit: prints are the output.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const _libRoot = 'packages/skribble/lib';

void main(List<String> args) {
  final asJson = args.contains('--json');
  final files =
      Directory(_libRoot)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final results = <Map<String, String>>[];
  var materialCount = 0;
  var cupertinoCount = 0;

  for (final file in files) {
    final source = file.readAsStringSync();
    final usesMaterial =
        source.contains("'package:flutter/material.dart'") ||
        source.contains('"package:flutter/material.dart"');
    final usesCupertino =
        source.contains("'package:flutter/cupertino.dart'") ||
        source.contains('"package:flutter/cupertino.dart"');
    if (!usesMaterial && !usesCupertino) continue;
    if (usesMaterial) materialCount++;
    if (usesCupertino) cupertinoCount++;

    results.add({
      'file': file.path,
      'framework': [
        if (usesMaterial) 'material',
        if (usesCupertino) 'cupertino',
      ].join('+'),
      'classification': _classifyWrapsMaterial(source) ? 'skin' : 'helpers',
    });
  }

  if (asJson) {
    print(
      jsonEncode({
        'totalFilesScanned': files.length,
        'filesImportingMaterial': materialCount,
        'filesImportingCupertino': cupertinoCount,
        'files': results,
      }),
    );
    return;
  }

  stdout.writeln(
    'Material dependency audit — ${results.length} of '
    '${files.length} files import material/cupertino\n',
  );
  final skins = results.where((r) => r['classification'] == 'skin').length;
  final helpers = results.where((r) => r['classification'] == 'helpers').length;
  print('  skin     (wraps a Material/Cupertino widget): $skins');
  print('  helpers  (constants/theme only):              $helpers\n');
  for (final r in results) {
    print(
      '${r['classification']!.padRight(9)} ${r['framework']!.padRight(16)} '
      '${r['file']}',
    );
  }
  print(
    '\nTarget: 0 files. Track progress with: '
    'dart run tool/audit_material_dependencies.dart',
  );
}

/// Heuristic: does the file construct or wrap a Material/Cupertino widget
/// class (as opposed to only importing helpers)? Detects common widget
/// class usages that indicate skin-debt rather than incidental helpers.
bool _classifyWrapsMaterial(String source) {
  const widgetNames = [
    // App scaffolding
    'MaterialApp', 'WidgetsApp', 'Scaffold', 'AppBar', 'Theme(',
    'ThemeData', 'DropdownButton', 'DropdownButtonFormField',
    'DropdownMenu', 'Dialog(', 'AlertDialog', 'SimpleDialog',
    'SnackBar(', 'InkWell(', 'InkResponse', 'Material(',
    'TextField(', 'TextFormField', 'TextSelectionTheme',
    'Scrollbar(', 'RefreshIndicator(', 'TabBar(', 'TabBarView(',
    'ExpansionTile(', 'Stepper(', 'DataTable(', 'PopupMenuButton(',
    'Chip(', 'SliderTheme', 'ProgressIndicator(', 'DatePickerDialog(',
    'TimePickerDialog', 'NavigationRail', 'NavigationBar(', 'BottomAppBar(',
    'ReorderableListView(', 'AboutDialog(', 'LicensePage(',
    'MaterialBanner(', 'MenuAnchor(', 'SearchAnchor', 'SegmentedButton(',
    'Tooltip(', 'ListTile(', 'PopupMenuItem', 'DropdownMenuItem',
    'MaterialState', 'WidgetState',
  ];
  for (final name in widgetNames) {
    if (source.contains(name)) return true;
  }
  // Extends or implements a Material base class.
  if (RegExp(
    r'(extends|implements)\s+(Stateless|Stateful)?\w*'
    '(Material|Ink)',
  ).hasMatch(source)) {
    return true;
  }
  return false;
}
