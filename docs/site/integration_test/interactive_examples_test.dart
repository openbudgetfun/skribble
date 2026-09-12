import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';
import 'package:skribble_docs_site/src/document.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest(
      'edit, render, copy, and keep roughness across pages at $width',
      ($) async {
        await $.platform.web.resizeWindow(size: Size(width, 1000));
        await $.platform.web.grantPermissions(
          permissions: ['clipboard-read', 'clipboard-write'],
        );
        await $.pumpWidget(
          DocsApp(
            documents: await loadDocuments(),
            initialLocation: '/widgets/buttons',
          ),
        );
        await $(DocsKeys.roughness('expressive')).tap();
        await $(
          DocsKeys.parameter('filled-button', 'label'),
        ).scrollTo(view: $(const ValueKey('document-scroll')), maxScrolls: 40);
        await $(DocsKeys.parameter('filled-button', 'label'))
            .enterText('A magical little idea');
        await $(
          DocsKeys.choice('filled-button', 'interaction', 'redraw'),
        ).scrollTo(view: $(const ValueKey('document-scroll')), maxScrolls: 40);
        await $(DocsKeys.choice('filled-button', 'interaction', 'redraw'))
            .tap();
        await $(
          DocsKeys.parameter('filled-button', 'radius'),
        ).scrollTo(view: $(const ValueKey('document-scroll')), maxScrolls: 40);
        await $(DocsKeys.parameter('filled-button', 'radius')).enterText('12');
        await $(DocsKeys.parameter('filled-button', 'color'))
            .enterText('#b9d6ad');
        await $(DocsKeys.exampleCode('filled-button'))
            .$(DocsKeys.copyCode)
            .scrollTo(
              view: $(const ValueKey('document-scroll')),
              maxScrolls: 40,
            );
        await $(DocsKeys.exampleCode('filled-button'))
            .$(DocsKeys.copyCode)
            .tap();
        final copied = await $.platform.web.getClipboard();
        if (width < 1050) await $(DocsKeys.menu).tap();
        await $(DocsKeys.search).enterText('Compare the lettering');
        await $(DocsKeys.page('/core/font-comparison')).tap();
        await $(DocsKeys.fontSample).scrollTo(
          view: $(const ValueKey('document-scroll')),
          maxScrolls: 40,
        );
        await $(DocsKeys.fontSample).enterText('Paper, ink, possibility.');
        final selected = $.tester
            .widget<DocsAction>($(DocsKeys.roughness('expressive')))
            .selected;
        if (selected != true) {
          throw StateError('Roughness reset during navigation.');
        }
        if (!copied.contains('A magical little idea') ||
            !copied.contains('WiredInkInteraction.redraw') ||
            !copied.contains('BorderRadius.circular(12)') ||
            !copied.contains('Color(0xffb9d6ad)')) {
          throw StateError(
            'Copied source did not match the edited preview: $copied',
          );
        }
        if (WiredTheme.of($.tester.element($(DocsKeys.fontSample)))
                .roughnessLevel !=
            WiredRoughness.expressive) {
          throw StateError('The page did not inherit the selected roughness.');
        }
        await $(DocsKeys.fontCodeSample).scrollTo(
          view: $(const ValueKey('document-scroll')),
          maxScrolls: 40,
        );
        await $(DocsKeys.fontCodeSample).tap();
        final mono = $.tester.widget<Text>(
          $(DocsKeys.fontSpecimen('mono', 'playful')),
        );
        if (!(mono.data?.contains('final total = 42;') ?? false) ||
            mono.style?.fontFamily != 'packages/skribble/SkribbleMonoPlayful') {
          throw StateError('The Mono specimen did not update.');
        }
        await $(DocsKeys.fontSample).waitUntilVisible();
      },
    );
  }
}
