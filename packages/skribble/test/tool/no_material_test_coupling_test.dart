import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps widget tests implemented against Skribble's public API.
///
/// Skribble's endgame is a standalone design system that no longer wraps
/// Material controls (see `AGENTS.md`, "Material decoupling direction").
/// A test that reaches for the wrapped control — `find.byType(Checkbox)`,
/// `tester.widget<TextButton>(...)` — cannot survive that rewrite and, worse,
/// passes while the Wired widget's own rendering, hit area, or semantics are
/// broken. `test/helpers/README.md` documents the replacement helpers and the
/// migration pattern.
///
/// This test scans every `*_test.dart` file under `test/` for type lookups
/// that name a Material or Cupertino class. The class list is derived from the
/// Flutter SDK that is running the suite, so it catches classes added by
/// Flutter upgrades too; when `FLUTTER_ROOT` is unavailable it falls back to a
/// curated list so the guard still runs in constrained environments.
void main() {
  test('widget tests do not name Material or Cupertino types', () {
    final packageRoot = _packageRoot();
    final banned = _bannedTypeNames();
    final violations = _scan(packageRoot, banned);

    final unexpected = <String, List<String>>{};
    for (final entry in violations.entries) {
      if (!_migrationBacklog.contains(entry.key)) {
        unexpected[entry.key] = entry.value;
      }
    }

    if (unexpected.isNotEmpty) {
      final details = unexpected.entries
          .map((entry) => '  ${entry.key}\n    ${entry.value.join('\n    ')}')
          .join('\n');
      fail(
        'New Material/Cupertino coupling in widget tests.\n\n'
        'These test files name a Flutter Material or Cupertino type in a '
        'type lookup:\n$details\n\n'
        "Assert against Skribble's public API instead. Use pumpWired / "
        'findWired / expectSemantics / expectPaints from '
        'test/helpers/skribble_test_support.dart; see test/helpers/README.md for the '
        'migration pattern.\n\n'
        'If a test genuinely must reference a Flutter type (for example the '
        'WiredMaterialApp bridge test), add its path to _migrationBacklog in '
        'this file with a comment explaining why.',
      );
    }
  });

  test('the migration backlog only lists files that still need it', () {
    final packageRoot = _packageRoot();
    final banned = _bannedTypeNames();
    final violations = _scan(packageRoot, banned);

    final stale = _migrationBacklog.difference(violations.keys.toSet()).toList()
      ..sort();

    if (stale.isNotEmpty) {
      fail(
        'The migration backlog in this file lists files with no remaining '
        'Material/Cupertino type lookups:\n'
        '${stale.map((path) => '  $path').join('\n')}\n\n'
        'Remove them from _migrationBacklog so the backlog keeps shrinking.',
      );
    }
  });

  test('the banned type list covers the Flutter SDK', () {
    if (Platform.environment['FLUTTER_ROOT'] == null) {
      // The curated fallback is used; nothing to verify.
      return;
    }
    expect(
      _bannedTypeNames().length,
      greaterThan(200),
      reason:
          'Expected the Material/Cupertino class list to be parsed from the '
          'running Flutter SDK.',
    );
  });
}

/// Test files that have not been migrated yet.
///
/// This is the migration backlog, not a permanent exemption. Every entry has
/// a comment naming the Flutter types it still references. Converting a file
/// removes its entry — the guard test above fails if an entry goes stale, so
/// the list can only shrink. Prefer converting a whole widget family at a
/// time, as the button, boolean-input, and value-input families were.
const Set<String> _migrationBacklog = <String>{
  'test/skribble_test.dart', // Checkbox, TextField
  'test/widgets/control_quality_test.dart', // Checkbox, Slider, TextField
  'test/widgets/wired_about_dialog_test.dart', // LicensePage
  'test/widgets/wired_animated_icon_test.dart', // AnimatedIcon
  'test/widgets/wired_autocomplete_test.dart', // TextField
  'test/widgets/wired_calendar_date_picker_test.dart', // CalendarDatePicker
  'test/widgets/wired_combo_test.dart', // DropdownButton
  'test/widgets/wired_cupertino_date_picker_test.dart', // CupertinoDatePicker
  'test/widgets/wired_cupertino_picker_test.dart', // CupertinoPicker
  'test/widgets/wired_cupertino_text_field_test.dart', // TextField
  'test/widgets/wired_data_table_test.dart', // InkWell
  'test/widgets/wired_date_picker_test.dart', // Dialog
  'test/widgets/wired_dialog_test.dart', // Dialog
  'test/widgets/wired_divider_test.dart', // Divider
  'test/widgets/wired_drawer_test.dart', // Drawer, Scaffold
  'test/widgets/wired_expansion_tile_test.dart', // InkWell
  'test/widgets/wired_form_test.dart', // TextFormField
  'test/widgets/wired_grid_tile_test.dart', // InkWell
  'test/widgets/wired_input_chip_test.dart', // CircleAvatar
  'test/widgets/wired_input_test.dart', // TextField
  'test/widgets/wired_license_page_test.dart', // BackButton
  'test/widgets/wired_list_tile_test.dart', // InkWell
  // Drives MaterialApp itself: the compatibility bridge is the subject here.
  'test/widgets/wired_material_app_test.dart', // MaterialApp
  'test/widgets/wired_material_banner_test.dart', // MaterialBanner
  'test/widgets/wired_menu_bar_test.dart', // Checkbox, DropdownMenu, MenuItemButton
  'test/widgets/wired_navigation_drawer_test.dart', // Drawer, Scaffold
  'test/widgets/wired_navigation_rail_test.dart', // FloatingActionButton
  'test/widgets/wired_popup_menu_test.dart', // PopupMenuButton
  'test/widgets/wired_progress_test.dart', // LinearProgressIndicator
  'test/widgets/wired_radio_list_tile_test.dart', // InkWell, Radio
  'test/widgets/wired_scaffold_test.dart', // Scaffold
  'test/widgets/wired_scrollbar_test.dart', // Scrollbar
  'test/widgets/wired_search_bar_test.dart', // TextField
  'test/widgets/wired_selectable_text_test.dart', // SelectableText
  'test/widgets/wired_snack_bar_test.dart', // SnackBar, TextButton
  'test/widgets/wired_switch_list_tile_test.dart', // InkWell
  'test/widgets/wired_text_area_test.dart', // TextField

  // Tests OF the compatibility layer are its subject: they must drive real
  // Material/Cupertino widgets to prove interop. Not migration backlog.
  'test/widgets/skribble_app_test.dart', // MaterialApp (interop + migration cases)
};

/// This file's path, relative to the package root, so the scan skips itself.
const String _guardTestPath = 'test/tool/no_material_test_coupling_test.dart';

/// Returns every violation as `path -> ['line N  find.byType(Checkbox)', ...]`.
Map<String, List<String>> _scan(
  Directory packageRoot,
  Set<String> banned,
) {
  final testDir = Directory('${packageRoot.path}/test');
  if (!testDir.existsSync()) {
    fail('Could not find the test directory at ${testDir.path}.');
  }

  final findLookup = RegExp(
    'find'
    r'\s*\.\s*byType\s*(?:<[^>]*>)?\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)',
  );
  final widgetLookup = RegExp(
    'tester'
    r'\s*\.\s*widget(?:List)?\s*<\s*([A-Za-z_][A-Za-z0-9_]*)\s*>',
  );

  final violations = <String, List<String>>{};
  for (final entity in testDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('_test.dart')) {
      continue;
    }
    final relative = _relativePath(packageRoot, entity);
    if (relative == _guardTestPath) {
      continue;
    }
    final source = entity.readAsStringSync();
    final lines = <int, Set<String>>{};
    for (final pattern in [findLookup, widgetLookup]) {
      for (final match in pattern.allMatches(source)) {
        final type = match.group(1)!;
        if (!banned.contains(type)) {
          continue;
        }
        final lineNumber =
            '\n'.allMatches(source.substring(0, match.start)).length + 1;
        (lines[lineNumber] ??= <String>{}).add(type);
      }
    }
    if (lines.isEmpty) {
      continue;
    }
    final sortedLines = lines.keys.toList()..sort();
    violations[relative] = [
      for (final line in sortedLines)
        'line $line: ${(lines[line]!.toList()..sort()).join(', ')}',
    ];
  }
  return violations;
}

/// Path of [file] relative to [root], with forward slashes.
String _relativePath(Directory root, File file) {
  final rootPath = root.path.endsWith(Platform.pathSeparator)
      ? root.path
      : '${root.path}${Platform.pathSeparator}';
  final relative = file.path.startsWith(rootPath)
      ? file.path.substring(rootPath.length)
      : file.path;
  return relative.replaceAll(Platform.pathSeparator, '/');
}

/// The directory that contains this package's `pubspec.yaml`.
///
/// Walks up from the working directory, then falls back to the workspace's
/// `packages/skribble` directory, so the guard works whether the suite is
/// started from the package or from the workspace root.
Directory _packageRoot() {
  var dir = Directory.current.absolute;
  while (true) {
    if (_isSkribbleRoot(dir)) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  final workspaceMember = Directory(
    '${Directory.current.absolute.path}'
    '${Platform.pathSeparator}packages${Platform.pathSeparator}skribble',
  );
  if (_isSkribbleRoot(workspaceMember)) {
    return workspaceMember;
  }
  fail(
    'Could not find the skribble package root near '
    '${Directory.current.path}.',
  );
}

/// Whether [dir] holds this package's `pubspec.yaml`.
bool _isSkribbleRoot(Directory dir) {
  final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
  return pubspec.existsSync() &&
      pubspec.readAsStringSync().contains('name: skribble');
}

/// Material and Cupertino class names, parsed from the running Flutter SDK
/// when available and otherwise taken from a curated list.
Set<String> _bannedTypeNames() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    return _fallbackBannedTypes;
  }
  final names = <String>{};
  for (final library in ['material', 'cupertino']) {
    final dir = Directory(
      '$flutterRoot/packages/flutter/lib/src/$library',
    );
    if (!dir.existsSync()) {
      continue;
    }
    final declaration = RegExp(
      r'^\s*(?:abstract\s+|sealed\s+|final\s+|base\s+|mixin\s+)*class\s+([A-Z][A-Za-z0-9_]*)',
      multiLine: true,
    );
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      for (final match in declaration.allMatches(entity.readAsStringSync())) {
        names.add(match.group(1)!);
      }
    }
  }
  return names.isEmpty ? _fallbackBannedTypes : names;
}

/// Curated Material/Cupertino widget names used when `FLUTTER_ROOT` is not
/// available. Keep this list focused on the controls tests are likely to
/// reach for; the SDK-derived list is authoritative when present.
const Set<String> _fallbackBannedTypes = <String>{
  'AlertDialog',
  'AnimatedIcon',
  'AppBar',
  'BackButton',
  'Badge',
  'BottomAppBar',
  'BottomNavigationBar',
  'BottomSheet',
  'CalendarDatePicker',
  'Card',
  'Checkbox',
  'CheckboxListTile',
  'Chip',
  'CircularProgressIndicator',
  'CupertinoActivityIndicator',
  'CupertinoAlertDialog',
  'CupertinoButton',
  'CupertinoDatePicker',
  'CupertinoNavigationBar',
  'CupertinoPicker',
  'CupertinoSegmentedControl',
  'CupertinoSlider',
  'CupertinoSwitch',
  'CupertinoTabBar',
  'CupertinoTextField',
  'Dialog',
  'Divider',
  'Drawer',
  'DropdownButton',
  'DropdownMenu',
  'ElevatedButton',
  'ExpansionTile',
  'FilledButton',
  'FloatingActionButton',
  'Form',
  'Icon',
  'IconButton',
  'InkWell',
  'LinearProgressIndicator',
  'ListTile',
  'Material',
  'MaterialApp',
  'MaterialBanner',
  'MenuBar',
  'MenuItemButton',
  'NavigationBar',
  'NavigationRail',
  'OutlinedButton',
  'PopupMenuButton',
  'Radio',
  'RadioListTile',
  'RangeLabels',
  'RangeSlider',
  'RangeValues',
  'Scaffold',
  'Scrollbar',
  'SegmentedButton',
  'SelectableText',
  'Slider',
  'SnackBar',
  'Stepper',
  'Switch',
  'SwitchListTile',
  'TabBar',
  'TextButton',
  'TextFormField',
  'TextField',
  'Theme',
  'ToggleButtons',
  'Tooltip',
};
