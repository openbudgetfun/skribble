import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/note.dart';

/// Color options available for notes.
const _colorOptions = <Color>[
  Color(0xFFF5ECD7), // Parchment (default)
  Color(0xFFE8F5E9), // Soft green
  Color(0xFFE3F2FD), // Soft blue
  Color(0xFFFFF3E0), // Soft orange
  Color(0xFFF3E5F5), // Soft purple
];

const _colorLabels = <String>[
  'Parchment',
  'Green',
  'Blue',
  'Orange',
  'Purple',
];

/// The note editing page.
///
/// Uses [WiredInput] for the title, [WiredTextArea] for content, and a
/// row of [WiredChip] widgets for color label selection.
class EditPage extends HookWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existingNote =
        ModalRoute.of(context)?.settings.arguments as Note?;
    final isNew = existingNote == null;

    final titleController = useTextEditingController(
      text: existingNote?.title ?? '',
    );
    final contentController = useTextEditingController(
      text: existingNote?.content ?? '',
    );
    final selectedColor = useState(
      existingNote?.color ?? _colorOptions.first,
    );

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: WiredIconButton(
          icon: Icons.arrow_back,
          size: 40,
          onPressed: () => Navigator.pop(context),
          semanticLabel: 'Go back',
        ),
        title: Text(isNew ? 'New Note' : 'Edit Note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WiredInput(
              controller: titleController,
              hintText: 'Note title...',
            ),
            const SizedBox(height: 16),
            WiredTextArea(
              controller: contentController,
              hintText: 'Write your thoughts...',
              maxLines: 12,
              minLines: 6,
            ),
            const SizedBox(height: 20),
            Text(
              'Label color',
              style: TextStyle(
                color: WiredTheme.of(context).textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_colorOptions.length, (index) {
                final color = _colorOptions[index];
                final isSelected = selectedColor.value == color;
                return GestureDetector(
                  onTap: () => selectedColor.value = color,
                  child: WiredChip(
                    avatar: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF5C3D2E),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                    label: Text(
                      _colorLabels[index],
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            WiredButton(
              onPressed: () {
                final note = isNew
                    ? Note.create(
                        title: titleController.text,
                        content: contentController.text,
                        color: selectedColor.value,
                      )
                    : existingNote.copyWith(
                        title: titleController.text,
                        content: contentController.text,
                        color: selectedColor.value,
                      );
                Navigator.pop(context, note);
              },
              child: Text(isNew ? 'Create Note' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
