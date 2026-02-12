

import '../../domain/entities/profile_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
class PersonalDetailsUpdateSuccess extends ProfileState {
  final Profile profile;
  PersonalDetailsUpdateSuccess(this.profile);
} // Trigger for Page 0 -> 1
class DocumentsUpdateSuccess extends ProfileState {
  final Profile profile;
  DocumentsUpdateSuccess(this.profile);
}       // Trigger for Page 1 -> 2
class CertificateUpdateSuccess extends ProfileState {
  final Profile profile;
  CertificateUpdateSuccess(this.profile);
}     // Trigger for Final Navigation
class ProfileCompleted extends ProfileState {}

