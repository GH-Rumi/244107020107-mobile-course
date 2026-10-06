// lib/features/stats/stats_notifier.dart

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stats_model.dart';

/// AsyncNotifier bertanggung jawab untuk:
/// 1. Mengambil data statistik dari "server" (disimulasikan).
/// 2. Mengelola state loading / error / data secara otomatis
///    melalui AsyncValue yang disediakan Riverpod.
class StatsNotifier extends AsyncNotifier<List<Stats>> {
  /// Random dipakai untuk mensimulasikan kegagalan 30%.
  /// Dibuat sebagai field agar mudah di-mock pada unit test.
  final Random _random;

  StatsNotifier({Random? random}) : _random = random ?? Random();

  /// build() dipanggil pertama kali provider dibaca,
  /// dan juga setiap kali provider di-refresh / di-invalidate.
  /// Return value-nya menjadi state awal (AsyncValue.data).
  @override
  Future<List<Stats>> build() async {
    return _fetchStats();
  }

  /// Fungsi internal untuk mengambil data statistik.
  /// - Delay 2 detik untuk mensimulasikan network call.
  /// - 30% kemungkinan throw Exception (simulasi server error).
  Future<List<Stats>> _fetchStats() async {
    // Simulasi latency jaringan 2 detik.
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi kegagalan 30% (angka acak < 0.3).
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik dari server');
    }

    // Data sukses: 3 item statistik.
    return const [
      Stats(title: 'Total Pengguna', value: 1250, unit: 'orang'),
      Stats(title: 'Tingkat Konversi', value: 4, unit: '%'),
      Stats(title: 'Rata-rata Latensi', value: 230, unit: 'ms'),
    ];
  }

  /// Method publik untuk retry saat terjadi error.
  /// Kita set state ke loading dulu, lalu coba fetch ulang.
  Future<void> retry() async {
    // state = AsyncValue.loading() -> UI otomatis menampilkan spinner.
    state = const AsyncValue.loading();

    // guard: menjalankan future & menangkap error/success secara aman,
    // lalu otomatis meng-update state ke data/error.
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

/// Provider global untuk StatsNotifier.
/// Di UI kita cukup watch provider ini.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<Stats>>(StatsNotifier.new);
