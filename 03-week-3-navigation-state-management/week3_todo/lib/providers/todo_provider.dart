import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo({required this.id, required this.title, this.done = false});
  final String id;
  final String title;
  final bool done;

  Todo copyWith({String? id, String? title, bool? done}) =>
      Todo(id: id ?? this.id, title: title ?? this.title, done: done ?? this.done);
}

// 1. Ubah Notifier menjadi AsyncNotifier
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    // Mensimulasikan loading pengambilan data dari server selama 2 detik
    await Future.delayed(const Duration(seconds: 2));
    return []; // Return data awal (success state)
  }

  void add(String title) {
    // Ambil data saat ini (jika ada), abaikan jika sedang loading/error
    final currentTodos = state.value ?? [];
    // Update state dengan AsyncValue.data (success state)
    state = AsyncValue.data([
      ...currentTodos,
      Todo(id: DateTime.now().toString(), title: title)
    ]);
  }

  void toggle(String id) {
    final currentTodos = state.value ?? [];
    state = AsyncValue.data(currentTodos.map((todo) {
      if (todo.id == id) return todo.copyWith(done: !todo.done);
      return todo;
    }).toList());
  }

  void remove(String id) {
    final currentTodos = state.value ?? [];
    state = AsyncValue.data(currentTodos.where((todo) => todo.id != id).toList());
  }
}

// Gunakan AsyncNotifierProvider
final todoListProvider = AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

// 1. Deklarasikan Enum
enum TodoFilter { all, active, completed }

// 2. Buat Class Notifier pengganti StateProvider
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  // Method untuk mengubah state
  void setFilter(TodoFilter newFilter) {
    state = newFilter;
  }
}

// 3. Daftarkan Provider-nya
final todoFilterProvider = NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

// 2. Filter provider juga harus mengembalikan AsyncValue
final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final filter = ref.watch(todoFilterProvider);
  final todosAsync = ref.watch(todoListProvider);

  // whenData akan mem-filter HANYA JIKA statusnya sedang success (ada datanya)
  return todosAsync.whenData((todos) {
    switch (filter) {
      case TodoFilter.active:
        return todos.where((todo) => !todo.done).toList();
      case TodoFilter.completed:
        return todos.where((todo) => todo.done).toList();
      case TodoFilter.all:
        return todos;
    }
  });
});
