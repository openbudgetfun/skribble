import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/wired_svg_icon_painter.dart';

void main() {
  testWidgets('a scrolled-away icon reuses its prepared painter when it '
      'returns', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final icons = SkribbleGlyphs.all.values.toList();
    await tester.pumpWidget(
      MaterialApp(
        home: WiredTheme(
          data: WiredThemeData(),
          child: Scaffold(
            body: ListView.builder(
              itemCount: 200,
              itemBuilder: (context, index) => ListTile(
                leading: WiredSvgIcon(
                  data: icons[index % icons.length],
                  size: 32,
                ),
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    CustomPainter painterOf(int index) => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .where((widget) => widget.painter is WiredSvgIconPainter)
        .skip(index)
        .first
        .painter!;

    final before = painterOf(0);

    // Scroll the first rows out of view and back.
    for (var i = 0; i < 40; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -120));
      await tester.pump(const Duration(milliseconds: 16));
    }
    for (var i = 0; i < 40; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();

    // The returned row hands its CustomPaint the very painter prepared when
    // the icon was first drawn, so revisited icons never re-prepare ink.
    expect(identical(painterOf(0), before), isTrue);
  });
}
