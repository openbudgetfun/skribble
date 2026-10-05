import 'dart:math' as math;
import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_emoji/src/emoji_catalog.dart';
import 'package:skribble_emoji/src/emoji_drawing.dart';
import 'package:skribble_emoji/src/emoji_motion.dart';
import 'package:skribble_emoji/src/emoji_motions.dart';
import 'package:skribble_emoji/src/emoji_palette.dart';

/// How many times a second the exported boil retraces the lines.
const double _boilRate = 8;

/// Builds a Lottie animation of [entry]: its motion, and its lines boiling.
///
/// The result is Lottie (Bodymovin 5.7) JSON as plain maps and lists, ready
/// for `jsonEncode`. It plays in the `lottie` Flutter package, lottie-web,
/// and the iOS and Android players. Rive's editor can import it as a
/// starting point on Rive's Enterprise plan.
///
/// The emoji is prepared at [detail] logical pixels (the wobble and pen are
/// tuned for that size by [config]) and scaled to a [size] canvas. [motion]
/// defaults to [EmojiMotions.of]; without one the animation is the boil
/// alone, over two seconds. [inkings] sets how many retraced inkings the
/// boil cycles through; 1 turns it off.
Map<String, Object?> emojiLottie(
  EmojiEntry entry, {
  required DrawConfig config,
  double size = 512,
  double detail = 72,
  int frameRate = 24,
  EmojiMotion? motion,
  EmojiPalette palette = EmojiPalette.skribble,
  double weight = 1,
  int inkings = 3,
}) {
  final chosen = motion ?? EmojiMotions.of(entry);
  final duration = chosen?.duration ?? const Duration(seconds: 2);
  final frames = math.max(
    1,
    (duration.inMicroseconds * frameRate / Duration.microsecondsPerSecond)
        .round(),
  );
  final vectors = [
    for (var inking = 0; inking < inkings; inking++)
      EmojiVector(
        entry,
        size: detail,
        config: config,
        palette: palette,
        weight: weight,
        inking: inking,
      ),
  ];
  // Painting needs part bounds for pivots, exactly as the widget uses them.
  final drawing = EmojiDrawing(
    entry,
    size: detail,
    config: config,
    palette: palette,
    weight: weight,
  );
  final builder = _LottieBuilder(
    frames: frames,
    frameRate: frameRate,
    unit: detail / kEmojiArtSize,
  );

  // The root scales the detailed drawing up to the canvas.
  final root = builder.nullLayer(
    'scale',
    parent: null,
    transform: _Transform.fixed(scale: size / detail * 100),
  );

  // Whole-emoji tracks wrap everything, one null layer each.
  final square = Offset.zero & Size.square(detail);
  var parent = root;
  final tracks = chosen?.tracks ?? const <EmojiTrack>[];
  final wholeOpacity = List<double>.filled(frames, 1);
  for (final track in tracks.where((track) => track.part == null)) {
    parent = builder.nullLayer(
      'emoji',
      parent: parent,
      transform: builder.track(track, track.pivot.withinRect(square)),
    );
    for (var frame = 0; frame < frames; frame++) {
      wholeOpacity[frame] *= track.move.at(frame / frames).opacity;
    }
  }

  // Each run of shapes sharing a part and clip becomes one shape layer,
  // parented through its part's tracks.
  final shapes = vectors.first.shapes;
  var start = 0;
  while (start < shapes.length) {
    var end = start + 1;
    while (end < shapes.length &&
        shapes[end].part == shapes[start].part &&
        shapes[end].clip == shapes[start].clip) {
      end++;
    }
    final part = shapes[start].part;
    var runParent = parent;
    final opacity = List<double>.of(wholeOpacity);
    final bounds = part == null ? null : drawing.boundsOf(part);
    if (part != null && bounds != null) {
      for (final track in tracks.where((track) => track.part == part)) {
        runParent = builder.nullLayer(
          part,
          parent: runParent,
          transform: builder.track(track, track.pivot.withinRect(bounds)),
        );
        for (var frame = 0; frame < frames; frame++) {
          opacity[frame] *= track.move.at(frame / frames).opacity;
        }
      }
    }
    builder.shapeLayer(
      part ?? 'shapes',
      parent: runParent,
      opacity: opacity,
      clip: shapes[start].clip,
      inkings: [
        for (final vector in vectors) vector.shapes.sublist(start, end),
      ],
      boilFrames: (frameRate / _boilRate).round(),
    );
    start = end;
  }

  return {
    'v': '5.7.0',
    'fr': frameRate,
    'ip': 0,
    'op': frames,
    'w': size.round(),
    'h': size.round(),
    'nm': entry.name,
    'ddd': 0,
    'assets': const <Object?>[],
    // Lottie draws the first layer on top.
    'layers': builder.layers.reversed.toList(),
  };
}

/// A Lottie transform: fixed, or sampled once per frame.
final class _Transform {
  _Transform.fixed({double scale = 100})
    : anchor = null,
      position = null,
      scale = null,
      rotation = null,
      fixedScale = scale;

  _Transform.sampled({
    required this.anchor,
    required this.position,
    required this.scale,
    required this.rotation,
  }) : fixedScale = 100;

  final Offset? anchor;
  final List<Offset>? position;
  final List<Offset>? scale;
  final List<double>? rotation;
  final double fixedScale;
}

final class _LottieBuilder {
  _LottieBuilder({
    required this.frames,
    required this.frameRate,
    required this.unit,
  });

  final int frames;
  final int frameRate;
  final double unit;
  final List<Map<String, Object?>> layers = [];

  int get _nextIndex => layers.length + 1;

  _Transform track(EmojiTrack track, Offset pivot) {
    final poses = [
      for (var frame = 0; frame < frames; frame++)
        track.move.at(frame / frames),
    ];
    return _Transform.sampled(
      anchor: pivot,
      position: [
        for (final pose in poses)
          Offset(pivot.dx + pose.dx * unit, pivot.dy + pose.dy * unit),
      ],
      scale: [
        for (final pose in poses) Offset(pose.scaleX * 100, pose.scaleY * 100),
      ],
      rotation: [for (final pose in poses) pose.rotation * 180 / math.pi],
    );
  }

  int nullLayer(
    String name, {
    required int? parent,
    required _Transform transform,
  }) {
    final index = _nextIndex;
    layers.add({
      'ddd': 0,
      'ind': index,
      'ty': 3,
      'nm': name,
      'parent': ?parent,
      'sr': 1,
      'ks': _layerTransform(transform),
      'ao': 0,
      'ip': 0,
      'op': frames,
      'st': 0,
      'bm': 0,
    });
    return index;
  }

  void shapeLayer(
    String name, {
    required int parent,
    required List<double> opacity,
    required String? clip,
    required List<List<EmojiVectorShape>> inkings,
    required int boilFrames,
  }) {
    final groups = <Map<String, Object?>>[];
    for (final (inking, shapes) in inkings.indexed) {
      groups.add(
        _group(
          [
            // Lottie draws earlier items on top, so paint order reverses.
            for (final shape in shapes.reversed) ..._shapeItems(shape),
          ],
          opacity: inkings.length == 1
              ? null
              : _boilOpacity(inking, inkings.length, boilFrames),
        ),
      );
    }
    layers.add({
      'ddd': 0,
      'ind': _nextIndex,
      'ty': 4,
      'nm': name,
      'parent': parent,
      'sr': 1,
      'ks': {
        ..._layerTransform(_Transform.fixed()),
        'o': _animated(
          [for (final value in opacity) value * 100],
          (value) => value,
        ),
      },
      'ao': 0,
      if (clip != null) 'hasMask': true,
      if (clip != null)
        'masksProperties': [
          for (final path in _paths(clip))
            {
              'inv': false,
              'mode': 'a',
              'pt': {'a': 0, 'k': path},
              'o': {'a': 0, 'k': 100},
              'x': {'a': 0, 'k': 0},
              'nm': 'clip',
            },
        ],
      'shapes': groups.reversed.toList(),
      'ip': 0,
      'op': frames,
      'st': 0,
      'bm': 0,
    });
  }

  /// Shows inking [inking] of [count] for [boilFrames] frames in turn.
  Map<String, Object?> _boilOpacity(int inking, int count, int boilFrames) {
    final keys = <Map<String, Object?>>[];
    for (var frame = 0; frame < frames; frame += boilFrames) {
      final visible = (frame ~/ boilFrames) % count == inking;
      keys.add({
        't': frame,
        's': [if (visible) 100 else 0],
        'h': 1,
      });
    }
    return {'a': 1, 'k': keys};
  }

  Map<String, Object?> _layerTransform(_Transform transform) => {
    'o': {'a': 0, 'k': 100},
    'r': transform.rotation == null
        ? {'a': 0, 'k': 0}
        : _animated(transform.rotation!, (value) => value),
    'p': transform.position == null
        ? {
            'a': 0,
            'k': [0, 0, 0],
          }
        : _animated(transform.position!, (value) => [value.dx, value.dy, 0]),
    'a': {
      'a': 0,
      'k': [transform.anchor?.dx ?? 0, transform.anchor?.dy ?? 0, 0],
    },
    's': transform.scale == null
        ? {
            'a': 0,
            'k': [transform.fixedScale, transform.fixedScale, 100],
          }
        : _animated(transform.scale!, (value) => [value.dx, value.dy, 100]),
  };

  /// A property sampled once per frame, with linear easing, collapsed to a
  /// constant when it never changes.
  Map<String, Object?> _animated<T>(List<T> values, Object Function(T) json) {
    if (values.every((value) => value == values.first)) {
      return {'a': 0, 'k': json(values.first)};
    }
    final keys = <Map<String, Object?>>[];
    for (var frame = 0; frame <= values.length; frame++) {
      // The final key repeats the first so the loop closes smoothly.
      final value = values[frame % values.length];
      final encoded = json(value);
      keys.add({
        't': frame,
        's': encoded is List ? encoded : [encoded],
        if (frame < values.length) ...{
          'i': {
            'x': [1],
            'y': [1],
          },
          'o': {
            'x': [0],
            'y': [0],
          },
        },
      });
    }
    return {'a': 1, 'k': keys};
  }

  static Map<String, Object?> _group(
    List<Map<String, Object?>> items, {
    Map<String, Object?>? opacity,
  }) => {
    'ty': 'gr',
    'it': [
      ...items,
      {
        'ty': 'tr',
        'p': {
          'a': 0,
          'k': [0, 0],
        },
        'a': {
          'a': 0,
          'k': [0, 0],
        },
        's': {
          'a': 0,
          'k': [100, 100],
        },
        'r': {'a': 0, 'k': 0},
        'o': opacity ?? {'a': 0, 'k': 100},
        'sk': {'a': 0, 'k': 0},
        'sa': {'a': 0, 'k': 0},
      },
    ],
  };

  /// The ink above the fill, as Lottie lists them.
  static List<Map<String, Object?>> _shapeItems(EmojiVectorShape shape) => [
    if (shape.ink case final ink?)
      _filled(ink, shape.inkColor!, evenOdd: false),
    if (shape.fill case final fill?)
      _filled(fill, shape.fillColor!, evenOdd: shape.evenOdd),
  ];

  static Map<String, Object?> _filled(
    String data,
    Color color, {
    required bool evenOdd,
  }) => _group([
    for (final path in _paths(data))
      {
        'ty': 'sh',
        'ks': {'a': 0, 'k': path},
      },
    {
      'ty': 'fl',
      'c': {
        'a': 0,
        'k': [color.r, color.g, color.b, 1],
      },
      'o': {'a': 0, 'k': color.a * 100},
      'r': evenOdd ? 2 : 1,
    },
  ]);

  /// Lottie paths (`{c, v, i, o}`) for SVG path [data], one per contour.
  static List<Map<String, Object?>> _paths(String data) {
    final writer = _LottiePathWriter();
    writeSvgPathDataToPath(data, writer);
    return writer.finish();
  }
}

/// Collects SVG path commands as Lottie vertices with relative tangents.
final class _LottiePathWriter extends PathProxy {
  final List<Map<String, Object?>> _paths = [];
  List<List<double>> _v = [];
  List<List<double>> _i = [];
  List<List<double>> _o = [];
  bool _closed = false;

  static double _round(double value) => (value * 100).roundToDouble() / 100;

  void _flush() {
    if (_v.isEmpty) return;
    // A closed contour that returns to its start repeats the first vertex;
    // Lottie closes the loop itself, so fold the last segment onto it.
    if (_closed && _v.length > 1) {
      final first = _v.first;
      final last = _v.last;
      if ((first[0] - last[0]).abs() < .01 &&
          (first[1] - last[1]).abs() < .01) {
        _i[0] = _i.last;
        _v.removeLast();
        _i.removeLast();
        _o.removeLast();
      }
    }
    _paths.add({'c': _closed, 'v': _v, 'i': _i, 'o': _o});
    _v = [];
    _i = [];
    _o = [];
    _closed = false;
  }

  List<Map<String, Object?>> finish() {
    _flush();
    return _paths;
  }

  @override
  void moveTo(double x, double y) {
    _flush();
    _v.add([_round(x), _round(y)]);
    _i.add([0, 0]);
    _o.add([0, 0]);
  }

  @override
  void lineTo(double x, double y) {
    _v.add([_round(x), _round(y)]);
    _i.add([0, 0]);
    _o.add([0, 0]);
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    final from = _v.last;
    _o[_o.length - 1] = [_round(x1 - from[0]), _round(y1 - from[1])];
    _v.add([_round(x3), _round(y3)]);
    _i.add([_round(x2 - x3), _round(y2 - y3)]);
    _o.add([0, 0]);
  }

  @override
  void close() => _closed = true;
}
