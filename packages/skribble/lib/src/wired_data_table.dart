import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A column definition for [WiredDataTable].
class WiredDataColumn {
  /// The column heading, drawn in bold.
  final Widget label;

  /// A preferred width for the column, in logical pixels.
  ///
  /// Not applied yet: every column currently takes an equal share of the
  /// table's width.
  final double? width;

  /// Creates a column definition.
  const WiredDataColumn({required this.label, this.width});
}

/// A row of data for [WiredDataTable].
class WiredDataRow {
  /// The row's cells, one per column, in column order.
  ///
  /// Cells beyond the number of columns are not shown.
  final List<Widget> cells;

  /// Called when the user taps the row. Null makes the row inert.
  final VoidCallback? onTap;

  /// Creates a row of data.
  const WiredDataRow({required this.cells, this.onTap});
}

/// A data table with hand-drawn grid lines.
class WiredDataTable extends HookWidget {
  /// The columns, which share the table's width equally.
  final List<WiredDataColumn> columns;

  /// The data rows, separated by hand-drawn lines.
  final List<WiredDataRow> rows;

  /// Creates a data table with hand-drawn grid lines.
  const WiredDataTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
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

  Widget _buildHeaderRow(WiredThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                child: columns[i].label,
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            for (int i = 0; i < row.cells.length && i < columns.length; i++)
              Expanded(
                child: DefaultTextStyle.merge(
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
