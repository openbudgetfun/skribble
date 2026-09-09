import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/wired_expansion_panel_list.dart';

import '../helpers/pump_app.dart';

WiredExpansionPanel panel(String name, {bool canTapOnHeader = true}) =>
    WiredExpansionPanel(
      canTapOnHeader: canTapOnHeader,
      headerBuilder: (context, expanded) =>
          Text('$name ${expanded ? 'open' : 'closed'}'),
      body: Text('$name content'),
    );

void main() {
  testWidgets('an inactive header leaves expansion to its accessible button', (
    tester,
  ) async {
    final changes = <(int, bool)>[];
    await pumpApp(
      tester,
      WiredExpansionPanelList(
        children: [panel('First', canTapOnHeader: false)],
        expansionCallback: (index, expanded) => changes.add((index, expanded)),
      ),
    );
    await tester.tap(find.text('First closed'));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsNothing);
    expect(changes, isEmpty);
    expect(
      tester
          .getSemantics(find.byType(WiredIconButton))
          .getSemanticsData()
          .label,
      contains('Expand panel'),
    );
    await tester.tap(find.byType(WiredIconButton));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byType(WiredIconButton))
          .getSemanticsData()
          .label,
      contains('Collapse panel'),
    );
    await tester.tap(find.byType(WiredIconButton));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsNothing);
    expect(changes, [(0, true), (0, false)]);
  });

  testWidgets('renders collapsed headers within the available width', (
    tester,
  ) async {
    await pumpApp(
      tester,
      SizedBox(
        width: 320,
        child: WiredExpansionPanelList(
          children: [panel('First'), panel('Second')],
        ),
      ),
    );
    expect(find.text('First closed'), findsOneWidget);
    expect(find.text('Second closed'), findsOneWidget);
    expect(find.text('First content'), findsNothing);
    expect(tester.getSize(find.byType(WiredExpansionPanelList)).width, 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens and closes a panel and reports the resulting state', (
    tester,
  ) async {
    final changes = <(int, bool)>[];
    await pumpApp(
      tester,
      WiredExpansionPanelList(
        children: [panel('First')],
        expansionCallback: (index, expanded) => changes.add((index, expanded)),
      ),
    );
    await tester.tap(find.text('First closed'));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsOneWidget);
    expect(find.text('First open'), findsOneWidget);
    await tester.tap(find.text('First open'));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsNothing);
    expect(changes, [(0, true), (0, false)]);
  });

  testWidgets('keeps other panels open when one panel closes', (tester) async {
    await pumpApp(
      tester,
      WiredExpansionPanelList(children: [panel('First'), panel('Second')]),
    );
    for (final name in ['First closed', 'Second closed', 'First open']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }
    expect(find.text('First content'), findsNothing);
    expect(find.text('Second content'), findsOneWidget);
  });

  testWidgets('rapid toggles settle correctly without a callback', (
    tester,
  ) async {
    await pumpApp(tester, WiredExpansionPanelList(children: [panel('First')]));
    for (var i = 0; i < 8; i++) {
      await tester.tap(find.text('First ${i.isEven ? 'closed' : 'open'}'));
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
    expect(find.text('First closed'), findsOneWidget);
    expect(find.text('First content'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty lists retain their accessible label', (tester) async {
    await pumpApp(
      tester,
      const WiredExpansionPanelList(
        children: [],
        semanticLabel: 'Notebook sections',
      ),
    );
    expect(find.bySemanticsLabel('Notebook sections'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('panel controls remain usable while their ink is hidden', (
    tester,
  ) async {
    final progress = AnimationController(vsync: tester);
    addTearDown(progress.dispose);
    await pumpApp(
      tester,
      WiredDrawTransition(
        progress: progress,
        child: WiredExpansionPanelList(children: [panel('First')]),
      ),
    );
    await tester.tap(find.text('First closed'));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsOneWidget);
    final border = tester
        .widgetList<Container>(find.byType(Container))
        .map((widget) => widget.decoration)
        .whereType<RoughBoxDecoration>()
        .single;
    expect(border.progress, same(progress));
    progress.value = .6;
    await tester.pump();
    expect(find.text('First content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('motion opt-out settles the border and preserves expansion', (
    tester,
  ) async {
    await pumpApp(
      tester,
      WiredMotion(
        enabled: false,
        child: WiredDrawTransition(
          progress: const AlwaysStoppedAnimation(.2),
          child: WiredExpansionPanelList(children: [panel('First')]),
        ),
      ),
    );
    final border = tester
        .widgetList<Container>(find.byType(Container))
        .map((widget) => widget.decoration)
        .whereType<RoughBoxDecoration>()
        .single;
    expect(border.progress, isNull);
    await tester.tap(find.text('First closed'));
    await tester.pumpAndSettle();
    expect(find.text('First content'), findsOneWidget);
  });
}
