import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skribble_storybook/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final screenshotsDir = '${Directory.current.path}/.screenshots';

  Future<void> takeScreenshot(String name) async {
    final dir = Directory('$screenshotsDir/${name.split('/').first}');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await binding.takeScreenshot(name);
  }

  Future<void> scrollToAndTap(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(find.text(text), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('Screenshots', () {
    testWidgets('capture home page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await takeScreenshot('home/home');
    });

    testWidgets('capture buttons page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buttons'));
      await tester.pumpAndSettle();

      await takeScreenshot('buttons/buttons');
    });

    testWidgets('capture inputs page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inputs'));
      await tester.pumpAndSettle();

      await takeScreenshot('inputs/inputs');
    });

    testWidgets('capture navigation page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Navigation'));
      await tester.pumpAndSettle();

      await takeScreenshot('navigation/navigation');
    });

    testWidgets('capture selection page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Selection');

      await takeScreenshot('selection/selection');
    });

    testWidgets('capture feedback page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Feedback');

      await takeScreenshot('feedback/feedback');
    });

    testWidgets('capture layout page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Layout');

      await takeScreenshot('layout/layout');
    });

    testWidgets('capture data display page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Data Display');

      await takeScreenshot('data-display/data-display');
    });
  });
}
