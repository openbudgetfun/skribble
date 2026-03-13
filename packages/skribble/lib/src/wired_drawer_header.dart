import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn drawer header corresponding to Flutter's [DrawerHeader].
///
/// Displays a header area at the top of a a drawer with a sketchy
/// bottom border separator.
class WiredDrawerHeader extends HookWidget {
  /// The content of the header.
  final Widget child;

  /// Padding inside the header.
  final EdgeInsetsGeometry padding;

  /// Duration of any decoration animation.
  final Duration duration;

  /// Background decoration (e.g. color or image).
  final BoxDecoration? decoration;

  /// Margin around the header.
  final EdgeInsetsGeometry? margin;

  const WiredDrawerHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    this.duration = const Duration(milliseconds: 250),
    this.decoration,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Container(
        margin: margin,
        child: Stack(
          children: [
            // Background
            if (decoration case final deco?)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: duration,
                  decoration: deco,
                ),
              )
            else
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    fillColor: borderColor.withValues(alpha: 0.06),
                  ),
                  fillerType: RoughFilter.hachureFiller,
                  fillerConfig: FillerConfig.build(hachureGap: 4.0),
                ),
              ),
            // Content
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(alignment: Alignment.bottomLeft, child: child),
                  ),
                ],
              ),
            ),
            // Bottom border
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
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A hand-drawn user accounts drawer header corresponding to
/// Flutter's [UserAccountsDrawerHeader].
///
/// Displays an avatar, account name, and email with a hand-drawn
/// background.
class WiredUserAccountsDrawerHeader extends HookWidget {
  /// The avatar widget, typically a `WiredAvatar`.
  final Widget? currentAccountPicture;

  /// Additional smaller account pictures.
  final List<Widget>? otherAccountsPictures;

  /// The account name widget.
  final Widget? accountName;

  /// The account email widget.
  final Widget? accountEmail;

  /// Called when the header is tapped.
  final VoidCallback? onDetailsPressed;

  /// Background decoration.
  final BoxDecoration? decoration;

  /// Margin around the header.
  final EdgeInsetsGeometry margin;

  const WiredUserAccountsDrawerHeader({
    super.key,
    this.currentAccountPicture,
    this.otherAccountsPictures,
    this.accountName,
    this.accountEmail,
    this.onDetailsPressed,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Container(
        margin: margin,
        height: 170,
        child: Stack(
          children: [
            // Background
            if (decoration case final deco?)
              Positioned.fill(child: DecoratedBox(decoration: deco))
            else
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    fillColor: borderColor.withValues(alpha: 0.08),
                  ),
                  fillerType: RoughFilter.hachureFiller,
                  fillerConfig: FillerConfig.build(hachureGap: 4.0),
                ),
              ),
            // Content
            GestureDetector(
              onTap: onDetailsPressed,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar row
                    Row(
                      children: [
                        ?currentAccountPicture,
                        if (otherAccountsPictures case final others?) ...[
                          const SizedBox(width: 8),
                          for (final pic in others)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: pic,
                            ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    // Account info
                    if (accountName != null)
                      DefaultTextStyle(
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        child: accountName!,
                      ),
                    if (accountEmail != null)
                      DefaultTextStyle(
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        child: accountEmail!,
                      ),
                  ],
                ),
              ),
            ),
            // Bottom border
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
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
