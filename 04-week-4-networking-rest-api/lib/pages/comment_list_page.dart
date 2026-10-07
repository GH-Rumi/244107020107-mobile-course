import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_providers.dart'; // Sesuaikan import jika namanya berbeda

class CommentListPage extends ConsumerWidget {
  final int postId;
  
  // Kita buat default postId = 1 untuk uji coba
  const CommentListPage({super.key, this.postId = 1});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Karena kita pakai FamilyAsyncNotifier, kita masukkan postId sebagai argumen
    final commentsAsync = ref.watch(commentListProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar untuk Post #$postId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(commentListProvider(postId).notifier).refresh(),
          ),
        ],
      ),
      body: commentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menggunakan fungsi pesan error ramah pengguna yang kita buat
                Text(
                  friendlyCommentErrorMessage(err),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(commentListProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (comments) {
          if (comments.isEmpty) {
            return const Center(child: Text('Tidak ada komentar.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(commentListProvider(postId).notifier).refresh(),
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(comment.id.toString()),
                  ),
                  title: Text(
                    comment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    comment.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
