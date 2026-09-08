import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/studio_page.dart';
import 'package:skribble_storybook/testing/quality_keys.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest(
      'app-wide roughness keeps the notebook at ${width.toInt()} pixels',
      ($) async {
        await $.platform.web.resizeWindow(size: Size(width, 1100));
        await $.pumpWidget(const SkribbleStorybookApp());
        await $('The sketchbook').tap();
        await $(QualityKeys.input).scrollTo();
        await $(QualityKeys.input).enterText('Keep my café sketch');
        await $(QualityKeys.add).tap();
        for (final level in [
          WiredRoughness.gentle,
          WiredRoughness.playful,
          WiredRoughness.expressive,
        ]) {
          await $(ValueKey('roughness-${level.name}')).tap();
          final theme = WiredTheme.of($.tester.element($(QualityKeys.title)));
          final field = $.tester.widget<EditableText>($(EditableText));
          if (theme.roughnessLevel != level ||
              field.style.fontFamily !=
                  'packages/skribble/${level.fontFamily}') {
            throw StateError(
              'The app level did not cascade to the notebook and input.',
            );
          }
          if (field.controller.text != 'Keep my café sketch' ||
              $(QualityKeys.inputResult).text != 'Keep my café sketch') {
            throw StateError('Changing the ink level lost the note.');
          }
        }
        await $(ValueKey('roughness-gentle')).tap();
        await $('All components').scrollTo();
        await $('All components').tap();
        await $('Buttons').tap();
        await $('Click Me').waitUntilVisible();
        final buttonTheme = WiredTheme.of($.tester.element($('Click Me')));
        if (buttonTheme.roughnessLevel != WiredRoughness.gentle) {
          throw StateError('The selected level did not follow navigation.');
        }
      },
    );
  }

  for (final width in [390.0, 820.0, 1440.0]) {
    patrolTest('sketchbook saves an idea at ${width.toInt()} pixels', (
      $,
    ) async {
      await $.platform.web.resizeWindow(size: Size(width, 1000));
      await $.pumpWidget(const WiredStudioPage());
      await $(QualityKeys.input).scrollTo();
      await $(QualityKeys.input)
          .enterText('Café sketch: £12.50 + a little joy!');
      await $(QualityKeys.add).tap();
      await $(QualityKeys.checkbox).scrollTo();
      await $(QualityKeys.checkbox).tap();
      await $(QualityKeys.inputResult).scrollTo();
      await $(QualityKeys.inputResult).waitUntilVisible();
      if ($(QualityKeys.inputResult).text !=
          'Café sketch: £12.50 + a little joy!') {
        throw StateError('The saved idea does not match the entered text.');
      }
      if ($(QualityKeys.status).text != 'A small win. Nicely done!') {
        throw StateError('The checkbox did not update the notebook.');
      }
    });
  }

  patrolTest('external reset clears the input and the checked state', (
    $,
  ) async {
    await $.platform.web.resizeWindow(size: const Size(390, 1000));
    await $.pumpWidget(const WiredStudioPage());
    await $(QualityKeys.checkbox).scrollTo();
    await $(QualityKeys.checkbox).tap();
    await $(QualityKeys.input).enterText('A fresh start');
    await $(QualityKeys.add).tap();
    await $(QualityKeys.reset).tap();
    await $(QualityKeys.status).scrollTo();
    await $(QualityKeys.status).waitUntilVisible();
    if ($(QualityKeys.status).text != 'Small steps count.') {
      throw StateError('Reset did not clear the checked state.');
    }
    final field = $.tester.widget<EditableText>($(EditableText));
    if (field.controller.text.isNotEmpty) {
      throw StateError('Reset did not clear the input controller.');
    }
    if ($(QualityKeys.inputResult).text !=
        'Pick something small. Make it yours.') {
      throw StateError('Reset did not restore the empty notebook.');
    }
  });

  patrolTest('evening ink keeps the note and reminder interactive', ($) async {
    await $.platform.web.resizeWindow(size: const Size(820, 1100));
    await $.pumpWidget(const WiredStudioPage());
    await $(QualityKeys.dark).tap();
    await $('Morning paper').waitUntilVisible();
    final theme = WiredTheme.of($.tester.element($(QualityKeys.title)));
    if (theme.fillColor != const Color(0xff29232f)) {
      throw StateError('The evening paper color was not applied.');
    }
    await $(QualityKeys.input).scrollTo();
    await $(QualityKeys.input).enterText('Ideas after sunset');
    await $(QualityKeys.add).tap();
    await $(QualityKeys.switchControl).scrollTo();
    await $(QualityKeys.switchControl).tap();
    await $(QualityKeys.reminderStatus).waitUntilVisible();
    if ($(QualityKeys.reminderStatus).text !=
        'Quiet time. Reminders are off.') {
      throw StateError('The reminder did not switch off.');
    }
    await $(QualityKeys.inputResult).waitUntilVisible();
    if ($(QualityKeys.inputResult).text != 'Ideas after sunset') {
      throw StateError('The evening palette lost the saved note.');
    }
  });
}
