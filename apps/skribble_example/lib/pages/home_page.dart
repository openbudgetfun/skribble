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
/// Swiping a note away deletes it, and the snack bar offers to undo.
///
/// The notes live in this page's state, so they last as long as the app
/// runs. A real app would load and save them through a repository.
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // useMemoized builds the sample notes once, not on every rebuild.
    final notes = useState(useMemoized(_sampleNotes));
    final searchQuery = useState('');
    final searchController = useTextEditingController();

    final filteredNotes = useMemoized(() {
      if (searchQuery.value.isEmpty) return notes.value;
      final query = searchQuery.value.toLowerCase();
      return notes.value.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    }, [notes.value, searchQuery.value]);

    Future<void> createNote() async {
      final result = await Navigator.pushNamed(context, '/edit');
      if (result is Note) notes.value = [...notes.value, result];
    }

    Future<void> editNote(Note note) async {
      final result = await Navigator.pushNamed(
        context,
        '/edit',
        arguments: note,
      );
      if (result is Note) {
        notes.value = [
          for (final n in notes.value)
            if (n.id == result.id) result else n,
        ];
      }
    }

    void deleteNote(Note note) {
      final index = notes.value.indexWhere((n) => n.id == note.id);
      notes.value = [
        for (final n in notes.value)
          if (n.id != note.id) n,
      ];

      // Look the messenger up now: the dismissed card's context is gone by
      // the time anyone taps "Undo".
      final messenger = ScaffoldMessenger.of(context);
      showWiredSnackBar(
        context,
        content: WiredSnackBarContent(
          action: WiredTextButton(
            onPressed: () {
              notes.value = [...notes.value]
                ..insert(index.clamp(0, notes.value.length), note);
              messenger.hideCurrentSnackBar();
            },
            child: const Text('UNDO'),
          ),
          child: const Text('Note deleted'),
        ),
      );
    }

    return WiredScaffold(
      appBar: WiredAppBar(
        // The Builder's context sits below the scaffold, which
        // Scaffold.of needs to find the drawer.
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
        onPressed: createNote,
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        searchQuery.value.isEmpty
                            ? 'No notes yet. Tap + to create one!'
                            : 'No notes match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: WiredTheme.of(context).disabledTextColor,
                          fontSize: 16,
                        ),
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
                        onDismissed: (_) => deleteNote(note),
                        child: NoteCard(
                          note: note,
                          onTap: () => editNote(note),
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

/// The notes a first launch starts with.
List<Note> _sampleNotes() {
  final now = DateTime.now();
  return [
    Note(
      id: 'sample-1',
      title: 'Welcome to Sketch Notes',
      content:
          'This is a hand-drawn notes app built with the Skribble design '
          'system. Every element you see has a sketchy, hand-drawn feel!',
      color: const Color(0xFFF5ECD7),
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    Note(
      id: 'sample-2',
      title: 'Shopping List',
      content: 'Milk, eggs, bread, butter, coffee beans, sketchbook',
      color: const Color(0xFFDCEBD5),
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    Note(
      id: 'sample-3',
      title: 'Project Ideas',
      content:
          'Build a weather app with hand-drawn clouds and sunshine '
          'animations. Use the Skribble canvas for custom drawings.',
      color: const Color(0xFFD9E7F5),
      createdAt: now.subtract(const Duration(hours: 3)),
      updatedAt: now,
    ),
  ];
}
