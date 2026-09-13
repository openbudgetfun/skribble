import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredCheckboxListTile', () {
    testWidgets('renders its title and subtitle', (tester) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (_) {},
          title: const Text('Main title'),
          subtitle: const Text('Supporting text'),
        ),
      );

      expect(find.text('Main title'), findsOneWidget);
      expect(find.text('Supporting text'), findsOneWidget);
      expectRenders(tester, findWired<WiredCheckboxListTile>());
      expectPaints(findWired<WiredCheckboxListTile>());
    });

    testWidgets('renders a WiredCheckbox as its control', (tester) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(value: false, onChanged: (_) {}),
      );

      expect(
        findWiredIn<WiredCheckbox>(findWired<WiredCheckboxListTile>()),
        findsOneWidget,
      );
    });

    testWidgets('reports the checked state through its control', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(value: true, onChanged: (_) {}),
      );

      expectSemantics(
        tester,
        findWiredIn<WiredCheckbox>(findWired<WiredCheckboxListTile>()),
        isChecked: true,
      );

      await pumpWired(
        tester,
        WiredCheckboxListTile(value: false, onChanged: (_) {}),
      );

      expectSemantics(
        tester,
        findWiredIn<WiredCheckbox>(findWired<WiredCheckboxListTile>()),
        isChecked: false,
      );
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (_) {},
          semanticLabel: 'Notifications',
        ),
      );

      expect(findWiredBySemanticsLabel('Notifications'), findsOneWidget);
    });

    testWidgets('calls onChanged when the tile is tapped', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (value) => receivedValue = value,
          title: const Text('Tap me'),
        ),
      );

      await tapWired(tester, findWired<WiredCheckboxListTile>());

      expect(receivedValue, isTrue);
    });

    testWidgets('calls onChanged when the checkbox is tapped', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (value) => receivedValue = value,
        ),
      );

      await tapWired(
        tester,
        findWiredIn<WiredCheckbox>(findWired<WiredCheckboxListTile>()),
      );

      expect(receivedValue, isTrue);
    });

    testWidgets('toggles to false when checked and tapped', (tester) async {
      bool? receivedValue;

      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: true,
          onChanged: (value) => receivedValue = value,
        ),
      );

      await tapWired(tester, findWired<WiredCheckboxListTile>());

      expect(receivedValue, isFalse);
    });

    testWidgets('renders a divider by default and can omit it', (tester) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(value: false, onChanged: (_) {}),
      );
      expect(
        findWiredIn<WiredCanvas>(findWired<WiredCheckboxListTile>()),
        findsOneWidget,
        reason: 'The divider is the only canvas painted by the tile itself.',
      );

      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (_) {},
          showDivider: false,
        ),
      );
      expect(
        findWiredIn<WiredCanvas>(findWired<WiredCheckboxListTile>()),
        findsNothing,
        reason: 'showDivider: false must not paint the separator line.',
      );
      expectPaints(findWired<WiredCheckboxListTile>());
    });

    testWidgets('has documented property defaults', (tester) async {
      const tile = WiredCheckboxListTile(value: false, onChanged: _noOp);

      expect(tile.title, isNull);
      expect(tile.subtitle, isNull);
      expect(tile.showDivider, isTrue);
    });

    testWidgets('handles a null value for tristate checkboxes', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(value: null, onChanged: (_) {}),
      );

      expectRenders(tester, findWired<WiredCheckboxListTile>());
      expectPaints(findWired<WiredCheckboxListTile>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out and paints in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (_) {},
          title: const Text('RTL title'),
          subtitle: const Text('RTL subtitle'),
        ),
      );

      expect(find.text('RTL title'), findsOneWidget);
      expectRenders(tester, findWired<WiredCheckboxListTile>());
      expectPaints(findWired<WiredCheckboxListTile>());
    });

    testWidgets('grows with doubled text without clipping', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredCheckboxListTile(
          value: false,
          onChanged: (_) {},
          title: const Text('Scaled title'),
          subtitle: const Text('Scaled subtitle'),
        ),
      );

      expectRenders(tester, findWired<WiredCheckboxListTile>());
      expectPaints(findWired<WiredCheckboxListTile>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders under narrow constraints', (tester) async {
      await pumpWired(
        tester,
        WiredCheckboxListTile(
          value: true,
          onChanged: (_) {},
          title: const Text('Narrow'),
        ),
        surfaceSize: const Size(120, 200),
      );

      expectRenders(tester, findWired<WiredCheckboxListTile>());
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('is disabled when onChanged is null', (tester) async {
    await pumpApp(
      tester,
      const WiredCheckboxListTile(value: false, title: Text('Label')),
    );

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    expect(
      tester.widget<WiredListTile>(find.byType(WiredListTile)).onTap,
      isNull,
    );
  });
}

void _noOp(bool? value) {}
