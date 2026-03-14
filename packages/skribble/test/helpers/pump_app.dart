import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [widget] inside a [MaterialApp] → [Scaffold] wrapper.
///
/// By default the widget is placed in [Scaffold.body]. Use the named
/// parameters to place it in other Scaffold slots instead:
///
/// ```dart
/// // body (default)
/// await pumpApp(tester, WiredButton(child: Text('Hi'), onPressed: () {}));
///
/// // appBar slot
/// await pumpApp(tester, WiredAppBar(title: Text('Title')), asAppBar: true);
///
/// // bottomNavigationBar slot
/// await pumpApp(tester, myNavBar, asBottomNav: true);
///
/// // drawer slot
/// await pumpApp(tester, WiredDrawer(child: Text('Menu')), asDrawer: true);
/// ```
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
