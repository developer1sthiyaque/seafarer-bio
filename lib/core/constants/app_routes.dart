import 'package:seafarer_bio_data/features/auth/presentation/pages/login_page.dart';
import 'package:seafarer_bio_data/features/auth/presentation/pages/signup_page.dart';
import 'package:seafarer_bio_data/features/onboarding/onboarding_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/home_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/profile_completion.dart';
import 'package:seafarer_bio_data/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes{
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const profileCompletion = '/profile-completion';


  static Route<dynamic> generatedRoutes(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (context) => const OnboardingPage());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case signup:
        return MaterialPageRoute(
          builder: (context) => const SignUpPage(),
        );
      case home:
        return MaterialPageRoute(builder: (context) => const HomePage());

      case profileCompletion:
        return MaterialPageRoute(builder: (context) => const ProfileCompletion(),);

      default:
        throw const FormatException("Route not found!, check routes again");
    }
  }
}