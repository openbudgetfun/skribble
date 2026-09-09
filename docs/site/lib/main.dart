import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/document.dart';

/// Loads the documentation catalog before opening the initial route.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final documents = await loadDocuments();
  runApp(DocsApp(documents: documents));
}
