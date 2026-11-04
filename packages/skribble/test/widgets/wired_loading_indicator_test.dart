import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredLoadingIndicator', () {
    testWidgets('renders a loader at its size', (tester) async {
      await pumpWired(tester, const WiredLoadingIndicator(size: 32));

      expect(findWired<WiredLoader>(), findsOneWidget);
      expect(tester.getSize(findWired<WiredLoader>()), const Size(32, 32));
    });

    testWidgets('uses the theme border colour by default', (tester) async {
      final theme = WiredThemeData(borderColor: const Color(0xFF123456));
      await pumpWired(tester, const WiredLoadingIndicator(), theme: theme);

      final loader = tester.widget<WiredLoader>(findWired<WiredLoader>());
      expect(loader.color, const Color(0xFF123456));
    });

    testWidgets('passes a custom colour and stroke through', (tester) async {
      await pumpWired(
        tester,
        const WiredLoadingIndicator(color: Colors.teal, strokeWidth: 4),
      );

      final loader = tester.widget<WiredLoader>(findWired<WiredLoader>());
      expect(loader.color, Colors.teal);
      expect(loader.strokeWidth, 4);
    });
  });

  group('WiredCircularProgressIndicator', () {
    testWidgets('renders at its size', (tester) async {
      await pumpWired(
        tester,
        const WiredCircularProgressIndicator(value: .5, size: 40),
      );

      expect(
        tester.getSize(findWired<WiredCircularProgressIndicator>()),
        const Size(40, 40),
      );
    });

    testWidgets('indeterminate sweep keeps running', (tester) async {
      await pumpWired(tester, const WiredCircularProgressIndicator());

      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('stops scheduling frames once a value arrives', (
      tester,
    ) async {
      await pumpWired(tester, const WiredCircularProgressIndicator());
      await tester.pump(const Duration(milliseconds: 300));

      await pumpWired(tester, const WiredCircularProgressIndicator(value: .6));
      await tester.pump();

      // pumpAndSettle times out while a controller keeps repeating.
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('restarts the sweep when the value goes back to null', (
      tester,
    ) async {
      await pumpWired(tester, const WiredCircularProgressIndicator(value: .2));
      await tester.pumpAndSettle();

      await pumpWired(tester, const WiredCircularProgressIndicator());
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('clamps out-of-range values without error', (tester) async {
      await pumpWired(tester, const WiredCircularProgressIndicator(value: 3));

      expect(tester.takeException(), isNull);
    });

    testWidgets('announces its label and percentage', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpWired(
        tester,
        const WiredCircularProgressIndicator(
          value: .42,
          semanticLabel: 'Uploading',
        ),
      );

      expect(
        tester.getSemantics(findWired<WiredCircularProgressIndicator>()),
        matchesSemantics(label: 'Uploading', value: '42%'),
      );
      semantics.dispose();
    });
  });
}
