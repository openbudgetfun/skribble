import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  for (final family in [skribbleFontFamily, 'App handwriting']) {
    testWidgets('labels retain the $family family through local styles', (
      tester,
    ) async {
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(fontFamily: family),
          home: WiredScaffold(
            appBar: const WiredAppBar(title: Text('A title')),
            body: Column(
              children: const [
                WiredListTile(
                  title: Text('A list title'),
                  subtitle: Text('A subtitle'),
                ),
                WiredChip(label: Text('A chip')),
              ],
            ),
          ),
        ),
      );
      for (final label in ['A title', 'A list title', 'A subtitle', 'A chip']) {
        final style = DefaultTextStyle.of(tester.element(find.text(label)))
            .style;
        expect(
          style.fontFamily,
          family == skribbleFontFamily ? 'packages/skribble/SkribblePlayful' : family,
          reason: label,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
