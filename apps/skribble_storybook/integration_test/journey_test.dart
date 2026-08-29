// Extended Patrol + integration journey tests: cross-page flows through the
// storybook, including the icons gallery, emoji, and the font specimen pages.
//
// These run under `flutter test integration_test/` (widget-test binding) in
// CI, and under `patrol test` with the native runner on devices — the same
// source drives both harnesses.
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble_storybook/app.dart';

void main() {
  patrolTest('navigates through every top-level category', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    const categories = [
      'Buttons',
      'Inputs',
      'Navigation',
      'Selection',
      'Feedback',
      'Layout',
      'Data Display',
      'Rough Icons',
      'Skribble Icons',
      'Emoji',
      'Font Specimen',
    ];
    for (final category in categories) {
      await $.scrollUntilVisible(finder: $(category));
      expect($(category), findsOneWidget);
    }
  });

  patrolTest('skribble icons page lists curated lookups', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Skribble Icons'));
    await $('Skribble Icons').tap();

    expect($('SkribbleIcon'), findsWidgets);
  });

  patrolTest('emoji page renders the emoji catalog', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Emoji'));
    await $('Emoji').tap();

    // Catalog header text from the emoji page.
    expect($('Hand-drawn emoji'), findsWidgets);
  });

  patrolTest('font specimen page shows glyph tables', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Font Specimen'));
    await $('Font Specimen').tap();

    // Block headings from the specimen page.
    expect($('Uppercase'), findsOneWidget);
    expect($('Digits'), findsOneWidget);
    await $.scrollUntilVisible(finder: $('Currency'));
    expect($('Currency'), findsOneWidget);
  });

  patrolTest('data display page shows picker helpers', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Data Display'));
    await $('Data Display').tap();

    // Long-tail widgets added in the parity batches.
    await $.scrollUntilVisible(finder: $('WiredMergeableMaterial'));
    expect($('WiredMergeableMaterial'), findsOneWidget);
  });

  patrolTest('inputs page shows search and long-tail inputs', ($) async {
    await $.pumpWidget(const SkribbleStorybookApp());

    await $.scrollUntilVisible(finder: $('Inputs'));
    await $('Inputs').tap();

    await $.scrollUntilVisible(finder: $('WiredSearchAnchor'));
    expect($('WiredSearchAnchor'), findsOneWidget);
  });
}
