import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredDataColumn', () {
    test('stores label widget', () {
      const column = WiredDataColumn(label: Text('Name'));
      expect(column.label, isA<Text>());
    });

    test('width defaults to null', () {
      const column = WiredDataColumn(label: Text('Name'));
      expect(column.width, isNull);
    });

    test('accepts custom width', () {
      const column = WiredDataColumn(label: Text('Name'), width: 120);
      expect(column.width, 120);
    });
  });

  group('WiredDataRow', () {
    test('stores cells list', () {
      const row = WiredDataRow(cells: [Text('A'), Text('B')]);
      expect(row.cells.length, 2);
    });

    test('onTap defaults to null', () {
      const row = WiredDataRow(cells: [Text('A')]);
      expect(row.onTap, isNull);
    });

    test('accepts onTap callback', () {
      final row = WiredDataRow(cells: const [Text('A')], onTap: () {});
      expect(row.onTap, isNotNull);
    });
  });

  group('WiredDataTable', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [
            WiredDataColumn(label: Text('Name')),
            WiredDataColumn(label: Text('Age')),
          ],
          rows: const [
            WiredDataRow(cells: [Text('Alice'), Text('30')]),
          ],
        ),
      );

      expect(find.byType(WiredDataTable), findsOneWidget);
    });

    testWidgets('renders column headers', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [
            WiredDataColumn(label: Text('Name')),
            WiredDataColumn(label: Text('Email')),
            WiredDataColumn(label: Text('Role')),
          ],
          rows: const [],
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
    });

    testWidgets('renders row cell data', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [
            WiredDataColumn(label: Text('Name')),
            WiredDataColumn(label: Text('Value')),
          ],
          rows: const [
            WiredDataRow(cells: [Text('Item 1'), Text('100')]),
            WiredDataRow(cells: [Text('Item 2'), Text('200')]),
          ],
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('calls row onTap callback when row is tapped', (tester) async {
      var tapped = false;

      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Name'))],
          rows: [
            WiredDataRow(
              cells: const [Text('Tappable row')],
              onTap: () => tapped = true,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Tappable row'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not crash when row onTap is null', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Name'))],
          rows: const [
            WiredDataRow(cells: [Text('No tap row')]),
          ],
        ),
      );

      await tester.tap(find.text('No tap row'));
      await tester.pump();

      expect(find.byType(WiredDataTable), findsOneWidget);
    });

    testWidgets('renders with empty rows', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Header'))],
          rows: const [],
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.byType(WiredDataTable), findsOneWidget);
    });

    testWidgets('renders separator lines between rows', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Col'))],
          rows: const [
            WiredDataRow(cells: [Text('Row 1')]),
            WiredDataRow(cells: [Text('Row 2')]),
            WiredDataRow(cells: [Text('Row 3')]),
          ],
        ),
      );

      // WiredCanvas instances include:
      // - 1 for the outer rectangle border
      // - 1 for the header separator (thick line)
      // - 2 for separators between 3 data rows (n-1 separators)
      // Total = 4
      expect(
        find.descendant(
          of: find.byType(WiredDataTable),
          matching: find.byType(WiredCanvas),
        ),
        findsNWidgets(4),
      );
    });

    testWidgets('renders header separator line', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Header'))],
          rows: const [
            WiredDataRow(cells: [Text('Data')]),
          ],
        ),
      );

      // Should have the outer rectangle + header separator line + no row
      // separators (only 1 row).
      expect(
        find.descendant(
          of: find.byType(WiredDataTable),
          matching: find.byType(WiredCanvas),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Col'))],
          rows: const [
            WiredDataRow(cells: [Text('Cell')]),
          ],
        ),
      );

      // WiredDataTable uses buildWiredElement which wraps in RepaintBoundary.
      expect(
        find.descendant(
          of: find.byType(WiredDataTable),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses InkWell for row tap handling', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Col'))],
          rows: [
            WiredDataRow(cells: const [Text('Row')], onTap: () {}),
          ],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredDataTable),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders multiple columns in each row', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [
            WiredDataColumn(label: Text('A')),
            WiredDataColumn(label: Text('B')),
            WiredDataColumn(label: Text('C')),
          ],
          rows: const [
            WiredDataRow(cells: [Text('1'), Text('2'), Text('3')]),
          ],
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('limits cells to column count', (tester) async {
      // When a row has more cells than columns, the extra cells should
      // not be rendered because the loop uses i < columns.length.
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Only'))],
          rows: const [
            WiredDataRow(cells: [Text('Shown'), Text('Hidden')]),
          ],
        ),
      );

      expect(find.text('Shown'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('each row calls its own onTap', (tester) async {
      var row1Tapped = false;
      var row2Tapped = false;

      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Name'))],
          rows: [
            WiredDataRow(
              cells: const [Text('Row 1')],
              onTap: () => row1Tapped = true,
            ),
            WiredDataRow(
              cells: const [Text('Row 2')],
              onTap: () => row2Tapped = true,
            ),
          ],
        ),
      );

      await tester.tap(find.text('Row 1'));
      await tester.pump();

      expect(row1Tapped, isTrue);
      expect(row2Tapped, isFalse);

      await tester.tap(find.text('Row 2'));
      await tester.pump();

      expect(row2Tapped, isTrue);
    });

    testWidgets('uses IntrinsicHeight for sizing', (tester) async {
      await pumpApp(
        tester,
        WiredDataTable(
          columns: const [WiredDataColumn(label: Text('Col'))],
          rows: const [
            WiredDataRow(cells: [Text('Cell')]),
          ],
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredDataTable),
          matching: find.byType(IntrinsicHeight),
        ),
        findsOneWidget,
      );
    });
  });
}
