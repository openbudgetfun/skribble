import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

/// Desktop themes default to compact density, which takes 4 pixels off
/// each side of a Material field's padding. skribble's fields keep the
/// standard density, so their text sits the same distance from the ink on
/// every platform.
void main() {
  final fields = <String, (Widget, String)>{
    'WiredInput': (const WiredInput(hintText: 'Your name'), 'Your name'),
    'WiredTextArea': (
      const WiredTextArea(hintText: 'Write something...'),
      'Write something...',
    ),
    'WiredAutocomplete': (
      WiredAutocomplete<String>(
        options: const ['Apple', 'Pear'],
        displayStringForOption: (option) => option,
        hintText: 'Search fruit',
      ),
      'Search fruit',
    ),
    'WiredCupertinoTextField': (
      const WiredCupertinoTextField(placeholder: 'Placeholder'),
      'Placeholder',
    ),
    'WiredSearchBar': (const WiredSearchBar(hintText: 'Search'), 'Search'),
  };

  for (final MapEntry(key: name, value: (field, hint)) in fields.entries) {
    testWidgets('$name lays out its text the same on desktop', (
      tester,
    ) async {
      Future<(Offset, Size)> measure(TargetPlatform platform) async {
        debugDefaultTargetPlatformOverride = platform;
        await pumpApp(tester, field);
        final origin = tester.getTopLeft(find.byWidget(field));
        final layout = (
          tester.getTopLeft(find.text(hint)) - origin,
          tester.getSize(find.byWidget(field)),
        );
        await tester.pumpWidget(const SizedBox());
        return layout;
      }

      final mobile = await measure(TargetPlatform.android);
      for (final desktop in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ]) {
        expect(await measure(desktop), mobile, reason: '$desktop');
      }
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
