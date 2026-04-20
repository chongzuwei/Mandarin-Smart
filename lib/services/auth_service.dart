enum UserRole {
  committee,
  student,
}

class AuthService {
  const AuthService();

  /// Placeholder implementation for account creation.
  /// Replace with Firebase/Auth API integration when backend is ready.
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
  /*
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': fullName,
          'email': email,
          'role': role.name,
        },
        SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
    }
    */
  }
}
