import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mocks.dart';

/// Test plan §1.2 — Auth Service (bloc behaviour): credential outcomes, session
/// persistence and session restore.
void main() {
  late MockSignInUseCase signIn;
  late MockSignUpUseCase signUp;
  late MockSignOutUseCase signOut;
  late MockAuthRepository authRepository;
  late MockUser user;
  late StreamController<User?> authStateController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferenceService.init();

    signIn = MockSignInUseCase();
    signUp = MockSignUpUseCase();
    signOut = MockSignOutUseCase();
    authRepository = MockAuthRepository();
    user = MockUser();
    authStateController = StreamController<User?>();

    when(() => user.uid).thenReturn('uid-123');
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() => authStateController.close());

  AuthBloc buildBloc() => AuthBloc(
        signInUseCase: signIn,
        signUpUseCase: signUp,
        signOutUseCase: signOut,
        authRepository: authRepository,
      );

  group('§1.2 login', () {
    blocTest<AuthBloc, AuthState>(
      'valid credentials emit [AuthLoading, Authenticated]',
      setUp: () {
        when(() => signIn('seafarer@example.com', 'password123'))
            .thenAnswer((_) async => user);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInEvent(
        email: 'seafarer@example.com',
        password: 'password123',
      )),
      expect: () => [AuthLoading(), Authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'a successful login persists the session locally',
      setUp: () {
        when(() => signIn(any(), any())).thenAnswer((_) async => user);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'seafarer@example.com', password: 'pw'),
      ),
      verify: (_) {
        expect(PreferenceService.userId, 'uid-123');
        expect(PreferenceService.isLoggedIn, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a wrong password emits an AuthError and no session',
      setUp: () {
        when(() => signIn(any(), any()))
            .thenThrow(FirebaseAuthException(code: 'wrong-password'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'seafarer@example.com', password: 'nope'),
      ),
      expect: () => [AuthLoading(), const AuthError('Wrong password')],
      verify: (_) => expect(PreferenceService.isLoggedIn, isFalse),
    );

    blocTest<AuthBloc, AuthState>(
      'an unknown account asks the user to register',
      setUp: () {
        when(() => signIn(any(), any()))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const SignInEvent(email: 'nobody@example.com', password: 'pw'),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError('User not found, please register'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a malformed email is reported as an invalid email',
      setUp: () {
        when(() => signIn(any(), any()))
            .thenThrow(FirebaseAuthException(code: 'invalid-email'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInEvent(email: 'nope', password: 'pw')),
      expect: () => [AuthLoading(), const AuthError('Invalid email')],
    );

    blocTest<AuthBloc, AuthState>(
      'an unmapped Firebase code falls back to a generic message',
      setUp: () {
        when(() => signIn(any(), any()))
            .thenThrow(FirebaseAuthException(code: 'too-many-requests'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInEvent(email: 'a@b.co', password: 'p')),
      expect: () => [
        AuthLoading(),
        const AuthError('An unknown error occurred'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'a null user is reported as a failed sign in',
      setUp: () {
        when(() => signIn(any(), any())).thenAnswer((_) async => null);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignInEvent(email: 'a@b.co', password: 'p')),
      expect: () => [AuthLoading(), const AuthError('Sign In Failed')],
    );
  });

  group('§1.2 signup', () {
    blocTest<AuthBloc, AuthState>(
      'a new account emits [AuthLoading, SignUpSuccess]',
      setUp: () {
        when(() => signUp(any(), any(), any(), any()))
            .thenAnswer((_) async => user);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignUpEvent(
        firstname: 'Isthiyaque',
        lastname: 'Kambathagothi',
        email: 'new@example.com',
        password: 'password123',
      )),
      expect: () => [AuthLoading(), SignUpSuccess(user)],
      verify: (_) {
        expect(PreferenceService.userId, 'uid-123');
        // Sign-up deliberately leaves the user "not logged in" until the
        // profile-completion flow finishes.
        expect(PreferenceService.isLoggedIn, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'an existing email is reported as a conflict',
      setUp: () {
        when(() => signUp(any(), any(), any(), any()))
            .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignUpEvent(
        firstname: 'Isthiyaque',
        lastname: 'Kambathagothi',
        email: 'taken@example.com',
        password: 'password123',
      )),
      expect: () => [AuthLoading(), const AuthError('Email already in use')],
    );

    blocTest<AuthBloc, AuthState>(
      'a weak password is surfaced to the user',
      setUp: () {
        when(() => signUp(any(), any(), any(), any()))
            .thenThrow(FirebaseAuthException(code: 'weak-password'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignUpEvent(
        firstname: 'A',
        lastname: 'B',
        email: 'a@b.co',
        password: '123',
      )),
      expect: () => [AuthLoading(), const AuthError('Weak password')],
    );

    blocTest<AuthBloc, AuthState>(
      'a null user is reported as a failed sign up',
      setUp: () {
        when(() => signUp(any(), any(), any(), any()))
            .thenAnswer((_) async => null);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const SignUpEvent(
        firstname: 'A',
        lastname: 'B',
        email: 'a@b.co',
        password: 'password123',
      )),
      expect: () => [AuthLoading(), const AuthError('Sign Up Failed')],
    );
  });

  group('§1.2 logout', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated]',
      setUp: () {
        when(() => signOut()).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(SignOutEvent()),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'clears the locally stored session',
      setUp: () async {
        when(() => signOut()).thenAnswer((_) async {});
        await PreferenceService.setUserId('uid-123');
        await PreferenceService.setLoggedIn(true);
        await PreferenceService.setProfileCompleted(true);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(SignOutEvent()),
      verify: (_) {
        expect(PreferenceService.userId, isEmpty);
        expect(PreferenceService.isLoggedIn, isFalse);
        expect(PreferenceService.isProfileCompleted, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'a failing sign out surfaces an error instead of a false logout',
      setUp: () {
        when(() => signOut()).thenThrow(Exception('network down'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(SignOutEvent()),
      expect: () => [AuthLoading(), isA<AuthError>()],
    );
  });

  group('§1.2 session restore on app start', () {
    blocTest<AuthBloc, AuthState>(
      'a valid session auto-authenticates the user',
      build: buildBloc,
      act: (_) => authStateController.add(user),
      expect: () => [Authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'an expired or missing session lands the user as unauthenticated',
      setUp: () async {
        await PreferenceService.setUserId('stale-uid');
        await PreferenceService.setLoggedIn(true);
      },
      build: buildBloc,
      act: (_) => authStateController.add(null),
      expect: () => [Unauthenticated()],
      verify: (_) {
        expect(PreferenceService.userId, isEmpty);
        expect(PreferenceService.isLoggedIn, isFalse);
      },
    );
  });

  group('§1.2 password visibility toggle', () {
    blocTest<AuthBloc, AuthState>(
      'flips the obscured flag on each event',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(TogglePasswordVisibility())
        ..add(TogglePasswordVisibility()),
      expect: () => [
        const AuthPasswordObscuredState(isPasswordObscured: false),
        const AuthPasswordObscuredState(isPasswordObscured: true),
      ],
    );
  });
}
