import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  // Penjelasan: Method ini menerima postId untuk memfilter komentar.
  Future<List<Comment>> fetchComments(int postId) async {
    // Penjelasan: Konfigurasi Options di tingkat request untuk memastikan
    // timeout spesifik 10 detik sesuai dengan kebutuhan.
    final options = Options(
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );

    // Endpoint GET /comments dengan query parameter postId={id}
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: options,
    );

    final data = response.data ?? [];
    
    // Parsing List JSON menjadi List Object Comment
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
