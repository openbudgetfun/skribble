import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// Wired text fields draw their own ink border. Under the Material bridge
/// theme, which supplies outlined and filled input defaults, the inner field
/// must still resolve to no border and no fill, or a second box appears
/// inside the ink.
void main() {
  Future<InputDecoration> resolved(WidgetTester tester, Widget field) async {
    await tester.pumpWidget(
      WiredMaterialApp(
        wiredTheme: WiredThemeData(),
        home: Scaffold(
          body: Center(child: SizedBox(width: 320, child: field)),
        ),
      ),
    );
    final decorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator).first,
    );
    final theme = Theme.of(tester.element(find.byType(InputDecorator).first));
    return decorator.decoration.applyDefaults(theme.inputDecorationTheme);
  }

  void expectBare(InputDecoration decoration) {
    expect(decoration.filled, isFalse);
    for (final border in [
      decoration.border,
      decoration.enabledBorder,
      decoration.focusedBorder,
      decoration.disabledBorder,
    ]) {
      expect(border, InputBorder.none);
    }
  }

  testWidgets('WiredSearchBar has only its ink border', (tester) async {
    expectBare(await resolved(tester, const WiredSearchBar()));
  });

  testWidgets('WiredAutocomplete has only its ink border', (tester) async {
    expectBare(
      await resolved(
        tester,
        WiredAutocomplete<String>(
          options: const ['one', 'two'],
          displayStringForOption: (option) => option,
        ),
      ),
    );
  });

  testWidgets('WiredCupertinoTextField has only its ink border', (
    tester,
  ) async {
    expectBare(await resolved(tester, const WiredCupertinoTextField()));
  });

  testWidgets('the theme does supply outlined, filled defaults', (
    tester,
  ) async {
    // Guards the premise: without the overrides these fields would be boxed.
    final theme = WiredThemeData().toThemeData();
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.enabledBorder, isA<OutlineInputBorder>());
  });
}
