import 'package:flutter/widgets.dart';

/// Start offsets of non-overlapping, case-insensitive matches in [text].
List<int> findTextMatches(String text, String query) {
  if (query.isEmpty) return const [];

  return RegExp(
    RegExp.escape(query),
    caseSensitive: false,
  ).allMatches(text).map((match) => match.start).toList();
}

/// Marks matches inside rich text without changing its text or link gestures.
TextSpan markTextMatches(TextSpan source, String query) {
  final offsets = findTextMatches(source.toPlainText(), query);
  if (offsets.isEmpty) return source;

  var position = 0;

  TextSpan mark(TextSpan span) {
    if (span.semanticsLabel != null) {
      position += span.toPlainText().length;
      return span;
    }

    final children = <InlineSpan>[];
    final value = span.text;
    if (value != null) {
      final start = position;
      final end = start + value.length;
      var cursor = start;

      for (final offset in offsets) {
        final matchEnd = offset + query.length;
        if (matchEnd <= start || offset >= end) continue;
        final from = offset.clamp(start, end);
        final to = matchEnd.clamp(start, end);
        if (from > cursor) {
          children.add(
            TextSpan(
              text: value.substring(cursor - start, from - start),
              recognizer: span.recognizer,
            ),
          );
        }
        children.add(
          TextSpan(
            text: value.substring(from - start, to - start),
            recognizer: span.recognizer,
            style: const TextStyle(backgroundColor: Color(0xffffdc79)),
          ),
        );
        cursor = to;
      }
      if (cursor < end) {
        children.add(
          TextSpan(
            text: value.substring(cursor - start),
            recognizer: span.recognizer,
          ),
        );
      }
      position = end;
    }

    for (final child in span.children ?? const <InlineSpan>[]) {
      if (child is TextSpan) {
        children.add(mark(child));
      } else {
        children.add(child);
        position += child.toPlainText().length;
      }
    }

    return TextSpan(
      style: span.style,
      children: children,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsIdentifier: span.semanticsIdentifier,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  return mark(source);
}
