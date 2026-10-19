/// The skribble.dev landing page, rendered with Jaspr into static HTML.
///
/// `bin/build.dart` renders [LandingPage] and [NotFoundPage] with the real
/// workspace assets and writes a deployable folder.
library;

import 'package:skribble_site/skribble_site.dart'
    show LandingPage, NotFoundPage;
import 'package:skribble_site/src/page.dart' show LandingPage, NotFoundPage;

export 'src/assets.dart';
export 'src/build.dart';
export 'src/config.dart';
export 'src/page.dart' show LandingPage, NotFoundPage, notFoundRedirect;
