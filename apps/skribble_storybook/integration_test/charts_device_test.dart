import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skribble_storybook/app.dart';

/// Runs against the real native chart and MapLibre platform view.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final platform = defaultTargetPlatform == TargetPlatform.iOS
      ? 'ios'
      : 'android';

  testWidgets(
    'financial charts and maps work through the native Storybook',
    (
      tester,
    ) async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      addTearDown(() => SystemChrome.setPreferredOrientations([]));
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Financial charts'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Financial charts'));
      await tester.pumpAndSettle();
      expect(find.text('Markets, in ink.'), findsOneWidget);
      binding.reportData = {
        'platform': platform,
        'buildMode': kProfileMode ? 'profile' : 'debug',
      };

      final plot = find.byKey(const ValueKey('chart-plot'));
      await tester.ensureVisible(plot);
      await tester.pumpAndSettle();
      final plotRect = tester.getRect(plot);
      await tester.tapAt(plotRect.topLeft + Offset(plotRect.width * .5, 100));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('chart-selection-details')))
            .data,
        contains('O '),
      );

      await binding.watchPerformance(() async {
        for (var index = 0; index < 8; index++) {
          await tester.dragFrom(
            plotRect.topLeft + Offset(plotRect.width * .5, 100),
            Offset(index.isEven ? 90 : -90, 0),
          );
          await tester.pumpAndSettle();
        }
      }, reportKey: 'chart_pan_$platform');

      final leftFinger = await tester.startGesture(
        plotRect.topLeft + Offset(plotRect.width * .35, 100),
        pointer: 1,
      );
      final rightFinger = await tester.startGesture(
        plotRect.topLeft + Offset(plotRect.width * .65, 100),
        pointer: 2,
      );
      await leftFinger.moveBy(const Offset(-35, 0));
      await rightFinger.moveBy(const Offset(35, 0));
      await tester.pump();
      await leftFinger.up();
      await rightFinger.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Measure normal native rendering before enabling Android screenshot mode.
      if (defaultTargetPlatform == TargetPlatform.android) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pump();
      }
      await binding.takeScreenshot('charts/$platform');

      for (final label in ['Line', 'Area', 'OHLC', 'Candles']) {
        await _show(tester, _choice(label), upwards: true);
        await tester.tap(_choice(label));
        await tester.pumpAndSettle();
        expect(find.text('✓ $label'), findsOneWidget);
      }
      await tester.tap(_choice('Night'));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('charts/$platform-night');
      await tester.tap(_choice('Night'));
      await tester.pumpAndSettle();

      await _show(tester, find.text('Draw and save'));
      await tester.tap(find.text('Draw and save'));
      await tester.pumpAndSettle();
      await _show(tester, _choice('Price level'));
      await tester.tap(_choice('Price level'));
      await _show(tester, plot, upwards: true);
      final drawRect = tester.getRect(plot);
      final drawingPoint = drawRect.topLeft + Offset(drawRect.width * .4, 100);
      await tester.tapAt(drawingPoint);
      await tester.pumpAndSettle();
      final pagePosition = tester.getTopLeft(plot);
      await tester.dragFrom(drawingPoint, const Offset(0, 45));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(plot).dy,
        closeTo(pagePosition.dy, .5),
        reason: 'Dragging a drawing handle must not scroll the Storybook page',
      );
      await _show(tester, find.text('Save workspace'));
      await tester.tap(find.text('Save workspace'));
      await tester.pumpAndSettle();
      await _show(tester, find.text('Undo'), upwards: true);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      await _show(tester, find.text('Restore workspace'));
      await tester.tap(find.text('Restore workspace'));
      await tester.pumpAndSettle();
      await _show(
        tester,
        find.byKey(const ValueKey('chart-workspace-status')),
        upwards: true,
      );
      expect(
        find.text('Workspace restored, including your drawings.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      final homeScroll = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Maps'),
        300,
        scrollable: homeScroll,
      );
      await tester.tap(find.text('Maps'));
      await tester.pumpAndSettle();
      await _waitFor(tester, find.text('Map ready'));
      final semantics = tester.ensureSemantics();
      await tester.tap(find.bySemanticsLabel('Brick Lane market'));
      await tester.pumpAndSettle();
      expect(find.text('Brick Lane market'), findsOneWidget);
      await binding.takeScreenshot('maps/$platform');
      await tester.tap(find.text('Tokyo'));
      await tester.pumpAndSettle();
      await _waitFor(tester, find.text('Map ready'));
      await tester.tap(find.bySemanticsLabel('Shibuya crossing'));
      await tester.pumpAndSettle();
      expect(find.text('Shibuya crossing'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Zoom in'));
      await tester.pumpAndSettle();
      await _waitFor(tester, find.text('Map ready'));
      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();
      await _waitFor(tester, find.text('Map ready'));
      await binding.takeScreenshot('maps/$platform-night');
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 5)),
    skip:
        kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS),
  );
}

Finder _choice(String label) =>
    find.textContaining(RegExp('^(?:✓ )?${RegExp.escape(label)}\$'));

Future<void> _show(
  WidgetTester tester,
  Finder finder, {
  bool upwards = false,
}) async {
  final scrollable = find
      .descendant(
        of: find.byKey(const ValueKey('charts-page-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(
    finder,
    upwards ? -250 : 250,
    scrollable: scrollable,
    maxScrolls: 30,
  );
  await tester.pumpAndSettle();
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget);
}
