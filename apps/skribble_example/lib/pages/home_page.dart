import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/note.dart';
import 'package:skribble_example/widgets/drawer_menu.dart';
import 'package:skribble_example/widgets/note_card.dart';

/// The main notes list page.
///
/// Displays all notes as [WiredCard] items in a scrollable list with a
/// [WiredSearchBar] for filtering, a [WiredFloatingActionButton] for
/// creating new notes, and a [WiredDrawer] accessible via the app bar.
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = useState<List<Note>>(_sampleNotes());
    final searchQuery = useState('');
    final searchController = useTextEditingController();

    final filteredNotes = useMemoized(
      () {
        if (searchQuery.value.isEmpty) return notes.value;
        final query = searchQuery.value.toLowerCase();
        return notes.value.where((note) {
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query);
        }).toList();
      },
      [notes.value, searchQuery.value],
    );

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: Builder(
          builder: (context) => WiredIconButton(
            icon: Icons.menu,
            size: 40,
            onPressed: () => Scaffold.of(context).openDrawer(),
            semanticLabel: 'Open menu',
          ),
        ),
        title: const Text('Sketch Notes'),
      ),
      drawer: const DrawerMenu(),
      floatingActionButton: WiredFloatingActionButton(
        icon: Icons.add,
        semanticLabel: 'Create new note',
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/edit');
          if (result is Note) {
            notes.value = [...notes.value, result];
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: WiredSearchBar(
              controller: searchController,
              hintText: 'Search notes...',
              onChanged: (value) => searchQuery.value = value,
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      searchQuery.value.isEmpty
                          ? 'No notes yet. Tap + to create one!'
                          : 'No notes match your search.',
                      style: TextStyle(
                        color: WiredTheme.of(context).disabledTextColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: filteredNotes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return WiredDismissible(
                        dismissKey: ValueKey(note.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          final removedNote = note;
                          final removedIndex =
                              notes.value.indexWhere((n) => n.id == note.id);
                          notes.value = notes.value
                              .where((n) => n.id != note.id)
                              .toList();

                          showWiredSnackBar(
                            context,
                            content: WiredSnackBarContent(
                              action: GestureDetector(
                                onTap: () {
                                  final restored =
                                      List<Note>.from(notes.value);
                                  if (removedIndex >= 0 &&
                                      removedIndex <= restored.length) {
                                    restored.insert(removedIndex, removedNote);
                                  } else {
                                    restored.add(removedNote);
                                  }
                                  notes.value = restored;
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                },
                                child: Text(
                                  'UNDO',
                                  style: TextStyle(
                                    color: WiredTheme.of(context).borderColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              child: const Text('Note deleted'),
                            ),
                          );
                        },
                        child: NoteCard(
                          note: note,
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/edit',
                              arguments: note,
                            );
                            if (result is Note) {
                              notes.value = notes.value
                                  .map(
                                    (n) => n.id == result.id ? result : n,
                                  )
                                  .toList();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

List<Note> _sampleNotes() {
  return [
    Note(
      id: 'sample-1',
      title: 'Welcome to Sketch Notes',
      content:
          'This is a hand-drawn notes app built with the Skribble design '
          'system. Every element you see has a sketchy, hand-drawn feel!',
      color: const Color(0xFFF5ECD7),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: 'sample-2',
      title: 'Shopping List',
      content: 'Milk, eggs, bread, butter, coffee beans, sketchbook',
      color: const Color(0xFFE8F5E9),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      id: 'sample-3',
      title: 'Project Ideas',
      content:
          'Build a weather app with hand-drawn clouds and sunshine '
          'animations. Use the Skribble canvas for custom drawings.',
      color: const Color(0xFFE3F2FD),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now(),
    ),
  ];
}
