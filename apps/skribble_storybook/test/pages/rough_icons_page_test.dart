import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/rough_icons_page.dart';

void main() {
  group('RoughIconsPage', () {
    Future<void> navigateToRoughIcons(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Rough Icons'), 200);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rough Icons'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders RoughIconsPage', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(RoughIconsPage), findsOneWidget);
    });

    testWidgets('shows title and subtitle text', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.text('Rough Icons'), findsOneWidget);
      expect(
        find.text('Generated rough Material icon catalog'),
        findsOneWidget,
      );
    });

    testWidgets('has back button', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('renders rough icons with identifier labels', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(WiredIcon), findsWidgets);
      // The grid lazily renders the first visible rows; the alphabetically
      // first identifier must be among them.
      expect(find.text('ac_unit'), findsOneWidget);
    });

    testWidgets('shows icon count text', (tester) async {
      await navigateToRoughIcons(tester);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.endsWith(' icons'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders a search input', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(WiredInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('search filters icons by identifier', (tester) async {
      await navigateToRoughIcons(tester);

      await tester.enterText(find.byType(TextField), 'ac_unit');
      await tester.pumpAndSettle();

      // The matching cell label stays visible. The predicate skips the
      // search field's own EditableText content — only grid Text labels
      // match.
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == 'ac_unit',
        ),
        findsOneWidget,
      );
      // Non-matching labels are filtered out of the lazy grid.
      expect(find.text('add'), findsNothing);
    });

    testWidgets('search shows an empty state without matches', (tester) async {
      await navigateToRoughIcons(tester);

      await tester.enterText(find.byType(TextField), 'zzzznope');
      await tester.pumpAndSettle();

      expect(find.text('No icons match "zzzznope"'), findsOneWidget);
      expect(find.byType(WiredIcon), findsNothing);
    });

    testWidgets('opens a preview popup when an icon is tapped', (tester) async {
      await navigateToRoughIcons(tester);

      await tester.tap(find.text('ac_unit'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('ac_unit'), findsNWidgets(2));
      expect(find.text('24px'), findsOneWidget);
      expect(find.text('48px'), findsOneWidget);
      expect(find.text('96px'), findsOneWidget);
    });

    testWidgets('popup dismisses on outside tap', (tester) async {
      await navigateToRoughIcons(tester);

      await tester.tap(find.text('ac_unit'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);

      await tester.tapAt(const Offset(10, 300));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('navigates back to home', (tester) async {
      await navigateToRoughIcons(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(RoughIconsPage), findsNothing);
      expect(find.text('Skribble Storybook'), findsOneWidget);
    });
  });
}
