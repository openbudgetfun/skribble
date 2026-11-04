import 'package:flutter/widgets.dart';

/// A note in the Sketch Notes app.
///
/// Notes are immutable: editing one produces a copy with [copyWith], and the
/// home page swaps the copy into its list.
@immutable
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new note with a generated ID based on the current time.
  factory Note.create({
    String title = '',
    String content = '',
    Color color = const Color(0xFFF5ECD7),
  }) {
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch}-${now.microsecond}';
    return Note(
      id: id,
      title: title,
      content: content,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Identifies the note across edits, so the list can replace it in place.
  final String id;

  /// The heading; the card shows "Untitled" while it is empty.
  final String title;

  /// The body text.
  final String content;

  /// The pastel the note's card is coloured in with.
  final Color color;

  /// When the note was first written.
  final DateTime createdAt;

  /// When the note last changed; the card shows a "new" badge on the same day.
  final DateTime updatedAt;

  /// Returns a copy with the given fields replaced. [updatedAt] defaults to
  /// now, because every copy is an edit.
  Note copyWith({
    String? title,
    String? content,
    Color? color,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
