import 'package:flutter/widgets.dart';

/// Shared targets for the financial chart's browser journeys.
abstract final class ChartDemoKeys {
  /// Opens the chart workspace from the Storybook catalog.
  static const ValueKey<String> category = ValueKey('storybook-chart-category');

  /// The actual financial chart, including its selection details.
  static const ValueKey<String> chart = ValueKey('storybook-financial-chart');

  /// A named chart option, independent of its selected checkmark.
  static ValueKey<String> choice(String label) =>
      ValueKey('chart-choice-$label');

  /// Expands the drawing and workspace controls.
  static const ValueKey<String> drawings = ValueKey('chart-drawing-controls');

  /// Restores the saved session workspace.
  static const ValueKey<String> restore = ValueKey('chart-restore-workspace');

  /// Saves the current session workspace.
  static const ValueKey<String> save = ValueKey('chart-save-workspace');

  /// The page scroll view surrounding the chart and controls.
  static const ValueKey<String> scroll = ValueKey('charts-page-scroll');

  /// Visible feedback from drawing and workspace actions.
  static const ValueKey<String> status = ValueKey('chart-workspace-status');
}
