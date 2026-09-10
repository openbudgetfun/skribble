import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_maps/skribble_maps.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    patrolTest('select map pins and opt into the online map at $width pixels', (
      $,
    ) async {
      await $.platform.web.resizeWindow(size: Size(width, 1000));
      await $.pumpWidget(
        DocsApp(
          documents: await loadDocuments(),
          initialLocation: '/widgets/maps',
        ),
      );
      await $(DocsKeys.mapPin('market'))
          .scrollTo(view: $(DocsKeys.documentScroll), maxScrolls: 60);
      await $(DocsKeys.mapPin('market')).tap();
      final selected = $.tester.widget<Text>($(DocsKeys.mapSelection)).data;
      await $(DocsKeys.mapPin('gallery')).tap();
      final gallery = $.tester.widget<Text>($(DocsKeys.mapSelection)).data;
      await $(DocsKeys.mapOnlineToggle).scrollTo(
        view: $(DocsKeys.documentScroll),
        scrollDirection: AxisDirection.up,
        maxScrolls: 60,
      );
      await $(DocsKeys.mapOnlineToggle).tap();
      final map = $.tester.widget<WiredMap>($(DocsKeys.map));
      await $(DocsKeys.mapOnlineToggle).tap();
      if (selected != 'Selected: Weekend market' ||
          gallery != 'Selected: Local gallery' ||
          map.initialCenter != const LatLng(51.5074, -0.1278) ||
          map.scrollGesturesEnabled ||
          $(DocsKeys.map).exists) {
        throw StateError(
          'The map preview did not select pins or close its online embed.',
        );
      }
      await $(DocsKeys.mapOnlineToggle).waitUntilVisible();
    });
  }
}
