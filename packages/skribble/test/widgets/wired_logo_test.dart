import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('uses the default 48 px square', (tester) async {
    await tester.pumpWidget(_app(const WiredLogo()));
    expect(tester.getSize(find.byType(WiredLogo)), const Size(48, 48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces one image with the brand name', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const WiredLogo()));
    expect(find.bySemanticsLabel('Skribble'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('can be silent beside a wordmark', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const WiredLogo(semanticLabel: null)));
    expect(find.bySemanticsLabel('Skribble'), findsNothing);
    semantics.dispose();
  });

  testWidgets('supports a custom accessible label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const WiredLogo(semanticLabel: 'Made with Skribble')),
    );
    expect(find.bySemanticsLabel('Made with Skribble'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('fits tight rectangular constraints without layout overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 24,
          height: 16,
          child: WiredLogo(size: 96),
        ),
      ),
    );
    expect(tester.getSize(find.byType(WiredLogo)), const Size(24, 16));
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero size and rapid theme changes remain still', (tester) async {
    await tester.pumpWidget(_app(const WiredLogo(size: 0)));
    expect(tester.getSize(find.byType(WiredLogo)), Size.zero);
    for (final brightness in [
      Brightness.light,
      Brightness.dark,
      Brightness.light,
    ]) {
      await tester.pumpWidget(
        _app(
          WiredTheme(
            data: WiredThemeData.cuddly(brightness: brightness),
            child: const WiredLogo(),
          ),
        ),
      );
    }
    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

Widget _app(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);
