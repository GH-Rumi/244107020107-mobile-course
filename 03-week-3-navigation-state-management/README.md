## AI Verification Checklist

| # | Item | Status | Catatan |
|---|---|---|---|
| 1 | State immutable | ✅ | Tidak ada `state.add()`; semua lewat reassignment + `AsyncValue.guard`. |
| 2 | `ref.watch` di build, `ref.read` di callback | ✅ | `watch` di `build()`, `read` di `onPressed`. |
| 3 | Ketiga state `AsyncValue` ditangani | ✅ | `loading`/`error`/`data` lengkap; error ada tombol retry. |
| 4 | Provider eksplisit & tidak duplikat | ✅ | `AsyncNotifierProvider<StatsNotifier, List<Stats>>`, satu deklarasi. |
| 5 | Tidak pakai API Riverpod lama | ✅ | Tidak ada `StateProvider` / `StateNotifierProvider`. Pakai `AsyncNotifier` + `ConsumerWidget`. |
| 6 | `flutter analyze` & `flutter test` bersih | ⚠️→✅ | Perbaikan: (a) lengkapi `FakeRandom`, (b) `await` future di test loading, (c) `_SequenceRandom` fail-safe. Setelah patch: 0 warning, semua test hijau. |

### Catatan tambahan
- `AsyncValue.when` default `skipLoadingOnRefresh: true` — saat `retry()`, data lama tetap tampil sampai fetch baru selesai. Perilaku ini disengaja.
- `Random` di-inject via constructor → mudah di-mock tanpa `mockito`.

## Checklist Verifikasi Mandiri (Refactoring)

- | ✅ | Navigasi GoRouter bekerja: pindah halaman, back, dan akses path detail langsung.
- | ✅ | `ProviderScope` membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.
- | ✅ | UI `AsyncValue` menangani loading, error, dan success, bukan hanya success.
- | ✅ | `flutter analyze` tanpa issue dan semua test lulus.
