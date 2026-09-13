import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

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
///
/// Prefer [pumpWired] for new tests. It will become the only host once the
/// widgets stop wrapping Material controls, whereas this function exposes
/// Material slots that new tests should not depend on.
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

/// Pumps [widget] under the host a Skribble widget needs to render.
///
/// Use this instead of [pumpApp] for new tests and when converting existing
/// ones. It applies the four ambient facts every widget should be resilient
/// to, and lets a test vary exactly one of them at a time:
///
/// * a [WiredTheme] (`theme`, defaulting to [WiredThemeData] defaults),
/// * a [Directionality] (`textDirection`),
/// * a [MediaQuery] text scale (`textScaler`),
/// * a bounded surface to lay out inside (`surfaceSize`).
///
/// The widget is aligned inside that surface with [alignment].
///
/// ## Why this helper exists
///
/// Tests must describe the host their subject needs, not the Material widgets
/// the current implementation happens to wrap. Today the host still contains
/// Material scaffolding because Skribble widgets delegate leaf rendering to
/// Material controls; when that transitional layer is removed the host shrinks
/// here, in one place, and every call site keeps working. If a test built its
/// own `MaterialApp`/`Scaffold` it would have to change with the rewrite and
/// would silently start asserting against Material again.
///
/// Pass [theme] to exercise a specific [WiredThemeData]; pass [textDirection]
/// or [textScaler] only when the test is *about* that dimension (otherwise
/// leave the defaults so the test stays focused).
Future<void> pumpWired(
  WidgetTester tester,
  Widget widget, {
  WiredThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
  Size? surfaceSize,
  Alignment alignment = Alignment.center,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            Widget child = Align(alignment: alignment, child: widget);
            if (surfaceSize != null) {
              child = Center(
                child: SizedBox.fromSize(size: surfaceSize, child: child),
              );
            }
            return MediaQuery(
              // copyWith keeps the view's size, padding, and insets intact:
              // replacing the whole MediaQueryData would report a zero-size
              // surface to widgets that consult it.
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: Directionality(
                textDirection: textDirection,
                child: WiredTheme(
                  data: theme ?? WiredThemeData(),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

/// Pumps [widget] with a right-to-left [Directionality].
///
/// Use for any control that places ink relative to text or places a value
/// along an axis (sliders, switches, checkboxes, tiles, progress bars).
/// Right-to-left layout is where hard-coded left/right offsets surface, and
/// Material currently masks many of those gaps.
Future<void> pumpWiredRtl(
  WidgetTester tester,
  Widget widget, {
  WiredThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
  Size? surfaceSize,
  Alignment alignment = Alignment.center,
}) => pumpWired(
  tester,
  widget,
  theme: theme,
  textDirection: TextDirection.rtl,
  textScaler: textScaler,
  surfaceSize: surfaceSize,
  alignment: alignment,
);

/// Pumps [widget] with a text scale factor of [scale].
///
/// Use for text-bearing controls (buttons, tiles, labels) to prove that the
/// ink, hit area, and painted border grow with the text instead of clipping
/// it. The default of `2.0` is the accessibility-scale case that most often
/// breaks hand-drawn borders, which are sized from constants rather than from
/// the laid-out text.
Future<void> pumpWiredScaled(
  WidgetTester tester,
  Widget widget, {
  double scale = 2.0,
  WiredThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  Size? surfaceSize,
  Alignment alignment = Alignment.center,
}) => pumpWired(
  tester,
  widget,
  theme: theme,
  textDirection: textDirection,
  textScaler: TextScaler.linear(scale),
  surfaceSize: surfaceSize,
  alignment: alignment,
);
