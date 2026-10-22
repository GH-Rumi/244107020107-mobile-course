import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart'; // Import logika sync terisolasi
import '../widgets/note_tile.dart'; // Import widget tile baru
import 'settings_page.dart';
import 'note_detail_page.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final dirtyCountState = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: dirtyCountState.maybeWhen(
                data: (count) => Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () async {
                      final repo = ref.read(noteRepositoryProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menyinkronkan data...')),
                      );
                      await syncNotes(repo); // Memanggil sync dari sync.dart
                      ref.invalidate(notesProvider);
                      ref.invalidate(dirtyCountProvider);
                    },
                  ),
                ),
                orElse: () => const Icon(Icons.sync),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: notesState.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteTile(
                note: note,
                onTap: () {
                  // Navigasi ke detail catatan (simulasi GoRouter / Navigator standar)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteDetailPage(noteId: note.id ?? 0),
                    ),
                  );
                },
                onDelete: () async {
                  await ref.read(noteRepositoryProvider).deleteNote(note.id!);
                  ref.invalidate(notesProvider);
                  ref.invalidate(dirtyCountProvider);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(noteRepositoryProvider).addNote(
                title: 'Catatan Baru ${DateTime.now().second}',
                body: 'Isi catatan offline-first...',
              );
          ref.invalidate(notesProvider);
          ref.invalidate(dirtyCountProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
