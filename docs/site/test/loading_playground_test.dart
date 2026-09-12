import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/loading_playground.dart';

void main() {
  testWidgets(
    'gallery supports narrow layouts, large text and loading controls',
    (tester) async {
      for (final width in [320.0, 900.0]) {
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: WiredThemeData.cuddly(),
            home: WiredScaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(width == 320 ? 1.5 : 1),
                ),
                child: const SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LoadingPlayground(),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.byType(WiredLoader), findsNWidgets(7));
        await tester.tap(find.text('Settle motion'));
        await tester.pumpAndSettle();
        expect(tester.hasRunningAnimations, isFalse);
        await tester.tap(find.text('Show loaded content'));
        await tester.pump();
        expect(
          tester
              .widget<WiredSkeletonOverlay>(find.byType(WiredSkeletonOverlay))
              .loading,
          isFalse,
        );
        await tester.ensureVisible(find.text('Load another sketch'));
        await tester.tap(find.text('Load another sketch'));
        await tester.pump();
        expect(
          tester
              .widget<WiredSkeletonOverlay>(find.byType(WiredSkeletonOverlay))
              .loading,
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
