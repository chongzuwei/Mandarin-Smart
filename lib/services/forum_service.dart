import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForumService {
  const ForumService();

  CollectionReference<Map<String, dynamic>> get _posts =>
      FirebaseFirestore.instance.collection('forum_posts');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPosts() {
    return _posts.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchReplies(String postId) {
    return _posts
        .doc(postId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<String?> createPost({
    required String title,
    required String body,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'No user found';

      final authorName = await _readAuthorName(user);

      await _posts.add({
        'title': title.trim(),
        'body': body.trim(),
        'authorId': user.uid,
        'authorEmail': user.email ?? '',
        'authorName': authorName,
        'replyCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> addReply({
    required String postId,
    required String body,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'No user found';

      final authorName = await _readAuthorName(user);
      final postRef = _posts.doc(postId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final replyRef = postRef.collection('replies').doc();

        transaction.set(replyRef, {
          'body': body.trim(),
          'authorId': user.uid,
          'authorEmail': user.email ?? '',
          'authorName': authorName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(postRef, {
          'replyCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deletePost(String postId) async {
    try {
      await _posts.doc(postId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteReply({
    required String postId,
    required String replyId,
  }) async {
    try {
      final postRef = _posts.doc(postId);
      final replyRef = postRef.collection('replies').doc(replyId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(replyRef);
        transaction.update(postRef, {
          'replyCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _readAuthorName(User user) async {
    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return (profile.data()?['name'] ?? user.displayName ?? user.email ?? 'User')
        .toString();
  }
}
