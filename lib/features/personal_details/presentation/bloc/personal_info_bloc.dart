import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/save_profile.dart';
import '../../domain/usecases/update_profile.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfile;
  final SaveProfileUseCase saveProfile;
  final UpdateProfileUseCase updateProfile;

  StreamSubscription? _profileSubscription;

  ProfileBloc({
    required this.getProfile,
    required this.saveProfile,
    required this.updateProfile,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<SaveProfileEvent>(_onSaveProfile);
    on<UpdatePersonalDetailsEvent>(_onUpdatePersonalDetails);
    on<UpdateDocumentsEvent>(_onUpdateDocuments);
    on<UpdateCoursesEvent>(_onUpdateCourses);
    on<UpdateSeaExperienceEvent>(_onUpdateSeaExperience);
    // on<CompleteProfile>(_onCompleteProfile);
    on<UpdateFullProfileEvent>(_onUpdateFullProfile);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    await emit.forEach<Profile?>(
      getProfile(event.userId),
      onData: (profile) {
        if (profile != null) {
          // if(profile.isProfileCompleted&&!PreferenceService.isProfileCompleted){
          //   return (ProfileCompleted());
          // }else{
          //   return ProfileLoaded(profile);
          // }
          return ProfileLoaded(profile);
        }

        // If profile is null, you must return the current state
        // or a specific 'Error' state.
        return state;
      },
      onError: (error, stackTrace) {
        // Handle errors gracefully here
        return ProfileError(error.toString());
      },
    );
  }

  // Future<void> _onCompleteProfile(
  //     CompleteProfile event,
  //     Emitter<ProfileState> emit,
  //     ) async {
  //   final current = (state as CertificateUpdateSuccess).profile;
  //
  //   await updateProfile(
  //     current.copyWith(isCompleted: true),
  //   );
  //   PreferenceService.isProfileCompleted=true;
  //   emit(ProfileCompleted());
  // }

  Future<void> _onSaveProfile(
      SaveProfileEvent event, Emitter<ProfileState> emit) async {
    await saveProfile(event.profile);
  }

  Future<void> _updateProfile(
      Profile updatedProfile, Emitter<ProfileState> emit,ProfileState successState,) async {
    try {
      await updateProfile(updatedProfile);
      emit(successState);
    } catch (e) {
      // Always good to handle errors so you don't get stuck in Loading forever!
      emit(ProfileError(e.toString()));
    }
  }

  void _onUpdatePersonalDetails(
      UpdatePersonalDetailsEvent event, Emitter<ProfileState> emit) async {
    // 2. Check and capture the profile BEFORE emitting Loading
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    // 3. Now it's safe to emit loading
    emit(ProfileLoading());

    // 4. Await the update so the emitter stays alive
    try {
      final updatedProfile = currentProfile.copyWith(personalDetails: event.personalDetails);
      // 2. Add 'await' here! This keeps the handler alive.
      await _updateProfile(
        currentProfile.copyWith(personalDetails: event.personalDetails),
        emit,PersonalDetailsUpdateSuccess(updatedProfile)
      );
      
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateDocuments(
      UpdateDocumentsEvent event, Emitter<ProfileState> emit) async {

    // if (state is! ProfileLoaded) return;
    // final currentProfile = (state as ProfileLoaded).profile;
    if (state is! PersonalDetailsUpdateSuccess) return;
    final current = (state as PersonalDetailsUpdateSuccess).profile;
    final updatedProfile = current.copyWith(documents: event.documents);
    emit(ProfileLoading());
    try {
      // 1. Await the update to Firebase
      await _updateProfile(
        current.copyWith(documents: event.documents,),
        emit,
        DocumentsUpdateSuccess(updatedProfile), // Trigger for Page 1 -> 2
      );

    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateCourses(
      UpdateCoursesEvent event, Emitter<ProfileState> emit) async {
    if (state is! DocumentsUpdateSuccess) return;
    final current = (state as DocumentsUpdateSuccess).profile;
    final updatedProfile = current.copyWith(courses: event.courses);
    emit(ProfileLoading());
    try {
      await _updateProfile(
        current.copyWith(courses: event.courses,isCompleted: true),
        emit,
        CertificateUpdateSuccess(updatedProfile), // Trigger for Page 1 -> 2
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onUpdateSeaExperience(
      UpdateSeaExperienceEvent event, Emitter<ProfileState> emit) {
    if (state is! ProfileLoaded) return;
    final current = (state as ProfileLoaded).profile;

    // 3. Now it's safe to emit loading
    emit(ProfileLoading());

    try{
      _updateProfile(
        current.copyWith(seaExperiences: event.seaExperiences),
        emit,
        CertificateUpdateSuccess(current), // Trigger for Page 1 -> 2
      );
    }catch(e){
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateFullProfile(
      UpdateFullProfileEvent event, Emitter<ProfileState> emit) async {
    if (state is! ProfileLoaded) return;

    final currentProfile = (state as ProfileLoaded).profile;
    emit(ProfileLoading());

    // Merge all changes into one object
    final updatedProfile = currentProfile.copyWith(
      personalDetails: event.personalDetails ?? currentProfile.personalDetails,
      documents: event.documents ?? currentProfile.documents,
      courses: event.courses ?? currentProfile.courses,
      seaExperiences: event.seaExperiences ?? currentProfile.seaExperiences,
    );

    try {
      await updateProfile(updatedProfile); // Single Firestore Write
      emit(ProfileLoaded(updatedProfile));
      // emit(AllChangesSavedSuccess()); // Optional success notification
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
