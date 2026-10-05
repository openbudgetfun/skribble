import 'dart:math' as math;

import 'package:path_parsing/path_parsing.dart';
import 'package:xml/xml.dart';

/// Palette tokens emoji art may use, by their art names.
///
/// Mirrors `EmojiToken` in `package:skribble_emoji`; a test in that package
/// keeps the two lists identical.
const List<String> kEmojiTokens = [
  'ink',
  'paper',
  'white',
  'black',
  'yellow',
  'yellow-shade',
  'orange',
  'orange-shade',
  'red',
  'red-shade',
  'coral',
  'pink',
  'pink-shade',
  'magenta',
  'purple',
  'purple-shade',
  'lilac',
  'blue',
  'blue-shade',
  'sky',
  'teal',
  'green',
  'green-shade',
  'leaf',
  'lime',
  'mint',
  'brown',
  'brown-shade',
  'tan',
  'cream',
  'grey',
  'grey-shade',
  'silver',
  'cheek',
  'skin',
  'skin-shade',
  'hair',
  'skin2',
  'skin2-shade',
  'hair2',
];

/// The variants a shape may be limited to.
const List<String> kEmojiVariants = ['person', 'man', 'woman'];

/// One compiled emoji shape in the 36-unit square.
final class CompiledShape {
  /// Creates a compiled shape.
  const CompiledShape({
    required this.d,
    this.fill,
    this.stroke,
    this.width = 2,
    this.part,
    this.variant,
    this.clip,
    this.evenOdd = false,
  });

  /// Absolute path data using only M, L, C, and Z.
  final String d;

  /// A palette token or `#rrggbb` literal, or null.
  final String? fill;

  /// A palette token or `#rrggbb` literal, or null.
  final String? stroke;

  /// Pen width in units of the 36-unit square.
  final double width;

  /// The named part, or null.
  final String? part;

  /// `person`, `man`, or `woman`, or null for every variant.
  final String? variant;

  /// Absolute clip path data, or null.
  final String? clip;

  /// Whether the shape fills with the even-odd rule.
  final bool evenOdd;

  /// A copy with token names replaced through [tokens].
  CompiledShape remap(Map<String, String> tokens) => CompiledShape(
    d: d,
    fill: tokens[fill] ?? fill,
    stroke: tokens[stroke] ?? stroke,
    width: width,
    part: part,
    variant: variant,
    clip: clip,
    evenOdd: evenOdd,
  );
}

/// Raised when emoji art breaks the authoring rules.
final class EmojiArtException implements Exception {
  /// Creates an exception about [art].
  const EmojiArtException(this.art, this.message);

  /// The art key.
  final String art;

  /// What is wrong.
  final String message;

  @override
  String toString() => 'Emoji art "$art": $message';
}

/// Compiles emoji art SVG sources into flat shape lists.
///
/// [sources] maps art keys (the file name without `.svg`) to SVG markup. Art
/// may include other art with `data-include`, so compile through one
/// compiler to share the cache.
final class EmojiArtCompiler {
  /// Creates a compiler over [sources].
  EmojiArtCompiler(this.sources);

  /// SVG markup by art key.
  final Map<String, String> sources;

  final Map<String, List<CompiledShape>> _cache = {};
  final Set<String> _compiling = {};

  /// The shapes for [key], in paint order.
  List<CompiledShape> compile(String key) {
    final cached = _cache[key];
    if (cached != null) return cached;
    final markup = sources[key];
    if (markup == null) {
      throw EmojiArtException(key, 'no such art');
    }
    if (!_compiling.add(key)) {
      throw EmojiArtException(key, 'includes itself');
    }
    try {
      final XmlDocument document;
      try {
        document = XmlDocument.parse(markup);
      } on XmlException catch (error) {
        throw EmojiArtException(key, 'invalid XML: ${error.message}');
      }
      final root = document.rootElement;
      if (root.getAttribute('viewBox')?.trim() != '0 0 36 36') {
        throw EmojiArtException(key, 'the viewBox must be "0 0 36 36"');
      }
      final clips = <String, XmlElement>{
        for (final element in document.findAllElements('clipPath'))
          if (element.getAttribute('id') case final id?) id: element,
      };
      final shapes = <CompiledShape>[];
      _walk(key, root, _Context.root(), clips, shapes);
      final warped = switch (root.getAttribute('data-warp')) {
        null => shapes,
        'flag' => _flag(shapes),
        final other => throw EmojiArtException(key, 'unknown warp "$other"'),
      };
      _validate(key, warped);
      return _cache[key] = List.unmodifiable(warped);
    } finally {
      _compiling.remove(key);
    }
  }

  void _walk(
    String key,
    XmlElement element,
    _Context context,
    Map<String, XmlElement> clips,
    List<CompiledShape> output,
  ) {
    final tag = element.name.local;
    if (tag == 'defs' || tag == 'clipPath' || tag == 'title' || tag == 'desc') {
      return;
    }
    final local = context.child(key, element, clips, this);
    if (element.getAttribute('data-include') case final include?) {
      // `data-as` draws the included art as one fixed variant, so a family
      // can include the same head as a man, a woman, and a child.
      final as = element.getAttribute('data-as');
      if (as != null && !kEmojiVariants.contains(as)) {
        throw EmojiArtException(key, 'unknown data-as "$as"');
      }
      for (final name in include.split(RegExp(r'\s+'))) {
        if (name.isEmpty) continue;
        for (final shape in compile(name)) {
          if (as != null && shape.variant != null && shape.variant != as) {
            continue;
          }
          output.add(
            CompiledShape(
              d: _transformData(shape.d, local.transform),
              fill: local.tokens[shape.fill] ?? shape.fill,
              stroke: local.tokens[shape.stroke] ?? shape.stroke,
              width: shape.width * local.transform.scale,
              part: shape.part ?? local.part,
              variant: as == null ? shape.variant ?? local.variant : null,
              clip: shape.clip == null
                  ? local.clip
                  : _transformData(shape.clip!, local.transform),
              evenOdd: shape.evenOdd,
            ),
          );
        }
      }
    }
    final data = _shapeData(key, element);
    if (data != null) {
      final fill = local.fill;
      final stroke = local.stroke;
      if (fill != null || stroke != null) {
        output.add(
          CompiledShape(
            d: _transformData(data, local.transform),
            fill: fill,
            stroke: stroke,
            width: local.strokeWidth * local.transform.scale,
            part: local.part,
            variant: local.variant,
            clip: local.clip,
            evenOdd: local.evenOdd,
          ),
        );
      }
    }
    for (final child in element.childElements) {
      _walk(key, child, local, clips, output);
    }
  }

  /// Path data for a drawable element in its own coordinates, or null.
  static String? _shapeData(String key, XmlElement element) {
    double number(String name, [double fallback = 0]) {
      final value = element.getAttribute(name);
      if (value == null) return fallback;
      return double.tryParse(value) ??
          (throw EmojiArtException(key, 'bad number $name="$value"'));
    }

    switch (element.name.local) {
      case 'path':
        return element.getAttribute('d');
      case 'circle':
        final r = number('r');
        return r <= 0 ? null : _ellipse(number('cx'), number('cy'), r, r);
      case 'ellipse':
        final rx = number('rx');
        final ry = number('ry');
        return rx <= 0 || ry <= 0
            ? null
            : _ellipse(number('cx'), number('cy'), rx, ry);
      case 'rect':
        final w = number('width');
        final h = number('height');
        if (w <= 0 || h <= 0) return null;
        var rx = number('rx', -1);
        var ry = number('ry', -1);
        if (rx < 0) rx = ry < 0 ? 0 : ry;
        if (ry < 0) ry = rx;
        return _rect(number('x'), number('y'), w, h, rx, ry);
      case 'line':
        return 'M${number('x1')} ${number('y1')}L${number('x2')} ${number('y2')}';
      case 'polyline':
      case 'polygon':
        final values = (element.getAttribute('points') ?? '')
            .trim()
            .split(RegExp(r'[\s,]+'))
            .where((value) => value.isNotEmpty)
            .map(double.parse)
            .toList();
        if (values.length < 4) return null;
        final buffer = StringBuffer('M${values[0]} ${values[1]}');
        for (var i = 2; i + 1 < values.length; i += 2) {
          buffer.write('L${values[i]} ${values[i + 1]}');
        }
        if (element.name.local == 'polygon') buffer.write('Z');
        return buffer.toString();
      default:
        return null;
    }
  }

  static String _ellipse(double cx, double cy, double rx, double ry) {
    const k = 0.5522847498307936;
    final ox = rx * k;
    final oy = ry * k;
    return 'M${cx + rx} $cy'
        'C${cx + rx} ${cy + oy} ${cx + ox} ${cy + ry} $cx ${cy + ry}'
        'C${cx - ox} ${cy + ry} ${cx - rx} ${cy + oy} ${cx - rx} $cy'
        'C${cx - rx} ${cy - oy} ${cx - ox} ${cy - ry} $cx ${cy - ry}'
        'C${cx + ox} ${cy - ry} ${cx + rx} ${cy - oy} ${cx + rx} ${cy}Z';
  }

  static String _rect(
    double x,
    double y,
    double w,
    double h,
    double rx,
    double ry,
  ) {
    final r = math.min(rx, w / 2);
    final s = math.min(ry, h / 2);
    if (r == 0 || s == 0) {
      return 'M$x ${y}L${x + w} ${y}L${x + w} ${y + h}L$x ${y + h}Z';
    }
    const k = 0.5522847498307936;
    return 'M${x + r} $y'
        'L${x + w - r} $y'
        'C${x + w - r + r * k} $y ${x + w} ${y + s - s * k} ${x + w} ${y + s}'
        'L${x + w} ${y + h - s}'
        'C${x + w} ${y + h - s + s * k} ${x + w - r + r * k} ${y + h} ${x + w - r} ${y + h}'
        'L${x + r} ${y + h}'
        'C${x + r - r * k} ${y + h} $x ${y + h - s + s * k} $x ${y + h - s}'
        'L$x ${y + s}'
        'C$x ${y + s - s * k} ${x + r - r * k} $y ${x + r} ${y}Z';
  }

  /// Bends a flat flag design (drawn in x 2–34, y 8–28) into waving cloth
  /// with an outline, and clips the design to it.
  static List<CompiledShape> _flag(List<CompiledShape> design) {
    (double, double) wave(double x, double y) {
      final t = ((x - 2) / 32).clamp(0.0, 1.0);
      return (x, y + 1.4 * math.sin(t * math.pi * 2 - 0.4) - 0.6 * t);
    }

    const cloth = 'M2 8L34 8L34 28L2 28Z';
    final clip = _mapData(_densify(cloth), wave);
    return [
      for (final shape in design)
        CompiledShape(
          d: _mapData(_densify(shape.d), wave),
          fill: shape.fill,
          stroke: shape.stroke,
          width: shape.width,
          part: shape.part ?? 'flag',
          variant: shape.variant,
          clip: clip,
          evenOdd: shape.evenOdd,
        ),
      CompiledShape(d: clip, stroke: 'ink', part: 'flag'),
    ];
  }

  void _validate(String key, List<CompiledShape> shapes) {
    if (shapes.isEmpty) throw EmojiArtException(key, 'draws nothing');
    for (final shape in shapes) {
      for (final paint in [shape.fill, shape.stroke]) {
        if (paint == null || kEmojiTokens.contains(paint)) continue;
        if (!RegExp(r'^#[0-9a-f]{6}$').hasMatch(paint)) {
          throw EmojiArtException(
            key,
            'unknown paint "$paint"; use a palette token or #rrggbb',
          );
        }
      }
      if (shape.stroke != null && shape.width < 0.75) {
        throw EmojiArtException(
          key,
          'stroke width ${shape.width} is thinner than 0.75 units',
        );
      }
    }
  }
}

/// Inherited paint and grouping state while walking art.
final class _Context {
  _Context({
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
    required this.transform,
    required this.part,
    required this.variant,
    required this.clip,
    required this.evenOdd,
    required this.tokens,
  });

  _Context.root()
    : fill = null,
      stroke = null,
      strokeWidth = 2,
      transform = const _Affine.identity(),
      part = null,
      variant = null,
      clip = null,
      evenOdd = false,
      tokens = const {};

  final String? fill;
  final String? stroke;
  final double strokeWidth;
  final _Affine transform;
  final String? part;
  final String? variant;
  final String? clip;
  final bool evenOdd;
  final Map<String, String> tokens;

  _Context child(
    String key,
    XmlElement element,
    Map<String, XmlElement> clips,
    EmojiArtCompiler compiler,
  ) {
    var remap = tokens;
    if (element.getAttribute('data-tokens') case final mapping?) {
      remap = {...tokens};
      for (final pair in mapping.split(',')) {
        final parts = pair.split(':').map((part) => part.trim()).toList();
        if (parts.length != 2) {
          throw EmojiArtException(key, 'bad data-tokens "$mapping"');
        }
        remap[parts[0]] = parts[1];
      }
    }

    String? paint(String name, String? inherited) {
      final value = element.getAttribute(name)?.trim();
      if (value == null) return inherited;
      if (value == 'none') return null;
      return remap[value] ?? value.toLowerCase();
    }

    final transform = this.transform.multiply(
      _Affine.parse(key, element.getAttribute('transform')),
    );
    final variant = element.getAttribute('data-variant') ?? this.variant;
    if (variant != null && !kEmojiVariants.contains(variant)) {
      throw EmojiArtException(key, 'unknown variant "$variant"');
    }
    String? clip = this.clip;
    if (element.getAttribute('clip-path') case final reference?) {
      final id = RegExp(r'^url\(#([^)]+)\)$').firstMatch(reference)?.group(1);
      final definition = clips[id];
      if (definition == null) {
        throw EmojiArtException(key, 'missing clip path "$reference"');
      }
      final parts = <String>[];
      for (final shape in definition.childElements) {
        final data = EmojiArtCompiler._shapeData(key, shape);
        if (data == null) continue;
        parts.add(
          _transformData(
            data,
            transform.multiply(
              _Affine.parse(key, shape.getAttribute('transform')),
            ),
          ),
        );
      }
      clip = parts.join();
    }
    final tag = element.name.local;
    final id =
        element.getAttribute('data-part') ??
        (tag == 'g' ? element.getAttribute('id') : null);
    final widthValue = element.getAttribute('stroke-width');
    return _Context(
      fill: paint('fill', fill),
      stroke: paint('stroke', stroke),
      strokeWidth: widthValue == null
          ? strokeWidth
          : double.tryParse(widthValue) ??
                (throw EmojiArtException(key, 'bad stroke-width')),
      transform: transform,
      part: id ?? part,
      variant: variant,
      clip: clip,
      evenOdd: switch (element.getAttribute('fill-rule')) {
        'evenodd' => true,
        'nonzero' => false,
        _ => evenOdd,
      },
      tokens: remap,
    );
  }
}

/// A 2D affine transform `[a c e; b d f]`.
final class _Affine {
  const _Affine(this.a, this.b, this.c, this.d, this.e, this.f);

  const _Affine.identity() : a = 1, b = 0, c = 0, d = 1, e = 0, f = 0;

  final double a;
  final double b;
  final double c;
  final double d;
  final double e;
  final double f;

  /// The average linear scale, applied to stroke widths.
  double get scale => math.sqrt((a * d - b * c).abs());

  bool get isIdentity =>
      a == 1 && b == 0 && c == 0 && d == 1 && e == 0 && f == 0;

  _Affine multiply(_Affine o) => _Affine(
    a * o.a + c * o.b,
    b * o.a + d * o.b,
    a * o.c + c * o.d,
    b * o.c + d * o.d,
    a * o.e + c * o.f + e,
    b * o.e + d * o.f + f,
  );

  (double, double) apply(double x, double y) =>
      (a * x + c * y + e, b * x + d * y + f);

  static _Affine parse(String key, String? value) {
    if (value == null || value.trim().isEmpty) return const _Affine.identity();
    var result = const _Affine.identity();
    for (final match in RegExp(
      r'(matrix|translate|scale|rotate|skewX|skewY)\s*\(([^)]*)\)',
    ).allMatches(value)) {
      final args = match
          .group(2)!
          .trim()
          .split(RegExp(r'[\s,]+'))
          .where((part) => part.isNotEmpty)
          .map(double.parse)
          .toList();
      final next = switch (match.group(1)) {
        'matrix' when args.length == 6 => _Affine(
          args[0],
          args[1],
          args[2],
          args[3],
          args[4],
          args[5],
        ),
        'translate' => _Affine(
          1,
          0,
          0,
          1,
          args[0],
          args.length > 1 ? args[1] : 0,
        ),
        'scale' => _Affine(
          args[0],
          0,
          0,
          args.length > 1 ? args[1] : args[0],
          0,
          0,
        ),
        'rotate' => _rotate(args),
        'skewX' => _Affine(1, 0, math.tan(args[0] * math.pi / 180), 1, 0, 0),
        'skewY' => _Affine(1, math.tan(args[0] * math.pi / 180), 0, 1, 0, 0),
        _ => throw EmojiArtException(key, 'bad transform "$value"'),
      };
      result = result.multiply(next);
    }
    return result;
  }

  static _Affine _rotate(List<double> args) {
    final radians = args[0] * math.pi / 180;
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    final rotation = _Affine(cos, sin, -sin, cos, 0, 0);
    if (args.length < 3) return rotation;
    return _Affine(
      1,
      0,
      0,
      1,
      args[1],
      args[2],
    ).multiply(rotation).multiply(_Affine(1, 0, 0, 1, -args[1], -args[2]));
  }
}

String _transformData(String data, _Affine transform) =>
    _mapData(data, transform.apply);

/// Rewrites path [data] as absolute M/L/C/Z, mapping every point.
String _mapData(String data, (double, double) Function(double, double) map) {
  final writer = _Writer(map);
  writeSvgPathDataToPath(data, writer);
  return writer.toString();
}

/// Splits long straight segments so a nonlinear warp can bend them.
String _densify(String data) {
  final writer = _Densifier();
  writeSvgPathDataToPath(data, writer);
  return writer.toString();
}

final class _Writer extends PathProxy {
  _Writer(this.map);

  final (double, double) Function(double, double) map;
  final StringBuffer _buffer = StringBuffer();

  static String _n(double value) {
    final rounded = (value * 100).round() / 100;
    final text = rounded.toStringAsFixed(2);
    final trimmed = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return trimmed == '-0' ? '0' : trimmed;
  }

  String _p(double x, double y) {
    final (mx, my) = map(x, y);
    return '${_n(mx)} ${_n(my)}';
  }

  @override
  void moveTo(double x, double y) => _buffer.write('M${_p(x, y)}');

  @override
  void lineTo(double x, double y) => _buffer.write('L${_p(x, y)}');

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => _buffer.write('C${_p(x1, y1)} ${_p(x2, y2)} ${_p(x3, y3)}');

  @override
  void close() => _buffer.write('Z');

  @override
  String toString() => _buffer.toString();
}

final class _Densifier extends PathProxy {
  final StringBuffer _buffer = StringBuffer();
  double _x = 0;
  double _y = 0;

  @override
  void moveTo(double x, double y) {
    _buffer.write('M$x $y');
    _x = x;
    _y = y;
  }

  @override
  void lineTo(double x, double y) {
    final steps = math.max(
      1,
      (math.sqrt(math.pow(x - _x, 2) + math.pow(y - _y, 2)) / 2).ceil(),
    );
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      _buffer.write('L${_x + (x - _x) * t} ${_y + (y - _y) * t}');
    }
    _x = x;
    _y = y;
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
    _buffer.write('C$x1 $y1 $x2 $y2 $x3 $y3');
    _x = x3;
    _y = y3;
  }

  @override
  void close() => _buffer.write('Z');

  @override
  String toString() => _buffer.toString();
}
