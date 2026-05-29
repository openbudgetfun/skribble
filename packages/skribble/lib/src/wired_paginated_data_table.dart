import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_theme.dart';

/// A hand-drawn paginated data table, corresponding to Flutter's `PaginatedDataTable`.
///
/// Wraps Flutter's `PaginatedDataTable` with a sketchy border and
/// hand-drawn styling that fits the Skribble aesthetic.
///
/// ## Example
///
/// ```dart
/// WiredPaginatedDataTable(
///   columns: [
///     DataColumn(label: Text('Name')),
///     DataColumn(label: Text('Age')),
///   ],
///   source: MyDataSource(),
///   rowsPerPage: 10,
/// )
/// ```
class WiredPaginatedDataTable extends HookWidget {
  /// The columns to display in the table.
  final List<DataColumn> columns;

  /// The data source for the table.
  final DataTableSource source;

  /// The number of rows per page.
  final int rowsPerPage;

  /// Whether to show the checkbox column.
  final bool showCheckboxColumn;

  /// Whether the table is sorted.
  final bool sortAscending;

  /// The index of the column to sort by.
  final int? sortColumnIndex;

  /// Callback when a row is selected.
  final ValueChanged<bool?>? onSelectAll;

  /// Callback when a page changes.
  final ValueChanged<int>? onPageChanged;

  /// The header widget to display above the table.
  final Widget? header;

  /// The actions to display in the header.
  final List<Widget>? actions;

  /// The semantic label for accessibility.
  final String? semanticLabel;

  /// Creates a hand-drawn paginated data table.
  const WiredPaginatedDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.rowsPerPage = PaginatedDataTable.defaultRowsPerPage,
    this.showCheckboxColumn = true,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSelectAll,
    this.onPageChanged,
    this.header,
    this.actions,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Semantics(
      label: semanticLabel ?? 'Paginated data table',
      child: Container(
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(width: 1, color: theme.borderColor),
        ),
        child: PaginatedDataTable(
          columns: columns,
          source: source,
          rowsPerPage: rowsPerPage,
          showCheckboxColumn: showCheckboxColumn,
          sortAscending: sortAscending,
          sortColumnIndex: sortColumnIndex,
          onSelectAll: onSelectAll,
          onPageChanged: onPageChanged,
          header: header,
          actions: actions,
        ),
      ),
    );
  }
}
