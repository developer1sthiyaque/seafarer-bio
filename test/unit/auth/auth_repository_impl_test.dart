import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/features/auth/data/repositories/auth_repository_impl.dart';

import '../../helpers/mocks.dart';

/// Test plan §1.2 — Auth Service (data layer).
///
/// The auth boundary in this app is `FirebaseAuth`; it is mocked here so no
/// network call is made. Failures surface as `FirebaseAuthException`, which the
/// bloc later maps to user-facing messages (see `auth_bloc_test.dart`).
void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockUserCredential credential;
  late MockUser user;
  late AuthRepositoryImpl repository;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    credential = MockUserCredential();
    user = MockUser();
    repository = AuthRepositoryImpl(firebaseAuth: firebaseAuth);

    when(() => user.uid).thenReturn('uid-123');
    when(() => user.email).thenReturn('seafarer@example.com');
    when(() => credential.user).thenReturn(user);
  });

  group('§1.2 signInWithEmailAndPassword', () {
    test('returns the signed-in user on success', () async {
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      final result = await repository.signInWithEmailAndPassword(
        'seafarer@example.com',
        'correct-password',
      );

      expect(result, isNotNull);
      expect(result!.uid, 'uid-123');
      verify(() => firebaseAuth.signInWithEmailAndPassword(
            email: 'seafarer@example.com',
            password: 'correct-password',
          )).called(1);
    });

    test('rethrows FirebaseAuthException for wrong credentials', () async {
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => repository.signInWithEmailAndPassword(
          'seafarer@example.com',
          'nope',
        ),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'wrong-password')),
      );
    });

    test('rethrows FirebaseAuthException for an unknown user', () async {
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => repository.signInWithEmailAndPassword('nobody@example.com', 'pw'),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'user-not-found')),
      );
    });

    test('rethrows non-Firebase errors untouched', () async {
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(StateError('socket closed'));

      expect(
        () => repository.signInWithEmailAndPassword('a@b.co', 'pw'),
        throwsA(isA<StateError>()),
      );
    });

    test('returns null when Firebase reports no user on the credential', () async {
      when(() => credential.user).thenReturn(null);
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      expect(
        await repository.signInWithEmailAndPassword('a@b.co', 'pw'),
        isNull,
      );
    });
  });

  group('§1.2 signUpWithEmailAndPassword', () {
    test('returns the created user on success', () async {
      when(() => firebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      final result = await repository.signUpWithEmailAndPassword(
        'Isthiyaque',
        'Kambathagothi',
        'seafarer@example.com',
        'password123',
      );

      expect(result!.uid, 'uid-123');
      verify(() => firebaseAuth.createUserWithEmailAndPassword(
            email: 'seafarer@example.com',
            password: 'password123',
          )).called(1);
    });

    test('rethrows a conflict when the email is already registered', () async {
      when(() => firebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => repository.signUpWithEmailAndPassword(
          'Isthiyaque',
          'Kambathagothi',
          'taken@example.com',
          'password123',
        ),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'email-already-in-use')),
      );
    });
  });

  group('§1.2 signOut', () {
    test('delegates to FirebaseAuth', () async {
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => firebaseAuth.signOut()).called(1);
    });
  });

  group('§1.2 authStateChanges', () {
    test('forwards the FirebaseAuth stream (session restore source)', () async {
      when(() => firebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream<User?>.fromIterable([user, null]));

      expect(await repository.authStateChanges.toList(), [user, null]);
    });
  });

  group('§1.2 password reset', () {
    test(
      'sendPasswordResetEmail succeeds for a known address',
      () {
        // TDD — not implemented yet. Expected interface:
        //   abstract class AuthRepository {
        //     Future<void> sendPasswordResetEmail(String email);
        //   }
        // delegating to FirebaseAuth.sendPasswordResetEmail(email: email) and
        // letting FirebaseAuthException propagate for the failure path below.
        fail('AuthRepository.sendPasswordResetEmail does not exist yet');
      },
      skip: 'Password reset is not implemented — see comment for expected API',
    );

    test(
      'sendPasswordResetEmail surfaces user-not-found as a failure',
      () {
        // TDD — see the note above; expects
        // FirebaseAuthException(code: 'user-not-found') to propagate.
        fail('AuthRepository.sendPasswordResetEmail does not exist yet');
      },
      skip: 'Password reset is not implemented — see comment for expected API',
    );
  });
}
