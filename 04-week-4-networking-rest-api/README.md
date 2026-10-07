# AI Verification Checklist - Praktikum Minggu 4

Berikut adalah hasil verifikasi dari kode yang dihasilkan oleh AI untuk tugas AI Challenge:

1. **Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?**
   **Jawab:** Aman. UI (`CommentListPage`) sama sekali tidak memanggil Dio. UI hanya memantau state dari Riverpod (`commentListProvider`). Alur pemanggilannya adalah: UI -> Provider/Notifier -> `CommentRepository` -> `Dio`.

2. **Apakah fromJson aman null, atau masih memakai cast langsung yang bisa crash?**
   **Jawab:** Aman dari null. Method `Comment.fromJson` sudah menggunakan *defensive casting* seperti `(json['id'] as num?)?.toInt() ?? 0` dan `json['name'] as String? ?? ''`. Ini mencegah error `type 'Null' is not a subtype`.

3. **Apakah semua tipe DioExceptionType dipetakan ke pesan pengguna?**
   **Jawab:** Ya, fungsi `friendlyCommentErrorMessage` di file `comment_providers.dart` telah memetakan `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, dan `badResponse` (seperti 404 dan 500) menjadi kalimat bahasa Indonesia yang ramah pengguna.

4. **Apakah baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method?**
   **Jawab:** Ya, `baseUrl` dan pengaturan utama Dio terpusat di `createDio()` pada file `api_client.dart`. (Catatan: Ada tambahan spesifik `Options(receiveTimeout: ...)` di repository semata-mata untuk memenuhi syarat *challenge* "timeout 10 detik" khusus untuk endpoint comments, namun konfigurasi dasarnya tetap terpusat).

5. **Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path? Tambahkan minimal 1 edge case sendiri.**
   **Jawab:** Test awal sudah menguji JSON dengan field yang sengaja dihilangkan dan diisi `null`. Sebagai tambahan *edge case* mandiri, saya telah menambahkan pengujian ekstrem dimana API mengembalikan JSON kosong `{}` sama sekali.
