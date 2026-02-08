import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';

import 'package:seafarer_bio_data/features/splash/bloc/splash_event.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<LoadSplash>(_onLoadSplash);
  }



  Future<void> _onLoadSplash(LoadSplash event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    await Future.delayed(const Duration(seconds: 3)).then((value) async{
      log("IS USER LOGIN ${PreferenceService.isLoggedIn}");
      log("IS PROFILE COMPLETE ${PreferenceService.isLoggedIn}");
      log("IS ONBOARDING COMPLETE ${PreferenceService.isOnboardingCompleted}");
      if (!PreferenceService.isOnboardingCompleted) {
        emit(SplashNavigateToOnboarding());
      } else if (!PreferenceService.isLoggedIn&&!PreferenceService.isProfileCompleted) {
        emit(SplashNavigateToLogin());
      } else if(PreferenceService.isLoggedIn){
        emit(SplashNavigateToDashboard());
      }
    },);
  }
}
