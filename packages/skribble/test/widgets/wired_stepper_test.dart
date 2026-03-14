import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredStepper', () {
    List<WiredStep> buildSteps({int count = 3}) {
      return List.generate(
        count,
        (i) => WiredStep(
          title: Text('Step ${i + 1}'),
          subtitle: Text('Subtitle ${i + 1}'),
          content: Text('Content ${i + 1}'),
        ),
      );
    }

    Widget buildStepper({
      List<WiredStep>? steps,
      int currentStep = 0,
      ValueChanged<int>? onStepTapped,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WiredStepper(
              steps: steps ?? buildSteps(),
              currentStep: currentStep,
              onStepTapped: onStepTapped,
            ),
          ),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildStepper());
      await tester.pumpAndSettle();

      expect(find.byType(WiredStepper), findsOneWidget);
    });

    testWidgets('renders all step titles', (tester) async {
      await tester.pumpWidget(buildStepper());
      await tester.pumpAndSettle();

      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Step 3'), findsOneWidget);
    });

    testWidgets('renders subtitles for all steps', (tester) async {
      await tester.pumpWidget(buildStepper());
      await tester.pumpAndSettle();

      expect(find.text('Subtitle 1'), findsOneWidget);
      expect(find.text('Subtitle 2'), findsOneWidget);
      expect(find.text('Subtitle 3'), findsOneWidget);
    });

    testWidgets('only shows content for current step', (tester) async {
      await tester.pumpWidget(buildStepper(currentStep: 0));
      await tester.pumpAndSettle();

      // Only the current step's content is shown.
      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsNothing);
      expect(find.text('Content 3'), findsNothing);
    });

    testWidgets('shows content for second step when currentStep is 1', (
      tester,
    ) async {
      await tester.pumpWidget(buildStepper(currentStep: 1));
      await tester.pumpAndSettle();

      expect(find.text('Content 1'), findsNothing);
      expect(find.text('Content 2'), findsOneWidget);
      expect(find.text('Content 3'), findsNothing);
    });

    testWidgets('shows step numbers for non-completed steps', (tester) async {
      await tester.pumpWidget(buildStepper(currentStep: 0));
      await tester.pumpAndSettle();

      // Step 1 is active, steps 2 and 3 are future - all should show numbers.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows check icon for completed steps', (tester) async {
      await tester.pumpWidget(buildStepper(currentStep: 2));
      await tester.pumpAndSettle();

      // Steps 0 and 1 are completed (index < currentStep), so they show
      // check icons. Step 3 (active) shows its number.
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('calls onStepTapped when a step is tapped', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildStepper(onStepTapped: (i) => tappedIndex = i),
      );
      await tester.pumpAndSettle();

      // Tap on the second step's title text.
      await tester.tap(find.text('Step 2'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('calls onStepTapped with correct index for each step', (
      tester,
    ) async {
      final tappedIndices = <int>[];

      await tester.pumpWidget(buildStepper(onStepTapped: tappedIndices.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Step 1'));
      await tester.pump();
      await tester.tap(find.text('Step 3'));
      await tester.pump();

      expect(tappedIndices, [0, 2]);
    });

    testWidgets('does not throw when onStepTapped is null', (tester) async {
      await tester.pumpWidget(buildStepper(onStepTapped: null));
      await tester.pumpAndSettle();

      // Tapping should not throw when onStepTapped is null.
      await tester.tap(find.text('Step 1'));
      await tester.pump();

      expect(find.byType(WiredStepper), findsOneWidget);
    });

    testWidgets('property defaults: currentStep is 0', (tester) async {
      await pumpApp(
        tester,
        SingleChildScrollView(child: WiredStepper(steps: buildSteps())),
      );
      await tester.pumpAndSettle();

      final stepper = tester.widget<WiredStepper>(find.byType(WiredStepper));
      expect(stepper.currentStep, 0);
      expect(stepper.onStepTapped, isNull);
    });

    testWidgets('renders WiredCanvas for step circles', (tester) async {
      await tester.pumpWidget(buildStepper());
      await tester.pumpAndSettle();

      // Each step has a WiredCanvas for its circle, and between steps there
      // are connector lines (also WiredCanvas). With 3 steps there are
      // 3 circles + 2 connectors = 5 WiredCanvas widgets.
      expect(
        find.descendant(
          of: find.byType(WiredStepper),
          matching: findWiredCanvas,
        ),
        findsNWidgets(5),
      );
    });

    testWidgets('renders connector lines between steps', (tester) async {
      await tester.pumpWidget(buildStepper());
      await tester.pumpAndSettle();

      // Between N steps there are N-1 connector lines. Each connector is
      // a SizedBox(width: 2, height: 24) containing a WiredCanvas.
      // We verify there are 2 connector line containers for 3 steps.
      final connectors = find.descendant(
        of: find.byType(WiredStepper),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 2 && w.height == 24,
        ),
      );
      expect(connectors, findsNWidgets(2));
    });

    testWidgets('renders steps without subtitles', (tester) async {
      final stepsNoSubtitle = [
        WiredStep(
          title: const Text('No subtitle step'),
          content: const Text('Step content'),
        ),
      ];

      await pumpApp(
        tester,
        SingleChildScrollView(child: WiredStepper(steps: stepsNoSubtitle)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No subtitle step'), findsOneWidget);
      expect(find.text('Step content'), findsOneWidget);
    });

    testWidgets('renders with a single step', (tester) async {
      await tester.pumpWidget(buildStepper(steps: buildSteps(count: 1)));
      await tester.pumpAndSettle();

      expect(find.byType(WiredStepper), findsOneWidget);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);

      // No connectors for a single step.
      final connectors = find.descendant(
        of: find.byType(WiredStepper),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 2 && w.height == 24,
        ),
      );
      expect(connectors, findsNothing);
    });
  });
}
