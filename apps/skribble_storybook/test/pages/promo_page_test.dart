import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/pages/promo_page.dart';
import 'package:skribble_storybook/promo/promo_reel.dart';

void main() {
  testWidgets('every scene of the reel builds and shows its words', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 1080)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final scenes = {
      2.5: 'skribble',
      5.0: 'A hand-drawn design system for Flutter',
      10.0: 'Every control, hand-drawn',
      14.0: 'Gentle ink',
      20.0: '3,963 emoji, all drawn by hand',
      25.0: 'and they move',
      29.0: 'Night paper',
      33.0: 'flutter pub add skribble',
    };
    for (final MapEntry(key: time, value: words) in scenes.entries) {
      await tester.pumpWidget(PromoReel(time: time));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(words), findsOneWidget, reason: '$time s');
      expect(tester.takeException(), isNull, reason: '$time s');
    }
  });

  testWidgets('the promo page plays the reel on a loop', (tester) async {
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: const PromoPage(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PromoReel), findsOneWidget);
    expect(tester.hasRunningAnimations, isTrue);
    final early = tester.widget<PromoReel>(find.byType(PromoReel)).time;
    await tester.pump(const Duration(seconds: 3));
    expect(
      tester.widget<PromoReel>(find.byType(PromoReel)).time,
      greaterThan(early),
    );
  });
}
