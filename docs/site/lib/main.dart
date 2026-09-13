import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/document.dart';

/// Shows the loading screen while the documentation catalog resolves.
///
/// The web shell sketches the same mark in HTML before Flutter starts, so the
/// mark keeps drawing from the first paint until the first page appears.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(
    WiredMaterialApp(
      wiredTheme: WiredThemeData.cuddly(),
      title: 'skribble — make something delightful',
      home: Builder(
        builder: (context) => WiredLoadingScreen(
          message: 'Getting the pens ready…',
          backgroundColor: WiredPalette.paper,
          // The same clamp the shell uses for its mark.
          size: (MediaQuery.sizeOf(context).width * 0.3).clamp(104, 160),
        ),
      ),
    ),
  );

  final documents = await loadDocuments();
  runApp(DocsApp(documents: documents));
}
