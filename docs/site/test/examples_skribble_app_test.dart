import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';

/// Every live example renders inside a widgets-only `SkribbleApp` bridged
/// with `WiredMaterialTheme`, the setup the getting-started guide teaches.
///
/// Material-backed widgets need a `Material` ancestor and Material and
/// Cupertino localizations; the bridge must supply all three, on every
/// page, without a `MaterialApp`.
void main() {
  for (final MapEntry(key: id, value: definition) in examples.entries) {
    testWidgets('$id renders in a SkribbleApp', (tester) async {
      tester.view
        ..physicalSize = const Size(1000, 2000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        SkribbleApp(
          builder: (context, child) => WiredMaterialTheme(child: child!),
          home: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 720,
                child: definition.builder(ExampleSettings()),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);

      // Let looping examples and their timers wind down.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
