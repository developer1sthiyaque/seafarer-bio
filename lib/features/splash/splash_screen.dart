import 'dart:developer';

import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_bloc.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_event.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_state.dart';
import 'package:seafarer_bio_data/widgets/app_text_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer immediately
    context.read<SplashBloc>().add(LoadSplash());
  }

  void _handleNavigation() {
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      // Load profile and navigate
      context.read<ProfileBloc>().add(LoadProfile(authState.user.uid));

      if (PreferenceService.isProfileCompleted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.profileCompletion);
      }
    } else {
      // Logic for Unauthenticated
      if (!PreferenceService.isOnboardingCompleted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if(state is SplashNavigateToOnboarding){
            if(context.mounted)Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          }

          if(state is SplashNavigateToLogin){
            if(context.mounted)Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
          if (state is SplashNavigateToOnboarding) {
            _handleNavigation();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                width: MediaQuery.sizeOf(context).width * 0.7,
              ),
              const SizedBox(height: 20),
              AppTextView(title: 'Seafarer Bio Data', textStyle: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 34,color: Colors.black,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}
