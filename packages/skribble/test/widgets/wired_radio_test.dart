import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

void main() {
  group('WiredRadio', () {
    testWidgets('renders and paints at its documented size', (tester) async {
      await pumpWired(
        tester,
        WiredRadio<String>(
          value: 'a',
          groupValue: null,
          onChanged: (_) => true,
        ),
      );

      expectRenders(
        tester,
        findWired<WiredRadio<String>>(),
        size: const Size(48, 48),
      );
      expectPaints(findWired<WiredRadio<String>>());
      expectRepaintIsolation(findWired<WiredRadio<String>>());
    });

    testWidgets('reports the selected state to assistive technology', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredRadio<String>(value: 'a', groupValue: 'a', onChanged: (_) => true),
      );

      expectSemantics(
        tester,
        findWired<WiredRadio<String>>(),
        isChecked: true,
        hasTapAction: true,
      );

      await pumpWired(
        tester,
        WiredRadio<String>(value: 'a', groupValue: 'b', onChanged: (_) => true),
      );

      expectSemantics(
        tester,
        findWired<WiredRadio<String>>(),
        isChecked: false,
        hasTapAction: true,
      );
    });

    testWidgets('exposes the supplied semantics label', (tester) async {
      await pumpWired(
        tester,
        WiredRadio<String>(
          value: 'a',
          groupValue: 'a',
          onChanged: (_) => true,
          semanticLabel: 'Option A',
        ),
      );

      expect(findWiredBySemanticsLabel('Option A'), findsOneWidget);
    });

    testWidgets('calls onChanged with its own value when tapped', (
      tester,
    ) async {
      String? changedValue;

      await pumpWired(
        tester,
        WiredRadio<String>(
          value: 'a',
          groupValue: 'b',
          onChanged: (value) {
            changedValue = value;
            return true;
          },
        ),
      );

      await tapWired(tester, findWired<WiredRadio<String>>());

      expect(changedValue, 'a');
    });

    testWidgets('activates through the semantics tap action', (tester) async {
      var selected = false;

      await pumpWired(
        tester,
        WiredRadio<String>(
          value: 'a',
          groupValue: 'b',
          onChanged: (value) {
            selected = true;
            return true;
          },
        ),
      );

      await semanticTapWired(tester, findWired<WiredRadio<String>>());

      expect(selected, isTrue);
    });

    testWidgets('disabled radio reports disabled and is not tappable', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredRadio<String>(
          value: 'a',
          groupValue: 'a',
          onChanged: null,
        ),
      );

      expectSemantics(
        tester,
        findWired<WiredRadio<String>>(),
        isEnabled: false,
        isChecked: true,
      );
      await tapWired(tester, findWired<WiredRadio<String>>());
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports String and int group values', (tester) async {
      int? selected;

      Widget buildGroup(int groupValue) => Column(
        children: [
          WiredRadio<int>(
            value: 1,
            groupValue: groupValue,
            onChanged: (value) {
              selected = value;
              return true;
            },
          ),
          WiredRadio<int>(
            value: 2,
            groupValue: groupValue,
            onChanged: (value) {
              selected = value;
              return true;
            },
          ),
        ],
      );

      await pumpWired(tester, buildGroup(1));

      expect(findWired<WiredRadio<int>>(), findsNWidgets(2));
      expectSemantics(
        tester,
        findWired<WiredRadio<int>>().first,
        isChecked: true,
      );
      expectSemantics(
        tester,
        findWired<WiredRadio<int>>().last,
        isChecked: false,
      );

      await tapWired(tester, findWired<WiredRadio<int>>().last);

      expect(selected, 2);

      // The group is controlled: once the parent moves the value, the second
      // radio must be the one that reports itself selected.
      await pumpWired(tester, buildGroup(2));

      expectSemantics(
        tester,
        findWired<WiredRadio<int>>().first,
        isChecked: false,
      );
      expectSemantics(
        tester,
        findWired<WiredRadio<int>>().last,
        isChecked: true,
      );
    });

    testWidgets('picks up the surrounding theme', (tester) async {
      await pumpWired(
        tester,
        WiredRadio<int>(value: 1, groupValue: 1, onChanged: (_) => true),
        theme: WiredThemeData(borderColor: const Color(0xFF00FF00)),
      );

      expectPaints(findWired<WiredRadio<int>>());
      expectSemantics(tester, findWired<WiredRadio<int>>(), isChecked: true);
    });

    testWidgets('lays out and paints in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        WiredRadio<String>(value: 'a', groupValue: 'a', onChanged: (_) => true),
      );

      expectRenders(tester, findWired<WiredRadio<String>>());
      expectPaints(findWired<WiredRadio<String>>());
      expectSemantics(tester, findWired<WiredRadio<String>>(), isChecked: true);
    });

    testWidgets('renders and paints under small and zero constraints', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredRadio<String>(value: 'a', groupValue: 'a', onChanged: (_) => true),
        surfaceSize: const Size(48, 48),
      );
      expectPaints(findWired<WiredRadio<String>>());
      expect(tester.takeException(), isNull);

      await pumpWired(
        tester,
        WiredRadio<String>(value: 'a', groupValue: 'a', onChanged: (_) => true),
        surfaceSize: Size.zero,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('is unaffected by doubled text scale', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredRadio<String>(value: 'a', groupValue: 'a', onChanged: (_) => true),
      );

      expectRenders(
        tester,
        findWired<WiredRadio<String>>(),
        size: const Size(48, 48),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
