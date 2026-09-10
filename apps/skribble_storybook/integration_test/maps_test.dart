import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble_maps/skribble_maps.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/testing/map_keys.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest('explore map cities, pins, and night ink at $width pixels', (
      $,
    ) async {
      await $.platform.web.resizeWindow(size: Size(width, 1000));
      await $.pumpWidget(const SkribbleStorybookApp());
      await $(MapDemoKeys.category).scrollTo();
      await $(MapDemoKeys.category).tap();
      await $(MapDemoKeys.choice('dubai')).tap();
      await $(MapDemoKeys.pin('Dubai Mall'))
          .scrollTo(view: $(MapDemoKeys.scroll), maxScrolls: 40);
      await $(MapDemoKeys.pin('Dubai Mall')).tap();
      final selected = $.tester.widget<Text>($(MapDemoKeys.status)).data;
      await $(MapDemoKeys.choice('night')).scrollTo(
        view: $(MapDemoKeys.scroll),
        scrollDirection: AxisDirection.up,
        maxScrolls: 40,
      );
      await $(MapDemoKeys.choice('night')).tap();
      final map = $.tester.widget<WiredMap>($(MapDemoKeys.map));
      if (selected != 'Dubai Mall' || map.style != WiredMapStyle.night) {
        throw StateError(
          'The map did not retain the selected Dubai pin and night ink.',
        );
      }
      await $(MapDemoKeys.map)
          .scrollTo(view: $(MapDemoKeys.scroll), maxScrolls: 40);
      await $(MapDemoKeys.map).waitUntilVisible();
    });
  }
}
