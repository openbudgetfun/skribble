import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'generated/skribble_glyphs.g.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
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

  /// Whether to show the route's title when [middle] is null.
  ///
  /// Like `CupertinoNavigationBar`, the title comes from a
  /// [CupertinoPageRoute]'s `title`. Other routes, and routes without a
  /// title, show nothing: a route's name, such as `/settings`, is an address
  /// and not something to read.
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
    void back() => Navigator.of(context).maybePop();
    // A labelled, focusable button that Enter and Space also activate.
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      // The previous page's title, as iOS reads it, or "Back".
      label: previousPageTitle ?? 'Back',
      onTap: back,
      excludeSemantics: true,
      child: WiredActivatable(
        onActivate: back,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WiredSvgIcon(
              data: SkribbleGlyphs.chevronLeft,
              color: theme.borderColor,
              size: 22,
              flipHorizontally: Directionality.of(context) == TextDirection.rtl,
            ),
            if (previousPageTitle != null)
              Text(
                previousPageTitle!,
                style: TextStyle(color: theme.borderColor, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    final theme = WiredTheme.of(context);
    final route = ModalRoute.of(context);
    final title = route is CupertinoRouteTransitionMixin ? route.title : null;

    if (title == null || title.isEmpty) return null;
    return Text(
      title,
      style: TextStyle(
        color: theme.textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
