import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_base.dart';
import 'wired_theme.dart';

/// A Material [Scaffold] wrapper tuned for skribble's paper-like palette.
///
/// This gives apps a lightweight architectural shell that matches the
/// hand-drawn widgets while keeping the familiar Material scaffold API.
class WiredScaffold extends HookWidget {
  /// Creates a scaffold with skribble's paper background and drawer scrim.
  const WiredScaffold({
    super.key,
    this.appBar,
    this.body,
    this.backgroundColor,
    this.bodyPadding,
    this.applySafeArea = false,
    this.floatingActionButton,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.primary = true,
  });

  /// See [Scaffold.appBar].
  final PreferredSizeWidget? appBar;

  /// See [Scaffold.body].
  final Widget? body;

  /// The page colour behind [body].
  ///
  /// Defaults to [WiredThemeData.paperBackgroundColor].
  final Color? backgroundColor;

  /// Padding inserted around [body]. Null adds none.
  final EdgeInsetsGeometry? bodyPadding;

  /// Whether to wrap [body] in a [SafeArea]. Defaults to false.
  final bool applySafeArea;

  /// See [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// See [Scaffold.floatingActionButtonAnimator].
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// See [Scaffold.floatingActionButtonLocation].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// See [Scaffold.drawer].
  final Widget? drawer;

  /// See [Scaffold.endDrawer].
  final Widget? endDrawer;

  /// The colour that dims the page while a drawer is open.
  ///
  /// Defaults to the theme border colour at 12% opacity.
  final Color? drawerScrimColor;

  /// See [Scaffold.drawerEdgeDragWidth].
  final double? drawerEdgeDragWidth;

  /// See [Scaffold.drawerEnableOpenDragGesture].
  final bool drawerEnableOpenDragGesture;

  /// See [Scaffold.endDrawerEnableOpenDragGesture].
  final bool endDrawerEnableOpenDragGesture;

  /// See [Scaffold.drawerDragStartBehavior].
  final DragStartBehavior drawerDragStartBehavior;

  /// See [Scaffold.bottomNavigationBar].
  final Widget? bottomNavigationBar;

  /// See [Scaffold.bottomSheet].
  final Widget? bottomSheet;

  /// See [Scaffold.persistentFooterButtons].
  final List<Widget>? persistentFooterButtons;

  /// See [Scaffold.persistentFooterAlignment].
  final AlignmentDirectional persistentFooterAlignment;

  /// See [Scaffold.resizeToAvoidBottomInset].
  final bool? resizeToAvoidBottomInset;

  /// See [Scaffold.extendBody].
  final bool extendBody;

  /// See [Scaffold.extendBodyBehindAppBar].
  final bool extendBodyBehindAppBar;

  /// See [Scaffold.primary].
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    Widget? effectiveBody = body;

    if (effectiveBody != null && bodyPadding != null) {
      effectiveBody = Padding(padding: bodyPadding!, child: effectiveBody);
    }

    if (effectiveBody != null && applySafeArea) {
      effectiveBody = SafeArea(child: effectiveBody);
    }

    return buildWiredElement(
      child: Scaffold(
        backgroundColor: backgroundColor ?? theme.paperBackgroundColor,
        appBar: appBar,
        body: effectiveBody,
        floatingActionButton: floatingActionButton,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: drawer,
        endDrawer: endDrawer,
        drawerScrimColor:
            drawerScrimColor ?? theme.borderColor.withValues(alpha: 0.12),
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        drawerDragStartBehavior: drawerDragStartBehavior,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        persistentFooterButtons: persistentFooterButtons,
        persistentFooterAlignment: persistentFooterAlignment,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        primary: primary,
      ),
    );
  }
}
