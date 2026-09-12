import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_docs_site/src/app.dart';
import 'package:skribble_docs_site/src/document.dart';

void main() {
  final documents = Directory('content')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .map((file) => DocDocument.parse(file.path, file.readAsStringSync()))
      .toList();

  test('every canonical document has a unique routable path and title', () {
    expect(documents.length, greaterThan(35));
    expect(
      documents.map((document) => document.path).toSet().length,
      documents.length,
    );
    expect(documents.any((document) => document.path == '/'), isTrue);
    expect(
      documents.any((document) => document.path == '/widgets/maps'),
      isTrue,
    );
    for (final document in documents) {
      expect(document.title, isNotEmpty);
      expect(document.nodes, isNotEmpty);
    }
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('all documentation renders and scrolls at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final document in documents) {
        await tester.pumpWidget(
          DocsApp(
            key: ValueKey(document.path),
            documents: documents,
            initialLocation: document.path,
          ),
        );
        if (document.path == '/widgets/loading') {
          // A loading gallery repeats until the visitor settles its motion.
          await tester.tap(find.text('Settle motion'));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: document.path);
        final scroll = find.byKey(const ValueKey('document-scroll'));
        await tester.drag(scroll, const Offset(0, -650));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${document.path} after scrolling',
        );
      }
    });
  }

  testWidgets('homepage examples respond and decorative motion can replay', (
    tester,
  ) async {
    await tester.pumpWidget(DocsApp(documents: documents));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Keep this little idea'));
    await tester.tap(find.text('Keep this little idea'));
    await tester.pumpAndSettle();
    expect(find.text('Lovely. It’s saved!'), findsOneWidget);
    await tester.ensureVisible(find.text('Draw it again'));
    await tester.tap(find.text('Draw it again'));
    await tester.pumpAndSettle();
    expect(find.text('Lovely. It’s saved!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selection includes prose beyond the viewport and keeps separators',
    (tester) async {
      final document = DocDocument.parse(
        'content/index.md',
        '# A long page\n\nFirst paragraph.\n\n${List.filled(50, 'A paragraph to scroll past.').join('\n\n')}\n\nLast paragraph.',
      );
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text']! as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(DocsApp(documents: [document]));
      await tester.pumpAndSettle();
      final region = tester.state<SelectableRegionState>(
        find.byType(SelectableRegion),
      )..selectAll();
      await tester.pump();
      region.contextMenuButtonItems
          .singleWhere((item) => item.type == ContextMenuButtonType.copy)
          .onPressed!();
      await tester.pump();
      expect(copied, contains('First paragraph.\nA paragraph'));
      expect(copied, endsWith('Last paragraph.'));
      expect(copied, isNot(contains('Keep this little idea')));
    },
  );
}
