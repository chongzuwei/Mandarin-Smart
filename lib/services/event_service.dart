import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventService {
  const EventService();

  CollectionReference<Map<String, dynamic>> get _events =>
      FirebaseFirestore.instance.collection('events');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEvents() {
    return _events.snapshots();
  }

  Future<String?> createEvent({
    required String title,
    required DateTime startAt,
    String? location,
    String? description,
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

      final creatorName = (profile.data()?['name'] ?? user.displayName ?? '')
          .toString();

      await _events.add({
        'title': title.trim(),
        'location': location?.trim() ?? '',
        'description': description?.trim() ?? '',
        'startAt': Timestamp.fromDate(startAt),
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

  Future<String?> updateEvent({
    required String eventId,
    required String title,
    required DateTime startAt,
    String? location,
    String? description,
  }) async {
    try {
      await _events.doc(eventId).update({
        'title': title.trim(),
        'location': location?.trim() ?? '',
        'description': description?.trim() ?? '',
        'startAt': Timestamp.fromDate(startAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteEvent(String eventId) async {
    try {
      await _events.doc(eventId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}