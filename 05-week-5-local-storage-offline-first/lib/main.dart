import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(
    // ProviderScope wajib ada untuk aplikasi berbasis Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mendengarkan perubahan state dari SharedPreferences
    final isDarkMode = ref.watch(darkModeProvider).value ?? false;

    return MaterialApp(
      title: 'Offline Notes',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
