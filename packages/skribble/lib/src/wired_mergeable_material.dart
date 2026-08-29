import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// Base class for children of [WiredMergeableMaterial].
///
/// Mirrors Material's `MergeableMaterialItem`: subclasses are
/// [WiredMaterialSlice] (a panel of content) and [WiredMaterialGap]
/// (animated vertical spacing between slices).
abstract class WiredMergeableMaterialItem {
  /// Abstract const constructor enables subclasses to provide their own
  /// key implementations.
  const WiredMergeableMaterialItem(this.key);

  /// Key that identifies this item across rebuilds. Stable keys are
  /// required so [WiredMergeableMaterial] can animate size changes.
  final LocalKey key;
}

/// A slice of content inside a [WiredMergeableMaterial].
///
/// Equivalent to Material's `MaterialSlice`, rendered as a row inside a
/// hand-drawn rough-bordered card instead of a Material shadowed panel.
class WiredMaterialSlice extends WiredMergeableMaterialItem {
  /// The slice content.
  final Widget child;

  /// Optional fill color override for this slice's background.
  final Color? color;

  const WiredMaterialSlice({
    required LocalKey key,
    required this.child,
    this.color,
  }) : super(key);
}

/// An animated vertical gap inside a [WiredMergeableMaterial].
///
/// Equivalent to Material's `MaterialGap`. Animating the [size] between
/// rebuilds drives the expand/collapse animation: a gap animating to `0`
/// merges the slices around it into a single hand-drawn card.
class WiredMaterialGap extends WiredMergeableMaterialItem {
  /// Size of the gap in logical pixels along the main axis.
  final double size;

  const WiredMaterialGap({required LocalKey key, this.size = 16.0})
    : super(key);
}

/// A vertically stacked group of slices and gaps with hand-drawn borders.
///
/// Mirrors Material's `MergeableMaterial`, re-imagined with a sketchy
/// aesthetic: every contiguous run of slices is outlined with one rough
/// rounded rectangle and sharing dividers, while gaps separate cards.
///
/// API parity with Material:
/// * `children` — slices and gaps, same as Material's `MergeableMaterial`.
/// * `hasDividers` — draws a hand-drawn line between contiguous slices.
/// * `dividerColor` — overrides the rough divider line color.
/// * No controller is exposed (Material's 3.47 API has none either);
///   drive expand/collapse by rebuilding `children` with different gap
///   sizes — the size change is animated automatically.
///
/// ```dart
/// WiredMergeableMaterial(
///   children: [
///     WiredMaterialSlice(
///       key: const ValueKey('a'),
///       child: Padding(
///         padding: EdgeInsets.all(16),
///         child: Text('Slice A'),
///       ),
///     ),
///     WiredMaterialGap(key: const ValueKey('gap'), size: 16),
///     WiredMaterialSlice(
///       key: const ValueKey('b'),
///       child: Padding(
///         padding: EdgeInsets.all(16),
///         child: Text('Slice B'),
///       ),
///     ),
///   ],
/// )
/// ```
class WiredMergeableMaterial extends HookWidget {
  /// The slices and gaps to display, in order.
  final List<WiredMergeableMaterialItem> children;

  /// Whether hand-drawn dividers are drawn between contiguous slices.
  final bool hasDividers;

  /// Optional color override for the divider lines.
  final Color? dividerColor;

  /// Duration used for gap grow/collapse animations.
  final Duration animationDuration;

  /// Curve used for gap grow/collapse animations.
  final Curve animationCurve;

  const WiredMergeableMaterial({
    super.key,
    required this.children,
    this.hasDividers = false,
    this.dividerColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.fastOutSlowIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final dividerColor = this.dividerColor ?? theme.borderColor;

    final cards = <Widget>[];
    final run = <WiredMaterialSlice>[];

    void closeRun() {
      if (run.isEmpty) return;
      cards.add(
        _SliceCard(
          slices: List.of(run),
          theme: theme,
          dividerColor: dividerColor,
          showDividers: hasDividers,
        ),
      );
      run.clear();
    }

    for (final child in children) {
      final slice = child is WiredMaterialSlice ? child : null;
      final gap = child is WiredMaterialGap ? child : null;

      if (slice != null) {
        run.add(slice);
      } else if (gap != null && gap.size > 0) {
        closeRun();
        cards.add(
          _AnimatedGap(
            gap: gap,
            duration: animationDuration,
            curve: animationCurve,
          ),
        );
      }
      // A gap with size <= 0 connects the slices around it: keep them in
      // the same run so they render as one merged card.
    }
    closeRun();

    return buildWiredElement(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards,
      ),
    );
  }
}

/// Renders a contiguous run of slices as one rough-bordered card.
class _SliceCard extends HookWidget {
  const _SliceCard({
    required this.slices,
    required this.theme,
    required this.dividerColor,
    required this.showDividers,
  });

  final List<WiredMaterialSlice> slices;
  final WiredThemeData theme;
  final Color dividerColor;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final slice in slices) {
      if (rows.isNotEmpty && showDividers) {
        rows.add(
          SizedBox(
            height: 1,
            child: WiredCanvas(
              painter: WiredLineBase(
                x1: 8,
                y1: 0,
                x2: double.infinity,
                y2: 0,
                borderColor: dividerColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
        );
      }
      final sliceColor = slice.color;
      rows.add(
        sliceColor == null
            ? slice.child
            : ColoredBox(color: sliceColor, child: slice.child),
      );
    }

    const radius = 8.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(radius),
                fillColor: theme.fillColor,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ],
      ),
    );
  }
}

/// A gap whose height animates whenever the target [WiredMaterialGap.size]
/// changes, driving the expand/collapse behavior.
class _AnimatedGap extends HookWidget {
  const _AnimatedGap({
    required this.gap,
    required this.duration,
    required this.curve,
  });

  final WiredMaterialGap gap;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: gap.size),
      duration: duration,
      curve: curve,
      builder: (context, value, _) => SizedBox(height: value < 0 ? 0 : value),
    );
  }
}
