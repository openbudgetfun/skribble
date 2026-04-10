import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/note.dart';

/// A reusable card widget for displaying a note preview in the list.
///
/// Shows the note title in bold, a content preview (first 50 characters),
/// and the date. Displays a [WiredBadge] if the note was updated today.
class NoteCard extends HookWidget {
  const NoteCard({
    required this.note,
    super.key,
    this.onTap,
  });

  final Note note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUpdatedToday = note.updatedAt.year == now.year &&
        note.updatedAt.month == now.month &&
        note.updatedAt.day == now.day;

    final contentPreview = note.content.length > 50
        ? '${note.content.substring(0, 50)}...'
        : note.content;

    final dateString =
        '${note.updatedAt.month}/${note.updatedAt.day}/${note.updatedAt.year}';

    final card = WiredCard(
      height: null,
      child: WiredListTile(
        onTap: onTap,
        showDivider: false,
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: note.color,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF5C3D2E)),
          ),
        ),
        title: Text(
          note.title.isEmpty ? 'Untitled' : note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contentPreview.isNotEmpty)
              Text(
                contentPreview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              dateString,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    if (isUpdatedToday) {
      return WiredBadge(label: 'new', child: card);
    }

    return card;
  }
}
