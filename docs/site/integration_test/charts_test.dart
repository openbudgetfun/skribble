import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble_charts/skribble_charts.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/document.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest('inspect a chart and copy its edited source at $width pixels', (
      $,
    ) async {
      await $.platform.web.resizeWindow(size: Size(width, 1000));
      await $.platform.web.grantPermissions(
        permissions: ['clipboard-read', 'clipboard-write'],
      );
      await $.pumpWidget(
        DocsApp(
          documents: await loadDocuments(),
          initialLocation: '/widgets/charts',
        ),
      );
      await $(DocsKeys.chart)
          .scrollTo(view: $(DocsKeys.documentScroll), maxScrolls: 40);
      await $(DocsKeys.chart).tap(alignment: const Alignment(0, -.4));
      final controller = $.tester
          .widget<WiredFinancialChart>($(DocsKeys.chart))
          .controller;
      final selectedTime = controller.candles[controller.selectedIndex!].time;
      await $(DocsKeys.parameter('chart-interactive', 'amount'))
          .scrollTo(view: $(DocsKeys.documentScroll), maxScrolls: 40);
      await $(DocsKeys.parameter('chart-interactive', 'amount')).enterText('1');
      await $(DocsKeys.exampleCode('chart-interactive'))
          .$(DocsKeys.copyCode)
          .scrollTo(view: $(DocsKeys.documentScroll), maxScrolls: 40);
      await $(DocsKeys.exampleCode('chart-interactive'))
          .$(DocsKeys.copyCode)
          .tap();
      final source = await $.platform.web.getClipboard();
      final displayedSource = $.tester
          .widget<CodeView>(
            $(DocsKeys.exampleCode('chart-interactive')),
          )
          .code;
      final sourceAmountMatches = RegExp(
        r'roughness:\s*1(?:\.0)?\s*/\s*2,',
      ).hasMatch(source);
      await $(DocsKeys.chart).scrollTo(
        view: $(DocsKeys.documentScroll),
        scrollDirection: AxisDirection.up,
        maxScrolls: 40,
      );
      final chart = $.tester.widget<WiredFinancialChart>($(DocsKeys.chart));
      if (chart.style.roughness != .5 ||
          chart.controller.candles[chart.controller.selectedIndex!].time !=
              selectedTime ||
          source != displayedSource ||
          !sourceAmountMatches ||
          !source.contains('WiredFinancialChart')) {
        throw StateError(
          'The browser chart and copied source did not retain the edited example: '
          'roughness=${chart.style.roughness}; '
          'selected=${chart.controller.candles[chart.controller.selectedIndex!].time}; '
          'expected=$selectedTime; '
          'sourceAmount=$sourceAmountMatches; '
          'sourceChart=${source.contains('WiredFinancialChart')}.',
        );
      }
      await $(DocsKeys.chart).waitUntilVisible();
    });
  }
}
