import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredGridTile', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(child: const SizedBox.shrink()),
        ),
      );

      expect(find.byType(WiredGridTile), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(child: const Text('Tile content')),
        ),
      );

      expect(find.text('Tile content'), findsOneWidget);
    });

    testWidgets('renders header when provided', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            header: const WiredGridTileBar(title: Text('Header')),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
    });

    testWidgets('renders footer when provided', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            footer: const WiredGridTileBar(title: Text('Footer')),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('renders both header and footer', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 200,
          child: WiredGridTile(
            header: const WiredGridTileBar(title: Text('Top')),
            footer: const WiredGridTileBar(title: Text('Bottom')),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('footer is anchored below header', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 200,
          child: WiredGridTile(
            header: const WiredGridTileBar(title: Text('Top')),
            footer: const WiredGridTileBar(title: Text('Bottom')),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final topCenter = tester.getCenter(find.text('Top'));
      final bottomCenter = tester.getCenter(find.text('Bottom'));
      expect(bottomCenter.dy, greaterThan(topCenter.dy));
    });

    testWidgets('does not render bars when not provided', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(child: const SizedBox.shrink()),
        ),
      );

      expect(find.byType(WiredGridTileBar), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            onTap: () => tapped = true,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      await tester.tap(find.byType(WiredGridTile));
      expect(tapped, isTrue);
    });

    testWidgets('does not throw when tapping without onTap', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(child: const SizedBox.shrink()),
        ),
      );

      await tester.tap(find.byType(WiredGridTile));
      // No crash is the assertion here.
    });

    testWidgets('uses WiredInkSplashFactory for the ripple', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            onTap: () {},
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(WiredGridTile),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.splashFactory, isA<WiredInkSplashFactory>());
      expect(inkWell.onTap, isNotNull);
    });

    testWidgets('shows hand-drawn splash when tapped', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            onTap: () {},
            child: const SizedBox.shrink(),
          ),
        ),
      );

      await tester.tap(find.byType(WiredGridTile));
      // The splash is painted on the Material ink layer; pump through the
      // 400ms splash animation and assert no crash/exception occurs.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('marks button semantics when onTap provided', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            onTap: () {},
            semanticLabel: 'Photo tile',
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Photo tile'), findsOneWidget);
      final anyButtonSemantics = find.descendant(
        of: find.byType(WiredGridTile),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.button ?? false),
        ),
      );
      expect(anyButtonSemantics, findsOneWidget);
    });

    testWidgets('no button semantics when onTap is null', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 100,
          child: WiredGridTile(
            semanticLabel: 'Static tile',
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Static tile'), findsOneWidget);
      final anyButtonSemantics = find.descendant(
        of: find.byType(WiredGridTile),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.button ?? false),
        ),
      );
      expect(anyButtonSemantics, findsNothing);
    });
  });

  group('WiredGridTileBar', () {
    testWidgets('renders title', (tester) async {
      await pumpApp(
        tester,
        const WiredGridTileBar(title: Text('Gallery')),
      );

      expect(find.text('Gallery'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await pumpApp(
        tester,
        const WiredGridTileBar(
          title: Text('Title'),
          subtitle: Text('Subtitle'),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (tester) async {
      await pumpApp(
        tester,
        const WiredGridTileBar(title: Text('Title')),
      );

      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders leading and trailing widgets', (tester) async {
      await pumpApp(
        tester,
        const WiredGridTileBar(
          title: Text('Title'),
          leading: Icon(Icons.folder),
          trailing: Icon(Icons.more_vert),
        ),
      );

      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('honors custom height', (tester) async {
      await pumpApp(
        tester,
        const WiredGridTileBar(height: 40, title: Text('Title')),
      );

      expect(
        tester.getSize(find.byType(WiredGridTileBar)).height,
        40,
      );
    });

    testWidgets('draws a hand-drawn edge line', (tester) async {
      await pumpApp(
        tester,
        const WiredGridTileBar(title: Text('Title')),
      );

      // The bar paints a rough line via WiredCanvas.
      expect(findWiredCanvas, findsOneWidget);
      expect(findRepaintBoundary, findsWidgets);
    });
  });
}
