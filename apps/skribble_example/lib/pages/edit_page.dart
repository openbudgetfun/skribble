import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/note.dart';

/// The pastels a note can be coloured in with. The first is the default.
const _noteColors = <({String name, Color color})>[
  (name: 'Parchment', color: Color(0xFFF5ECD7)),
  (name: 'Green', color: Color(0xFFDCEBD5)),
  (name: 'Blue', color: Color(0xFFD9E7F5)),
  (name: 'Orange', color: Color(0xFFF8E1CC)),
  (name: 'Purple', color: Color(0xFFE8DEF3)),
];

/// The note editing page.
///
/// Uses [WiredInput] for the title, [WiredTextArea] for content, and a
/// row of [WiredChoiceChip] widgets for the note's colour. Opened with a
/// [Note] as the route argument it edits that note; opened without one it
/// writes a new note. Either way it pops with the saved note.
class EditPage extends HookWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existingNote = ModalRoute.of(context)?.settings.arguments as Note?;
    final isNew = existingNote == null;

    // Hooks own the controllers, so they are disposed with the page.
    final titleController = useTextEditingController(
      text: existingNote?.title ?? '',
    );
    final contentController = useTextEditingController(
      text: existingNote?.content ?? '',
    );
    final selectedColor = useState(
      existingNote?.color ?? _noteColors.first.color,
    );
    final theme = WiredTheme.of(context);

    void save() {
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
    }

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
                color: theme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (index, option) in _noteColors.indexed)
                  WiredChoiceChip(
                    // Neighbouring chips of the same size get their own
                    // seeds, so their wobbles don't read as copies.
                    seed: index + 1,
                    selected: selectedColor.value == option.color,
                    onSelected: (_) => selectedColor.value = option.color,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: option.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.borderColor),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(option.name),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            WiredFilledButton(
              onPressed: save,
              child: Text(isNew ? 'Create Note' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
