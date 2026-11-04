import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A column definition for [WiredDataTable].
class WiredDataColumn {
  /// The column's header, read by screen readers as a header.
  final Widget label;

  /// A fixed width for the column's cells, or null to share the table's
  /// remaining width with the other flexible columns.
  final double? width;

  /// Creates a column definition.
  const WiredDataColumn({required this.label, this.width});
}

/// A row of data for [WiredDataTable].
class WiredDataRow {
  /// The row's cells, one per column. Extra cells are ignored.
  final List<Widget> cells;

  /// Called when the row is tapped.
  final VoidCallback? onTap;

  /// Creates a row of data.
  const WiredDataRow({required this.cells, this.onTap});
}

/// A data table with hand-drawn grid lines.
///
/// Columns with a [WiredDataColumn.width] keep it; the others share the rest
/// of the width, each getting at least [minColumnWidth]. When the columns
/// need more room than the table is offered, as on a narrow phone, the table
/// scrolls sideways instead of squeezing its text into a thin column.
class WiredDataTable extends HookWidget {
  /// The table's columns, in order.
  final List<WiredDataColumn> columns;

  /// The table's rows, in order.
  final List<WiredDataRow> rows;

  /// The least width of a column without a fixed width.
  final double minColumnWidth;

  /// Creates a data table with hand-drawn grid lines.
  const WiredDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minColumnWidth = 96,
  });

  /// The horizontal padding at each end of a row.
  static const double _rowPadding = 16;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fixed = columns.fold<double>(0, (sum, c) => sum + (c.width ?? 0));
    final flexible = columns.where((c) => c.width == null).length;
    final needed = fixed + flexible * minColumnWidth + _rowPadding * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final offered = constraints.maxWidth;
        final table = _buildTable(theme);
        if (offered.isFinite && needed <= offered) return table;
        // Too narrow for the columns: keep their widths and scroll.
        final scrolled = SizedBox(width: needed, child: table);
        return offered.isFinite
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: scrolled,
              )
            : scrolled;
      },
    );
  }

  Widget _buildTable(WiredThemeData theme) {
    return buildWiredElement(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRectangleBase(
                  strokeWidth: theme.strokeWidth,
                  fillColor: theme.fillColor,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                _buildHeaderRow(theme),
                SizedBox(
                  height: theme.inkExtent,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      x1: 0,
                      y1: 0,
                      x2: double.infinity,
                      y2: 0,
                      strokeWidth: theme.strokeWidth,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
                // Data rows
                for (int i = 0; i < rows.length; i++) ...[
                  _buildDataRow(rows[i], theme),
                  if (i < rows.length - 1)
                    SizedBox(
                      height: theme.inkExtent,
                      child: WiredCanvas(
                        painter: WiredLineBase(
                          strokeWidth: theme.strokeWidth,
                          x1: 0,
                          y1: 0,
                          x2: double.infinity,
                          y2: 0,
                          borderColor: theme.borderColor,
                        ),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A cell sized by its column: fixed when the column has a width,
  /// sharing the remaining space otherwise.
  Widget _cell(int column, Widget child) {
    final width = columns[column].width;
    return width == null
        ? Expanded(child: child)
        : SizedBox(width: width, child: child);
  }

  Widget _buildHeaderRow(WiredThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: _rowPadding,
      ),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            _cell(
              i,
              Semantics(
                header: true,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  child: columns[i].label,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(WiredDataRow row, WiredThemeData theme) {
    return InkWell(
      onTap: row.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _rowPadding,
        ),
        child: Row(
          children: [
            for (int i = 0; i < row.cells.length && i < columns.length; i++)
              _cell(
                i,
                DefaultTextStyle.merge(
                  style: TextStyle(color: theme.textColor, fontSize: 14),
                  child: row.cells[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
