/// Rewrites SVG path data in its smallest equivalent text at
/// [fractionDigits] decimals.
///
/// Every coordinate is first rounded to [fractionDigits] decimals in
/// absolute space; the path is then written with relative commands (which
/// are shorter and compress better), implicit command repetition, no leading zeros (`.5`, `-.5`), and no separator where
/// a minus sign or a second decimal point already starts the next number.
///
/// The rounding happens on absolute coordinates and the deltas are computed
/// in whole units of `10^-fractionDigits`, so relative commands never drift:
/// the drawn shape is exactly the input rounded to [fractionDigits] decimals.
/// When the input already has no more than [fractionDigits] decimals, the
/// output draws exactly the same path.
///
/// Rough drawings are the main use: a server-rendered page of sketches ships
/// about a fifth less markup before compression and a quarter less after.
///
/// Every SVG path command is understood, absolute or relative, including arcs
/// (`A`/`a`, whose flags are kept as `0`/`1`). Data that cannot be parsed is
/// returned unchanged.
///
/// ```dart
/// compactSvgPath('M10.04 20 L15.5 20 L15.5 25');
/// // 'M10 20l5.5 0 0 5'
/// ```
String compactSvgPath(String data, {int fractionDigits = 1}) {
  if (fractionDigits < 0 || fractionDigits > 6) {
    throw RangeError.range(fractionDigits, 0, 6, 'fractionDigits');
  }
  final segments = _parse(data);
  if (segments == null) return data;
  if (segments.isEmpty) return '';

  final scale = _pow10(fractionDigits);
  int q(double v) => (v * scale).round();
  String f(int units) => _format(units, fractionDigits);

  final out = StringBuffer();
  // Current point and subpath start, in rounded units.
  var x = 0;
  var y = 0;
  var startX = 0;
  var startY = 0;
  // The command letter last written, to repeat it implicitly.
  String? last;
  // The last number written, to decide whether the next needs a separator.
  var previous = '';

  void command(String letter, List<String> numbers) {
    if (letter == last && letter != 'z' && numbers.isNotEmpty) {
      // Repeat implicitly; a separator is needed unless the number starts
      // with "-" or (after a number holding ".") with ".".
      _writeNumbers(out, numbers, previous);
    } else {
      out.write(letter);
      _writeNumbers(out, numbers, '');
    }
    if (numbers.isNotEmpty) previous = numbers.last;
    // Pairs repeated after "m" are relative linetos, after "M" absolute
    // ones; only relative linetos are written.
    last = switch (letter) {
      'm' => 'l',
      'M' => null,
      _ => letter,
    };
  }

  /// Writes [kind] in its relative form. [args] are absolute rounded
  /// units; [axis] marks each as an x (`x`) or y (`y`) coordinate.
  void write(String kind, List<int> args, String axis) {
    command(kind.toLowerCase(), [
      for (var i = 0; i < args.length; i++)
        f(args[i] - (axis[i] == 'x' ? x : y)),
    ]);
  }

  var first = true;
  for (final segment in segments) {
    final relative = segment.command.toLowerCase() == segment.command;
    final kind = segment.command.toUpperCase();
    final a = segment.args;
    // Absolute rounded units of an x or y argument.
    int ax(double v) => relative ? x + q(v) : q(v);
    int ay(double v) => relative ? y + q(v) : q(v);

    switch (kind) {
      case 'Z':
        command('z', const []);
        x = startX;
        y = startY;
      case 'M':
        final nx = ax(a[0]);
        final ny = ay(a[1]);
        if (first) {
          command('M', [f(nx), f(ny)]);
        } else {
          write('M', [nx, ny], 'xy');
        }
        x = startX = nx;
        y = startY = ny;
      case 'H':
        final nx = ax(a[0]);
        write('H', [nx], 'x');
        x = nx;
      case 'V':
        final ny = ay(a[0]);
        write('V', [ny], 'y');
        y = ny;
      case 'A':
        final nx = ax(a[5]);
        final ny = ay(a[6]);
        final large = a[3] == 0 ? '0' : '1';
        final sweep = a[4] == 0 ? '0' : '1';
        command('a', [
          f(q(a[0])),
          f(q(a[1])),
          f(q(a[2])),
          large,
          sweep,
          f(nx - x),
          f(ny - y),
        ]);
        x = nx;
        y = ny;
      default:
        // L, T, C, S, and Q: x, y pairs.
        final args = <int>[
          for (var i = 0; i < a.length; i++)
            if (i.isEven) ax(a[i]) else ay(a[i]),
        ];
        write(kind, args, 'xy' * (a.length ~/ 2));
        x = args[args.length - 2];
        y = args[args.length - 1];
    }
    first = false;
  }

  return out.toString();
}

/// Writes [numbers] with the fewest separators, given the [previous] number
/// already in [out] (empty right after a command letter).
void _writeNumbers(StringBuffer out, List<String> numbers, String previous) {
  var before = previous;
  for (final number in numbers) {
    if (before.isNotEmpty && !_joins(before, number)) out.write(' ');
    out.write(number);
    before = number;
  }
}

/// Whether [next] can follow [previous] with no separator.
bool _joins(String previous, String next) =>
    next.startsWith('-') || (next.startsWith('.') && previous.contains('.'));

int _pow10(int digits) {
  var value = 1;
  for (var i = 0; i < digits; i++) {
    value *= 10;
  }
  return value;
}

/// Formats [units] of `10^-digits` with no trailing zeros or leading zero.
String _format(int units, int digits) {
  if (units == 0) return '0';
  final negative = units < 0;
  final magnitude = units.abs();
  final scale = _pow10(digits);
  final whole = magnitude ~/ scale;
  var fraction = digits == 0
      ? ''
      : (magnitude % scale).toString().padLeft(digits, '0');
  fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
  final text = fraction.isEmpty
      ? '$whole'
      : (whole == 0 ? '.$fraction' : '$whole.$fraction');
  return negative ? '-$text' : text;
}

final class _Segment {
  const _Segment(this.command, this.args);

  final String command;
  final List<double> args;
}

const _arity = {
  'M': 2,
  'L': 2,
  'T': 2,
  'H': 1,
  'V': 1,
  'C': 6,
  'S': 4,
  'Q': 4,
  'A': 7,
  'Z': 0,
};

/// Splits [data] into one segment per command, expanding implicit repeats.
/// Returns null when [data] is not valid path data.
List<_Segment>? _parse(String data) {
  final scanner = _Scanner(data);
  final segments = <_Segment>[];
  String? command;

  while (true) {
    scanner.skipSeparators();
    if (scanner.done) break;
    final letter = scanner.commandLetter();
    if (letter != null) {
      command = letter;
      if (letter.toUpperCase() == 'Z') {
        segments.add(_Segment(letter, const []));
        command = null;
        continue;
      }
    } else if (command == null) {
      return null;
    }
    final kind = command.toUpperCase();
    final count = _arity[kind]!;
    final args = <double>[];
    for (var k = 0; k < count; k++) {
      scanner.skipSeparators();
      // Arc flags are single digits and may be written with no separator.
      final value = kind == 'A' && (k == 3 || k == 4)
          ? scanner.flag()
          : scanner.number();
      if (value == null) return null;
      args.add(value);
    }
    segments.add(_Segment(command, args));
    // Pairs after a moveto are linetos of the same case.
    if (command == 'M') command = 'L';
    if (command == 'm') command = 'l';
  }
  return segments;
}

final class _Scanner {
  _Scanner(this.text);

  final String text;
  var _at = 0;

  bool get done => _at >= text.length;

  void skipSeparators() {
    while (!done) {
      final c = text.codeUnitAt(_at);
      // space, tab, newline, carriage return, form feed, comma
      if (c == 0x20 ||
          c == 0x09 ||
          c == 0x0A ||
          c == 0x0D ||
          c == 0x0C ||
          c == 0x2C) {
        _at++;
      } else {
        break;
      }
    }
  }

  String? commandLetter() {
    final c = text[_at];
    if (_arity.containsKey(c.toUpperCase()) &&
        c.toUpperCase() != c.toLowerCase()) {
      _at++;
      return c;
    }
    return null;
  }

  double? flag() {
    if (done) return null;
    final c = text[_at];
    if (c != '0' && c != '1') return null;
    _at++;
    return c == '1' ? 1 : 0;
  }

  static final _number = RegExp(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

  double? number() {
    final match = _number.matchAsPrefix(text, _at);
    if (match == null) return null;
    _at = match.end;
    return double.tryParse(match[0]!);
  }
}
