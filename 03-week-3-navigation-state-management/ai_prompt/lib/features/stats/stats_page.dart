// lib/features/stats/stats_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stats_notifier.dart';

/// ConsumerWidget = Widget stateless yang bisa "watch" provider.
/// Setiap kali state provider berubah, widget ini rebuild otomatis.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch() = subscribe ke provider; rebuild saat state berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: Center(
        // when() = pattern-matching untuk 3 kondisi AsyncValue.
        child: statsAsync.when(
          // 1) LOADING -> tampilkan spinner.
          loading: () => const CircularProgressIndicator(),

          // 2) ERROR -> tampilkan pesan + tombol retry.
          //    `error` = object exception, `stackTrace` opsional.
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Terjadi kesalahan:\n$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Tombol retry memanggil notifier.retry()
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  onPressed: () {
                    // .notifier memberi akses ke instance StatsNotifier.
                    ref.read(statsProvider.notifier).retry();
                  },
                ),
              ],
            ),
          ),

          // 3) SUCCESS -> tampilkan ListView 3 item.
          data: (stats) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: stats.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final item = stats[index];
              return ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text(item.title),
                // Contoh format: "1250 orang"
                trailing: Text(
                  '${item.value} ${item.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
