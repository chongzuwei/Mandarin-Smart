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

  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        return "Login failed. Please try again.";
      }

      await user.reload();

      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        return "EMAIL_NOT_VERIFIED";
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        return "User profile not found. Please register again.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email.";

        case 'wrong-password':
        case 'invalid-credential':
          return "Incorrect email or password.";

        case 'invalid-email':
          return "Invalid email format.";

        case 'too-many-requests':
          return "Too many attempts. Try again later.";

        default:
          return "Login failed. Please try again.";
      }
    } catch (e) {
      return "Unexpected error occurred.";
    }
  }

  Future<String?> resendVerificationEmailLoggedIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return "No user logged in.";
      }

      if (user.emailVerified) {
        return "Email already verified.";
      }

      await user.sendEmailVerification();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found for this email.";
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateUserProfile({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "No user found";

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': name,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
