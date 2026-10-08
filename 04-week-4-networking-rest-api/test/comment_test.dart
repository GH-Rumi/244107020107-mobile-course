import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart'; // Sesuaikan dengan nama project kamu

void main() {
  group('Comment Model Test', () {
    test('fromJson harus menangani field yang hilang atau null dengan nilai default', () {
      // Penjelasan: Arrange - Menyiapkan JSON kotor (ada field hilang, ada field null)
      final Map<String, dynamic> incompleteJson = {
        'postId': 1,
        // 'id' dihilangkan sengaja
        'name': null, // 'name' diset null sengaja
        // 'email' dihilangkan sengaja
        'body': 'Ini isi komentar',
      };

      // Penjelasan: Act - Mengonversi JSON menjadi Object
      final comment = Comment.fromJson(incompleteJson);

      // Penjelasan: Assert - Memverifikasi bahwa aplikasi tidak crash 
      // dan nilai default diisi dengan benar.
      expect(comment.postId, 1); // Normal
      expect(comment.id, 0); // Default karena hilang
      expect(comment.name, ''); // Default karena null
      expect(comment.email, ''); // Default karena hilang
      expect(comment.body, 'Ini isi komentar'); // Normal
    });
  });
}
