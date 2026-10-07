import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import halaman yang sudah dibuat
import 'pages/todo_page.dart';
import 'pages/stats_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

// 1. Konfigurasi GoRouter
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute berfungsi sebagai kerangka layout utama (punya NavigationBar)
    ShellRoute(
      builder: (context, state, child) => AppLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Ubah MaterialApp menjadi MaterialApp.router
    return MaterialApp.router(
      title: 'Week 3 - ToDo Refactor',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      routerConfig: _router, // Daftarkan konfigurasi router di sini
    );
  }
}

// 3. Buat Wrapper untuk Navigation Bar
class AppLayout extends StatelessWidget {
  final Widget child; // child ini akan berisi TodoPage atau StatsPage

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Menentukan index aktif dari path GoRouter saat ini
    final String location = GoRouterState.of(context).uri.path;
    final int currentIndex = location == '/stats' ? 1 : 0;

    return Scaffold(
      body: child, // Menampilkan halaman sesuai route
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // Navigasi menggunakan context.go()
          if (index == 0) context.go('/');
          if (index == 1) context.go('/stats');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
