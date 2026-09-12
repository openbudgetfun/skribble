import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// A TrueType font whose unrelated OpenType tables survive regeneration.
///
/// Outlines are edited in font units, including off-curve points. Character
/// maps, kerning, layout features, metrics, and composite references are kept.
final class TrueTypeFont {
  /// Reads a glyf font. Variable fonts require explicit deltas for every point.
  /// Expand sparse deltas with `fonttools varLib.instancer --no-optimize` first.
  TrueTypeFont(Uint8List bytes) {
    final reader = _Reader(bytes);

    if (reader.u32() != 0x00010000) {
      throw const FormatException('Expected a static TrueType glyf font.');
    }

    final count = reader.u16();
    reader.position = 12;

    for (var i = 0; i < count; i++) {
      final tag = ascii.decode(reader.take(4));
      reader.u32();
      final offset = reader.u32();
      final length = reader.u32();

      if (offset > bytes.length || length > bytes.length - offset) {
        throw FormatException('Invalid $tag table range.');
      }

      tables[tag] = Uint8List.fromList(bytes.sublist(offset, offset + length));
    }

    final head = ByteData.sublistView(_table('head'));
    unitsPerEm = head.getUint16(18);
    final countGlyphs = ByteData.sublistView(_table('maxp')).getUint16(4);
    final loca = _Reader(_table('loca'));
    final offsets = List.generate(
      countGlyphs + 1,
      (_) => head.getInt16(50) == 0 ? loca.u16() * 2 : loca.u32(),
    );
    final glyf = _table('glyf');

    for (var i = 0; i < countGlyphs; i++) {
      final start = offsets[i];
      final end = offsets[i + 1];

      if (start > end || end > glyf.length) {
        throw FormatException('Invalid glyph $i range.');
      }

      _glyphs.add(_Glyph(Uint8List.fromList(glyf.sublist(start, end))));
    }

    if (tables.containsKey('fvar')) _validateVariations(countGlyphs);
  }

  // IUP infers omitted deltas from the ORIGINAL outline coordinates. Warping
  // that outline invalidates its inference ratios, so accept only full tuples.
  // Keeping full deltas makes the displacement constant across the designspace.
  void _validateVariations(int glyphCount) {
    final data = _table('gvar');
    final reader = _Reader(data);
    if (reader.u16() != 1 || reader.u16() != 0) {
      throw const FormatException('Unsupported gvar version.');
    }
    final axes = reader.u16();
    reader
      ..u16()
      ..u32();
    if (reader.u16() != glyphCount) {
      throw const FormatException('gvar glyph count does not match glyf.');
    }
    final longOffsets = reader.u16() & 1 != 0;
    final start = reader.u32();
    final offsets = List.generate(
      glyphCount + 1,
      (_) => longOffsets ? reader.u32() : reader.u16() * 2,
    );
    for (var glyph = 0; glyph < glyphCount; glyph++) {
      final begin = start + offsets[glyph];
      final end = start + offsets[glyph + 1];
      if (begin > end || end > data.length) {
        throw const FormatException('Invalid gvar glyph range.');
      }
      if (begin == end) continue;
      final tuples = _Reader(Uint8List.sublistView(data, begin, end));
      final flags = tuples.u16();
      var payload = tuples.u16();
      final shared = flags & 0x8000 != 0;
      final sharedAll = !shared || tuples.data[payload] == 0;
      // An all-point shared list consists of the single zero count byte.
      if (shared) {
        if (!sharedAll) {
          throw const FormatException(
            'Expand sparse gvar deltas before roughening.',
          );
        }
        payload++;
      }
      for (var tuple = 0; tuple < (flags & 0x0fff); tuple++) {
        final size = tuples.u16();
        final index = tuples.u16();
        if (index & 0x8000 != 0) tuples.take(axes * 2);
        if (index & 0x4000 != 0) tuples.take(axes * 4);
        if (payload + size > tuples.data.length ||
            (index & 0x2000 != 0 && tuples.data[payload] != 0)) {
          throw const FormatException(
            'Expand sparse gvar deltas before roughening.',
          );
        }
        payload += size;
      }
    }
  }

  /// Original tables, with outline and naming tables replaced on serialization.
  final Map<String, Uint8List> tables = {};

  /// Number of units per em in the source font.
  late final int unitsPerEm;

  final List<_Glyph> _glyphs = [];

  /// Resolves the points of a glyph, including transformed composite accents.
  List<math.Point<int>> glyphPoints(int id) => _resolvePoints(id, {}, {});

  /// Number of glyphs, including space, alternates, and composite characters.
  int get glyphCount => _glyphs.length;

  Uint8List _table(String name) =>
      tables[name] ?? (throw FormatException('Missing $name table.'));

  /// Moves neighbouring points together so strokes bend without torn contours.
  ///
  /// [amount] is measured at 1000 units per em. A per-glyph tilt and two smooth
  /// waves vary stems and bowls while preserving counters and curve continuity.
  /// Zero is an outline-preserving control for comparisons.
  int roughen(double amount) {
    if (!amount.isFinite || amount < 0 || amount > 50) {
      throw ArgumentError.value(amount, 'amount', 'Must be between 0 and 50.');
    }

    var changed = 0;

    for (var id = 0; id < _glyphs.length; id++) {
      final glyph = _glyphs[id];
      final phase = (id * 0.61803398875 % 1) * math.pi * 2;
      final tilt = math.sin(phase * 1.7) * amount * 0.0014;

      for (var i = 0; i < glyph.points.length; i++) {
        final point = glyph.points[i];
        final x = point.x * 1000 / unitsPerEm;
        final y = point.y * 1000 / unitsPerEm;
        final dx =
            amount *
                (0.65 * math.sin(y / 105 + phase) +
                    0.35 * math.sin((x + y) / 57 + phase * 2)) +
            tilt * y;
        final dy =
            amount *
            (0.55 * math.sin(x / 125 + phase * 1.3) +
                0.25 * math.sin((y - x) / 83 + phase));
        glyph.points[i] = math.Point(
          (point.x + dx * unitsPerEm / 1000).round(),
          (point.y + dy * unitsPerEm / 1000).round(),
        );
      }

      if (glyph.points.isNotEmpty || glyph.components.isNotEmpty) changed++;
    }

    return changed;
  }

  /// Serializes the edited outlines and names, removing obsolete hint programs
  /// and digital signatures and recalculating every table checksum.
  Uint8List encode({
    required String family,
    required String style,
    int? weight,
    bool? italic,
  }) {
    final bounds = <int, List<math.Point<int>>>{};
    final allPoints = <math.Point<int>>[];
    final glyf = BytesBuilder(copy: false);
    final loca = _Writer();

    for (var i = 0; i < _glyphs.length; i++) {
      final points = _resolvePoints(i, bounds, {});
      allPoints.addAll(points);
      loca.u32(glyf.length);
      glyf.add(_glyphs[i].encode(points));

      while (glyf.length % 4 != 0) {
        glyf.addByte(0);
      }
    }

    loca.u32(glyf.length);
    tables['glyf'] = glyf.takeBytes();
    tables['loca'] = loca.bytes;
    final head = ByteData.sublistView(_table('head'));
    head
      ..setInt16(50, 1)
      ..setUint32(8, 0)
      ..setUint16(16, head.getUint16(16) & ~0x1e);
    // Edited outlines no longer share the source font's hinted side bearings.
    _writeBounds(head, 36, allPoints);
    ByteData.sublistView(_table('maxp')).setUint16(26, 0);
    if (weight != null && italic != null) {
      final os2 = ByteData.sublistView(_table('OS/2'));
      final bold = weight >= 700;
      os2
        ..setUint16(4, weight)
        ..setUint16(
          62,
          (os2.getUint16(62) & ~0x61) |
              (italic ? 1 : 0) |
              (bold ? 0x20 : 0) |
              (!italic && !bold ? 0x40 : 0),
        );
      head.setUint16(44, (bold ? 1 : 0) | (italic ? 2 : 0));
    }
    _rename(family, style);

    [
      'DSIG',
      'fpgm',
      'prep',
      'cvt ',
      'cvar',
      'hdmx',
      'LTSH',
      'VDMX',
    ].forEach(tables.remove);

    final tags = tables.keys.toList()..sort();
    final directory = _Writer();
    final power = (math.log(tags.length) / math.ln2).floor();
    directory
      ..u32(0x00010000)
      ..u16(tags.length)
      ..u16(16 * (1 << power))
      ..u16(power)
      ..u16(tags.length * 16 - 16 * (1 << power));
    var offset = 12 + tags.length * 16;
    var headOffset = 0;
    final body = BytesBuilder(copy: false);

    for (final tag in tags) {
      final table = tables[tag]!;
      directory
        ..add(ascii.encode(tag))
        ..u32(checksum(table))
        ..u32(offset)
        ..u32(table.length);
      if (tag == 'head') headOffset = offset;
      body.add(table);
      final padding = (4 - table.length % 4) % 4;
      body.add(List<int>.filled(padding, 0));
      offset += table.length + padding;
    }

    final output = Uint8List.fromList([
      ...directory.bytes,
      ...body.takeBytes(),
    ]);
    ByteData.sublistView(output).setUint32(
      headOffset + 8,
      (0xb1b0afba - checksum(output)) & 0xffffffff,
    );

    return output;
  }

  List<math.Point<int>> _resolvePoints(
    int id,
    Map<int, List<math.Point<int>>> cache,
    Set<int> visiting,
  ) {
    if (cache.containsKey(id)) return cache[id]!;
    if (id >= _glyphs.length || !visiting.add(id)) {
      throw const FormatException('Invalid composite glyph reference.');
    }

    final glyph = _glyphs[id];
    final points = [...glyph.points];

    for (final component in glyph.components) {
      final source = _resolvePoints(component.id, cache, visiting);
      final transformed = source.map(component.transform).toList();
      var dx = component.dx;
      var dy = component.dy;

      if (!component.xy) {
        final parent = points[component.dx];
        final child = transformed[component.dy];
        dx = parent.x - child.x;
        dy = parent.y - child.y;
      } else if (component.scaledOffset) {
        final translated = component.transform(math.Point(dx, dy));
        dx = translated.x;
        dy = translated.y;
      }

      points.addAll(transformed.map((p) => math.Point(p.x + dx, p.y + dy)));
    }

    visiting.remove(id);
    cache[id] = points;

    return points;
  }

  void _rename(String family, String style) {
    final reader = _Reader(_table('name'));
    final count = (reader..u16()).u16();
    final start = reader.u16();
    final records = _Writer();
    final strings = BytesBuilder(copy: false);
    final compactStyle = style.replaceAll(' ', '');
    final extended =
        !tables.containsKey('fvar') &&
        !['Regular', 'Bold', 'Italic', 'Bold Italic'].contains(style);
    final replacements = <int, String>{
      1: extended ? '$family ${style.replaceAll(' Italic', '')}' : family,
      2: extended ? (style.endsWith('Italic') ? 'Italic' : 'Regular') : style,
      3: '$family-$compactStyle;Skribble-2',
      4: '$family $style',
      6: '$family-$compactStyle',
      16: family,
      17: style,
      18: '$family $style',
      21: family,
      22: style,
      25: family,
    };

    for (var i = 0; i < count; i++) {
      final platform = reader.u16();
      final encoding = reader.u16();
      final language = reader.u16();
      final name = reader.u16();
      final length = reader.u16();
      final offset = reader.u16();
      var replacement = replacements[name];
      if (replacement == null && name >= 256) {
        final original = reader.data.sublist(
          start + offset,
          start + offset + length,
        );
        final text = platform == 0 || platform == 3
            ? String.fromCharCodes([
                for (var i = 0; i + 1 < original.length; i += 2)
                  (original[i] << 8) | original[i + 1],
              ])
            : latin1.decode(original);
        if (text.contains('Recursive')) {
          replacement = text.replaceAll('Recursive', family);
        }
      }
      final List<int> data;

      if (replacement == null) {
        data = reader.data.sublist(start + offset, start + offset + length);
      } else if (platform == 0 || platform == 3) {
        data = replacement.codeUnits.expand((c) => [c >> 8, c & 255]).toList();
      } else {
        data = ascii.encode(replacement);
      }

      records
        ..u16(platform)
        ..u16(encoding)
        ..u16(language)
        ..u16(name)
        ..u16(data.length)
        ..u16(strings.length);
      strings.add(data);
    }

    tables['name'] =
        (_Writer()
              ..u16(0)
              ..u16(count)
              ..u16(6 + count * 12)
              ..add(records.bytes)
              ..add(strings.takeBytes()))
            .bytes;
  }

  /// OpenType checksum, including zero padding to a four-byte boundary.
  static int checksum(List<int> bytes) {
    var sum = 0;

    for (var i = 0; i < bytes.length; i += 4) {
      var word = 0;

      for (var j = 0; j < 4; j++) {
        word = (word << 8) | (i + j < bytes.length ? bytes[i + j] : 0);
      }

      sum = (sum + word) & 0xffffffff;
    }

    return sum;
  }
}

final class _Glyph {
  _Glyph(this.raw) {
    if (raw.isEmpty) return;
    final reader = _Reader(raw);
    contours = reader.i16();
    reader.position = 10;

    if (contours < 0) {
      var more = true;

      while (more) {
        final start = reader.position;
        final flags = reader.u16();
        final id = reader.u16();
        final xy = flags & 2 != 0;
        final words = flags & 1 != 0;
        final dx = words
            ? (xy ? reader.i16() : reader.u16())
            : (xy ? reader.i8() : reader.u8());
        final dy = words
            ? (xy ? reader.i16() : reader.u16())
            : (xy ? reader.i8() : reader.u8());
        var a = 1.0;
        var b = 0.0;
        var c = 0.0;
        var d = 1.0;

        if (flags & 8 != 0) {
          a = d = reader.i16() / 16384;
        } else if (flags & 64 != 0) {
          a = reader.i16() / 16384;
          d = reader.i16() / 16384;
        } else if (flags & 128 != 0) {
          a = reader.i16() / 16384;
          b = reader.i16() / 16384;
          c = reader.i16() / 16384;
          d = reader.i16() / 16384;
        }

        final bytes = Uint8List.fromList(raw.sublist(start, reader.position));
        ByteData.sublistView(bytes).setUint16(0, flags & ~256);
        components.add(
          _Component(
            id,
            dx,
            dy,
            a,
            b,
            c,
            d,
            bytes,
            xy: xy,
            scaledOffset: flags & 2048 != 0,
          ),
        );
        more = flags & 32 != 0;
      }

      return;
    }

    if (contours == 0) return;
    ends.addAll(List.generate(contours, (_) => reader.u16()));
    final instructionLength = reader.u16();
    reader.position += instructionLength;
    final pointCount = ends.last + 1;

    while (flags.length < pointCount) {
      final flag = reader.u8();
      final repeat = flag & 8 != 0 ? reader.u8() + 1 : 1;
      flags.addAll(List<int>.filled(repeat, flag));
    }

    if (flags.length != pointCount) {
      throw const FormatException('Invalid glyph flags.');
    }
    final xs = _coordinates(reader, 2, 16);
    final ys = _coordinates(reader, 4, 32);
    points.addAll(List.generate(pointCount, (i) => math.Point(xs[i], ys[i])));
  }

  final Uint8List raw;
  int contours = 0;
  final List<int> ends = [];
  final List<int> flags = [];
  final List<math.Point<int>> points = [];
  final List<_Component> components = [];

  List<int> _coordinates(_Reader reader, int short, int same) {
    var coordinate = 0;

    return flags.map((flag) {
      if (flag & short != 0) {
        coordinate += reader.u8() * (flag & same != 0 ? 1 : -1);
      } else if (flag & same == 0) {
        coordinate += reader.i16();
      }

      return coordinate;
    }).toList();
  }

  Uint8List encode(List<math.Point<int>> resolved) {
    if (raw.isEmpty) return raw;
    final header = ByteData(10)..setInt16(0, contours);
    _writeBounds(header, 2, resolved);
    final writer = _Writer()..add(header.buffer.asUint8List());

    if (contours < 0) {
      for (final component in components) {
        writer.add(component.bytes);
      }

      return writer.bytes;
    }

    ends.forEach(writer.u16);

    writer.u16(0);

    for (final flag in flags) {
      writer.u8(flag & 0x41);
    }

    for (final axis in [0, 1]) {
      var previous = 0;

      for (final point in points) {
        final coordinate = axis == 0 ? point.x : point.y;
        writer.i16(coordinate - previous);
        previous = coordinate;
      }
    }

    return writer.bytes;
  }
}

final class _Component {
  const _Component(
    this.id,
    this.dx,
    this.dy,

    this.a,
    this.b,
    this.c,
    this.d,
    this.bytes, {
    required this.xy,
    required this.scaledOffset,
  });
  final int id;
  final int dx;
  final int dy;
  final bool xy;
  final bool scaledOffset;
  final double a;
  final double b;
  final double c;
  final double d;
  final Uint8List bytes;

  math.Point<int> transform(math.Point<int> p) => math.Point(
    (a * p.x + c * p.y).round(),
    (b * p.x + d * p.y).round(),
  );
}

void _writeBounds(ByteData data, int offset, List<math.Point<int>> points) {
  final xs = points.map((p) => p.x);
  final ys = points.map((p) => p.y);
  final bounds = points.isEmpty
      ? [0, 0, 0, 0]
      : [
          xs.reduce(math.min),
          ys.reduce(math.min),
          xs.reduce(math.max),
          ys.reduce(math.max),
        ];

  for (var i = 0; i < 4; i++) {
    data.setInt16(offset + i * 2, bounds[i]);
  }
}

final class _Reader {
  _Reader(this.data);
  final Uint8List data;
  int position = 0;
  int u8() => take(1).first;
  int i8() => ByteData.sublistView(take(1)).getInt8(0);
  int u16() => ByteData.sublistView(take(2)).getUint16(0);
  int i16() => ByteData.sublistView(take(2)).getInt16(0);
  int u32() => ByteData.sublistView(take(4)).getUint32(0);
  Uint8List take(int length) {
    if (position < 0 || length > data.length - position) {
      throw const FormatException('Truncated font data.');
    }

    final result = Uint8List.sublistView(data, position, position + length);
    position += length;
    return result;
  }
}

final class _Writer {
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  Uint8List get bytes => _buffer.toBytes();
  void add(List<int> bytes) => _buffer.add(bytes);
  void u8(int value) => _buffer.addByte(value);
  void u16(int value) =>
      add((ByteData(2)..setUint16(0, value)).buffer.asUint8List());
  void u32(int value) =>
      add((ByteData(4)..setUint32(0, value)).buffer.asUint8List());
  void i16(int value) {
    if (value < -32768 || value > 32767) {
      throw const FormatException(
        'Roughened coordinate exceeds TrueType range.',
      );
    }

    add((ByteData(2)..setInt16(0, value)).buffer.asUint8List());
  }
}
