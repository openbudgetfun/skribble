import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [widget] inside a [MaterialApp] → [Scaffold] wrapper.
///
/// By default the widget is placed in [Scaffold.body]. Use the named
/// parameters to place it in other Scaffold slots instead:
///
/// <!-- {=docsPumpAppExample|trim|linePrefix:"/// "} -->
/// ```dart
/// // Static example: test
/// // Body slot (default)
/// await pumpApp(tester, myWidget);

/// // AppBar slot
/// await pumpApp(tester, WiredAppBar(title: Text('T')), asAppBar: true);

/// // BottomNavigationBar slot
/// await pumpApp(tester, myNavBar, asBottomNav: true);

/// // Drawer slot
/// await pumpApp(tester, WiredDrawer(child: Text('X')), asDrawer: true);

/// // With custom theme
/// await pumpApp(
///   tester,
///   myWidget,
///   theme: WiredThemeData(borderColor: Colors.red),
/// );
/// ```
/// <!-- {/docsPumpAppExample} -->
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
  bool asAppBar = false,
  bool asBottomNav = false,
  bool asDrawer = false,
  Widget? body,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: asAppBar ? widget as PreferredSizeWidget : null,
        body: asAppBar || asBottomNav || asDrawer
            ? body ?? const SizedBox.shrink()
            : widget,
        bottomNavigationBar: asBottomNav ? widget : null,
        drawer: asDrawer ? widget : null,
      ),
    ),
  );
}
