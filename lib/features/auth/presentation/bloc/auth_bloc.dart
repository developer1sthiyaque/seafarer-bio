import 'dart:async';

import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_in.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_up.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_out.dart';
import 'package:seafarer_bio_data/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _authRepository;

  late StreamSubscription<User?> _userSubscription;
  bool _isPasswordObscured = true;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthRepository authRepository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<SignInEvent>(_onSignInEvent);
    on<SignUpEvent>(_onSignUpEvent);
    on<SignOutEvent>(_onSignOutEvent);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);

    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthStatusChanged(user)),
    );
  }

  Future<void> _onSignInEvent(
      SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signInUseCase(event.email, event.password);
      if (user != null) {
        await PreferenceService.setUserId(user.uid);
        await PreferenceService.setLoggedIn(true);
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Sign In Failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown error occurred'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpEvent(
      SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signUpUseCase(event.firstname,event.lastname,event.email, event.password);
      if (user != null) {
        await PreferenceService.setUserId(user.uid);
        await PreferenceService.setLoggedIn(false);
        emit(SignUpSuccess(user));
      } else {
        emit(const AuthError('Sign Up Failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown error occurred'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutEvent(
      SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
      await PreferenceService.setUserId('');
      await PreferenceService.setLoggedIn(false);
      await PreferenceService.setProfileCompleted(false);
      await PreferenceService.setOnboardingCompleted(false);
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      await PreferenceService.setUserId('');
      await PreferenceService.setLoggedIn(false);
      await PreferenceService.setProfileCompleted(false);
      await PreferenceService.setOnboardingCompleted(false);
      emit(Unauthenticated());
    }
  }



  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility event,
      Emitter<AuthState> emit,
      ) {
    _isPasswordObscured = !_isPasswordObscured;

    emit(AuthPasswordObscuredState(
      isPasswordObscured: _isPasswordObscured,
    ));
  }
}
