import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

/// Performance regression gate for the icon painter cache.
///
/// Icons whose [WiredSvgIconData] is built at runtime (parsed from SVG, not
/// shared const glyphs) compare structurally, so two equal-valued data
/// objects must share one prepared painter instead of re-wavering every
/// contour on each rebuild.
void main() {
  testWidgets('equal runtime icon data reuses one prepared painter', (
    tester,
  ) async {
    debugResetIconPainterCacheStats();
    addTearDown(debugResetIconPainterCacheStats);

    WiredSvgIconData iconData(int bias) => WiredSvgIconData(
      width: 24,
      height: 24,
      primitives: [
        WiredSvgPrimitive.path('M4 4 L20 4 L20 20 L4 20 Z'),
        WiredSvgPrimitive.circle(cx: 12 + bias.toDouble(), cy: 12, radius: 5),
      ],
    );

    await pumpWired(tester, WiredSvgIcon(data: iconData(0), size: 24));
    expect(debugIconPainterGenerations, 1);

    // A fresh, equal-valued data object is the common runtime case.
    await pumpWired(tester, WiredSvgIcon(data: iconData(0), size: 24));
    expect(
      debugIconPainterGenerations,
      1,
      reason: 'equal-valued runtime icon data must hit the painter cache',
    );

    // Different data really does prepare a new painter.
    await pumpWired(tester, WiredSvgIcon(data: iconData(1), size: 24));
    expect(debugIconPainterGenerations, 2);
  });

  test('icon data and primitives compare structurally', () {
    WiredSvgIconData data({double? radius}) => WiredSvgIconData(
      width: 24,
      height: 24,
      primitives: [
        WiredSvgPrimitive.circle(cx: 12, cy: 12, radius: radius ?? 5),
      ],
    );

    expect(data(), data());
    expect(data().hashCode, data().hashCode);
    expect(data(), isNot(data(radius: 6)));

    const path = WiredSvgPrimitive.path('M0 0 L10 10', strokeColor: '#123456');
    expect(
      path,
      const WiredSvgPrimitive.path('M0 0 L10 10', strokeColor: '#123456'),
    );
    expect(
      path,
      isNot(
        const WiredSvgPrimitive.path('M0 0 L10 11', strokeColor: '#123456'),
      ),
    );
    expect(
      const WiredSvgPrimitive.ellipse(cx: 1, cy: 2, radiusX: 3, radiusY: 4),
      isNot(const WiredSvgPrimitive.circle(cx: 1, cy: 2, radius: 3)),
    );
  });
}
