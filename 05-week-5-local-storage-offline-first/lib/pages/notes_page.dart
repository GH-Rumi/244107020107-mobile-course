import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import 'settings_page.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  // Fungsi simulasi sync sesuai jobsheet
  Future<int> syncNotes(NoteRepository repo) async {
    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;
    
    // Simulasi upload / koneksi jaringan lambat
    await Future.delayed(const Duration(seconds: 1));
    await repo.markAllSynced();
    return dirtyCount;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesProvider);
    final dirtyCountState = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          // Indikator Badge Jumlah Dirty
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
                      // Jalankan antrean sync
                      final repo = ref.read(noteRepositoryProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menyinkronkan data...')),
                      );
                      await syncNotes(repo);
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
              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.updatedAt.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (note.dirty) const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await ref.read(noteRepositoryProvider).deleteNote(note.id!);
                        ref.invalidate(notesProvider);
                        ref.invalidate(dirtyCountProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Menambahkan catatan akan tersimpan sebagai dirty = 1
          await ref.read(noteRepositoryProvider).addNote(
                title: 'Catatan ${DateTime.now().second}',
                body: 'Deskripsi singkat...',
              );
          // Refresh state UI
          ref.invalidate(notesProvider);
          ref.invalidate(dirtyCountProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
