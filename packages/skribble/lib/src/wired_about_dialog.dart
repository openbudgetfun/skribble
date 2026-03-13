import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn about dialog corresponding to Flutter's [AboutDialog].
///
/// Shows app name, version, icon, and legal text with a hand-drawn
/// rounded rectangle border.
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
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: BorderRadius.circular(16),
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (applicationIcon != null) ...[
                    applicationIcon!,
                    const SizedBox(height: 16),
                  ],
                  Text(
                    name,
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
                    height: 2,
                    child: WiredCanvas(
                      painter: WiredLineBase(
                        x1: 0,
                        y1: 1,
                        x2: double.maxFinite,
                        y2: 1,
                      ),
                      fillerType: RoughFilter.noFiller,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showLicensePage(
                            context: context,
                            applicationName: name,
                            applicationVersion: applicationVersion,
                            applicationIcon: applicationIcon,
                            applicationLegalese: applicationLegalese,
                          );
                        },
                        child: const Text('VIEW LICENSES'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
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
    );
  }

  String _getApplicationName(BuildContext context) {
    final title = context.findAncestorWidgetOfExactType<MaterialApp>();
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
