import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // Menerapkan UI Loading, Error, dan Success
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Terjadi kesalahan: $error')),
        data: (todos) {
          final completed = todos.where((t) => t.done).length;
          final active = todos.length - completed;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Tugas: ${todos.length}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text('Selesai: $completed', style: const TextStyle(color: Colors.green, fontSize: 18)),
                Text('Belum Selesai: $active', style: const TextStyle(color: Colors.red, fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
