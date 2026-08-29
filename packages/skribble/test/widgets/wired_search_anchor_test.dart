import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

void main() {
  group('WiredSearchController', () {
    test('starts closed', () {
      final controller = WiredSearchController();

      expect(controller.isOpen, isFalse);

      controller.dispose();
    });

    testWidgets('openView and closeView flip the open state', (tester) async {
      WiredSearchController? observed;

      await pumpApp(
        tester,
        WiredSearchAnchor(
          builder: (context, controller) {
            observed = controller;
            return const Text('collapsed');
          },
          suggestionsBuilder: (context, controller) => const [],
        ),
      );

      final controller = observed!;
      expect(controller.isOpen, isFalse);

      controller.openView();
      await tester.pump();

      expect(controller.isOpen, isTrue);
      expect(find.text('collapsed'), findsNothing);

      controller.closeView();
      await tester.pump();

      expect(controller.isOpen, isFalse);
      expect(find.text('collapsed'), findsOneWidget);
    });

    testWidgets('closeView stores the selected text', (tester) async {
      WiredSearchController? observed;

      await pumpApp(
        tester,
        WiredSearchAnchor(
          builder: (context, controller) {
            observed = controller;
            return const Text('collapsed');
          },
          suggestionsBuilder: (context, controller) => const [],
        ),
      );

      final controller = observed!;
      controller.openView();
      await tester.pump();

      controller.closeView('picked result');
      await tester.pump();

      expect(controller.text, 'picked result');
      expect(controller.isOpen, isFalse);
    });
  });

  group('WiredSearchAnchor', () {
    WiredSearchAnchor buildAnchor({
      WiredSearchController? controller,
      String? viewHintText,
      Widget? viewLeading,
      Widget? viewTrailing,
      Widget? viewEmptyWidget,
      List<String> Function(String query)? options,
      ValueChanged<String>? onSelected,
    }) {
      return WiredSearchAnchor(
        searchController: controller,
        viewHintText: viewHintText,
        viewLeading: viewLeading,
        viewTrailing: viewTrailing,
        viewEmptyWidget: viewEmptyWidget,
        builder: (context, controller) => WiredSearchBar(
          controller: controller,
          hintText: 'Find a fruit',
          onTap: controller.openView,
        ),
        suggestionsBuilder: (context, controller) => [
          for (final option
              in (options ?? (_) => const <String>['Apple', 'Banana'])(
                controller.text,
              ))
            WiredListTile(
              title: Text(option),
              onTap: () {
                onSelected?.call(option);
                controller.closeView(option);
              },
            ),
        ],
      );
    }

    testWidgets('renders the collapsed builder by default', (tester) async {
      await pumpApp(tester, buildAnchor());

      expect(find.byType(WiredSearchBar), findsOneWidget);
      expect(find.text('Find a fruit'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('opens the search view when the bar is tapped', (tester) async {
      final controller = WiredSearchController();

      await pumpApp(tester, buildAnchor(controller: controller));

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(controller.isOpen, isTrue);
      // The view contains its own wired search bar for the live query.
      expect(find.text('Search...'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('rebuilds suggestions while typing', (tester) async {
      final controller = WiredSearchController();

      await pumpApp(
        tester,
        buildAnchor(
          controller: controller,
          options: (query) =>
              <String>[
                    'Apple',
                    'Banana',
                  ]
                  .where((o) => o.toLowerCase().contains(query.toLowerCase()))
                  .toList(),
        ),
      );

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);

      // Type into the view's live search bar.
      await tester.enterText(
        find.widgetWithText(TextField, 'Search...'),
        'ban',
      );
      await tester.pump();

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('default hint text is Search...', (tester) async {
      final controller = WiredSearchController();

      await pumpApp(tester, buildAnchor(controller: controller));

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(find.text('Search...'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('viewHintText customizes the view hint', (tester) async {
      final controller = WiredSearchController();

      await pumpApp(
        tester,
        buildAnchor(controller: controller, viewHintText: 'Type a fruit'),
      );

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(find.text('Type a fruit'), findsOneWidget);
      expect(find.text('Search...'), findsNothing);

      controller.dispose();
    });

    testWidgets('tapping the default back arrow closes the view', (
      tester,
    ) async {
      final controller = WiredSearchController();

      await pumpApp(tester, buildAnchor(controller: controller));

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();
      expect(controller.isOpen, isTrue);

      await tester.tap(findWiredIcon(Icons.arrow_back));
      await tester.pump();

      expect(controller.isOpen, isFalse);
      expect(find.byType(WiredSearchBar), findsOneWidget);
      expect(find.text('Find a fruit'), findsOneWidget);
      expect(find.text('Search...'), findsNothing);

      controller.dispose();
    });

    testWidgets('viewLeading replaces the default back arrow', (tester) async {
      final controller = WiredSearchController();

      await pumpApp(
        tester,
        buildAnchor(
          controller: controller,
          viewLeading: const Icon(Icons.menu),
        ),
      );

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      controller.dispose();
    });

    testWidgets('viewTrailing is rendered in the view', (tester) async {
      final controller = WiredSearchController();

      await pumpApp(
        tester,
        buildAnchor(controller: controller, viewTrailing: Icon(Icons.mic)),
      );

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(find.byIcon(Icons.mic), findsOneWidget);

      controller.dispose();
    });

    testWidgets('viewEmptyWidget is shown when there are no suggestions', (
      tester,
    ) async {
      final controller = WiredSearchController();

      await pumpApp(
        tester,
        buildAnchor(
          controller: controller,
          viewEmptyWidget: const Text('No matches'),
          options: (_) => const <String>[],
        ),
      );

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      expect(find.text('No matches'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('selecting a suggestion populates the field and closes', (
      tester,
    ) async {
      final controller = WiredSearchController();
      String? selected;

      await pumpApp(
        tester,
        buildAnchor(controller: controller, onSelected: (v) => selected = v),
      );

      await tester.tap(find.byType(WiredSearchBar));
      await tester.pump();

      await tester.tap(find.text('Banana'));
      await tester.pump();

      expect(selected, 'Banana');
      expect(controller.isOpen, isFalse);
      expect(find.text('Banana'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('disposes the controller it owns', (tester) async {
      WiredSearchController? observed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredSearchAnchor(
              builder: (context, controller) {
                observed = controller;
                return const Text('collapsed');
              },
              suggestionsBuilder: (context, controller) => const [],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(observed, isNotNull);

      // Unmounting must dispose the internally created controller.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(() => observed!.dispose(), throwsFlutterError);
    });
  });
}
