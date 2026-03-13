import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn navigation bar corresponding to [CupertinoNavigationBar].
///
/// Provides the same leading/middle/trailing API as [CupertinoNavigationBar]
/// with a sketchy hand-drawn bottom border instead of the standard hairline.
class WiredCupertinoNavigationBar extends HookWidget
    implements ObstructingPreferredSizeWidget {
  /// Widget at the left of the nav bar.
  final Widget? leading;

  /// Widget in the center. Typically a [Text] title.
  final Widget? middle;

  /// Widget at the right of the nav bar.
  final Widget? trailing;

  /// Whether to show a back chevron when [leading] is null and there's
  /// a previous route.
  final bool automaticallyImplyLeading;

  /// Whether to show a middle widget when [middle] is null.
  final bool automaticallyImplyMiddle;

  /// Previous page title for the back button label.
  final String? previousPageTitle;

  /// Background color.
  final Color? backgroundColor;

  /// Padding around the nav bar content.
  final EdgeInsetsDirectional? padding;

  /// Border — not used since we draw a sketchy border.
  final Border? border;

  const WiredCupertinoNavigationBar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.automaticallyImplyLeading = true,
    this.automaticallyImplyMiddle = true,
    this.previousPageTitle,
    this.backgroundColor,
    this.padding,
    this.border,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(kMinInteractiveDimensionCupertino);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final bgColor = backgroundColor ?? theme.fillColor;

    return buildWiredElement(
      child: SizedBox(
        height: preferredSize.height + MediaQuery.of(context).padding.top,
        child: Stack(
          children: [
            // Background + bottom border
            Positioned.fill(child: Container(color: bgColor)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 3,
              child: WiredCanvas(
                painter: WiredLineBase(
                  x1: 0,
                  y1: 1,
                  x2: double.maxFinite,
                  y2: 1,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            // Content
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: kMinInteractiveDimensionCupertino,
              child: Padding(
                padding:
                    padding ??
                    const EdgeInsetsDirectional.only(start: 8, end: 8),
                child: NavigationToolbar(
                  leading:
                      leading ??
                      (automaticallyImplyLeading
                          ? _buildBackButton(context)
                          : null),
                  middle:
                      middle ??
                      (automaticallyImplyMiddle ? _buildTitle(context) : null),
                  trailing: trailing,
                  middleSpacing: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    final theme = WiredTheme.of(context);
    if (!Navigator.of(context).canPop()) return null;
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.back, color: theme.borderColor, size: 22),
          if (previousPageTitle != null)
            Text(
              previousPageTitle!,
              style: TextStyle(color: theme.borderColor, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    final theme = WiredTheme.of(context);
    final route = ModalRoute.of(context);
    if (route?.settings.name == null) return null;
    return Text(
      route!.settings.name!,
      style: TextStyle(
        color: theme.textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
