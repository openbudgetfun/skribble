import 'dart:io';

import 'package:skribble_emoji_gen/svg_shapes.dart';
import 'package:skribble_emoji_gen/svg_transform.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  setUp(() => temp = Directory.systemTemp.createTempSync('skribble-svg-'));
  tearDown(() => temp.deleteSync(recursive: true));
  List<SvgShape> parse(String body) {
    final file = File('${temp.path}/source.svg')
      ..writeAsStringSync('<svg>$body</svg>');
    return extractShapes(file.path);
  }

  test('nested fill none stays absent and strokes inherit', () {
    final shapes = parse('''
      <g fill="none" stroke="#123456" stroke-width="3">
        <g><path d="M0 0L10 10"/></g>
        <path fill="#ffcc00" d="M0 0H10V10Z"/>
        <path stroke="none" d="M0 0L5 5"/>
      </g>''');
    expect(shapes, hasLength(2));
    expect(shapes.first.fillColor, isNull);
    expect(shapes.first.strokeColor, '#123456');
    expect(shapes.first.strokeWidth, 3);
    expect(shapes.last.fillColor, '#ffcc00');
  });

  test('nested transforms and evenodd are preserved', () {
    final shapes = parse('''
      <g transform="translate(10 20)" fill-rule="evenodd">
        <g transform="scale(2)"><path stroke="#000000" stroke-width="3"
          d="M0 0H5V5Z M1 1V2H2Z"/></g>
      </g>''');
    expect(shapes.single.evenOdd, isTrue);
    expect(shapes.single.strokeWidth, 6);
    expect(shapes.single.data, contains('M'));
    final start = RegExp(r'M([-\d.]+) ([-\d.]+)')
        .firstMatch(shapes.single.data)!;
    expect(double.parse(start[1]!), closeTo(10, 1));
    expect(double.parse(start[2]!), closeTo(20, 1));
    expect('M'.allMatches(shapes.single.data), hasLength(2));
  });

  test('rotation around a center and matrix composition match SVG order', () {
    final rotate = SvgTransform.parse('rotate(90 10 10)');
    expect(rotate.a * 20 + rotate.c * 10 + rotate.e, closeTo(10, 1e-10));
    expect(rotate.b * 20 + rotate.d * 10 + rotate.f, closeTo(20, 1e-10));
    final composed = SvgTransform.parse('translate(10,20) scale(2,3)');
    expect([composed.a, composed.d, composed.e, composed.f], [2, 3, 10, 20]);
  });

  test('circles, ellipses, rectangles and polygons generate closed paths', () {
    final shapes = parse('''
      <circle cx="20" cy="20" r="5"/>
      <ellipse cx="20" cy="20" rx="8" ry="4"/>
      <rect x="2" y="3" width="10" height="8" rx="2"/>
      <polygon points="0,0 10,0 10,10"/>
    ''');
    expect(shapes, hasLength(4));
    for (final shape in shapes) {
      expect(shape.data, endsWith('Z'));
      expect(shape.fillColor, '#000000');
    }
  });
  test('definitions clip artwork without becoming visible shapes', () {
    final shapes = parse(
      '''<defs><clipPath id="shield"><path d="M0 0H10V10H0Z"/></clipPath></defs>
      <g clip-path="url(#shield)"><rect width="20" height="20" fill="#ff0000"/></g>''',
    );
    expect(shapes, hasLength(1));
    expect(shapes.single.clipPaths, hasLength(1));
    expect(shapes.single.clipPaths.single, contains('Z'));
  });

  test('zero and partial opacity preserve strokes and shading', () {
    final shapes = parse('''<path d="M0 0H10V10Z" fill-opacity="0"/>
      <path d="M0 0H10V10Z" fill-opacity="0" stroke="#000000"/>
      <path d="M0 0H10V10Z" fill="#ff0000" opacity="0.5"/>''');
    expect(shapes, hasLength(2));
    expect(shapes.first.fillColor, isNull);
    expect(shapes.first.strokeColor, '#000000');
    expect(shapes.last.fillColor, '#ff000080');
  });

  test('comma-only polygons keep every coordinate pair', () {
    final shape = parse('<polygon points="0,0,10,0,10,10"/>').single;
    expect('L'.allMatches(shape.data), hasLength(2));
  });

  test('hidden subtrees are omitted and visibility can be restored', () {
    final shapes = parse('''<g display="none"><path d="M0 0H10V10Z"/></g>
      <g visibility="hidden"><path d="M0 0H10V10Z"/>
        <path visibility="visible" d="M0 0H2V2Z"/></g>''');
    expect(shapes, hasLength(1));
  });

  test('stroke details inherit and scale with nested transforms', () {
    final shapes = parse('''<g stroke="#000" fill="none" stroke-dasharray="2,4"
        stroke-dashoffset="1" stroke-linecap="square" stroke-linejoin="bevel"
        stroke-miterlimit="8" transform="scale(2)">
      <path d="M0 0H20"/><path stroke-dasharray="none" d="M0 2H20"/>
      </g>''');
    expect(shapes.first.strokeDashArray, [4, 8]);
    expect(shapes.first.strokeDashOffset, 2);
    expect(shapes.first.strokeCap, 'square');
    expect(shapes.first.strokeJoin, 'bevel');
    expect(shapes.first.strokeMiterLimit, 8);
    expect(shapes.last.strokeDashArray, isEmpty);
  });

  test('stroke-first paint order emits separate ordered shapes', () {
    final shapes = parse('''<g paint-order="stroke fill markers">
      <path d="M0 0H10V10Z" fill="#fff" stroke="#000"/>
      </g>''');
    expect(shapes, hasLength(2));
    expect(shapes.first.fillColor, isNull);
    expect(shapes.first.strokeColor, '#000');
    expect(shapes.last.fillColor, '#fff');
    expect(shapes.last.strokeColor, isNull);
  });

  test('negative dash lengths are rejected', () {
    expect(
      () => parse('<path d="M0 0H10" stroke-dasharray="-1,2"/>'),
      throwsFormatException,
    );
  });
}
