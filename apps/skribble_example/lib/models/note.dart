import 'package:flutter/material.dart';

/// A simple note model for the Sketch Notes app.
class Note {
  /// Creates a note from all of its fields.
  Note({
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

  /// Unique identifier for the note.
  final String id;

  /// Title shown on the note card.
  final String title;

  /// Body text of the note.
  final String content;

  /// Pastel colour the note card is filled with.
  final Color color;

  /// When the note was first created.
  final DateTime createdAt;

  /// When the note was last edited.
  final DateTime updatedAt;

  /// Returns a copy with the given fields replaced.
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
