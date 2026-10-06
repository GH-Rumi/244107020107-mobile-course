// test/stats_notifier_test.dart

import 'dart:math';

import 'package:ai_prompt_test/features/stats/stats_model.dart';
import 'package:ai_prompt_test/features/stats/stats_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake Random deterministik.
/// - value >= 0.3 → simulasi SUKSES
/// - value <  0.3 → simulasi GAGAL
class FakeRandom implements Random {
  final double value;
  FakeRandom(this.value);

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

/// Random yang mengembalikan nilai bergantian dari list.
/// Dipakai untuk skenario "gagal dulu, baru sukses" di test retry.
class _SequenceRandom implements Random {
  final List<double> values;
  int _index = 0;

  _SequenceRandom(this.values) : assert(values.isNotEmpty);

  @override
  double nextDouble() {
    if (_index >= values.length) {
      throw StateError(
        'nextDouble dipanggil lebih dari ${values.length} kali',
      );
    }
    return values[_index++];
  }

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

/// Helper: bikin ProviderContainer dengan StatsNotifier + FakeRandom.
ProviderContainer _makeContainer(double randomValue) {
  final container = ProviderContainer(
    overrides: [
      statsProvider.overrideWith(
        () => StatsNotifier(random: FakeRandom(randomValue)),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('StatsNotifier', () {
    test('state awal adalah loading', () async {
      final container = _makeContainer(0.5);

      // Baca tanpa await → build() masih berjalan → state loading.
      final initial = container.read(statsProvider);
      expect(initial, isA<AsyncLoading<List<Stats>>>());

      // Tunggu future selesai agar tidak ada pending timer.
      await container.read(statsProvider.future);
    });

    test('berhasil mengambil data (random >= 0.3)', () async {
      final container = _makeContainer(0.5);

      final result = await container.read(statsProvider.future);

      expect(result, isA<List<Stats>>());
      expect(result, isNotNull);
      expect(result.length, 3);
      expect(result.first.title, 'Total Pengguna');
      expect(result.first.value, 1250);
      expect(result.first.unit, 'orang');

      final state = container.read(statsProvider);
      expect(state, isA<AsyncData<List<Stats>>>());
    });

    test('gagal mengambil data (random < 0.3)', () async {
      final container = _makeContainer(0.1);

      await expectLater(
        container.read(statsProvider.future),
        throwsA(isA<Exception>()),
      );

      final state = container.read(statsProvider);
      expect(state, isA<AsyncError<List<Stats>>>());
    });

    test('retry() mengubah state dari error ke data', () async {
      // Pemanggilan 1 → 0.1 (gagal), pemanggilan 2 → 0.5 (sukses).
      final sequence = _SequenceRandom([0.1, 0.5]);

      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: sequence),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 1) Pemanggilan pertama → error.
      await expectLater(
        container.read(statsProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(statsProvider), isA<AsyncError>());

      // 2) retry() → sukses.
      await container.read(statsProvider.notifier).retry();

      final state = container.read(statsProvider);
      expect(state, isA<AsyncData<List<Stats>>>());
      expect(state.value!.length, 3);
    });
  });
}
