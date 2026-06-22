import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementService {
  const AnnouncementService();

  CollectionReference<Map<String, dynamic>> get _announcements =>
      FirebaseFirestore.instance.collection('announcements');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAnnouncements() {
    return _announcements.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchActiveAnnouncements({
    int limit = 5,
  }) {
    return _announcements
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<String?> createAnnouncement({
    required String title,
    required String message,
    required bool isPublished,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'No user found';
      }

      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final creatorName =
          (profile.data()?['name'] ?? user.displayName ?? '').toString();

      await _announcements.add({
        'title': title.trim(),
        'message': message.trim(),
        'isPublished': isPublished,
        'creatorId': user.uid,
        'creatorEmail': user.email ?? '',
        'creatorName': creatorName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateAnnouncement({
    required String announcementId,
    required String title,
    required String message,
    required bool isPublished,
  }) async {
    try {
      await _announcements.doc(announcementId).update({
        'title': title.trim(),
        'message': message.trim(),
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAnnouncement(String announcementId) async {
    try {
      await _announcements.doc(announcementId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
