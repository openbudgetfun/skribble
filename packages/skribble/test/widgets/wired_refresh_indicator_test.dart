import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

/// Dispatches an overscroll past the refresh threshold from inside [child],
/// where the indicator's notification listener receives it.
Future<void> overscrollPastThreshold(WidgetTester tester, Finder child) async {
  final context = tester.element(child);
  final metrics = FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 0,
    pixels: 0,
    viewportDimension: 600,
    axisDirection: AxisDirection.down,
    devicePixelRatio: 1,
  );
  OverscrollNotification(
    metrics: metrics,
    context: context,
    overscroll: -60,
  ).dispatch(context);
  await tester.pump();
}

void main() {
  group('WiredRefreshIndicator', () {
    testWidgets('is exported and paints its child', (tester) async {
      await pumpWired(
        tester,
        SizedBox(
          height: 200,
          child: WiredRefreshIndicator(
            onRefresh: () async {},
            child: ListView(children: const [Text('list body')]),
          ),
        ),
      );

      expectRenders(tester, findWired<WiredRefreshIndicator>());
      expect(find.text('list body'), findsOneWidget);
    });

    testWidgets(
      'forwards the semantics label without announcing it as a value',
      (tester) async {
        final handle = tester.ensureSemantics();

        await pumpWired(
          tester,
          SizedBox(
            height: 400,
            child: WiredRefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 100));
              },
              semanticLabel: 'Refreshing content',
              // Clamping physics reports overscroll, so the pull works on
              // every host platform's default scroll behavior.
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                children: const [
                  SizedBox(height: 100, child: Text('list body')),
                ],
              ),
            ),
          ),
        );

        await tester.fling(find.text('list body'), const Offset(0, 300), 1000);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        String? value;
        String? label;
        bool visit(SemanticsNode node) {
          if (node.label.isNotEmpty) label = node.label;
          if (node.value.isNotEmpty) value = node.value;
          node.visitChildren(visit);
          return true;
        }

        visit(tester.getSemantics(findWired<WiredRefreshIndicator>()));

        expect(label, 'Refreshing content');
        expect(
          value,
          isNot('Refreshing content'),
          reason:
              'the label was previously forwarded as the semantics value '
              'too, so screen readers announced it twice; the framework now '
              'synthesizes its own progress value instead',
        );

        await tester.pumpAndSettle();
        handle.dispose();
      },
    );
  });

  group('WiredCustomRefreshIndicator', () {
    testWidgets(
      'hides the spinner after a failing refresh instead of wedging',
      (tester) async {
        var attempts = 0;
        Object? zoneError;
        await runZonedGuarded(() async {
          await pumpApp(
            tester,
            WiredCustomRefreshIndicator(
              onRefresh: () async {
                attempts++;
                await Future<void>.delayed(const Duration(milliseconds: 50));
                throw Exception('network down');
              },
              child: const Text('list body'),
            ),
          );

          await overscrollPastThreshold(tester, find.text('list body'));
        }, (error, stackTrace) => zoneError = error);
        expect(attempts, 1);
        expect(find.byType(WiredLoadingIndicator), findsOneWidget);

        // After the refresh future fails the error still reaches the zone...
        await tester.pump(const Duration(milliseconds: 50));
        expect(zoneError, isA<Exception>());
        // ...and the spinner clears instead of wedging on screen forever.
        await tester.pump();
        expect(find.byType(WiredLoadingIndicator), findsNothing);
      },
    );

    testWidgets('hides the spinner after a successful refresh', (tester) async {
      await pumpApp(
        tester,
        WiredCustomRefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          },
          child: const Text('list body'),
        ),
      );

      await overscrollPastThreshold(tester, find.text('list body'));
      expect(find.byType(WiredLoadingIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(WiredLoadingIndicator), findsNothing);
    });

    testWidgets('ignores a second trigger while a refresh is running', (
      tester,
    ) async {
      var attempts = 0;
      await pumpApp(
        tester,
        WiredCustomRefreshIndicator(
          onRefresh: () async {
            attempts++;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          },
          child: const Text('list body'),
        ),
      );

      await overscrollPastThreshold(tester, find.text('list body'));
      await overscrollPastThreshold(tester, find.text('list body'));
      expect(attempts, 1);

      await tester.pumpAndSettle();
      expect(find.byType(WiredLoadingIndicator), findsNothing);
    });
  });
}
