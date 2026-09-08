import 'dart:io';

import 'package:xml/xml.dart';

import 'svg_transform.dart';

/// A resolved SVG shape: path data + effective paint attributes.
class SvgShape {
  /// Creates a shape after resolving SVG paint, transforms, and clipping.
  SvgShape(
    this.data,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth,
    this.evenOdd, [
    this.clipPaths = const [],
    this.strokeDashArray = const [],
    this.strokeDashOffset = 0,
    this.strokeCap = 'butt',
    this.strokeJoin = 'miter',
    this.strokeMiterLimit = 4,
  ]);

  /// Whether the shape uses the even-odd fill rule.
  final bool evenOdd;

  /// Resolved clipping paths in the same coordinate space.
  final List<String> clipPaths;

  /// Transformed and gently warped SVG path data.
  final String data;

  /// Fill color, including optional alpha, or null for no fill.
  final String? fillColor;

  /// Stroke color, including optional alpha, or null for no stroke.
  final String? strokeColor;

  /// Stroke width in the transformed coordinate space.
  final double strokeWidth;

  /// Alternating painted and unpainted stroke lengths.
  final List<double> strokeDashArray;

  /// Dash phase in transformed coordinates.
  final double strokeDashOffset;

  /// SVG stroke-linecap value.
  final String strokeCap;

  /// SVG stroke-linejoin value.
  final String strokeJoin;

  /// SVG stroke-miterlimit value.
  final double strokeMiterLimit;
}

/// Resolves drawable shapes from a source SVG file.
/// Missing or malformed XML returns an empty list; unsupported features throw.
List<SvgShape> extractShapes(String svgFile) {
  final file = File(svgFile);
  if (!file.existsSync()) return [];

  XmlDocument doc;
  try {
    doc = XmlDocument.parse(file.readAsStringSync());
  } on XmlParserException {
    return [];
  }

  final shapes = <SvgShape>[];
  final definitions = <String, XmlElement>{
    for (final element in doc.findAllElements('clipPath'))
      element.getAttribute('id')!: element,
  };
  _processElement(doc.rootElement, shapes, _PaintContext(), definitions);
  return shapes;
}

/// Effective fill/stroke state, resolving SVG group inheritance.
class _PaintContext {
  String? fill; // null = default (black), 'none' = no fill
  String? stroke; // null or 'none' = no stroke
  double strokeWidth = 1;
  SvgTransform transform = const SvgTransform();
  bool evenOdd = false;

  List<String> clipPaths = const [];
  double fillOpacity = 1;
  double strokeOpacity = 1;
  List<double> dashArray = const [];
  double dashOffset = 0;
  String strokeCap = 'butt';
  String strokeJoin = 'miter';
  double miterLimit = 4;
  String paintOrder = 'normal';
  String visibility = 'visible';
}

void _processElement(
  XmlElement element,
  List<SvgShape> shapes,
  _PaintContext parent,
  Map<String, XmlElement> definitions,
) {
  final tag = element.name.local;
  if (tag == 'defs' || element.getAttribute('display') == 'none') return;
  final visibility = element.getAttribute('visibility') ?? parent.visibility;
  final dash = element.getAttribute('stroke-dasharray');
  final dashArray = dash == null
      ? parent.dashArray
      : dash == 'none'
      ? <double>[]
      : dash.trim().split(RegExp(r'[\s,]+')).map(double.parse).toList();
  if (dashArray.any((value) => !value.isFinite || value < 0)) {
    throw const FormatException('Invalid SVG dash array.');
  }
  final dashOffset =
      double.tryParse(element.getAttribute('stroke-dashoffset') ?? '') ??
      parent.dashOffset;
  final strokeCap = element.getAttribute('stroke-linecap') ?? parent.strokeCap;
  final strokeJoin =
      element.getAttribute('stroke-linejoin') ?? parent.strokeJoin;
  if (!['butt', 'round', 'square'].contains(strokeCap) ||
      !['miter', 'round', 'bevel'].contains(strokeJoin)) {
    throw const FormatException('Unsupported SVG stroke cap or join.');
  }
  final miterLimit =
      double.tryParse(element.getAttribute('stroke-miterlimit') ?? '') ??
      parent.miterLimit;
  final paintOrder = element.getAttribute('paint-order') ?? parent.paintOrder;
  final transform = parent.transform.multiply(
    SvgTransform.parse(element.getAttribute('transform')),
  );
  final evenOdd =
      element.getAttribute('fill-rule') == 'evenodd' ||
      (element.getAttribute('fill-rule') == null && parent.evenOdd);

  var resolvedFill = _resolvePaint(
    element,
    'fill',
    parent.fill,
    () => '#000000',
  );
  var resolvedStroke = _resolvePaint(
    element,
    'stroke',
    parent.stroke,
    () => null,
  );
  final swAttr = element.getAttribute('stroke-width');
  final resolvedSw = double.tryParse(swAttr ?? '') ?? parent.strokeWidth;

  if ((resolvedFill ?? '').toLowerCase() == 'none') {
    resolvedFill = null; // explicit "no fill"
  }
  if ((resolvedStroke ?? '').toLowerCase() == 'none') {
    resolvedStroke = null;
  }

  final fillOpacity =
      double.tryParse(element.getAttribute('fill-opacity') ?? '') ??
      parent.fillOpacity;
  final strokeOpacity =
      double.tryParse(element.getAttribute('stroke-opacity') ?? '') ??
      parent.strokeOpacity;
  final opacity = double.tryParse(element.getAttribute('opacity') ?? '') ?? 1;
  if (tag == 'g' && opacity != 1) {
    throw const FormatException(
      'Group opacity requires compositing; flatten it in the source SVG.',
    );
  }
  final clips = [...parent.clipPaths];
  final clip = element.getAttribute('clip-path');
  if (clip != null && clip != 'none') {
    final id = RegExp(r'^url\(#([^)]*)\)$').firstMatch(clip)?.group(1);
    final definition = definitions[id];
    if (definition == null ||
        (definition.getAttribute('clipPathUnits') ?? 'userSpaceOnUse') !=
            'userSpaceOnUse') {
      throw FormatException('Unsupported clip path: $clip');
    }
    final paths = <SvgShape>[];
    _processElement(
      definition,
      paths,
      _PaintContext()..transform = transform,
      definitions,
    );
    clips.add(paths.map((shape) => shape.data).join());
  }
  final childCtx = _PaintContext()
    ..dashArray = dashArray
    ..dashOffset = dashOffset
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin
    ..miterLimit = miterLimit
    ..paintOrder = paintOrder
    ..visibility = visibility
    ..clipPaths = clips
    ..fillOpacity = fillOpacity
    ..strokeOpacity = strokeOpacity
    ..transform = transform
    ..evenOdd = evenOdd
    ..fill = resolvedFill ?? 'none'
    ..stroke = resolvedStroke ?? 'none'
    ..strokeWidth = (swAttr != null
        ? (double.tryParse(swAttr) ?? 1)
        : parent.strokeWidth);

  void add(String data) {
    if (data.isEmpty || visibility != 'visible') return;
    // Invisible if it has neither fill nor stroke after resolution.
    if (resolvedFill == null && resolvedStroke == null) return;
    final fill = _withOpacity(resolvedFill, opacity * fillOpacity);
    final stroke = _withOpacity(resolvedStroke, opacity * strokeOpacity);
    if (fill == null && stroke == null) return;
    final path = transform.path(data);
    SvgShape shape(String? fill, String? stroke) => SvgShape(
      path,
      fill,
      stroke,
      resolvedSw * transform.strokeScale,
      evenOdd,
      clips,
      dashArray.map((value) => value * transform.strokeScale).toList(),
      dashOffset * transform.strokeScale,
      strokeCap,
      strokeJoin,
      miterLimit,
    );
    final order = paintOrder.split(RegExp(r'\s+'));
    if (fill != null && stroke != null && order.first == 'stroke') {
      shapes.addAll([shape(null, stroke), shape(fill, null)]);
    } else {
      shapes.add(shape(fill, stroke));
    }
  }

  if (tag == 'path') {
    final d = element.getAttribute('d')?.trim() ?? '';
    if (d.isNotEmpty && d.toLowerCase() != 'none') {
      add(d);
    }
  } else if (tag == 'polygon') {
    final pts = element.getAttribute('points')?.trim() ?? '';
    if (pts.isNotEmpty) {
      add(_polygonPointsToPath(pts));
    }
  } else if (tag == 'polyline') {
    final pts = element.getAttribute('points')?.trim() ?? '';
    if (pts.isNotEmpty) {
      var pd = _polygonPointsToPath(pts);
      if (pd.endsWith('Z')) pd = pd.substring(0, pd.length - 1);
      if (pd.isNotEmpty) add(pd);
    }
  } else if (tag == 'circle') {
    {
      final cx = double.tryParse(element.getAttribute('cx') ?? '0') ?? 0;
      final cy = double.tryParse(element.getAttribute('cy') ?? '0') ?? 0;
      final r = double.tryParse(element.getAttribute('r') ?? '0') ?? 0;
      if (r > 0) add(_circleToPath(cx, cy, r));
    }
  } else if (tag == 'ellipse') {
    {
      final cx = double.tryParse(element.getAttribute('cx') ?? '0') ?? 0;
      final cy = double.tryParse(element.getAttribute('cy') ?? '0') ?? 0;
      final rx = double.tryParse(element.getAttribute('rx') ?? '0') ?? 0;
      final ry = double.tryParse(element.getAttribute('ry') ?? '0') ?? 0;
      if (rx > 0 && ry > 0) add(_ellipseToPath(cx, cy, rx, ry));
    }
  } else if (tag == 'rect') {
    {
      final x = double.tryParse(element.getAttribute('x') ?? '0') ?? 0;
      final y = double.tryParse(element.getAttribute('y') ?? '0') ?? 0;
      final w = double.tryParse(element.getAttribute('width') ?? '0') ?? 0;
      final h = double.tryParse(element.getAttribute('height') ?? '0') ?? 0;
      final rx = double.tryParse(element.getAttribute('rx') ?? '0') ?? 0;
      final ry = double.tryParse(element.getAttribute('ry') ?? '0') ?? 0;
      if (w > 0 && h > 0) add(_rectToPath(x, y, w, h, rx, ry));
    }
  } else if (tag == 'line') {
    {
      final x1 = element.getAttribute('x1') ?? '0';
      final y1 = element.getAttribute('y1') ?? '0';
      final x2 = element.getAttribute('x2') ?? '0';
      final y2 = element.getAttribute('y2') ?? '0';
      add('M$x1,$y1 L$x2,$y2');
    }
  }

  for (final child in element.childElements) {
    _processElement(child, shapes, childCtx, definitions);
  }
}

/// Resolves an `attribute = inherited ?? svgDefault` paint chain.
/// `svgDefault` supplies the value when the attribute is absent everywhere.
String? _resolvePaint(
  XmlElement element,
  String attr,
  String? inherited,
  String? Function() svgDefault,
) {
  final own = element.getAttribute(attr)?.trim();
  if (own != null && own.isNotEmpty) return own;
  return inherited ?? svgDefault();
}

String? _withOpacity(String? color, double opacity) {
  if (color == null || opacity <= 0) return null;
  if (opacity >= 1) return color;
  var hex = color.replaceFirst('#', '');
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  if (hex.length != 6) throw FormatException('Unsupported SVG color: $color');
  return '#$hex${(opacity * 255).round().toRadixString(16).padLeft(2, '0')}';
}

String _polygonPointsToPath(String input) {
  final values = RegExp(r'[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?')
      .allMatches(input)
      .map((match) => match[0]!)
      .toList();
  if (values.length.isOdd)
    throw const FormatException('Odd polygon coordinate count.');
  if (values.isEmpty) return '';
  return [
    for (var i = 0; i < values.length; i += 2)
      '${i == 0 ? 'M' : 'L'}${values[i]} ${values[i + 1]}',
    'Z',
  ].join();
}

String _circleToPath(double cx, double cy, double r) {
  return 'M${cx - r},$cy'
      ' A$r,$r,0,1,0,${cx + r},$cy'
      ' A$r,$r,0,1,0,${cx - r},$cy'
      'Z';
}

String _ellipseToPath(double cx, double cy, double rx, double ry) {
  return 'M${cx - rx},$cy'
      ' A$rx,$ry,0,1,0,${cx + rx},$cy'
      ' A$rx,$ry,0,1,0,${cx - rx},$cy'
      'Z';
}

String _rectToPath(
  double x,
  double y,
  double w,
  double h, [
  double rx = 0,
  double ry = 0,
]) {
  if (rx == 0 && ry == 0) {
    return 'M$x,${y}L${x + w},$y L${x + w},${y + h}L$x,${y + h}Z';
  }
  var rxVal = rx;
  var ryVal = ry;
  if (rxVal == 0) rxVal = ryVal;
  if (ryVal == 0) ryVal = rxVal;
  return 'M${x + rxVal},$y'
      ' L${x + w - rxVal},$y'
      ' A$rxVal,$ryVal,0,0,1,${x + w},${y + ryVal}'
      ' L${x + w},${y + h - ryVal}'
      ' A$rxVal,$ryVal,0,0,1,${x + w - rxVal},${y + h}'
      ' L${x + rxVal},${y + h}'
      ' A$rxVal,$ryVal,0,0,1,$x,${y + h - ryVal}'
      ' L$x,${y + ryVal}'
      ' A$rxVal,$ryVal,0,0,1,${x + rxVal},$y'
      'Z';
}
