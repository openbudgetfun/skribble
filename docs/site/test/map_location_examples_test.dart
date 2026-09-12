import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';
import 'package:skribble_maps/skribble_maps.dart';

void main() {
  testWidgets('location comparison wraps on narrow pages', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: WiredScaffold(
          body: SingleChildScrollView(
            child: examples['map-location']!.builder(ExampleSettings()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Hide heading'));
    await tester.tap(find.text('Hide heading'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<WiredMapLocation>(find.byType(WiredMapLocation))
          .every((dot) => dot.heading == null),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('compare location ink and update all previews', (tester) async {
    final font = FontLoader('packages/skribble/Skribble')
      ..addFont(
        rootBundle.load('packages/skribble/assets/fonts/Skribble-Regular.ttf'),
      );
    await font.load();
    final buttonFont = FontLoader('packages/skribble/SkribblePlayful')
      ..addFont(
        rootBundle.load(
          'packages/skribble/assets/fonts/SkribblePlayful-Regular.ttf',
        ),
      );
    await buttonFont.load();
    await tester.binding.setSurfaceSize(const Size(660, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WiredTheme(
          data: WiredThemeData(),
          child: ColoredBox(
            color: const Color(0xFFFFFCF3),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'Skribble',
                  package: 'skribble',
                  fontSize: 16,
                  color: Color(0xFF292C30),
                ),
                child: examples['map-location']!.builder(
                  ExampleSettings(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WiredMapLocation), findsNWidgets(6));
    await tester.tap(find.text('Turn 45°'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<WiredMapLocation>(find.byType(WiredMapLocation))
          .every((dot) => dot.heading == 80),
      isTrue,
    );
    await tester.tap(find.text('Hide heading'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<WiredMapLocation>(find.byType(WiredMapLocation))
          .every((dot) => dot.heading == null),
      isTrue,
    );
    await tester.tap(find.text('Restore heading'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
