import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/skribble_test_support.dart';

/// Keyboard, focus, and semantics contracts shared by skribble's leaf
/// controls: every control can be reached with Tab and activated with Enter
/// or Space, a disabled control can be neither, and assistive technology
/// meets one labelled node per control.
void main() {
  /// Every semantics node at or below the node for [finder].
  List<SemanticsNode> nodesUnder(WidgetTester tester, Finder finder) {
    final nodes = <SemanticsNode>[];
    void visit(SemanticsNode node) {
      nodes.add(node);
      // Merged descendants are part of this node, not nodes of their own.
      if (node.mergeAllDescendantsIntoThisNode) return;
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.getSemantics(finder));
    return nodes;
  }

  int buttonNodes(WidgetTester tester, Finder finder) => nodesUnder(
    tester,
    finder,
  ).where((n) => n.getSemanticsData().flagsCollection.isButton).length;

  Future<void> tab(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }

  bool focusIsWithin(Finder finder) {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return false;
    final target = finder.evaluate().single;
    var inside = focused == target;
    focused.visitAncestorElements((element) {
      if (element == target) inside = true;
      return !inside;
    });
    return inside;
  }

  group('button family', () {
    final variants = <String, Widget Function(VoidCallback?, String?)>{
      'WiredButton': (onPressed, label) => WiredButton(
        onPressed: onPressed,
        semanticLabel: label,
        child: const Text('Save'),
      ),
      'WiredElevatedButton': (onPressed, label) => WiredElevatedButton(
        onPressed: onPressed,
        semanticLabel: label,
        child: const Text('Save'),
      ),
      'WiredFilledButton': (onPressed, label) => WiredFilledButton(
        onPressed: onPressed,
        semanticLabel: label,
        child: const Text('Save'),
      ),
      'WiredOutlinedButton': (onPressed, label) => WiredOutlinedButton(
        onPressed: onPressed,
        semanticLabel: label,
        child: const Text('Save'),
      ),
      'WiredTextButton': (onPressed, label) => WiredTextButton(
        onPressed: onPressed,
        semanticLabel: label,
        child: const Text('Save'),
      ),
    };

    for (final entry in variants.entries) {
      testWidgets('${entry.key} is a single labelled button node', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpWired(tester, entry.value(() {}, null));

        final root = find.byType(entry.value(null, null).runtimeType);
        expect(buttonNodes(tester, root), 1);
        expectSemantics(
          tester,
          root,
          label: 'Save',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        );
        handle.dispose();
      });

      testWidgets('${entry.key} reads only its semantic label when given', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpWired(tester, entry.value(() {}, 'Save the drawing'));

        final root = find.byType(entry.value(null, null).runtimeType);
        expect(buttonNodes(tester, root), 1);
        expectSemantics(tester, root, label: 'Save the drawing');
        handle.dispose();
      });

      testWidgets('${entry.key} writes a disabled label in the theme colour', (
        tester,
      ) async {
        const disabled = Color(0xFF8A8296);
        await pumpWired(
          tester,
          entry.value(null, null),
          theme: WiredThemeData(
            textColor: const Color(0xFFF4EFE6),
            fillColor: const Color(0xFF1E1A22),
            disabledTextColor: disabled,
          ),
        );

        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('Save'),
        );
        final color = paragraph.text.style?.color;
        if (entry.key == 'WiredFilledButton') {
          // Filled buttons keep their contrast-picked label at 75% opacity.
          expect(color?.a, closeTo(0.75, 0.01));
        } else {
          expect(color, disabled);
        }
      });

      testWidgets('${entry.key} grows with doubled text instead of clipping', (
        tester,
      ) async {
        await pumpWiredScaled(tester, entry.value(() {}, null));

        expect(tester.takeException(), isNull);
        final button = tester.getRect(
          find.byType(entry.value(null, null).runtimeType),
        );
        final label = tester.getRect(find.text('Save'));
        expect(button.top, lessThanOrEqualTo(label.top));
        expect(button.bottom, greaterThanOrEqualTo(label.bottom));
      });

      testWidgets('${entry.key} keeps the ink padding on desktop platforms', (
        tester,
      ) async {
        // Desktop platforms default to a compact visual density, which must
        // not eat into the space between the label and the ink.
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        await pumpWiredScaled(tester, entry.value(() {}, null));
        final button = tester.getRect(
          find.byType(entry.value(null, null).runtimeType),
        );
        final label = tester.getRect(find.text('Save'));
        debugDefaultTargetPlatformOverride = null;

        expect(label.top - button.top, greaterThanOrEqualTo(8));
      });
    }

    testWidgets('WiredIconButton is a single labelled button node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWired(
        tester,
        WiredIconButton(
          icon: roughIconFor('add'),
          semanticLabel: 'Add',
          onPressed: () {},
        ),
      );

      expect(buttonNodes(tester, findWired<WiredIconButton>()), 1);
      expectSemantics(
        tester,
        findWired<WiredIconButton>(),
        label: 'Add',
        isButton: true,
        isEnabled: true,
        hasTapAction: true,
      );
      handle.dispose();
    });

    testWidgets('a disabled WiredIconButton dims its default glyph', (
      tester,
    ) async {
      const disabled = Color(0xFF8A8296);
      await pumpWired(
        tester,
        WiredIconButton(icon: roughIconFor('add')),
        theme: WiredThemeData(disabledTextColor: disabled),
      );

      expect(tester.widget<WiredIcon>(find.byType(WiredIcon)).color, disabled);
    });

    testWidgets('buttons forward their seed to the ink', (tester) async {
      await pumpWired(
        tester,
        WiredButton(onPressed: () {}, seed: 42, child: const Text('Save')),
      );

      final decorated = tester.widget<Container>(
        find
            .descendant(
              of: findWired<WiredButton>(),
              matching: find.byWidgetPredicate(
                (w) => w is Container && w.decoration is RoughBoxDecoration,
              ),
            )
            .first,
      );
      expect((decorated.decoration! as RoughBoxDecoration).seed, 42);
    });
  });

  group('keyboard activation', () {
    final controls = <String, Widget Function(VoidCallback)>{
      'WiredChoiceChip': (hit) =>
          WiredChoiceChip(label: const Text('A'), onSelected: (_) => hit()),
      'WiredFilterChip': (hit) =>
          WiredFilterChip(label: const Text('A'), onSelected: (_) => hit()),
      'WiredInputChip': (hit) =>
          WiredInputChip(label: const Text('A'), onPressed: hit),
      'WiredActionChip': (hit) =>
          WiredActionChip(label: const Text('A'), onPressed: hit),
      'WiredCupertinoButton': (hit) =>
          WiredCupertinoButton(onPressed: hit, child: const Text('A')),
      'WiredCupertinoSwitch': (hit) =>
          WiredCupertinoSwitch(value: false, onChanged: (_) => hit()),
      'WiredToggleButtons': (hit) => WiredToggleButtons(
        isSelected: const [false],
        onPressed: (_) => hit(),
        children: const [Text('A')],
      ),
      'WiredSegmentedButton': (hit) => WiredSegmentedButton<int>(
        segments: const [WiredButtonSegment(value: 1, label: Text('A'))],
        selected: const {},
        onSelectionChanged: (_) => hit(),
      ),
      'WiredCupertinoSegmentedControl': (hit) =>
          WiredCupertinoSegmentedControl<int>(
            children: const {1: Text('A')},
            groupValue: null,
            onValueChanged: (_) => hit(),
          ),
      'WiredSlidingSegmentedControl': (hit) =>
          WiredSlidingSegmentedControl<int>(
            children: const {1: Text('A')},
            groupValue: null,
            onValueChanged: (_) => hit(),
          ),
      'WiredCupertinoTabBar': (hit) => WiredCupertinoTabBar(
        currentIndex: 1,
        onTap: (_) => hit(),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'A'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'B'),
        ],
      ),
      'WiredCupertinoDialogAction': (hit) =>
          WiredCupertinoDialogAction(onPressed: hit, child: const Text('A')),
      'WiredCupertinoActionSheetAction': (hit) =>
          WiredCupertinoActionSheetAction(
            onPressed: hit,
            child: const Text('A'),
          ),
    };

    for (final entry in controls.entries) {
      for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
        testWidgets('${entry.key} is reached by Tab and activated by '
            '${key.keyLabel.isEmpty ? 'Space' : key.keyLabel}', (
          tester,
        ) async {
          var hits = 0;
          await pumpWired(
            tester,
            SizedBox(width: 320, child: entry.value(() => hits++)),
          );

          await tab(tester);
          expect(
            focusIsWithin(find.byType(SizedBox).first),
            isTrue,
            reason: '${entry.key} should join focus traversal',
          );
          await tester.sendKeyEvent(key);
          await tester.pump();

          expect(hits, 1);
        });
      }
    }

    testWidgets('a focused chip shows a hand-drawn ring in the theme ink', (
      tester,
    ) async {
      const ink = Color(0xFFF4EFE6);
      await pumpWired(
        tester,
        WiredChoiceChip(label: const Text('A'), onSelected: (_) {}),
        theme: WiredThemeData(borderColor: ink),
      );
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );

      await tab(tester);

      final ring = find.descendant(
        of: findWired<WiredChoiceChip>(),
        matching: find.byWidgetPredicate(
          (w) =>
              w is WiredCanvas &&
              w.painter is WiredRoundedRectangleBase &&
              w.seed == 7,
        ),
      );
      expect(ring, findsOneWidget);
      final painter =
          tester.widget<WiredCanvas>(ring).painter as WiredRoundedRectangleBase;
      expect(painter.borderColor, ink);
      // The ring surrounds the chip rather than tracing its outline.
      final chip = tester.getRect(findWired<WiredChoiceChip>());
      final ringRect = tester.getRect(ring);
      expect(ringRect.left, lessThan(chip.left));
      expect(ringRect.bottom, greaterThan(chip.bottom));
    });
  });

  group('disabled controls', () {
    final disabled = <String, Widget>{
      'WiredRadio': const WiredRadio<int>(
        value: 1,
        groupValue: 0,
        onChanged: null,
      ),
      'WiredChoiceChip': const WiredChoiceChip(label: Text('A')),
      'WiredFilterChip': const WiredFilterChip(label: Text('A')),
      'WiredInputChip': WiredInputChip(
        label: const Text('A'),
        enabled: false,
        onPressed: () {},
      ),
      'WiredActionChip': const WiredActionChip(label: Text('A')),
      'WiredCupertinoButton': const WiredCupertinoButton(
        onPressed: null,
        child: Text('A'),
      ),
      'WiredCupertinoSwitch': const WiredCupertinoSwitch(
        value: false,
        onChanged: null,
      ),
      'WiredRadioListTile': const WiredRadioListTile<int>(
        value: 1,
        groupValue: 0,
        onChanged: null,
        title: Text('A'),
      ),
      'WiredSwitchListTile': const WiredSwitchListTile(
        value: false,
        title: Text('A'),
      ),
    };

    for (final entry in disabled.entries) {
      testWidgets('${entry.key} cannot be focused or tapped', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWired(tester, SizedBox(width: 320, child: entry.value));

        await tab(tester);
        expect(
          focusIsWithin(find.byType(SizedBox).first),
          isFalse,
          reason: 'a disabled ${entry.key} should not take focus',
        );
        for (final node in nodesUnder(tester, find.byType(SizedBox).first)) {
          final data = node.getSemanticsData();
          expect(
            data.hasAction(SemanticsAction.tap),
            isFalse,
            reason: 'a disabled ${entry.key} should not offer a tap action',
          );
          final enabled = data.flagsCollection.isEnabled.toBoolOrNull();
          expect(
            enabled,
            isNot(isTrue),
            reason: 'no node of a disabled ${entry.key} may report enabled',
          );
        }
        handle.dispose();
      });
    }
  });

  group('chips', () {
    testWidgets('the delete mark is its own labelled, focusable button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var deleted = 0;
      await pumpWired(
        tester,
        WiredChip(label: const Text('Tag'), onDeleted: () => deleted++),
      );

      expect(find.bySemanticsLabel('Delete'), findsOneWidget);
      expectSemantics(
        tester,
        find.bySemanticsLabel('Delete'),
        isButton: true,
        hasTapAction: true,
      );
      // The chip itself is not a button.
      expectSemantics(tester, findWired<WiredChip>(), isButton: false);

      await tab(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(deleted, 1);
      handle.dispose();
    });

    testWidgets('a semantic label replaces the chip text, not joins it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpWired(
        tester,
        WiredChoiceChip(
          label: const Text('🏿'),
          semanticLabel: 'dark skin tone',
          onSelected: (_) {},
        ),
      );

      expect(find.bySemanticsLabel('dark skin tone'), findsOneWidget);
      expectSemantics(
        tester,
        find.bySemanticsLabel('dark skin tone'),
        isButton: true,
        hasTapAction: true,
      );
      handle.dispose();
    });

    testWidgets('the delete label can be replaced', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWired(
        tester,
        WiredInputChip(
          label: const Text('Tag'),
          onDeleted: () {},
          deleteButtonSemanticLabel: 'Remove tag',
        ),
      );

      expect(find.bySemanticsLabel('Remove tag'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a selected input chip writes on ink in the paper colour', (
      tester,
    ) async {
      final theme = WiredThemeData();
      await pumpWired(
        tester,
        WiredInputChip(label: const Text('Tag'), selected: true),
        theme: theme,
      );

      final paragraph = tester.renderObject<RenderParagraph>(find.text('Tag'));
      expect(paragraph.text.style?.color, theme.fillColor);
      final border =
          tester
                  .widget<WiredCanvas>(
                    find.descendant(
                      of: findWired<WiredInputChip>(),
                      matching: find.byType(WiredCanvas),
                    ),
                  )
                  .painter
              as WiredRoundedRectangleBase;
      expect(border.fillColor, theme.borderColor);
    });

    testWidgets('chips keep the button padding around their label', (
      tester,
    ) async {
      for (final chip in <Widget>[
        const WiredChip(label: Text('Tag')),
        const WiredChoiceChip(label: Text('Tag')),
        const WiredFilterChip(label: Text('Tag')),
        const WiredInputChip(label: Text('Tag')),
        const WiredActionChip(label: Text('Tag')),
      ]) {
        await pumpWired(tester, chip);
        final outer = tester.getRect(find.byWidget(chip));
        final label = tester.getRect(find.text('Tag'));
        expect(
          label.left - outer.left,
          greaterThanOrEqualTo(kWiredButtonPadding.left),
          reason: '${chip.runtimeType} crowds its label',
        );
      }
    });
  });

  group('WiredCupertinoSlider', () {
    testWidgets('reports a slider with its value and moves by actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final values = <double>[];
      await pumpWired(
        tester,
        SizedBox(
          width: 300,
          child: WiredCupertinoSlider(
            value: 0.5,
            semanticLabel: 'Volume',
            onChanged: values.add,
          ),
        ),
      );

      final finder = findWired<WiredCupertinoSlider>();
      expectSemantics(
        tester,
        finder,
        label: 'Volume',
        isSlider: true,
        isEnabled: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      );
      expect(semanticsOf(tester, finder).value, '0.5');

      final node = tester.getSemantics(finder);
      node.owner!.performAction(node.id, SemanticsAction.increase);
      await tester.pump();
      expect(values.single, closeTo(0.6, 1e-9));
      handle.dispose();
    });

    testWidgets('lays out a one-value range without failing', (tester) async {
      await pumpWired(
        tester,
        SizedBox(
          width: 200,
          child: WiredCupertinoSlider(
            value: 1,
            min: 1,
            max: 1,
            onChanged: (_) {},
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('snaps to divisions counted from min', (tester) async {
      double? received;
      await pumpWired(
        tester,
        SizedBox(
          width: 228,
          child: WiredCupertinoSlider(
            value: 1,
            min: 1,
            max: 4,
            divisions: 2,
            onChanged: (v) => received = v,
          ),
        ),
      );

      // Just right of the middle of the 200px of travel.
      final box = tester.getRect(findWired<WiredCupertinoSlider>());
      await tester.tapAt(Offset(box.left + 14 + 110, box.center.dy));
      await tester.pump();

      expect(received, 2.5);
    });

    testWidgets('puts the minimum at the right under RTL', (tester) async {
      double? received;
      await pumpWiredRtl(
        tester,
        SizedBox(
          width: 300,
          child: WiredCupertinoSlider(
            value: 0.5,
            onChanged: (v) => received = v,
          ),
        ),
      );

      final box = tester.getRect(findWired<WiredCupertinoSlider>());
      await tester.tapAt(Offset(box.left + 2, box.center.dy));
      await tester.pump();

      expect(received, 1.0);
    });
  });

  group('Cupertino surfaces', () {
    testWidgets('a search field survives gaining a focus node', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const SizedBox(width: 300, child: WiredCupertinoSearchTextField()),
      );
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpWired(
        tester,
        SizedBox(
          width: 300,
          child: WiredCupertinoSearchTextField(focusNode: node),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('dialogs and action sheets sit on the theme paper', (
      tester,
    ) async {
      const paper = Color(0xFF1E1A22);
      for (final surface in <Widget>[
        const WiredCupertinoAlertDialog(title: Text('Title')),
        const WiredCupertinoActionSheet(title: Text('Title')),
      ]) {
        await pumpWired(
          tester,
          surface,
          theme: WiredThemeData(fillColor: paper),
        );

        final paperBoxes = find.descendant(
          of: find.byWidget(surface),
          matching: find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).color == paper,
          ),
        );
        expect(paperBoxes, findsWidgets, reason: '${surface.runtimeType}');
        final white = find.descendant(
          of: find.byWidget(surface),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).color?.r == 1.0,
          ),
        );
        expect(white, findsNothing, reason: '${surface.runtimeType}');
      }
    });

    testWidgets('dialog actions stack instead of breaking words at 2x', (
      tester,
    ) async {
      await pumpWiredScaled(
        tester,
        WiredCupertinoAlertDialog(
          title: const Text('Discard?'),
          actions: [
            WiredCupertinoDialogAction(
              onPressed: () {},
              child: const Text('Keep'),
            ),
            WiredCupertinoDialogAction(
              onPressed: () {},
              child: const Text('Discard'),
            ),
          ],
        ),
      );

      final keep = tester.getRect(find.text('Keep'));
      final discard = tester.getRect(find.text('Discard'));
      expect(discard.top, greaterThanOrEqualTo(keep.bottom));
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('Discard'))
            .didExceedMaxLines,
        isFalse,
      );
    });

    testWidgets('two dialog actions share a row at normal text', (
      tester,
    ) async {
      await pumpWired(
        tester,
        WiredCupertinoAlertDialog(
          actions: [
            WiredCupertinoDialogAction(
              onPressed: () {},
              child: const Text('Keep'),
            ),
            WiredCupertinoDialogAction(
              onPressed: () {},
              child: const Text('Discard'),
            ),
          ],
        ),
      );

      expect(
        tester.getCenter(find.text('Keep')).dy,
        tester.getCenter(find.text('Discard')).dy,
      );
    });

    testWidgets('the tab bar grows with doubled text instead of overflowing', (
      tester,
    ) async {
      await pumpWiredScaled(
        tester,
        WiredCupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Settings'),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(findWired<WiredCupertinoTabBar>()).height,
        greaterThan(50),
      );
    });

    testWidgets('the tab bar keeps its height at normal text', (tester) async {
      await pumpWired(
        tester,
        WiredCupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Settings'),
          ],
        ),
      );

      expect(tester.getSize(findWired<WiredCupertinoTabBar>()).height, 50);
    });
  });

  group('toggle buttons', () {
    testWidgets('report their toggled state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWired(
        tester,
        WiredToggleButtons(
          isSelected: const [true, false],
          onPressed: (_) {},
          children: const [Text('Bold'), Text('Italic')],
        ),
      );

      expectSemantics(
        tester,
        find.text('Bold'),
        isButton: true,
        isToggled: true,
      );
      expectSemantics(
        tester,
        find.text('Italic'),
        isButton: true,
        isToggled: false,
      );
      handle.dispose();
    });

    testWidgets('grow past their height with doubled text', (tester) async {
      await pumpWiredScaled(
        tester,
        WiredToggleButtons(
          isSelected: const [true],
          onPressed: (_) {},
          children: const [Text('Bold')],
        ),
      );

      expect(tester.takeException(), isNull);
      final bold = tester.getRect(find.text('Bold'));
      final group = tester.getRect(findWired<WiredToggleButtons>());
      expect(bold.top - group.top, greaterThanOrEqualTo(8));
      expect(group.bottom - bold.bottom, greaterThanOrEqualTo(8));
    });
  });

  testWidgets('a selected segment is washed with marker, not hachured', (
    tester,
  ) async {
    final theme = WiredThemeData();
    await pumpWired(
      tester,
      WiredSegmentedButton<int>(
        segments: const [
          WiredButtonSegment(value: 1, label: Text('Day')),
          WiredButtonSegment(value: 2, label: Text('Week')),
        ],
        selected: const {1},
        onSelectionChanged: (_) {},
      ),
      theme: theme,
    );

    final decorated = tester.widget<Container>(
      find
          .ancestor(of: find.text('Day'), matching: find.byType(Container))
          .first,
    );
    final decoration = decorated.decoration! as RoughBoxDecoration;
    expect(decoration.filler, isA<SolidFiller>());
    expect(decoration.fillStyle?.color, theme.markerColor);
  });

  testWidgets('WiredSwitch paints a supplied inactive colour', (tester) async {
    const off = Color(0xFFCCE0FF);
    await pumpWired(
      tester,
      WiredSwitch(value: false, inactiveColor: off, onChanged: (_) {}),
    );

    final track = tester.widget<WiredCanvas>(
      find
          .descendant(
            of: findWired<WiredSwitch>(),
            matching: find.byType(WiredCanvas),
          )
          .first,
    );
    expect(track.fillerType, RoughFilter.solidFiller);
    expect((track.painter as WiredRoundedRectangleBase).fillColor, off);
  });
}
