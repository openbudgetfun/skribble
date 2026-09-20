// Material dependency audit for the skribble design system.
//
// Scans packages/skribble/lib for imports of package:flutter/material.dart and
// package:flutter/cupertino.dart and classifies how each file uses them:
//
//   skin      – wraps/extends a Material or Cupertino widget (transition debt;
//               must be rewritten to reach a zero-Material endgame)
//   helpers   – only uses theme/geometry/constants (e.g. ThemeData, EdgeInsets,
//               Colors) with no Material widget in the public surface
//   compat    – lives in lib/src/compat/, the sanctioned compatibility layer.
//               These files exist to keep Material/Cupertino interop working
//               during migration and are expected to import Material.
//
// Usage (from the repo root):
//   dart run tool/audit_material_dependencies.dart            # human table
//   dart run tool/audit_material_dependencies.dart --json     # machine output
//
//   # Freeze today's counts as the ceiling CI enforces:
//   dart run tool/audit_material_dependencies.dart \
//       --write-baseline docs/material-dependency-baseline.json
//
//   # CI gate: fail if any count rises above the committed baseline. Debt may
//   # go down freely; it may never go up.
//   dart run tool/audit_material_dependencies.dart \
//       --check --baseline docs/material-dependency-baseline.json
//
// The zero-Material endgame: packages/skribble core must import only
// flutter/widgets.dart and below, making skribble a peer of
// package:material_ui / package:cupertino_ui instead of a skin over them. Only
// skin + helpers count against that target; compat is the deliberate,
// quarantined exception (see lib/src/compat/compat.dart).

// CLI audit: prints are the output.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const _libRoot = 'packages/skribble/lib';
const _compatPathFragment = '$_libRoot/src/compat/';

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
      'classification': file.path.contains(_compatPathFragment)
          ? 'compat'
          : _classifyWrapsMaterial(source)
          ? 'skin'
          : 'helpers',
    });
  }

  final skins = results.where((r) => r['classification'] == 'skin').length;
  final helpers = results.where((r) => r['classification'] == 'helpers').length;
  final compat = results.where((r) => r['classification'] == 'compat').length;
  final core = skins + helpers;

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

  final writePath = _optionValue(args, '--write-baseline');
  if (writePath != null) {
    File(writePath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({
        'core': core,
        'skin': skins,
        'helpers': helpers,
        'compat': compat,
      })}\n',
    );
    print(
      'Baseline written to $writePath: $core core files '
      '($skins skin, $helpers helpers) and $compat compat files.',
    );
    return;
  }

  if (args.contains('--check')) {
    exitCode = _checkBaseline(
      args,
      core: core,
      skins: skins,
      helpers: helpers,
      compat: compat,
    );
    if (exitCode != 0) return;
    print('');
  }

  stdout.writeln(
    'Material dependency audit — $core core files and $compat compat files '
    'import material/cupertino\n',
  );
  print('  skin     (wraps a Material/Cupertino widget): $skins');
  print('  helpers  (constants/theme only):              $helpers');
  print('  compat   (sanctioned interop layer):          $compat');
  print('  core total (target: 0):                       $core\n');
  for (final r in results) {
    print(
      '${r['classification']!.padRight(9)} ${r['framework']!.padRight(16)} '
      '${r['file']}',
    );
  }
  print(
    '\nTarget: 0 core files (lib/src/compat is exempt). Track progress with: '
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

/// Compares the current counts against the committed baseline and returns the
/// process exit code: 0 when no counter rose above its allowed ceiling, 1 when
/// it did, 2 when the baseline cannot be used.
int _checkBaseline(
  List<String> args, {
  required int core,
  required int skins,
  required int helpers,
  required int compat,
}) {
  final path = _optionValue(args, '--baseline');
  if (path == null) {
    stderr.writeln('--check requires --baseline <path>.');
    return 2;
  }
  final baselineFile = File(path);
  if (!baselineFile.existsSync()) {
    stderr
      ..writeln('Baseline file not found: $path')
      ..writeln(
        'Create it with: dart run tool/audit_material_dependencies.dart '
        '--write-baseline $path',
      );
    return 2;
  }
  final baseline =
      jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>;

  final regressions = <String>[];
  void compare(String label, int current, int allowed) {
    if (current > allowed) {
      regressions.add('$label: $current (baseline allows $allowed)');
    }
  }

  compare(
    'core files importing material/cupertino',
    core,
    baseline['core'] as int,
  );
  compare(
    'skin (wraps a Material/Cupertino widget)',
    skins,
    baseline['skin'] as int,
  );
  compare(
    'helpers (constants/theme only)',
    helpers,
    baseline['helpers'] as int,
  );
  compare(
    'compat (sanctioned interop layer)',
    compat,
    baseline['compat'] as int,
  );

  if (regressions.isNotEmpty) {
    stderr.writeln('Material dependency audit regressed past the baseline:');
    for (final regression in regressions) {
      stderr.writeln('  $regression');
    }
    stderr
      ..writeln()
      ..writeln('New code must not import material/cupertino (see AGENTS.md),')
      ..writeln(
        'and only lib/src/compat/ may import it deliberately. Rewrite the',
      )
      ..writeln(
        'offending files, or — only if the baseline itself is genuinely',
      )
      ..writeln('stale — refresh it and explain the increase in the PR:')
      ..writeln(
        '  dart run tool/audit_material_dependencies.dart --write-baseline $path',
      );
    return 1;
  }

  stdout.writeln(
    'Material dependency audit within baseline: $core core files '
    '(ceiling ${baseline['core']}), $skins skin (ceiling ${baseline['skin']}), '
    '$helpers helpers (ceiling ${baseline['helpers']}), $compat compat '
    '(ceiling ${baseline['compat']}).',
  );
  return 0;
}

/// Returns the value following a flag such as `--baseline`, or null when the
/// flag is absent or has no value.
String? _optionValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
