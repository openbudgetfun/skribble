import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String? clipboardText;
  setUp(() {
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = (call.arguments as Map<Object?, Object?>)['text']! as String;
          }
          if (call.method == 'Clipboard.getData') return {'text': clipboardText};
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
  testWidgets('selects styled text across paragraphs and copies it exactly', (
    tester,
  ) async {
    String? selected;
    await pumpApp(
      tester,
      WiredSelectionArea(
        onSelectionChanged: (value) => selected = value?.plainText,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'A bright '),
                  TextSpan(
                    text: 'idea\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text('A small beginning.'),
          ],
        ),
      ),
    );
    final region = tester.state<SelectableRegionState>(
      find.byType(SelectableRegion),
    );
    region.selectAll();
    await tester.pump();
    expect(selected, 'A bright idea\nA small beginning.');
    region.contextMenuButtonItems
        .singleWhere((item) => item.type == ContextMenuButtonType.copy)
        .onPressed!();
    await tester.pump();
    final clipboard = await tester.runAsync(
      () => Clipboard.getData(Clipboard.kTextPlain),
    );
    expect(clipboard?.text, 'A bright idea\nA small beginning.');
  });

  testWidgets('selection ignores interactive example text', (tester) async {
    String? selected;
    await pumpApp(
      tester,
      WiredSelectionArea(
        onSelectionChanged: (value) => selected = value?.plainText,
        child: const Column(
          children: [
            Text('Keep this'),
            SelectionContainer.disabled(child: Text('Interactive example')),
          ],
        ),
      ),
    );
    tester
        .state<SelectableRegionState>(find.byType(SelectableRegion))
        .selectAll();
    await tester.pump();
    expect(selected, 'Keep this');
  });

  testWidgets('mouse drag selects real prose', (tester) async {
    String? selected;
    await pumpApp(
      tester,
      WiredSelectionArea(
        onSelectionChanged: (value) => selected = value?.plainText,
        child: const Text('Make something worth keeping.'),
      ),
    );
    final bounds = tester.getRect(find.text('Make something worth keeping.'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.down(bounds.centerLeft + const Offset(1, 0));
    await mouse.moveTo(bounds.centerRight - const Offset(1, 0));
    await mouse.up();
    await tester.pump();
    expect(selected, contains('something worth'));
  });

  testWidgets('empty content does not report a selection', (tester) async {
    String? selected;
    await pumpApp(
      tester,
      WiredSelectionArea(
        onSelectionChanged: (value) => selected = value?.plainText,
        child: const SizedBox(),
      ),
    );
    tester
        .state<SelectableRegionState>(find.byType(SelectableRegion))
        .selectAll();
    await tester.pump();
    expect(selected, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removal preserves the caller-owned focus node', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await pumpApp(
      tester,
      WiredSelectionArea(focusNode: focus, child: const Text('Hello')),
    );
    await tester.pumpWidget(const SizedBox());
    focus.addListener(() {});
    expect(tester.takeException(), isNull);
  });

  testWidgets('copy toolbar remains usable at a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpApp(
      tester,
      const WiredSelectionArea(child: Center(child: Text('A little ink'))),
    );
    await tester.longPress(find.text('A little ink'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsOneWidget);
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    final clipboard = await tester.runAsync(
      () => Clipboard.getData(Clipboard.kTextPlain),
    );
    expect(clipboard?.text, 'A little ink');
    expect(tester.takeException(), isNull);
  });
}
