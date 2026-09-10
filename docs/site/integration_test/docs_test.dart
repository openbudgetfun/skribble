import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/document.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest('read, navigate, and copy documentation at $width pixels', (
      $,
    ) async {
      await $.platform.web.resizeWindow(size: Size(width, 1000));
      await $.platform.web.grantPermissions(
        permissions: ['clipboard-read', 'clipboard-write'],
      );
      final documents = await loadDocuments();
      await $.pumpWidget(DocsApp(documents: documents));
      if (width < 1050) await $(DocsKeys.menu).tap();
      await $(DocsKeys.search).enterText('Quick Start');
      await $(DocsKeys.page('/getting-started/quick-start')).tap();
      await $(DocsKeys.copyPage).tap();
      final clipboard = await $.platform.web.getClipboard();
      if (clipboard !=
          documents
              .singleWhere(
                (document) => document.path == '/getting-started/quick-start',
              )
              .source) {
        throw StateError('Copy page did not preserve the canonical Markdown.');
      }
      await $(DocsKeys.copyPage).waitUntilVisible();
    });
  }

  patrolTest('live drawing preserves the saved idea when replayed', ($) async {
    await $.platform.web.resizeWindow(size: const Size(1100, 1000));
    await $.pumpWidget(DocsApp(documents: await loadDocuments()));
    await $(DocsKeys.saveIdea).scrollTo();
    await $(DocsKeys.saveIdea).tap();
    await $(DocsKeys.replay).tap();
    final button = $.tester.widget<WiredFilledButton>($(DocsKeys.saveIdea));
    if ((button.child as Text).data != 'Lovely. It’s saved!') {
      throw StateError('Replaying decorative ink lost the example state.');
    }
    await $(DocsKeys.saveIdea).waitUntilVisible();
  });
}
