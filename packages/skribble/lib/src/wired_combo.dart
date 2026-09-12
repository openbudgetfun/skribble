import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn dropdown selector with a padded label and trailing indicator.
///
/// Wraps a `DropdownButton` with a sketchy field border and outlined triangle.
/// Menu rows have their own borders, independent of the selected label.
///
/// See also:
///  * `WiredDropdownMenu`, for an M3-style dropdown menu.
class WiredCombo<T> extends HookWidget {
  /// The selected value, or null for an empty field.
  final T? value;

  /// Available menu rows, including their enabled state and tap callbacks.
  final List<DropdownMenuItem<T>> items;

  /// Return true when the caller owns [value] and rebuilds it.
  /// Return false or null to update selection internally.
  final bool? Function(T?)? onChanged;

  /// Creates a selector from dropdown menu items.
  const WiredCombo({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
  });

  /// Creates a selector from unique values and their visible labels.
  /// Return true from [onChanged] when the caller owns [value] and rebuilds it.
  /// Return false or null, or omit the callback, to update selection internally.
  factory WiredCombo.options({
    Key? key,
    required Map<T, Widget> options,
    T? value,
    bool? Function(T?)? onChanged,
  }) => WiredCombo<T>(
    key: key,
    value: value,
    onChanged: onChanged,
    items: [
      for (final option in options.entries)
        DropdownMenuItem(value: option.key, child: option.value),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final internalValue = useState<T?>(value);
    // Reserve a scaled 24px label line plus vertical breathing room.
    final height = math.max(
      60.0,
      MediaQuery.textScalerOf(context).scale(24) + 24,
    );

    useEffect(() {
      internalValue.value = value;
      return null;
    }, [value]);

    return buildWiredElement(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: _border(theme)),
            DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                itemHeight: height,
                isExpanded: true,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                icon: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: WiredCanvas(
                    painter: WiredInvertedTriangleBase(
                      strokeWidth: 1.4,
                      borderColor: theme.borderColor,
                    ),
                    drawConfig: theme.drawConfig.copyWith(
                      roughness: 0.7,
                      maxRandomnessOffset: 0.6,
                      lineWobble: 0.1,
                    ),
                    fillerType: RoughFilter.noFiller,
                    size: const Size(18, 14),
                  ),
                ),
                selectedItemBuilder: (context) => [
                  for (final item in items) _label(item),
                ],
                value: internalValue.value,
                items: [
                  for (final item in items)
                    DropdownMenuItem<T>(
                      value: item.value,
                      enabled: item.enabled,
                      onTap: item.onTap,
                      alignment: item.alignment,
                      child: SizedBox(
                        height: height,
                        child: Stack(
                          children: [
                            Positioned.fill(child: _border(theme)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _label(item),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                onChanged: (changedValue) {
                  final isControlled = onChanged?.call(changedValue) ?? false;

                  if (isControlled) return;

                  internalValue.value = changedValue;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(DropdownMenuItem<T> item) => DefaultTextStyle.merge(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    child: Align(alignment: item.alignment, child: item.child),
  );

  Widget _border(WiredThemeData theme) => IgnorePointer(
    child: WiredCanvas(
      painter: WiredRoundedRectangleBase(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        strokeWidth: theme.strokeWidth,
        fillColor: theme.fillColor,
        borderColor: theme.borderColor,
      ),
      fillerType: RoughFilter.noFiller,
    ),
  );
}
