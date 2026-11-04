import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_license_page.dart';
import 'wired_text_button.dart';
import 'wired_theme.dart';

/// A hand-drawn about dialog corresponding to Flutter's [AboutDialog].
///
/// Shows app name, version, icon, and legal text on the theme's paper with a
/// hand-drawn rounded rectangle border. "VIEW LICENSES" opens
/// [WiredLicensePage]; "CLOSE" pops the dialog. When [applicationName] is
/// null, the dialog shows the title of the enclosing app.
class WiredAboutDialog extends HookWidget {
  /// The name of the application.
  final String? applicationName;

  /// The version string.
  final String? applicationVersion;

  /// The application icon widget.
  final Widget? applicationIcon;

  /// Legal text shown at the bottom.
  final String? applicationLegalese;

  /// Additional children below the about information.
  final List<Widget>? children;

  const WiredAboutDialog({
    super.key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final name = applicationName ?? _getApplicationName(context);

    return buildWiredElement(
      child: Dialog(
        backgroundColor: theme.fillColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Stack(
            children: [
              // The border sits on the paper, so it stays visible in light
              // and dark themes alike.
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    borderRadius: BorderRadius.circular(16),
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              // Short screens, such as a phone on its side, scroll the
              // details instead of cutting them off.
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (applicationIcon != null) ...[
                      Center(child: applicationIcon),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (applicationVersion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        applicationVersion!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (applicationLegalese != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        applicationLegalese!,
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (children != null) ...[
                      const SizedBox(height: 16),
                      ...children!,
                    ],
                    const SizedBox(height: 20),
                    // Sketchy divider
                    SizedBox(
                      height: theme.inkExtent,
                      child: WiredCanvas(
                        painter: WiredLineBase(
                          strokeWidth: theme.strokeWidth,
                          x1: 0,
                          y1: 1,
                          x2: double.maxFinite,
                          y2: 1,
                          borderColor: theme.borderColor,
                        ),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // The actions stack, end-aligned, when a narrow screen
                    // or large text leaves no room for them side by side.
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      overflowAlignment: OverflowBarAlignment.end,
                      spacing: 8,
                      overflowSpacing: 8,
                      children: [
                        WiredTextButton(
                          onPressed: () {
                            unawaited(
                              showWiredLicensePage(
                                context: context,
                                applicationName: name,
                                applicationVersion: applicationVersion,
                                applicationIcon: applicationIcon,
                              ),
                            );
                          },
                          child: const Text('VIEW LICENSES'),
                        ),
                        WiredTextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CLOSE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The app's title, as `MaterialApp`, `SkribbleApp`, and every other
  /// `WidgetsApp` publish it through their [Title].
  String _getApplicationName(BuildContext context) {
    final title = context.findAncestorWidgetOfExactType<Title>();

    return title?.title ?? '';
  }
}

/// Shows a [WiredAboutDialog].
Future<void> showWiredAboutDialog({
  required BuildContext context,
  String? applicationName,
  String? applicationVersion,
  Widget? applicationIcon,
  String? applicationLegalese,
  List<Widget>? children,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => WiredAboutDialog(
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: applicationIcon,
      applicationLegalese: applicationLegalese,
      children: children,
    ),
  );
}
