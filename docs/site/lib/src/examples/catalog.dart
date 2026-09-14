import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_charts/skribble_charts.dart';
import 'package:skribble_docs_site/src/examples/example.dart';
import 'package:skribble_emoji/skribble_emoji.dart'
    show PrecomputedEmoji, WiredEmoji;
import 'package:skribble_icons/skribble_icons.dart'
    show SkribbleIcon, kSkribbleCuratedIcons, registerSkribbleIcons;
import 'package:skribble_maps/skribble_maps.dart';

part 'buttons.examples.dart';
part 'charts.examples.dart';
part 'cupertino.examples.dart';
part 'emoji.examples.dart';
part 'feedback.examples.dart';
part 'icons.examples.dart';
part 'inputs.examples.dart';
part 'layout.examples.dart';
part 'maps.examples.dart';
part 'motion.examples.dart';
part 'navigation.examples.dart';
part 'patterns.examples.dart';
part 'selection.examples.dart';
part 'shapes.examples.dart';
part 'catalog.g.dart';

/// The examples look Material identifiers up by name, which needs a registered
/// catalog. Registering here means any entry point that renders an example —
/// the app, a widget test, an embedded preview — resolves them correctly.
bool _iconsRegistered = false;

/// Registers the icon catalog and returns [identifier]'s geometry.
///
/// Examples use this rather than calling the lookup directly, so the
/// registration happens on first use and the example keeps an expression body
/// (which `tool/generate_examples.dart` requires).
WiredSvgIconData exampleIcon(String identifier) {
  if (!_iconsRegistered) {
    registerSkribbleIcons();
    _iconsRegistered = true;
  }
  return lookupMaterialRoughIconByIdentifier(identifier)!;
}
