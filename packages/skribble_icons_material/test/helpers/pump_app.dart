import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// Pumps [widget] inside a [WiredTheme] wrapped in a [MaterialApp].
Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WiredTheme(
        data: WiredThemeData(),
        child: Scaffold(body: widget),
      ),
    ),
  );
}
