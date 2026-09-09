import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';

void main() {
  testWidgets('quiet actions support tab, space, enter, and button semantics', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: WiredScaffold(
          body: Center(
            child: DocsAction(
              onPressed: () => calls++,
              child: const Text('Change the ink'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.bySemanticsLabel('Change the ink'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Change the ink')),
      matchesSemantics(
        label: 'Change the ink',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        isFocused: true,
      ),
    );
  });
}
