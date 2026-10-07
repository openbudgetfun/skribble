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

    await _open($, 'Buttons');

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

    await _open($, 'Buttons');
    expect($('WiredButton'), findsOneWidget);

    await $(BackButton).tap();
    expect($('Skribble Storybook'), findsOneWidget);
  });

  patrolTest('navigates to Inputs page and displays components', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Inputs');

    expect($('WiredInput'), findsOneWidget);
    await $('WiredCheckbox').scrollTo();
    expect($('WiredCheckbox'), findsOneWidget);
  });

  patrolTest('navigates to Navigation page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Navigation');

    expect($('WiredAppBar'), findsOneWidget);
  });

  patrolTest('navigates to Selection page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Selection');

    expect($('WiredChip'), findsOneWidget);
  });

  patrolTest('navigates to Feedback page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Feedback');

    expect($('WiredProgress'), findsOneWidget);
  });

  patrolTest('navigates to Layout page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Layout');

    expect($('WiredCard'), findsOneWidget);
  });

  patrolTest('navigates to Data Display page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Data Display');

    expect($('WiredCalendar'), findsOneWidget);
  });

  patrolTest('button interaction works on Buttons page', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Buttons');

    // Verify the basic button is tappable.
    await $('Click Me').tap();
  });

  patrolTest('segmented button toggles selection', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await _open($, 'Buttons');

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

/// Opens a storybook category from the home page. The hero and the
/// playground sit above the category grid, so the card is scrolled into view
/// before it is tapped.
Future<void> _open(PatrolIntegrationTester $, String category) async {
  await $.scrollUntilVisible(finder: $(category));
  await $(category).tap();
}
