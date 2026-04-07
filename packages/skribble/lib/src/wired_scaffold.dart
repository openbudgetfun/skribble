import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_base.dart';
import 'wired_theme.dart';

/// A Material [Scaffold] wrapper tuned for Skribble's paper-like palette.
///
/// This gives apps a lightweight architectural shell that matches the
/// hand-drawn widgets while keeping the familiar Material scaffold API.
class WiredScaffold extends HookWidget {
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

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? bodyPadding;
  final bool applySafeArea;
  final Widget? floatingActionButton;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final DragStartBehavior drawerDragStartBehavior;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
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
