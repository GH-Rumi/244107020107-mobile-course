# Laporan Praktikum & Refactoring: Flutter Offline Notes (SQLite & Riverpod)

## 1. Analisis Trade-off Penyimpanan Lokal

Setiap teknologi penyimpanan memiliki kompromi (*trade-off*) berdasarkan kriteria arsitektur aplikasi:

* **SharedPreferences**
  * **Trade-off:** Sangat efisien dan minim *boilerplate* untuk menyimpan tipe data primitif, namun tidak dirancang untuk koleksi data besar. Tidak mendukung *query* atau relasi.
  * **Testing & Type-Safety:** Sangat mudah diuji (banyak *mock* bawaan), *type-safe* untuk nilai primitif dasar.
* **Hive (NoSQL / Key-Value)**
  * **Trade-off:** Sangat reaktif dan cepat karena di *memory*, namun kurang efisien untuk *query* kompleks dan relasi antar entitas (seperti pencarian bersyarat pada 1000+ data).
  * **Testing & Type-Safety:** Membutuhkan *type adapter* (*code generation*), cukup *type-safe*.
* **sqflite (SQLite)**
  * **Trade-off:** Unggul mutlak dalam fleksibilitas *query* kompleks dan relasi antar tabel. Sangat skalabel untuk 1000+ data karena eksekusi dilakukan di level database. Kekurangannya adalah *boilerplate* manual (`Map` mapping) dan tidak reaktif bawaan.
  * **Testing & Type-Safety:** Memerlukan injeksi database *in-memory* atau *fake repository* saat pengujian.
* **Drift**
  * **Trade-off:** Memberikan *type-safety* penuh dan reaktivitas bawaan (*Stream*) layaknya SQL modern di Dart. Kelemahannya adalah kurva belajar yang curam dan ukuran *boilerplate* yang besar.
  * **Testing & Type-Safety:** Sangat *type-safe* pada fase *compile* dan mudah diuji.

---

## 2. Rekomendasi Final & Skema Database

| Kebutuhan | Pilihan Terbaik | Alasan (Berdasarkan Kriteria) |
| :--- | :--- | :--- |
| **Preferensi Tema** (Nilai primitif) | **SharedPreferences** | Minim *boilerplate*, tidak butuh *query*, sangat cepat dibaca saat aplikasi pertama kali menyala, dan mudah di-mock. |
| **CRUD Catatan** (Terstruktur & Offline-first) | **sqflite** | Menangani 1000+ catatan dengan *query* efisien (seperti memilah `dirty = 1` untuk antrean sinkronisasi) di level database. |

### Skema Tabel untuk Skalabilitas 1000+ Catatan
```sql
-- 1. Tabel Utama Catatan
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at INTEGER NOT NULL, -- Epoch Milliseconds untuk kecepatan komparasi waktu
  dirty INTEGER NOT NULL DEFAULT 0
);

-- 2. Index untuk pengurutan tampilan utama (Terbaru ke Terlama)
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);

-- 3. Index untuk antrean sinkronisasi
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

---

## 3. AI Verification Checklist

| # | Item | Status | Catatan |
|---|---|:---:|---|
| 1 | State immutable | ✅ | Model catatan (`Note`) bersifat *immutable* (`final` properties); mutasi state database dilakukan lewat pembaruan baris terstruktur. |
| 2 | `ref.watch` di build, `ref.read` di callback | ✅ | `ref.watch` digunakan di dalam metode `build()` widget, sedangkan `ref.read` digunakan di dalam event handler (`onPressed`, `onTap`). |
| 3 | Ketiga state `AsyncValue` ditangani | ✅ | `AsyncValue.when` menangani state `data`, `loading`, dan `error` secara lengkap pada seluruh halaman utama dan detail. |
| 4 | Provider eksplisit & tidak duplikat | ✅ | Provider dideklarasikan secara eksplisit (`NoteRepository`, `notesProvider`, `dirtyCountProvider`) tanpa adanya duplikasi. |
| 5 | Tidak pakai API Riverpod lama | ✅ | Menggunakan arsitektur Riverpod modern (`Provider`, `FutureProvider`, `ConsumerWidget`) tanpa `StateProvider` atau `StateNotifierProvider` lama. |
| 6 | `flutter analyze` & `flutter test` bersih | ✅ | Analisis kode bersih tanpa *issue*, dan seluruh rangkaian *unit test* dengan *Fake Repository* berhasil dijalankan dengan status hijau (*passed*). |

### Catatan Tambahan
* Akses penyimpanan lokal terisolasi dengan baik melalui *repository pattern* (`PrefsRepository` & `NoteRepository`), menjaga UI tetap bersih dari logika akses database langsung.
* Dependency injeksi pada constructor *repository* memungkinkan pengujian instan menggunakan *Fake Repository* tanpa menyentuh *instance* SQLite fisik di disk.

---

## 4. Checklist Verifikasi Mandiri (Refactoring)
- | ✅ | UI tidak memanggil SQLite/SharedPreferences langsung; semua lewat repository + provider.
- | ✅ | Aplikasi penuh berfungsi dalam mode pesawat: baca, tambah, hapus catatan.
- | ✅ | Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet.
- | ✅ | `flutter analyze` tanpa issue dan semua test lulus.
