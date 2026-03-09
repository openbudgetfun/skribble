import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A column definition for [WiredDataTable].
class WiredDataColumn {
  final Widget label;
  final double? width;

  const WiredDataColumn({required this.label, this.width});
}

/// A row of data for [WiredDataTable].
class WiredDataRow {
  final List<Widget> cells;
  final VoidCallback? onTap;

  const WiredDataRow({required this.cells, this.onTap});
}

/// A data table with hand-drawn grid lines.
class WiredDataTable extends HookWidget {
  final List<WiredDataColumn> columns;
  final List<WiredDataRow> rows;

  const WiredDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                _buildHeaderRow(),
                SizedBox(
                  height: 2,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      x1: 0,
                      y1: 0,
                      x2: double.infinity,
                      y2: 0,
                      strokeWidth: 2,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
                // Data rows
                for (int i = 0; i < rows.length; i++) ...[
                  _buildDataRow(rows[i]),
                  if (i < rows.length - 1)
                    SizedBox(
                      height: 1,
                      child: WiredCanvas(
                        painter: WiredLineBase(
                          x1: 0,
                          y1: 0,
                          x2: double.infinity,
                          y2: 0,
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

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: textColor,
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

  Widget _buildDataRow(WiredDataRow row) {
    return InkWell(
      onTap: row.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            for (int i = 0; i < row.cells.length && i < columns.length; i++)
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(color: textColor, fontSize: 14),
                  child: row.cells[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
