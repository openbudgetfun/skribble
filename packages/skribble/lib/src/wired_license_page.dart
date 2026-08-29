import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_app_bar.dart';
import 'wired_base.dart';
import 'wired_circular_progress.dart';
import 'wired_divider.dart';
import 'wired_scaffold.dart';
import 'wired_theme.dart';

/// One aggregated open-source library entry shown by [WiredLicensePage].
///
/// Groups every paragraph contributed to [name] by `LicenseRegistry`
/// (entries listing multiple package names contribute to each of them).
class WiredLicenseLibrary {
  /// Package/library name, e.g. `skribble`.
  final String name;

  /// License text paragraphs for the library, in registration order.
  final List<String> paragraphs;

  /// Creates an aggregated library entry.
  const WiredLicenseLibrary({required this.name, required this.paragraphs});
}

/// Aggregates all licenses registered with `LicenseRegistry` into a list of
/// [WiredLicenseLibrary]s, sorted alphabetically by package name. Entries that
/// name several packages contribute their paragraphs to each of them.
Future<List<WiredLicenseLibrary>> loadWiredLicenses() async {
  final buckets = <String, List<String>>{};
  await for (final entry in LicenseRegistry.licenses) {
    final texts = [
      for (final paragraph in entry.paragraphs) paragraph.text,
    ];
    for (final packageName in entry.packages) {
      buckets.putIfAbsent(packageName, () => <String>[]).addAll(texts);
    }
  }
  final names = buckets.keys.toList()..sort();
  return [
    for (final name in names)
      WiredLicenseLibrary(name: name, paragraphs: buckets[name]!),
  ];
}

/// A hand-drawn license page listing the open source packages the app uses,
/// analogous to Material's `LicensePage`.
///
/// Data is read from `LicenseRegistry` (populated automatically by Flutter
/// builds, or manually via `LicenseRegistry.addLicense`), so the widget
/// reflects the same license inventory as Material's page. Each package is
/// rendered as a rough-bordered header with its license paragraphs beneath a
/// hand-drawn divider.
///
/// Example:
///
/// ```dart
/// showWiredLicensePage(
///   context: context,
///   applicationName: 'My App',
///   applicationVersion: '1.2.0',
/// );
/// ```
///
/// See also:
///  * `WiredAboutDialog`, the compact about dialog.
class WiredLicensePage extends HookWidget {
  /// Application name rendered in the page header.
  final String? applicationName;

  /// Application version rendered under the header.
  final String? applicationVersion;

  /// Optional icon (typically a logo) rendered above the header.
  final Widget? applicationIcon;

  /// Padding around the scrollable license list.
  final EdgeInsetsGeometry padding;

  /// Creates a hand-drawn license page.
  const WiredLicensePage({
    super.key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    final packages = useState<List<WiredLicenseLibrary>?>(null);
    useEffect(() {
      var cancelled = false;
      unawaited(() async {
        final licenses = await loadWiredLicenses();
        if (cancelled) return;
        packages.value = licenses;
      }());
      return () {
        cancelled = true;
      };
    }, const []);

    final licenseList = packages.value;
    final isLoading = licenseList == null;

    return Semantics(
      label: 'Licenses',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LicenseHeader(
            theme: theme,
            applicationName: applicationName,
            applicationVersion: applicationVersion,
            applicationIcon: applicationIcon,
            packageCount: isLoading ? null : licenseList.length,
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: WiredCircularProgress()),
            )
          else
            Flexible(
              child: ListView(
                padding: padding,
                children: [
                  for (final library in licenseList)
                    _LicensePackageSection(library: library),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

TextStyle _headerStyle(WiredThemeData theme) => TextStyle(
  fontFamily: skribbleFontFamily,
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: theme.textColor,
);

/// Application header at the top of the license page.
class _LicenseHeader extends StatelessWidget {
  final WiredThemeData theme;
  final String? applicationName;
  final String? applicationVersion;
  final Widget? applicationIcon;
  final int? packageCount;

  const _LicenseHeader({
    required this.theme,
    required this.applicationName,
    required this.applicationVersion,
    required this.applicationIcon,
    required this.packageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (applicationIcon != null) ...[
            applicationIcon!,
            const SizedBox(height: 12),
          ],
          Text(
            applicationName ?? 'This app',
            textAlign: TextAlign.center,
            style: _headerStyle(theme),
          ),
          if (applicationVersion != null)
            Text(
              'Version $applicationVersion',
              style: TextStyle(
                color: theme.disabledTextColor,
                fontFamily: skribbleFontFamily,
              ),
            ),
          if (packageCount != null)
            Text(
              'Built with $packageCount open source packages',
              style: TextStyle(
                color: theme.disabledTextColor,
                fontFamily: skribbleFontFamily,
              ),
            ),
        ],
      ),
    );
  }
}

/// A single package entry: rough-bordered header with the package name and
/// its license paragraphs beneath a hand-drawn divider.
class _LicensePackageSection extends StatelessWidget {
  final WiredLicenseLibrary library;

  const _LicensePackageSection({required this.library});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  library.name,
                  style: TextStyle(
                    fontFamily: skribbleFontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final paragraph in library.paragraphs) ...[
                  Text(
                    paragraph,
                    style: TextStyle(
                      fontFamily: skribbleFontFamily,
                      fontSize: 13,
                      color: theme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const WiredDivider(),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a full-screen hand-drawn license page.
///
/// Pushes a route wrapping [WiredLicensePage] in a scaffold with a wired app
/// bar (title "Licenses") and a back button.
///
/// Returns a future that completes when the pushed route is popped.
Future<void> showWiredLicensePage({
  required BuildContext context,
  String? applicationName,
  String? applicationVersion,
  Widget? applicationIcon,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (routeContext) => WiredScaffold(
        appBar: const WiredAppBar(
          title: Text('Licenses'),
          leading: BackButton(),
        ),
        body: WiredLicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
        ),
      ),
    ),
  );
}
