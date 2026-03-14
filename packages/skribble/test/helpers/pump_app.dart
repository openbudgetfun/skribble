import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [widget] inside a [MaterialApp] → [Scaffold] wrapper.
///
/// Optionally applies a custom `ThemeData` via [theme].
///
/// ```dart
/// await pumpApp(tester, WiredButton(onPressed: () {}, child: Text('Hi')));
/// ```
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: widget),
    ),
  );
}
