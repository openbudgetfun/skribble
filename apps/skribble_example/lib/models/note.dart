import 'package:flutter/material.dart';

/// A simple note model for the Sketch Notes app.
class Note {
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
    final id =
        '${now.millisecondsSinceEpoch}-${now.microsecond}';
    return Note(
      id: id,
      title: title,
      content: content,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
  }

  final String id;
  final String title;
  final String content;
  final Color color;
  final DateTime createdAt;
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
