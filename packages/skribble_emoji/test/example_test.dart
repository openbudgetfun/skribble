import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

import '../example/example.dart';

void main() {
  testWidgets('the package example draws its emoji', (tester) async {
    await tester.pumpWidget(
      SkribbleApp(wiredTheme: WiredThemeData(), home: const EmojiExample()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WiredEmoji), findsWidgets);
    expect(find.byType(WiredEmojiText), findsOneWidget);
    expect(find.byType(WiredAnimatedEmoji), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
