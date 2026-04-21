import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  committee,
  student,
}

class AuthService {
  const AuthService();

  Future<String?> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return "Registration failed. Please try again.";
      }

      await user.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': fullName,
        'email': email,
        'role': role.name,
        'roleIndex': role.index,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return "This email is already registered. Please sign in instead.";
      }

      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return "No user found";

      await user.reload();

      if (user.emailVerified) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'isVerified': true});

        return null;
      } else {
        return "Email not verified yet";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
