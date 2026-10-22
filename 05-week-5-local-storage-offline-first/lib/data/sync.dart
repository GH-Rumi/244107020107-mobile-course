import 'repositories/note_repository.dart';

// Fungsi simulasi cache pos dari jaringan (contoh dari jobsheet minggu sebelumnya)
Future<void> refreshPostsInBackground() async {
  // Simulasi fetch API background
  await Future.delayed(const Duration(milliseconds: 500));
}

// Logika sinkronisasi catatan kotor (dirty) terisolasi
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  
  // Simulasi upload ke server/REST API
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
