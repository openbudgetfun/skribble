import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble_charts/skribble_charts.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/testing/chart_keys.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest(
      'draw and restore the chart workspace in a $width pixel browser',
      ($) async {
        await $.platform.web.resizeWindow(size: Size(width, 1000));
        await $.pumpWidget(const SkribbleStorybookApp());
        await $(ChartDemoKeys.category).scrollTo();
        await $(ChartDemoKeys.category).tap();
        await $(ChartDemoKeys.choice('Line')).tap();
        await $(ChartDemoKeys.choice('Night')).tap();
        await $(ChartDemoKeys.choice('5m'))
            .scrollTo(view: $(ChartDemoKeys.scroll), maxScrolls: 40);
        await $(ChartDemoKeys.choice('5m')).tap();
        await $(ChartDemoKeys.drawings)
            .scrollTo(view: $(ChartDemoKeys.scroll), maxScrolls: 40);
        await $(ChartDemoKeys.drawings).tap();
        await $(ChartDemoKeys.choice('Price level'))
            .scrollTo(view: $(ChartDemoKeys.scroll), maxScrolls: 40);
        await $(ChartDemoKeys.choice('Price level')).tap();
        await $(ChartDemoKeys.chart).scrollTo(
          view: $(ChartDemoKeys.scroll),
          scrollDirection: AxisDirection.up,
          maxScrolls: 40,
        );
        await $(ChartDemoKeys.chart).tap(alignment: const Alignment(0, -.4));
        await $(ChartDemoKeys.save)
            .scrollTo(view: $(ChartDemoKeys.scroll), maxScrolls: 40);
        await $(ChartDemoKeys.save).tap();
        await $(ChartDemoKeys.choice('15m')).scrollTo(
          view: $(ChartDemoKeys.scroll),
          scrollDirection: AxisDirection.up,
          maxScrolls: 40,
        );
        await $(ChartDemoKeys.choice('15m')).tap();
        await $(ChartDemoKeys.choice('OHLC')).scrollTo(
          view: $(ChartDemoKeys.scroll),
          scrollDirection: AxisDirection.up,
          maxScrolls: 40,
        );
        await $(ChartDemoKeys.choice('OHLC')).tap();
        await $(ChartDemoKeys.restore)
            .scrollTo(view: $(ChartDemoKeys.scroll), maxScrolls: 40);
        await $(ChartDemoKeys.restore).tap();
        final status = $.tester.widget<Text>($(ChartDemoKeys.status)).data;
        await $(ChartDemoKeys.chart).scrollTo(
          view: $(ChartDemoKeys.scroll),
          scrollDirection: AxisDirection.up,
          maxScrolls: 40,
        );
        final chart = $.tester.widget<WiredFinancialChart>(
          $(ChartDemoKeys.chart),
        );
        if (chart.controller.candles.length != 72 ||
            chart.series != WiredPriceSeries.line ||
            chart.annotations?.annotations.single.label != 'Watch this level' ||
            status != 'Workspace restored, including your drawings.') {
          throw StateError(
            'The browser did not restore the 5-minute chart and drawing.',
          );
        }
        await $(ChartDemoKeys.chart).waitUntilVisible();
      },
    );
  }
}
