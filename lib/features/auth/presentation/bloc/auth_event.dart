part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String firstname;
  final String lastname;
  final String email;
  final String password;

  const SignUpEvent({required this.firstname,required this.lastname, required this.email, required this.password});

  @override
  List<Object> get props => [firstname,lastname,email, password];
}

class SignOutEvent extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final User? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object> get props => [user ?? 'null'];
}

class TogglePasswordVisibility extends AuthEvent {}
