import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';

void main() {
  patrolTest('home page renders all category cards', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    expect($('Skribble Storybook'), findsOneWidget);
    expect($('Buttons'), findsOneWidget);
    expect($('Inputs'), findsOneWidget);
    expect($('Navigation'), findsOneWidget);

    // Scroll to reveal remaining categories.
    await $.scrollUntilVisible(finder: $('Data Display'));
    expect($('Data Display'), findsOneWidget);
  });

  patrolTest('navigates to Buttons page and displays components', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $('Buttons').tap();

    for (final label in [
      'WiredButton',
      'WiredElevatedButton',
      'WiredOutlinedButton',
      'WiredTextButton',
      'WiredIconButton',
    ]) {
      await $(label).scrollTo();
      await $(label).waitUntilVisible();
    }

    await $.scrollUntilVisible(finder: $('WiredFloatingActionButton'));
    expect($('WiredFloatingActionButton'), findsOneWidget);

    await $('Week').scrollTo(step: 250, maxScrolls: 50);
    expect($('WiredSegmentedButton'), findsOneWidget);
  });

  patrolTest('navigates to Buttons page and back', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $('Buttons').tap();
    expect($('WiredButton'), findsOneWidget);

    await $(BackButton).tap();
    expect($('Skribble Storybook'), findsOneWidget);
  });

  patrolTest('navigates to Inputs page and displays components', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $('Inputs').tap();

    expect($('WiredInput'), findsOneWidget);
    await $('WiredCheckbox').scrollTo();
    expect($('WiredCheckbox'), findsOneWidget);
  });

  patrolTest('navigates to Navigation page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $('Navigation').tap();

    expect($('WiredAppBar'), findsOneWidget);
  });

  patrolTest('navigates to Selection page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Selection'));
    await $('Selection').tap();

    expect($('WiredChip'), findsOneWidget);
  });

  patrolTest('navigates to Feedback page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Feedback'));
    await $('Feedback').tap();

    expect($('WiredProgress'), findsOneWidget);
  });

  patrolTest('navigates to Layout page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Layout'));
    await $('Layout').tap();

    expect($('WiredCard'), findsOneWidget);
  });

  patrolTest('navigates to Data Display page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Data Display'));
    await $('Data Display').tap();

    expect($('WiredCalendar'), findsOneWidget);
  });

  patrolTest('button interaction works on Buttons page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $('Buttons').tap();

    // Verify the basic button is tappable.
    await $('Click Me').tap();
  });

  patrolTest('segmented button toggles selection', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $('Buttons').tap();

    // Scroll to the segmented button section.
    await $('Week').scrollTo(step: 250, maxScrolls: 50);

    // Tap "Week" segment.
    await $('Week').tap();
    expect(
      $.tester
          .widget<WiredSegmentedButton<String>>(
            find.byType(WiredSegmentedButton<String>),
          )
          .selected,
      {'week'},
    );
  });
}
