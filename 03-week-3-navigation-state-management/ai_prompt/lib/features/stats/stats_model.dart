// lib/features/stats/stats_model.dart

/// Model data statistik yang akan ditampilkan di UI.
/// Immutable class sederhana (bisa juga pakai freezed/equatable).
class Stats {
  final String title; // Nama statistik, misal "Total Pengguna"
  final int value;    // Nilai statistik, misal 1250
  final String unit;  // Satuan, misal "orang", "%", "ms"

  const Stats({
    required this.title,
    required this.value,
    required this.unit,
  });
}
