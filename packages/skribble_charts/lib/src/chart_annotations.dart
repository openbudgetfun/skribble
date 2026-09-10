import 'package:flutter/foundation.dart';
import 'package:skribble_charts/src/chart_data.dart';

/// A drawing mode supported by the chart editor.
enum WiredChartDrawingTool {
  /// Inspect the chart without adding drawings.
  none,

  /// Connect two points in time and price.
  trendLine,

  /// Mark one price across the visible chart.
  horizontalLine,

  /// Outline a time and price range.
  rectangle,

  /// Attach a label to a time and price.
  text,

  /// Draw retracement levels between two prices.
  fibonacci,
}

/// An exact market coordinate, independent of the chart viewport.
@immutable
final class WiredChartAnchor {
  /// Creates an anchor at [time] and [price], normalizing time to UTC.
  WiredChartAnchor({required DateTime time, required this.price})
    : time = time.toUtc();

  /// Parses the canonical format produced by [toJson].
  ///
  /// Throws [FormatException] for missing, malformed, or noncanonical fields.
  factory WiredChartAnchor.fromJson(Object? value) {
    final json = _object(value, 'anchor');
    final timestamp = _string(json, 'time');
    final price = _string(json, 'price');
    final time = DateTime.tryParse(timestamp);

    // Dart accepts overflowing days and months. Canonical round trips reject
    // those dates instead of silently attaching a drawing to another candle.
    if (time == null || !time.isUtc || time.toIso8601String() != timestamp) {
      throw const FormatException('Anchor time must be a canonical UTC date.');
    }

    return WiredChartAnchor(
      time: time,
      price: WiredChartDecimal.parse(price),
    );
  }

  /// The absolute market timestamp in UTC.
  final DateTime time;

  /// The exact source price, without conversion through a floating-point value.
  final WiredChartDecimal price;

  /// Encodes the UTC timestamp and exact decimal as strings.
  Map<String, Object?> toJson() => {
    'time': time.toIso8601String(),
    'price': price.toString(),
  };

  @override
  bool operator ==(Object other) =>
      other is WiredChartAnchor && time == other.time && price == other.price;

  @override
  int get hashCode => Object.hash(time, price);
}

/// An immutable drawing stored in market coordinates.
///
/// IDs must be nonempty and remain stable when an annotation is edited. Labels
/// are plain text. Persistence preserves decimal prices without rounding.
@immutable
sealed class WiredChartAnnotation {
  WiredChartAnnotation({required this.id, required this.label}) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
  }

  /// A stable identifier unique within its annotation collection.
  final String id;

  /// Plain text displayed alongside the drawing.
  final String label;

  /// The coordinates used by the drawing, in editing-handle order.
  List<WiredChartAnchor> get anchors;

  /// The tool that produces this annotation.
  WiredChartDrawingTool get tool;

  /// Returns a copy with the coordinate at [index] replaced by [anchor].
  ///
  /// Throws [RangeError] if [index] does not identify an editing handle.
  WiredChartAnnotation withAnchor(int index, WiredChartAnchor anchor);

  /// Encodes this drawing with exact decimal coordinates.
  Map<String, Object?> toJson() => {
    'id': id,
    'type': tool.name,
    'label': label,
    'anchors': anchors.map((anchor) => anchor.toJson()).toList(),
  };

  /// Decodes a supported drawing, rejecting invalid IDs, types, and anchors.
  ///
  /// Throws [FormatException] before returning any partially valid drawing.
  static WiredChartAnnotation fromJson(Object? value) {
    final json = _object(value, 'annotation');
    final id = _string(json, 'id');
    final label = _string(json, 'label');
    final type = _string(json, 'type');
    final rawAnchors = json['anchors'];

    if (id.trim().isEmpty) {
      throw const FormatException('Annotation ID must not be empty.');
    }

    if (rawAnchors is! List<Object?>) {
      throw const FormatException('Annotation anchors must be a list.');
    }

    final count = switch (type) {
      'trendLine' || 'rectangle' || 'fibonacci' => 2,
      'horizontalLine' || 'text' => 1,
      _ => throw FormatException('Unknown annotation type: $type.'),
    };

    if (rawAnchors.length != count) {
      throw FormatException('$type requires $count anchors.');
    }

    final anchors = rawAnchors.map(WiredChartAnchor.fromJson).toList();

    return switch (type) {
      'trendLine' => WiredChartTrendLine(
        id: id,
        start: anchors[0],
        end: anchors[1],
        label: label,
      ),
      'horizontalLine' => WiredChartHorizontalLine(
        id: id,
        anchor: anchors[0],
        label: label,
      ),
      'rectangle' => WiredChartRectangle(
        id: id,
        start: anchors[0],
        end: anchors[1],
        label: label,
      ),
      'text' => WiredChartText(id: id, anchor: anchors[0], label: label),
      'fibonacci' => WiredChartFibonacci(
        id: id,
        start: anchors[0],
        end: anchors[1],
        label: label,
      ),
      _ => throw FormatException('Unknown annotation type: $type.'),
    };
  }
}

/// A line segment joining two market coordinates.
final class WiredChartTrendLine extends WiredChartAnnotation {
  /// Creates a line with stable [id], [start], [end], and optional [label].
  WiredChartTrendLine({
    required super.id,
    required this.start,
    required this.end,
    super.label = '',
  });

  /// The first editing handle.
  final WiredChartAnchor start;

  /// The second editing handle.
  final WiredChartAnchor end;

  @override
  List<WiredChartAnchor> get anchors => List.unmodifiable([start, end]);

  @override
  WiredChartDrawingTool get tool => WiredChartDrawingTool.trendLine;

  @override
  WiredChartTrendLine withAnchor(int index, WiredChartAnchor anchor) {
    RangeError.checkValidIndex(index, anchors);

    return WiredChartTrendLine(
      id: id,
      start: index == 0 ? anchor : start,
      end: index == 1 ? anchor : end,
      label: label,
    );
  }
}

/// A price level extending across the chart viewport.
final class WiredChartHorizontalLine extends WiredChartAnnotation {
  /// Creates a level with stable [id], [anchor], and optional [label].
  WiredChartHorizontalLine({
    required super.id,
    required this.anchor,
    super.label = '',
  });

  /// The time and price used by the editing handle.
  final WiredChartAnchor anchor;

  @override
  List<WiredChartAnchor> get anchors => List.unmodifiable([anchor]);

  @override
  WiredChartDrawingTool get tool => WiredChartDrawingTool.horizontalLine;

  @override
  WiredChartHorizontalLine withAnchor(int index, WiredChartAnchor anchor) {
    RangeError.checkValidIndex(index, anchors);

    return WiredChartHorizontalLine(id: id, anchor: anchor, label: label);
  }
}

/// A rectangular range defined by two opposite market coordinates.
final class WiredChartRectangle extends WiredChartAnnotation {
  /// Creates a range with stable [id], [start], [end], and optional [label].
  WiredChartRectangle({
    required super.id,
    required this.start,
    required this.end,
    super.label = '',
  });

  /// One corner of the range.
  final WiredChartAnchor start;

  /// The opposite corner, which may precede [start] in either coordinate.
  final WiredChartAnchor end;

  @override
  List<WiredChartAnchor> get anchors => List.unmodifiable([start, end]);

  @override
  WiredChartDrawingTool get tool => WiredChartDrawingTool.rectangle;

  @override
  WiredChartRectangle withAnchor(int index, WiredChartAnchor anchor) {
    RangeError.checkValidIndex(index, anchors);

    return WiredChartRectangle(
      id: id,
      start: index == 0 ? anchor : start,
      end: index == 1 ? anchor : end,
      label: label,
    );
  }
}

/// A plain-text label attached to a market coordinate.
final class WiredChartText extends WiredChartAnnotation {
  /// Creates a [label] with stable [id] at [anchor].
  WiredChartText({
    required super.id,
    required this.anchor,
    required super.label,
  });

  /// The label's origin in market coordinates.
  final WiredChartAnchor anchor;

  @override
  List<WiredChartAnchor> get anchors => List.unmodifiable([anchor]);

  @override
  WiredChartDrawingTool get tool => WiredChartDrawingTool.text;

  @override
  WiredChartText withAnchor(int index, WiredChartAnchor anchor) {
    RangeError.checkValidIndex(index, anchors);

    return WiredChartText(id: id, anchor: anchor, label: label);
  }
}

/// Fibonacci retracement levels defined by two market coordinates.
///
/// Renderers interpolate the standard levels between [start] and [end]. The
/// anchors remain exact even when intermediate display coordinates are doubles.
final class WiredChartFibonacci extends WiredChartAnnotation {
  /// Creates retracements with stable [id], [start], [end], and optional [label].
  WiredChartFibonacci({
    required super.id,
    required this.start,
    required this.end,
    super.label = '',
  });

  /// The zero-percent retracement coordinate.
  final WiredChartAnchor start;

  /// The hundred-percent retracement coordinate.
  final WiredChartAnchor end;

  /// The standard retracement ratios, including both exact endpoints.
  static const levels = <double>[0, 0.236, 0.382, 0.5, 0.618, 0.786, 1];

  @override
  List<WiredChartAnchor> get anchors => List.unmodifiable([start, end]);

  @override
  WiredChartDrawingTool get tool => WiredChartDrawingTool.fibonacci;

  @override
  WiredChartFibonacci withAnchor(int index, WiredChartAnchor anchor) {
    RangeError.checkValidIndex(index, anchors);

    return WiredChartFibonacci(
      id: id,
      start: index == 0 ? anchor : start,
      end: index == 1 ? anchor : end,
      label: label,
    );
  }
}

/// Owns annotations, selection, and bounded history of completed edits.
///
/// Keep pointer-drag previews outside this controller, then call [update] once
/// when the edit completes. Selection changes notify listeners but do not create
/// undo entries. Undo and redo restore the selection captured with each edit.
/// The owner must call [dispose] when this controller is no longer needed.
final class WiredChartAnnotations extends ChangeNotifier {
  /// Creates an empty editor retaining at most [historyLimit] completed edits.
  ///
  /// A zero limit disables undo history. Negative values throw [ArgumentError].
  WiredChartAnnotations({this.historyLimit = 100}) {
    if (historyLimit < 0) {
      throw ArgumentError.value(historyLimit, 'historyLimit', 'Must be >= 0.');
    }
  }

  /// Maximum number of previous edit states retained in memory.
  final int historyLimit;

  _AnnotationState _state = const _AnnotationState([], null);
  final _undo = <_AnnotationState>[];
  final _redo = <_AnnotationState>[];
  bool _disposed = false;

  /// Whether the owner has disposed this editor.
  bool get isDisposed => _disposed;

  /// The drawings in paint order, exposed as an immutable snapshot.
  List<WiredChartAnnotation> get annotations => _state.annotations;

  /// The selected drawing's ID, or null when no drawing is selected.
  String? get selectedId => _state.selectedId;

  /// Whether there is a completed edit to undo.
  bool get canUndo => _undo.isNotEmpty;

  /// Whether an undone edit can be reapplied.
  bool get canRedo => _redo.isNotEmpty;

  /// Adds [annotation] as one edit, preserving the current selection.
  ///
  /// Throws [ArgumentError] if another drawing already uses its ID.
  void add(WiredChartAnnotation annotation) {
    _checkAlive();

    if (annotations.any((item) => item.id == annotation.id)) {
      throw ArgumentError.value(
        annotation.id,
        'annotation.id',
        'Duplicate ID.',
      );
    }

    _commit([...annotations, annotation], selectedId);
  }

  /// Replaces the drawing with [annotation]'s ID as one completed edit.
  ///
  /// Throws [ArgumentError] if the ID does not exist. Reusing the same instance
  /// is a no-op and preserves redo history.
  void update(WiredChartAnnotation annotation) {
    final index = _indexOf(annotation.id);

    if (identical(annotations[index], annotation)) {
      return;
    }

    final updated = [...annotations]..[index] = annotation;
    _commit(updated, selectedId);
  }

  /// Removes [id] as one edit and clears selection if that drawing was selected.
  ///
  /// Throws [ArgumentError] if [id] does not exist.
  void remove(String id) {
    final index = _indexOf(id);
    final updated = [...annotations]..removeAt(index);
    _commit(updated, selectedId == id ? null : selectedId);
  }

  /// Selects [id], or clears selection for null, without adding an undo entry.
  ///
  /// Throws [ArgumentError] if a nonnull ID does not exist.
  void select(String? id) {
    _checkAlive();

    if (id != null) {
      _indexOf(id);
    }

    if (id == selectedId) {
      return;
    }

    _state = _AnnotationState(annotations, id);
    notifyListeners();
  }

  /// Reverts the most recent completed edit, or does nothing when unavailable.
  void undo() {
    _checkAlive();

    if (!canUndo) {
      return;
    }

    _redo.add(_state);
    _state = _undo.removeLast();
    notifyListeners();
  }

  /// Reapplies the most recent undone edit, or does nothing when unavailable.
  void redo() {
    _checkAlive();

    if (!canRedo) {
      return;
    }

    _undo.add(_state);
    _state = _redo.removeLast();
    notifyListeners();
  }

  /// Atomically replaces all drawings and clears both undo and redo history.
  ///
  /// [annotations] is copied. [selectedId] must identify one of those drawings
  /// or be null. Duplicate IDs and missing selections throw [ArgumentError]
  /// without changing the editor.
  void replaceAll(
    Iterable<WiredChartAnnotation> annotations, {
    String? selectedId,
  }) {
    _checkAlive();
    final replacement = List<WiredChartAnnotation>.unmodifiable(annotations);
    _validateCollection(replacement, selectedId);
    _state = _AnnotationState(replacement, selectedId);
    _undo.clear();
    _redo.clear();
    notifyListeners();
  }

  /// Creates a version-1 persistence document including the current selection.
  ///
  /// The returned map is detached from the editor. Encode it with `jsonEncode`
  /// to store it. Undo history belongs to the editing session and is omitted.
  Map<String, Object?> exportDocument() => {
    'version': 1,
    'annotations': annotations.map((item) => item.toJson()).toList(),
    'selectedId': selectedId,
  };

  /// Restores a document produced by [exportDocument], clearing edit history.
  ///
  /// Accepts a decoded JSON object. Any malformed field, unsupported version,
  /// duplicate ID, or missing selection throws [FormatException] before mutation.
  void restore(Object? document) {
    final json = _object(document, 'document');
    final version = json['version'];
    final rawAnnotations = json['annotations'];
    final selection = json['selectedId'];

    if (version is! int || version != 1) {
      throw const FormatException('Unsupported annotation document version.');
    }

    if (rawAnnotations is! List<Object?>) {
      throw const FormatException('Document annotations must be a list.');
    }

    if (!json.containsKey('selectedId') ||
        (selection != null && selection is! String)) {
      throw const FormatException(
        'Document selectedId must be a string or null.',
      );
    }

    final restored = rawAnnotations.map(WiredChartAnnotation.fromJson).toList();
    final selectedId = selection as String?;
    final ids = restored.map((item) => item.id).toSet();

    if (ids.length != restored.length) {
      throw const FormatException('Duplicate annotation IDs.');
    }

    if (selectedId != null && !ids.contains(selectedId)) {
      throw const FormatException('Selected annotation does not exist.');
    }

    replaceAll(restored, selectedId: selectedId);
  }

  int _indexOf(String id) {
    _checkAlive();
    final index = annotations.indexWhere((item) => item.id == id);

    if (index < 0) {
      throw ArgumentError.value(id, 'id', 'Annotation does not exist.');
    }

    return index;
  }

  void _commit(List<WiredChartAnnotation> annotations, String? selectedId) {
    if (historyLimit > 0) {
      _undo.add(_state);

      if (_undo.length > historyLimit) {
        _undo.removeAt(0);
      }
    }

    _redo.clear();
    _state = _AnnotationState(List.unmodifiable(annotations), selectedId);
    notifyListeners();
  }

  void _checkAlive() {
    if (_disposed) {
      throw StateError('WiredChartAnnotations has been disposed.');
    }
  }

  @override
  void dispose() {
    _checkAlive();
    _disposed = true;
    _undo.clear();
    _redo.clear();
    super.dispose();
  }
}

final class _AnnotationState {
  const _AnnotationState(this.annotations, this.selectedId);

  final List<WiredChartAnnotation> annotations;
  final String? selectedId;
}

Map<String, Object?> _object(Object? value, String name) {
  if (value is! Map<String, Object?>) {
    throw FormatException('$name must be a JSON object.');
  }

  return value;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];

  if (value is! String) {
    throw FormatException('$key must be a string.');
  }

  return value;
}

void _validateCollection(
  List<WiredChartAnnotation> annotations,
  String? selectedId,
) {
  final ids = <String>{};

  for (final annotation in annotations) {
    if (!ids.add(annotation.id)) {
      throw ArgumentError.value(annotation.id, 'annotations', 'Duplicate ID.');
    }
  }

  if (selectedId != null && !ids.contains(selectedId)) {
    throw ArgumentError.value(selectedId, 'selectedId', 'Annotation missing.');
  }
}
