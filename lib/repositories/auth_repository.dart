import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Method to check if a user is logged in
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  // Existing sign-in method
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Existing sign-out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
