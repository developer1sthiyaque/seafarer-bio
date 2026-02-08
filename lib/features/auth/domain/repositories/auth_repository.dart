import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> signUpWithEmailAndPassword(String firstname,String lastname,String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
