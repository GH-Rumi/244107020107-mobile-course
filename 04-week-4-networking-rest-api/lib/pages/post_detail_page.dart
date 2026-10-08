import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/providers.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId, this.postArg});

  final int postId;
  final Post? postArg;

  @override

  Widget build(BuildContext context, WidgetRef ref) {
    if (postArg != null) {
      return _buildScaffold(context, postArg!);
    }

    final postsAsync = ref.watch(postListProvider);

    return postsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detail Post')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Post')),
        body: Center(child: Text('Gagal memuat detail: $err')),
      ),
      data: (posts) {
        final post = posts.firstWhere(
          (p) => p.id == postId,
          orElse: () => Post(userId: 0, id: postId, title: 'Tidak Ditemukan', body: ''),
        );
        return _buildScaffold(context, post);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Post post) {
    return Scaffold(
      appBar: AppBar(title: Text('Post #${post.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
