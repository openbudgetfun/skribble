import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Hand-drawn category glyphs sized for [WiredMapPin].
enum WiredMapPinIcon {
  /// A general place.
  place('place'),

  /// A completed check-in.
  checkIn('check'),

  /// A cafe or coffee stop.
  coffee('coffee'),

  /// A shop or market.
  market('storefront'),

  /// A gallery, studio, or museum.
  gallery('palette'),

  /// A saved or favourite place.
  favorite('favorite'),

  /// A person or meeting point.
  person('person');

  const WiredMapPinIcon(this.identifier);

  /// Identifier in Skribble's rough Material icon catalog.
  final String identifier;
}

/// A hand-drawn map pin with a stable, seedable outline.
class WiredMapPin extends HookWidget {
  /// Creates a map pin.
  const WiredMapPin({
    super.key,
    this.child,
    this.onTap,
    this.semanticLabel,
    this.width = 52,
    this.height = 64,
    this.fillColor,
    this.inkColor,
    this.iconColor,
    this.icon = WiredMapPinIcon.place,
    this.iconSize = 28,
    this.strokeWidth,
    this.seed = 37,
  }) : assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive'),
       assert(iconSize > 0, 'iconSize must be positive');

  /// Content drawn inside the rounded head of the pin.
  final Widget? child;

  /// Called when the pin is activated.
  final VoidCallback? onTap;

  /// An accessibility label for the pin.
  final String? semanticLabel;

  /// The pin width.
  final double width;

  /// The pin height.
  final double height;

  /// The pin body color, or a pastel chosen for its category.
  final Color? fillColor;

  /// The pin outline color, or a dark brown ink readable on the pastel fill.
  final Color? inkColor;

  /// The icon color, or the resolved pin outline color.
  final Color? iconColor;

  /// Rough category icon used when [child] is null.
  ///
  /// Set this to null for a pin without an icon.
  final WiredMapPinIcon? icon;

  /// Size of the generated rough icon.
  final double iconSize;

  /// The pin outline width, or the active Wired theme stroke width.
  final double? strokeWidth;

  /// The deterministic rough-drawing seed.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final pressed = useState(false);
    final enabled = onTap != null;
    final resolvedInk = inkColor ?? const Color(0xFF35332F);
    final resolvedFill =
        fillColor ??
        switch (icon) {
          WiredMapPinIcon.coffee => const Color(0xFFF5CB83),
          WiredMapPinIcon.market => const Color(0xFFAED9BC),
          WiredMapPinIcon.gallery => const Color(0xFFBFC8ED),
          WiredMapPinIcon.favorite => const Color(0xFFF3ABA6),
          WiredMapPinIcon.person => const Color(0xFFA9D8E8),
          WiredMapPinIcon.checkIn => const Color(0xFFC9DC91),
          WiredMapPinIcon.place || null => const Color(0xFFF3D77A),
        };
    final iconData = icon == null
        ? null
        : lookupMaterialRoughIconByIdentifier(icon!.identifier);
    final pinDrawConfig = theme.drawConfig.copyWith(
      seed: seed,
      maxRandomnessOffset: math.min(
        theme.drawConfig.maxRandomnessOffset ?? 1.2,
        1.2,
      ),
      roughness: math.min(theme.drawConfig.roughness ?? 1.25, 1.25),
      lineWobble: math.min(theme.drawConfig.lineWobble ?? 0, 0.35),
    );
    final duration = theme.motionEnabled
        ? const Duration(milliseconds: 90)
        : Duration.zero;

    return buildWiredElement(
      child: Semantics(
        label: semanticLabel,
        button: enabled,
        excludeSemantics: semanticLabel != null,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onTapDown: enabled ? (_) => pressed.value = true : null,
            onTapUp: enabled ? (_) => pressed.value = false : null,
            onTapCancel: enabled ? () => pressed.value = false : null,
            child: AnimatedScale(
              duration: duration,
              curve: Curves.easeOut,
              scale: pressed.value ? 0.92 : 1,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned.fill(
                      child: WiredCanvas(
                        drawConfig: pinDrawConfig,
                        fillerType: RoughFilter.solidFiller,
                        painter: _WiredMapPinPainter(
                          fillColor: const Color(0xFFFFFCF3),
                          inkColor: const Color(0xFFFFFCF3),
                          strokeWidth: strokeWidth ?? theme.strokeWidth,
                          halo: true,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: WiredCanvas(
                        drawConfig: pinDrawConfig,
                        fillerType: RoughFilter.solidFiller,
                        painter: _WiredMapPinPainter(
                          fillColor: resolvedFill,
                          inkColor: resolvedInk,
                          strokeWidth: strokeWidth ?? theme.strokeWidth,
                        ),
                      ),
                    ),
                    if (child != null || iconData != null)
                      Positioned(
                        top: height * 0.12,
                        width: width * 0.64,
                        height: height * 0.48,
                        child: Center(
                          child:
                              child ??
                              WiredSvgIcon(
                                data: iconData!,
                                size: iconSize,
                                color: iconColor ?? resolvedInk,
                                fillStyle: WiredIconFillStyle.none,
                                strokeWidth: 1.2,
                                drawConfig: pinDrawConfig.copyWith(
                                  seed: seed + 1,
                                  roughness: 0.35,
                                  maxRandomnessOffset: 0.3,
                                  lineWobble: 0,
                                ),
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WiredMapPinPainter extends WiredPainterBase {
  _WiredMapPinPainter({
    required this.fillColor,
    required this.inkColor,
    required this.strokeWidth,
    this.halo = false,
  });

  final Color fillColor;
  final Color inkColor;
  final double strokeWidth;
  final bool halo;

  @override
  RoughDrawing prepare(Size size, DrawConfig drawConfig, Filler filler) {
    final inset = math.min(strokeWidth / 2 + 3, size.shortestSide / 4);
    final width = size.width - inset * 2;
    final height = size.height - inset * 2;
    final random = math.Random(drawConfig.seed);
    // Vary the shoulders, never the tip: a marker must still point at its
    // geographic anchor. One continuous contour avoids polygon corners and
    // doubled strokes at this small size.
    final lean = (random.nextDouble() - 0.5) * 0.06;
    PointD point(double x, double y) =>
        PointD(inset + width * x, inset + height * y);
    final contour = <Op>[
      Op.move(point(0.5, 1)),
      Op.curveTo(point(0.40, 0.80), point(0.02, 0.62), point(0.02, 0.35)),
      Op.curveTo(point(0, 0.13), point(0.20 + lean, 0.01), point(0.47, 0.02)),
      Op.curveTo(point(0.77 + lean, 0), point(0.99, 0.13), point(0.98, 0.36)),
      Op.curveTo(point(0.98, 0.63), point(0.62, 0.82), point(0.5, 1)),
    ];
    final accent = <Op>[
      Op.move(point(0.12, 0.34)),
      Op.curveTo(point(0.11, 0.23), point(0.18, 0.15), point(0.28, 0.13)),
    ];
    final drawable = Drawable(
      options: drawConfig,
      sets: [
        OpSet(type: OpSetType.fillPath, ops: contour),
        OpSet(type: OpSetType.path, ops: [...contour, if (!halo) ...accent]),
      ],
    );

    return RoughDrawing(
      drawable,
      WiredBase.pathPainter(
          halo ? strokeWidth + 4 : strokeWidth,
          color: inkColor,
        )
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
      WiredBase.fillPainter(fillColor),
    );
  }

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    prepare(size, drawConfig, filler).paint(canvas);
  }
}
