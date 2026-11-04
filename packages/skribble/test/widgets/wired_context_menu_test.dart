import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

void main() {
  group('WiredContextMenu', () {
    testWidgets('renders child', (tester) async {
      await pumpApp(
        tester,
        WiredContextMenu(
          actions: const [WiredContextMenuAction(label: 'Copy')],
          child: const Text('Long press me'),
        ),
      );
      expect(find.text('Long press me'), findsOneWidget);
    });

    testWidgets('shows menu on long press', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [
              WiredContextMenuAction(label: 'Cut', icon: Icons.cut),
              WiredContextMenuAction(label: 'Copy', icon: Icons.copy),
              WiredContextMenuAction(
                label: 'Delete',
                icon: Icons.delete,
                isDestructive: true,
              ),
            ],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Target')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Target'));
      await tester.pumpAndSettle();

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('calls action onPressed and dismisses', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: [
              WiredContextMenuAction(
                label: 'Action',
                onPressed: () => pressed = true,
              ),
            ],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Item')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Item'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
      // Menu should be dismissed
      expect(find.text('Action'), findsNothing);
    });

    testWidgets('dismisses when tapping outside', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [WiredContextMenuAction(label: 'Option')],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Box')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Box'));
      await tester.pumpAndSettle();
      expect(find.text('Option'), findsOneWidget);

      // Tap the background to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Option'), findsNothing);
    });

    testWidgets('shows icons when provided', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [
              WiredContextMenuAction(label: 'Edit', icon: Icons.edit),
              WiredContextMenuAction(label: 'Share', icon: Icons.share),
            ],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Press me')),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Press me'));
      await tester.pumpAndSettle();

      expect(findWiredIcon(Icons.edit), findsOneWidget);
      expect(findWiredIcon(Icons.share), findsOneWidget);
    });

    testWidgets('contains RepaintBoundary', (tester) async {
      await pumpApp(
        tester,
        WiredContextMenu(
          actions: const [WiredContextMenuAction(label: 'Test')],
          child: const Text('Content'),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('renders within WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.brown),
            child: Scaffold(
              body: WiredContextMenu(
                actions: [
                  WiredContextMenuAction(label: 'Action', onPressed: () {}),
                ],
                child: const Text('Long press me'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Long press me'), findsOneWidget);
    });

    testWidgets('ignores a long press that arrives after unmounting', (
      tester,
    ) async {
      await pumpApp(
        tester,
        WiredContextMenu(
          actions: const [WiredContextMenuAction(label: 'Copy')],
          child: const Text('target'),
        ),
      );

      final gesture = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(WiredContextMenu),
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // The captured long-press closure runs with a defunct context; the
      // guard must return instead of throwing.
      gesture.onLongPress?.call();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    Future<void> openMenu(
      WidgetTester tester, {
      Alignment alignment = Alignment.center,
      WiredThemeData? theme,
      List<WiredContextMenuAction>? actions,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: theme ?? WiredThemeData(),
            child: Scaffold(
              body: Align(
                alignment: alignment,
                child: WiredContextMenu(
                  actions:
                      actions ??
                      const [
                        WiredContextMenuAction(label: 'Copy'),
                        WiredContextMenuAction(label: 'Share'),
                        WiredContextMenuAction(
                          label: 'Delete',
                          isDestructive: true,
                        ),
                      ],
                  child: const SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(child: Text('Anchor')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.longPress(find.text('Anchor'));
      await tester.pumpAndSettle();
    }

    testWidgets('opens on a right-click', (tester) async {
      await pumpApp(
        tester,
        Center(
          child: WiredContextMenu(
            actions: const [WiredContextMenuAction(label: 'Rename')],
            child: const SizedBox(
              width: 100,
              height: 50,
              child: Center(child: Text('Desktop')),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Desktop'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();

      expect(find.text('Rename'), findsOneWidget);
    });

    testWidgets('closes with the Escape key', (tester) async {
      await openMenu(tester);
      expect(find.text('Copy'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('closes with the back button', (tester) async {
      await openMenu(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsNothing);
      expect(find.text('Anchor'), findsOneWidget);
    });

    testWidgets('activates the focused item with Enter', (tester) async {
      var copied = 0;
      await openMenu(
        tester,
        actions: [
          WiredContextMenuAction(label: 'Copy', onPressed: () => copied++),
        ],
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(copied, 1);
      expect(find.text('Copy'), findsNothing);
    });

    for (final alignment in [Alignment.bottomRight, Alignment.bottomLeft]) {
      testWidgets('stays on screen when anchored at $alignment', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(320, 640)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await openMenu(tester, alignment: alignment);

        final screen = Offset.zero & const Size(320, 640);
        for (final label in ['Copy', 'Share', 'Delete']) {
          final rect = tester.getRect(find.text(label));
          expect(screen.contains(rect.topLeft), isTrue, reason: label);
          expect(screen.contains(rect.bottomRight), isTrue, reason: label);
        }
        // There is no room below the anchor, so the menu opens above it.
        expect(
          tester.getRect(find.text('Delete')).bottom,
          lessThan(tester.getRect(find.text('Anchor')).top),
        );
      });
    }

    testWidgets('keeps clear of the notch and home indicator', (tester) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1
        ..padding = const FakeViewPadding(top: 48, bottom: 34);
      addTearDown(tester.view.reset);

      await openMenu(tester, alignment: Alignment.bottomCenter);

      expect(
        tester.getRect(find.text('Delete')).bottom,
        lessThanOrEqualTo(640 - 34),
      );
    });

    testWidgets('names its route for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await openMenu(tester);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Menu')),
        matchesSemantics(
          label: 'Menu',
          scopesRoute: true,
          namesRoute: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('draws on the theme paper and inks destructive items in the '
        'error colour', (tester) async {
      final dark = WiredThemeData.cuddly(brightness: Brightness.dark);
      await openMenu(tester, theme: dark);

      final delete = tester.widget<Text>(find.text('Delete'));
      expect(delete.style?.color, dark.errorColor);
      final copy = tester.widget<Text>(find.text('Copy'));
      expect(copy.style?.color, dark.textColor);

      final paper = tester
          .widgetList<WiredCanvas>(findWiredCanvas)
          .map((canvas) => canvas.painter)
          .whereType<WiredRoundedRectangleBase>()
          .single;
      expect(paper.fillColor, dark.fillColor);
      expect(paper.borderColor, dark.borderColor);
    });
  });
}
