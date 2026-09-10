import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_controller.dart';
import 'package:skribble_charts/src/chart_data.dart';
import 'package:skribble_charts/src/chart_geometry.dart';
import 'package:skribble_charts/src/chart_indicators.dart';
import 'package:skribble_charts/src/chart_painter.dart';
import 'package:skribble_charts/src/chart_theme.dart';

/// A financial chart with exact price geometry and restrained ink texture.
///
/// Give the chart bounded width and height. The caller owns [controller] and
/// any supplied [annotations]. Data updates never enter annotation undo history.
/// Drag to pan, pinch or scroll to zoom, and tap or long press to inspect.
/// Drawing tools use one tap for levels/text and two taps for other shapes.
class WiredFinancialChart extends HookWidget {
  /// Creates a chart backed by the caller's data and viewport controller.
  const WiredFinancialChart({
    required this.controller,
    this.annotations,
    this.series = WiredPriceSeries.candlesticks,
    this.scale = WiredChartPriceScale.linear,
    this.overlays = const [],
    this.panes = const [],
    this.style = const WiredChartStyle(),
    this.tool = WiredChartDrawingTool.none,
    this.annotationLabel = '',
    this.semanticLabel = 'Financial chart',
    this.showSelectionDetails = true,
    this.onCandleSelected,
    this.onAnnotationCreated,
    super.key,
  });

  /// Caller-owned history, viewport, and candle selection.
  final WiredChartController controller;

  /// Caller-owned drawings, or a widget-local editor when omitted.
  final WiredChartAnnotations? annotations;

  /// How prices are represented.
  final WiredPriceSeries series;

  /// Coordinate transform for the price pane.
  final WiredChartPriceScale scale;

  /// Indicators drawn on the price pane.
  final List<WiredChartIndicator> overlays;

  /// Additional panes sharing the same time coordinates.
  final List<WiredChartPane> panes;

  /// Explicit, independent chart colors and texture policy.
  final WiredChartStyle style;

  /// Active drawing tool. Normal navigation uses [WiredChartDrawingTool.none].
  final WiredChartDrawingTool tool;

  /// Text attached to newly created annotations. Empty text becomes `Note`.
  final String annotationLabel;

  /// Accessible chart name, normally including the instrument and quote unit.
  final String semanticLabel;

  /// Whether to show exact selected OHLC values below the plot.
  final bool showSelectionDetails;

  /// Called when user interaction selects a candle.
  final ValueChanged<WiredChartCandle?>? onCandleSelected;

  /// Called after a complete drawing is added to the annotation editor.
  final ValueChanged<WiredChartAnnotation>? onAnnotationCreated;

  @override
  Widget build(BuildContext context) {
    final editor = useMemoized(
      () => annotations ?? WiredChartAnnotations(),
      [annotations],
    );
    useEffect(() {
      final borrowed = annotations != null;
      return () {
        if (!borrowed) editor.dispose();
      };
    }, [editor]);
    useListenable(controller);
    final index = controller.selectedIndex;
    final selected = index == null ? null : controller.candles[index];
    final description = selected == null
        ? '${controller.instrument.id}. ${controller.candles.length} candles.'
        : _describeCandle(controller.instrument.id, selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (!constraints.hasBoundedWidth ||
                  !constraints.hasBoundedHeight) {
                throw FlutterError(
                  'WiredFinancialChart needs a bounded width and height.',
                );
              }

              return _ChartCanvas(
                chart: this,
                editor: editor,
                size: constraints.biggest,
                description: description,
              );
            },
          ),
        ),
        if (showSelectionDetails)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              description,
              key: const ValueKey('chart-selection-details'),
              style: TextStyle(color: style.foreground, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _ChartCanvas extends HookWidget {
  const _ChartCanvas({
    required this.chart,
    required this.editor,
    required this.size,
    required this.description,
  });

  final WiredFinancialChart chart;
  final WiredChartAnnotations editor;
  final Size size;
  final String description;

  @override
  Widget build(BuildContext context) {
    final controller = chart.controller;
    useListenable(editor);
    final focus = useFocusNode();
    final pending = useState<WiredChartAnchor?>(null);
    final preview = useState<WiredChartAnnotation?>(null);
    final editing = useRef<({WiredChartAnnotation drawing, int handle})?>(null);
    final gestureOrigin = useRef(Offset.zero);
    final gestureFirst = useRef<double>(0);
    final gestureCount = useRef<double>(60);
    final pointers = useRef<Map<int, Offset>>({});
    final nextId = useRef(0);
    useEffect(() {
      pending.value = null;
      preview.value = null;
      editing.value = null;
      return null;
    }, [chart.tool, controller, chart.scale, editor]);
    useEffect(() {
      final edit = editing.value;
      if (edit != null &&
          (editor.selectedId != edit.drawing.id ||
              !editor.annotations.any(
                (drawing) => identical(drawing, edit.drawing),
              ))) {
        preview.value = null;
        editing.value = null;
      }
      return null;
    }, [editor.annotations, editor.selectedId]);
    final drawings = useMemoized(
      () => [
        for (final drawing in editor.annotations)
          if (drawing.id != preview.value?.id &&
              (chart.scale != WiredChartPriceScale.logarithmic ||
                  drawing.anchors.every(
                    (anchor) => anchor.price > WiredChartDecimal.zero,
                  )))
            drawing,
        ?preview.value,
      ],
      [editor.annotations, preview.value, chart.scale],
    );
    final textStyle = DefaultTextStyle.of(context).style;
    final scene = useMemoized(
      () => ChartScene(
        candles: controller.candles,
        instrument: controller.instrument,
        firstVisible: controller.firstVisible,
        visibleCount: controller.visibleCount,
        size: size,
        series: chart.series,
        scale: chart.scale,
        percentageReference: controller.percentageReference,
        style: chart.style,
        overlays: chart.overlays,
        panes: chart.panes,
        annotations: drawings,
        textStyle: textStyle,
      ),
      [
        controller,
        controller.dataRevision,
        controller.percentageReference,
        controller.firstVisible,
        controller.visibleCount,
        size,
        chart.series,
        chart.scale,
        chart.style,
        chart.overlays,
        chart.panes,
        drawings,
        textStyle,
      ],
    );
    // Gesture recognition begins after touch slop. Keep the actual initial
    // centroid so zoom does not drift and an editing handle remains hittable.
    void resetGestureOrigin() {
      if (pointers.value.isEmpty) return;
      gestureOrigin.value =
          pointers.value.values.reduce((a, b) => a + b) /
          pointers.value.length.toDouble();
      gestureFirst.value = controller.firstVisible;
      gestureCount.value = controller.visibleCount;
    }

    ({WiredChartAnnotation drawing, int handle})? handleAt(Offset point) {
      if (chart.tool != WiredChartDrawingTool.none) return null;
      final selected = drawings
          .where((drawing) => drawing.id == editor.selectedId)
          .firstOrNull;
      if (selected == null) return null;

      for (var index = 0; index < selected.anchors.length; index++) {
        if ((scene.positionForAnchor(selected.anchors[index]) - point)
                .distance <=
            22) {
          return (drawing: selected, handle: index);
        }
      }
      return null;
    }

    void finishEdit() {
      final changed = preview.value;
      final edit = editing.value;
      if (changed != null &&
          edit != null &&
          editor.selectedId == edit.drawing.id &&
          editor.annotations.any(
            (drawing) => identical(drawing, edit.drawing),
          )) {
        editor.update(changed);
      }
      editing.value = null;
      preview.value = null;
    }

    void inspect(double x) {
      final index = scene.indexForX(x);
      if (index == controller.selectedIndex) return;
      controller.selectIndex(index);
      chart.onCandleSelected?.call(
        index == null ? null : controller.candles[index],
      );
    }

    WiredChartAnchor anchorAt(Offset point) => WiredChartAnchor(
      time: scene.timeForX(
        point.dx.clamp(scene.priceRect.left, scene.priceRect.right),
      ),
      price: scene.priceForY(
        point.dy.clamp(scene.priceRect.top, scene.priceRect.bottom),
      ),
    );

    void zoom(double factor, double anchor) {
      controller.zoom(factor, anchorFraction: anchor);
    }

    void tap(Offset point) {
      focus.requestFocus();
      if (controller.candles.isEmpty || !scene.priceRect.contains(point)) {
        return;
      }
      inspect(point.dx);

      if (chart.tool == WiredChartDrawingTool.none) {
        editor.select(_hitDrawing(scene, drawings, point)?.id);
        return;
      }

      final anchor = anchorAt(point);
      final single =
          chart.tool == WiredChartDrawingTool.horizontalLine ||
          chart.tool == WiredChartDrawingTool.text;
      if (!single && pending.value == null) {
        pending.value = anchor;
        return;
      }

      String id;
      do {
        id = 'drawing-${controller.instrument.id}-${nextId.value++}';
      } while (editor.annotations.any((annotation) => annotation.id == id));
      final drawing = _newDrawing(
        chart.tool,
        id,
        pending.value ?? anchor,
        anchor,
        chart.annotationLabel,
      );
      editor
        ..add(drawing)
        ..select(drawing.id);
      pending.value = null;
      chart.onAnnotationCreated?.call(drawing);
    }

    KeyEventResult keyEvent(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
        return KeyEventResult.ignored;
      }
      final key = event.logicalKey;
      final keyboard = HardwareKeyboard.instance;
      final command = keyboard.isControlPressed || keyboard.isMetaPressed;

      if (command && key == LogicalKeyboardKey.keyZ) {
        keyboard.isShiftPressed ? editor.redo() : editor.undo();
      } else if (command && key == LogicalKeyboardKey.keyY) {
        editor.redo();
      } else if (key == LogicalKeyboardKey.escape) {
        pending.value = null;
        preview.value = null;
        editing.value = null;
        editor.select(null);
      } else if (key == LogicalKeyboardKey.delete ||
          key == LogicalKeyboardKey.backspace) {
        editing.value = null;
        preview.value = null;
        final id = editor.selectedId;
        if (id != null) editor.remove(id);
      } else if (key == LogicalKeyboardKey.end) {
        controller.scrollToLatest();
      } else if (key == LogicalKeyboardKey.equal ||
          key == LogicalKeyboardKey.add) {
        zoom(1.25, .5);
      } else if (key == LogicalKeyboardKey.minus ||
          key == LogicalKeyboardKey.numpadSubtract) {
        zoom(.8, .5);
      } else if (key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowRight) {
        if (controller.candles.isEmpty) return KeyEventResult.handled;
        final delta = key == LogicalKeyboardKey.arrowLeft ? -1 : 1;
        final next =
            ((controller.selectedIndex ?? controller.candles.length - 1) +
                    delta)
                .clamp(0, controller.candles.length - 1);
        controller.selectIndex(next);
        if (next < controller.firstVisible ||
            next >= controller.firstVisible + controller.visibleCount) {
          controller.setViewport(
            next - controller.visibleCount / 2,
            controller.visibleCount,
          );
        }
        chart.onCandleSelected?.call(controller.candles[next]);
      } else {
        return KeyEventResult.ignored;
      }

      return KeyEventResult.handled;
    }

    String zoomDescription(double count) =>
        '$description ${count.toStringAsFixed(1)} visible candle slots.';

    return Semantics(
      label: chart.semanticLabel,
      value: zoomDescription(controller.visibleCount),
      increasedValue: zoomDescription(
        (controller.visibleCount / 1.25).clamp(1.0, 1000000.0),
      ),
      decreasedValue: zoomDescription(
        (controller.visibleCount / .8).clamp(1.0, 1000000.0),
      ),
      hint: 'Drag to pan. Pinch to zoom. Tap to inspect. Arrow keys select candles.',
      onIncrease: controller.visibleCount > 1 ? () => zoom(1.25, .5) : null,
      onDecrease: controller.visibleCount < 1000000 ? () => zoom(.8, .5) : null,
      child: Focus(
        focusNode: focus,
        onKeyEvent: keyEvent,
        child: Listener(
          onPointerDown: (event) {
            pointers.value[event.pointer] = event.localPosition;
            resetGestureOrigin();
          },
          onPointerMove: (event) {
            pointers.value[event.pointer] = event.localPosition;
          },
          onPointerUp: (event) {
            pointers.value.remove(event.pointer);
            resetGestureOrigin();
          },
          onPointerCancel: (event) {
            pointers.value.remove(event.pointer);
            resetGestureOrigin();
          },
          onPointerPanZoomStart: (event) {
            gestureOrigin.value = event.localPosition;
            gestureFirst.value = controller.firstVisible;
            gestureCount.value = controller.visibleCount;
          },
          onPointerSignal: (event) {
            if (event is! PointerScrollEvent ||
                !scene.priceRect.contains(event.localPosition)) {
              return;
            }
            GestureBinding.instance.pointerSignalResolver.register(event, (_) {
              final anchor =
                  ((event.localPosition.dx - scene.priceRect.left) /
                          scene.priceRect.width)
                      .clamp(0.0, 1.0);
              zoom(
                math.exp(-event.scrollDelta.dy.clamp(-200.0, 200.0) * .003),
                anchor,
              );
            });
          },
          child: MouseRegion(
            cursor: chart.tool == WiredChartDrawingTool.none
                ? SystemMouseCursors.precise
                : SystemMouseCursors.precise,
            onHover: (event) {
              if (scene.priceRect.contains(event.localPosition)) {
                inspect(event.localPosition.dx);
              }
            },
            child: RawGestureDetector(
              gestures: {
                _ChartHandleDragGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      _ChartHandleDragGestureRecognizer
                    >(
                      _ChartHandleDragGestureRecognizer.new,
                      (recognizer) {
                        recognizer
                          ..isHandle = ((point) => handleAt(point) != null)
                          // Match the parent scroll drag threshold only when
                          // this pointer starts on a selected editing handle.
                          ..gestureSettings = DeviceGestureSettings(
                            touchSlop:
                                (MediaQuery.maybeGestureSettingsOf(context)
                                        ?.touchSlop ??
                                    kTouchSlop) /
                                2,
                          )
                          ..dragStartBehavior = DragStartBehavior.down
                          ..onStart = (_) {
                            focus.requestFocus();
                            editing.value = handleAt(gestureOrigin.value);
                          }
                          ..onUpdate = (details) {
                            final edit = editing.value;
                            if (edit == null) return;
                            preview.value = edit.drawing.withAnchor(
                              edit.handle,
                              anchorAt(details.localPosition),
                            );
                          }
                          ..onEnd = (_) {
                            finishEdit();
                          }
                          ..onCancel = () {
                            editing.value = null;
                            preview.value = null;
                          };
                      },
                    ),
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                dragStartBehavior: DragStartBehavior.down,
                onTapUp: (details) => tap(details.localPosition),
                onLongPressStart: (details) =>
                    inspect(details.localPosition.dx),
                onLongPressMoveUpdate: (details) =>
                    inspect(details.localPosition.dx),
                onScaleStart: (details) {
                  focus.requestFocus();
                  editing.value = handleAt(gestureOrigin.value);
                },
                onScaleUpdate: (details) {
                  final edit = editing.value;
                  if (edit != null) {
                    preview.value = edit.drawing.withAnchor(
                      edit.handle,
                      anchorAt(details.localFocalPoint),
                    );
                    return;
                  }
                  if (chart.tool != WiredChartDrawingTool.none ||
                      scene.priceRect.width <= 0) {
                    return;
                  }
                  final anchor =
                      ((gestureOrigin.value.dx - scene.priceRect.left) /
                              scene.priceRect.width)
                          .clamp(0.0, 1.0);
                  final count = (gestureCount.value / details.scale).clamp(
                    1.0,
                    1000000.0,
                  );
                  final moved =
                      (details.localFocalPoint.dx - gestureOrigin.value.dx) /
                      scene.priceRect.width *
                      count;
                  controller.setViewport(
                    gestureFirst.value +
                        anchor * (gestureCount.value - count) -
                        moved,
                    count,
                  );
                },
                onScaleEnd: (_) => finishEdit(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        key: const ValueKey('chart-plot'),
                        painter: ChartPainter(scene),
                      ),
                    ),
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _InteractionPainter(
                            scene: scene,
                            selected: controller.selectedIndex,
                            drawing: drawings
                                .where(
                                  (drawing) => drawing.id == editor.selectedId,
                                )
                                .firstOrNull,
                            pending: pending.value,
                          ),
                        ),
                      ),
                    ),
                    if (pending.value != null)
                      Positioned(
                        left: 8,
                        top: 4,
                        child: Text(
                          'Tap the second point',
                          style: TextStyle(
                            color: chart.style.foreground,
                            backgroundColor: chart.style.background,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Joins the gesture arena only for pointers that start on an editing handle.
class _ChartHandleDragGestureRecognizer extends PanGestureRecognizer {
  late bool Function(Offset) isHandle;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      isHandle(event.localPosition) && super.isPointerAllowed(event);
}

String _describeCandle(String instrument, WiredChartCandle candle) =>
    '$instrument · ${candle.time.toIso8601String()} · '
    'O ${candle.open}  H ${candle.high}  L ${candle.low}  C ${candle.close}  V ${candle.volume}';

WiredChartAnnotation _newDrawing(
  WiredChartDrawingTool tool,
  String id,
  WiredChartAnchor start,
  WiredChartAnchor end,
  String label,
) => switch (tool) {
  WiredChartDrawingTool.trendLine => WiredChartTrendLine(
    id: id,
    start: start,
    end: end,
    label: label,
  ),
  WiredChartDrawingTool.horizontalLine => WiredChartHorizontalLine(
    id: id,
    anchor: end,
    label: label,
  ),
  WiredChartDrawingTool.rectangle => WiredChartRectangle(
    id: id,
    start: start,
    end: end,
    label: label,
  ),
  WiredChartDrawingTool.text => WiredChartText(
    id: id,
    anchor: end,
    label: label.isEmpty ? 'Note' : label,
  ),
  WiredChartDrawingTool.fibonacci => WiredChartFibonacci(
    id: id,
    start: start,
    end: end,
    label: label,
  ),
  WiredChartDrawingTool.none => throw StateError('No drawing tool selected.'),
};

WiredChartAnnotation? _hitDrawing(
  ChartScene scene,
  List<WiredChartAnnotation> drawings,
  Offset point,
) {
  for (final drawing in drawings.reversed) {
    final first = scene.positionForAnchor(drawing.anchors.first);
    if (drawing is WiredChartHorizontalLine &&
        (first.dy - point.dy).abs() < 14) {
      return drawing;
    }
    if (drawing is WiredChartText &&
        Rect.fromLTWH(
          first.dx - 10,
          first.dy - 20,
          math.max(44, drawing.label.length * 8),
          36,
        ).contains(point)) {
      return drawing;
    }
    if (drawing.anchors.any(
      (anchor) => (scene.positionForAnchor(anchor) - point).distance < 20,
    )) {
      return drawing;
    }
    if (drawing.anchors.length < 2) continue;
    final second = scene.positionForAnchor(drawing.anchors.last);
    if (drawing is WiredChartRectangle &&
        Rect.fromPoints(first, second).inflate(10).contains(point)) {
      return drawing;
    }
    if (_segmentDistance(point, first, second) < 14) return drawing;
    if (drawing is WiredChartFibonacci) {
      for (final level in WiredChartFibonacci.levels) {
        final price = drawing.anchors.first.price.interpolate(
          drawing.anchors.last.price,
          level,
        );
        final y = scene.yForPrice(price);
        if ((point.dy - y).abs() < 10 &&
            point.dx >= math.min(first.dx, second.dx) - 10 &&
            point.dx <= math.max(first.dx, second.dx) + 10) {
          return drawing;
        }
      }
    }
  }

  return null;
}

double _segmentDistance(Offset point, Offset start, Offset end) {
  final span = end - start;
  if (span.distanceSquared == 0) return (point - start).distance;
  final fraction =
      (((point.dx - start.dx) * span.dx + (point.dy - start.dy) * span.dy) /
              span.distanceSquared)
          .clamp(0.0, 1.0);
  return (point - (start + span * fraction)).distance;
}

class _InteractionPainter extends CustomPainter {
  _InteractionPainter({
    required this.scene,
    required this.selected,
    required this.drawing,
    required this.pending,
  });

  final ChartScene scene;
  final int? selected;
  final WiredChartAnnotation? drawing;
  final WiredChartAnchor? pending;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scene.style.foreground.withValues(alpha: .6)
      ..strokeWidth = 1;
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    final index = selected;
    if (index != null && index < scene.candles.length) {
      final candle = scene.candles[index];
      final x = scene.xForTime(candle.time);
      if (x >= scene.priceRect.left && x <= scene.priceRect.right) {
        final y = scene.yForPrice(candle.close);
        canvas
          ..drawLine(
            Offset(x, scene.priceRect.top),
            Offset(x, size.height - 24),
            paint,
          )
          ..save()
          ..clipRect(scene.priceRect)
          ..drawLine(
            Offset(scene.priceRect.left, y),
            Offset(scene.priceRect.right, y),
            paint,
          )
          ..drawCircle(Offset(x, y), 3, paint)
          ..restore();
      }
    }

    for (final anchor in [...?drawing?.anchors, ?pending]) {
      final point = scene.positionForAnchor(anchor);
      canvas
        ..drawCircle(point, 6, Paint()..color = scene.style.background)
        ..drawCircle(
          point,
          6,
          Paint()
            ..color = scene.style.foreground
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InteractionPainter oldDelegate) =>
      scene != oldDelegate.scene ||
      selected != oldDelegate.selected ||
      drawing != oldDelegate.drawing ||
      pending != oldDelegate.pending;
}
