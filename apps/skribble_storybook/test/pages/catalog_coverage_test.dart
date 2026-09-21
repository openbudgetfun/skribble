import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/pages/drawing_page.dart';
import 'package:skribble_storybook/pages/loading_page.dart';
import 'package:skribble_storybook/pages/skribble_icons_page.dart';
import 'package:skribble_storybook/pages/variable_fonts_page.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      WiredMaterialApp(wiredTheme: WiredThemeData(), home: page),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'each icon set renders searchable artwork and an accessible preview',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await pump(tester, const SkribbleIconsPage());
        for (final set in [
          'Curated',
          'Material',
          'Lucide',
          'Simple Icons',
          'Boxicons',
          'CoreUI Brands',
        ]) {
          await tester.tap(find.text(set));
          await tester.pump();
          expect(find.byType(WiredSvgIcon), findsWidgets);
          expect(tester.takeException(), isNull, reason: set);
        }
        await tester.tap(find.text('Lucide'));
        await tester.pump();
        await tester.enterText(find.byType(EditableText), 'arrow-down');
        await tester.pump();
        final icon = find.byWidgetPredicate(
          (widget) =>
              widget is WiredSvgIcon &&
              widget.semanticLabel == 'Lucide: arrow-down',
        );
        expect(icon, findsOneWidget);
        await tester.tap(icon);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Gentle'), findsOneWidget);
        expect(find.text('Playful'), findsOneWidget);
        expect(find.text('Expressive'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(find.text('24px'), findsNWidgets(3));
        expect(find.text('48px'), findsNWidgets(3));
        expect(find.text('96px'), findsNWidgets(3));
        expect(find.bySemanticsLabel(RegExp('arrow-down')), findsWidgets);
        Navigator.of(tester.element(find.text('24px').first)).pop();
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(EditableText),
          'no-icon-with-this-name',
        );
        await tester.pump();
        expect(
          find.text('No icons match "no-icon-with-this-name"'),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('icon comparisons fit a small phone with enlarged text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const SkribbleIconsPage(),
      ),
    );
    await tester.pumpAndSettle();
    final home = find.byWidgetPredicate(
      (widget) =>
          widget is WiredSvgIcon && widget.semanticLabel == 'Curated: home',
    );
    await tester.scrollUntilVisible(
      home,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(home);
    await tester.pumpAndSettle();
    expect(find.text('Gentle'), findsOneWidget);
    await tester.ensureVisible(find.text('Expressive'));
    await tester.pumpAndSettle();
    expect(find.text('Expressive').hitTestable(), findsOneWidget);
    final largest = find.byWidgetPredicate(
      (widget) =>
          widget is WiredSvgIcon &&
          widget.semanticLabel == 'home, expressive, 96 pixels',
    );
    await tester.ensureVisible(largest);
    await tester.pumpAndSettle();
    expect(largest.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'loading controls pause animation and reveal selectable content',
    (tester) async {
      await pump(tester, const WiredLoadingPage());
      expect(find.byType(WiredLoader), findsWidgets);
      await tester.tap(find.text('Pause motion'));
      await tester.pump();
      expect(
        tester.widget<WiredMotion>(find.byType(WiredMotion).last).enabled,
        isFalse,
      );
      await tester.tap(find.text('Show content'));
      await tester.pump();
      expect(
        tester
            .widget<WiredSkeletonOverlay>(find.byType(WiredSkeletonOverlay))
            .loading,
        isFalse,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('doodles can be redrawn without overflow on a phone', (
    tester,
  ) async {
    await pump(tester, const WiredDrawingPage());
    final before = tester
        .widget<WiredDoodle>(find.byType(WiredDoodle).first)
        .seed;
    await tester.tap(find.text('Draw another'));
    await tester.pump();
    expect(
      tester.widget<WiredDoodle>(find.byType(WiredDoodle).first).seed,
      before + 1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'variable font changes sample, weight and cursive form then resets',
    (tester) async {
      await pump(tester, const WiredVariableFontsPage());
      await tester.enterText(find.byType(EditableText), 'Notebook 42');
      await tester.pump();
      Text sample() =>
          tester.widget<Text>(find.byKey(const ValueKey('variable-specimen')));
      expect(sample().data, 'Notebook 42');
      final weight = tester
          .widgetList<WiredSlider>(find.byType(WiredSlider))
          .first;
      weight.onChanged!(750);
      await tester.pump();
      expect(sample().style!.fontVariations!.first.value, 750);
      await tester.ensureVisible(find.text('Cursive'));
      await tester.tap(find.text('Cursive'));
      await tester.pump();
      expect(sample().style!.fontVariations!.last.value, 1);
      await tester.ensureVisible(find.text('Reset axes'));
      await tester.tap(find.text('Reset axes'));
      await tester.pump();
      expect(sample().style!.fontVariations!.first.value, 400);
      expect(sample().style!.fontVariations!.last.value, 0.5);
      expect(tester.takeException(), isNull);
    },
  );
}
