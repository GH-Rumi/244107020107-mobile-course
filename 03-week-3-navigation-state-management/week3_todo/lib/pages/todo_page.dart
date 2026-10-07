// file: lib/pages/todo_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca dari filteredTodosProvider, bukan list utama
    final todos = ref.watch(filteredTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          // Filter Popup Menu
          PopupMenuButton<TodoFilter>(
            onSelected: (filter) => ref.read(todoFilterProvider.notifier).setFilter(filter),
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('Semua')),
              PopupMenuItem(value: TodoFilter.active, child: Text('Belum Selesai')),
              PopupMenuItem(value: TodoFilter.completed, child: Text('Selesai')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(child: Text('Tidak ada tugas'))
          : ListView.builder(
              itemCount: todos.length,
              // Memanggil TodoTile yang ada di bawah file ini
              itemBuilder: (context, index) => TodoTile(todo: todos[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

// --- refactoring: Ekstraksi Widget TodoTile ---
class TodoTile extends ConsumerWidget {
  final Todo todo; // Hanya membutuhkan objek Todo yang sudah memiliki id

  const TodoTile({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: todo.done,
        onChanged: (_) => ref.read(todoListProvider.notifier).toggle(todo.id),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => ref.read(todoListProvider.notifier).remove(todo.id),
      ),
    );
  }
}
