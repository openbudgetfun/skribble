import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredIcon lookup helpers', () {
    test(
      'lookupMaterialRoughIcon returns data for supported material icons',
      () {
        expect(lookupMaterialRoughIcon(Icons.search), isNotNull);
      },
    );

    test('lookupMaterialRoughIcon returns null for unsupported families', () {
      const icon = IconData(0xe001, fontFamily: 'CupertinoIcons');
      expect(lookupMaterialRoughIcon(icon), isNull);
    });

    test('lookupMaterialRoughIconByIdentifier resolves known identifiers', () {
      expect(lookupMaterialRoughIconByIdentifier('search'), isNotNull);
      expect(lookupMaterialRoughIconByIdentifier('does_not_exist'), isNull);
    });

    test('lookupMaterialRoughFontIcon resolves generated rough font icons', () {
      final iconData = lookupMaterialRoughFontIcon('search');
      expect(iconData, isNotNull);
      expect(iconData!.fontFamily, materialRoughFontFamily);
    });

    test('rough icon metadata accessors expose non-empty catalog data', () {
      expect(materialRoughFontFamily, isNotEmpty);
      expect(materialRoughFontCodePoints, isNotEmpty);
      expect(materialRoughIconIdentifiers, isNotEmpty);
      expect(materialRoughIconCodePoints, isNotEmpty);

      expect(materialRoughFontCodePoints['search'], isNotNull);
      expect(materialRoughIconIdentifiers, contains('search'));
      expect(
        materialRoughIconCodePoints,
        contains(materialRoughFontCodePoints['search']),
      );
    });
  });

  group('WiredIcon', () {
    testWidgets('renders a supported material icon without error', (
      tester,
    ) async {
      await pumpApp(tester, const Center(child: WiredIcon(icon: Icons.search)));

      expect(find.byType(WiredIcon), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WiredIcon),
          matching: find.byType(WiredSvgIcon),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(WiredIcon),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(WiredIcon),
          matching: find.byType(RepaintBoundary),
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('applies custom size and color', (tester) async {
      await pumpApp(
        tester,
        const Center(
          child: WiredIcon(
            icon: Icons.favorite,
            size: 32,
            color: Colors.purple,
          ),
        ),
      );

      final wiredIcon = tester.widget<WiredIcon>(find.byType(WiredIcon));
      expect(wiredIcon.size, 32);
      expect(wiredIcon.color, Colors.purple);
    });

    testWidgets('adds semantics when semanticLabel is provided', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpApp(
          tester,
          const Center(
            child: WiredIcon(
              icon: Icons.search,
              semanticLabel: 'Search rough icon',
            ),
          ),
        );

        expect(find.bySemanticsLabel('Search rough icon'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('falls back to Icon for unsupported icon families', (
      tester,
    ) async {
      const icon = IconData(0xe001, fontFamily: 'CupertinoIcons');

      await pumpApp(tester, const Center(child: WiredIcon(icon: icon)));

      expect(find.byType(Icon), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WiredIcon),
          matching: find.byType(WiredSvgIcon),
        ),
        findsNothing,
      );
    });

    testWidgets('falls back to Icon for unknown Material codepoint', (
      tester,
    ) async {
      const unknownMaterialIcon = IconData(
        0x10fffd,
        fontFamily: 'MaterialIcons',
      );

      await pumpApp(
        tester,
        const Center(child: WiredIcon(icon: unknownMaterialIcon)),
      );

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(WiredSvgIcon), findsNothing);
    });

    testWidgets('flips directional icons in RTL text direction', (
      tester,
    ) async {
      expect(lookupMaterialRoughIcon(Icons.arrow_back), isNotNull);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(child: WiredIcon(icon: Icons.arrow_back)),
          ),
        ),
      );

      final svgIcon = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(svgIcon.flipHorizontally, isTrue);
    });

    testWidgets('does not flip directional icons in LTR text direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: WiredIcon(icon: Icons.arrow_back)),
          ),
        ),
      );

      final svgIcon = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(svgIcon.flipHorizontally, isFalse);
    });
  });

  group('WiredSvgIcon', () {
    const data = WiredSvgIconData(
      width: 24,
      height: 24,
      primitives: <WiredSvgPrimitive>[
        WiredSvgPrimitive.circle(cx: 12, cy: 12, radius: 8),
      ],
    );

    Future<void> pumpIcon(
      WidgetTester tester, {
      WiredIconFillStyle fillStyle = WiredIconFillStyle.solid,
      double sampleDistance = 1.2,
      bool flipHorizontally = false,
      DrawConfig? drawConfig,
    }) {
      return pumpApp(
        tester,
        Center(
          child: WiredSvgIcon(
            data: data,
            fillStyle: fillStyle,
            sampleDistance: sampleDistance,
            flipHorizontally: flipHorizontally,
            drawConfig: drawConfig,
          ),
        ),
      );
    }

    testWidgets('renders custom svg icon data', (tester) async {
      await pumpIcon(tester);

      expect(find.byType(WiredSvgIcon), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WiredSvgIcon),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('supports all fill styles without errors', (tester) async {
      for (final fillStyle in WiredIconFillStyle.values) {
        await pumpIcon(tester, fillStyle: fillStyle);
        expect(find.byType(WiredSvgIcon), findsOneWidget);
      }
    });

    testWidgets('supports flipped rendering and low sample distance', (
      tester,
    ) async {
      await pumpIcon(tester, flipHorizontally: true, sampleDistance: 0.1);

      final widget = tester.widget<WiredSvgIcon>(find.byType(WiredSvgIcon));
      expect(widget.flipHorizontally, isTrue);
      expect(widget.sampleDistance, 0.1);
    });

    testWidgets('repaints when configuration changes', (tester) async {
      await pumpIcon(
        tester,
        fillStyle: WiredIconFillStyle.none,
        drawConfig: DrawConfig.build(seed: 1),
      );

      final firstPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(WiredSvgIcon),
          matching: find.byType(CustomPaint),
        ),
      );
      final firstPainter = firstPaint.painter!;

      await pumpIcon(
        tester,
        fillStyle: WiredIconFillStyle.crossHatch,
        drawConfig: DrawConfig.build(seed: 2),
      );

      final secondPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(WiredSvgIcon),
          matching: find.byType(CustomPaint),
        ),
      );
      final secondPainter = secondPaint.painter!;

      expect((secondPainter as dynamic).shouldRepaint(firstPainter), isTrue);
      expect((secondPainter as dynamic).shouldRepaint(secondPainter), isFalse);
    });

    testWidgets('handles empty path primitives without crashing', (
      tester,
    ) async {
      const emptyPathData = WiredSvgIconData(
        width: 24,
        height: 24,
        primitives: <WiredSvgPrimitive>[WiredSvgPrimitive.path('M0 0')],
      );

      await pumpApp(
        tester,
        const Center(
          child: WiredSvgIcon(
            data: emptyPathData,
            fillStyle: WiredIconFillStyle.hachure,
          ),
        ),
      );

      expect(find.byType(WiredSvgIcon), findsOneWidget);
    });
  });
}
