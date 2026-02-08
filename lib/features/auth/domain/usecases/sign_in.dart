import 'package:firebase_auth/firebase_auth.dart';
import 'package:seafarer_bio_data/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User?> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
