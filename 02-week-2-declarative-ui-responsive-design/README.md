# **AI Prompt Challenge**

**1. Perbandingan GridView vs LayoutBuilder + Column/Row**

Pendekatan hibrida direkomendasikan: `LayoutBuilder` untuk menyusun struktur makro (sidebar vs konten), dan `GridView` untuk elemen mikro di dalamnya (grid kartu nilai).

| Parameter | GridView | LayoutBuilder + Column/Row |
| --- | --- | --- |
| **Kekuatan Utama** | Virtualisasi bawaan (performa optimal untuk data panjang), perhitungan kolom otomatis. | Kontrol presisi tinggi pada struktur layout, fleksibel untuk ukuran *widget* yang heterogen. |
| **Kelemahan** | Kaku (dipaksa seragam via `childAspectRatio`), sulit membuat layout asimetris (misal lebar sidebar 30%). | Tidak ada virtualisasi otomatis, banyak *boilerplate*, risiko *overflow* horizontal tinggi. |
| **Aksesibilitas (Screen Reader)** | Urutan baca aman (kiri-kanan), tapi item di luar layar tidak terdeteksi. Rentan terpotong saat font dibesarkan. | Adaptasi font besar sangat baik (*reflow* alami), seluruh elemen terbaca, tapi urutan baca bisa melenceng saat *breakpoint* berubah. |

**2. Solusi Error Rendering `Expanded`**

Penyebab error *RenderFlex unbounded* adalah menempatkan `Expanded` di dalam *widget scrollable* (`ListView` atau `SingleChildScrollView`). `Expanded` butuh ruang berbatas pasti (bounded), sementara area *scroll* bersifat tak terbatas (*double.infinity*).

* **Keputusan 1 (Tinggi Eksplisit):** Ganti `Expanded` dengan `SizedBox(height: ...)` jika grafik atau elemen tersebut harus ikut terguling (di-scroll) bersama elemen lainnya.
* **Keputusan 2 (Pembalikan Struktur):** Letakkan `Column` di bagian paling luar yang dibatasi oleh layar, lalu gunakan `Expanded` untuk membungkus `ListView`. Dipilih jika area grafik ingin mengisi sisa layar dengan statis, sementara daftar tugas di bawahnya bisa di-scroll secara terpisah.

**3. Hasil Audit Teknis**

* **Risiko Overflow (< 600px):** Kode contoh perbaikan `Expanded` tidak dijamin aman pada layar kecil. Penggunaan `SizedBox(height: 220)` dapat memicu *overflow* saat HP posisi *landscape*, dan teks dinamis pada `Row` tanpa pembatas tetap akan memicu *overflow* horizontal.
* **Celah Semantics:** Komponen visual berbasis kanvas (seperti grafik nilai) dilewati oleh *screen reader* jika tidak dibungkus dengan `Semantics(label: ...)`. Beralih ke `ListView.builder` untuk optimasi daftar panjang akan mengembalikan masalah "virtualisasi", di mana item belum terbaca sebelum di-scroll.
* **Validasi Komponen:** Seluruh *widget* yang digunakan (`Row`, `Column`, `Expanded`, `MergeSemantics`, `OrdinalSortKey`, `LayoutBuilder`) dipastikan 100% tersedia di Flutter Stable tanpa memerlukan paket eksternal dari `pub.dev`.

Link Prompt : https://claude.ai/chat/e2789294-ea8f-435d-80e6-c7919d77fd4d
