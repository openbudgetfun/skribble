import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredIcon', () {
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

    testWidgets('renders a supported material icon without error', (
      tester,
    ) async {
      await pumpApp(tester, const Center(child: WiredIcon(icon: Icons.search)));

      expect(find.byType(WiredIcon), findsOneWidget);
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
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });
  });

  group('WiredSvgIcon', () {
    testWidgets('renders custom svg icon data', (tester) async {
      const data = WiredSvgIconData(
        width: 24,
        height: 24,
        primitives: <WiredSvgPrimitive>[
          WiredSvgPrimitive.circle(cx: 12, cy: 12, radius: 6),
        ],
      );

      await pumpApp(tester, const Center(child: WiredSvgIcon(data: data)));

      expect(find.byType(WiredSvgIcon), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(WiredSvgIcon),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });
}
