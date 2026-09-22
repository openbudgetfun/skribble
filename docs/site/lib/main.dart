import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Loads the catalog while the HTML loading mark remains on screen.
///
/// The first Flutter frame is the requested article, including direct links.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerSkribbleIcons();
  usePathUrlStrategy();
  final documents = await loadDocuments();
  runApp(DocsApp(documents: documents));
}
