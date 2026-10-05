import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';
import 'package:skribble_storybook/pages/emoji_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      WiredMaterialApp(wiredTheme: WiredThemeData(), home: const EmojiPage()),
    );
    await tester.pumpAndSettle();
  }

  Finder emoji(String text) => find.byWidgetPredicate(
    (widget) =>
        widget is WiredEmoji &&
        SkribbleEmoji.lookup(widget.emoji) == SkribbleEmoji.lookup(text),
  );

  testWidgets('opens on smileys with the catalog size', (tester) async {
    await pumpPage(tester);
    expect(find.text('Hand-drawn emoji'), findsOneWidget);
    expect(
      find.textContaining('3,963 emoji'),
      findsOneWidget,
    );
    expect(emoji('😀'), findsWidgets);
  });

  testWidgets('switches groups with the group chips', (tester) async {
    await pumpPage(tester);
    expect(find.text('Smileys & Emotion'), findsOneWidget);
    await tester.tap(emoji('🍕'));
    await tester.pumpAndSettle();
    expect(find.text('Food & Drink'), findsOneWidget);
    final food = SkribbleEmoji.inGroup(EmojiGroup.foodAndDrink);
    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: emoji(food.first.emoji),
      ),
      findsOneWidget,
    );
  });

  testWidgets('searches by name and says when nothing matches', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'party popper');
    await tester.pumpAndSettle();
    expect(emoji('🎉'), findsWidgets);
    expect(find.text('Smileys & Emotion'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzzz not an emoji');
    await tester.pumpAndSettle();
    expect(find.text('No emoji match "zzzz not an emoji"'), findsOneWidget);
  });

  testWidgets('applies the chosen skin tone to toned emoji', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'thumbs up');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('dark skin tone'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is WiredEmoji && widget.emoji == '👍🏿',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('previews an emoji at three sizes and three weights', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'popper');
    await tester.pumpAndSettle();
    await tester.tap(emoji('🎉').first);
    await tester.pumpAndSettle();
    expect(find.text('party popper'), findsOneWidget);
    expect(find.text('96 px'), findsOneWidget);
    expect(find.text('Bold'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Bold'), findsNothing);
  });
}
