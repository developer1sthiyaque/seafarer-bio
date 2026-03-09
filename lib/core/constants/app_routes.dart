import 'package:seafarer_bio_data/features/auth/presentation/pages/login_page.dart';
import 'package:seafarer_bio_data/features/auth/presentation/pages/signup_page.dart';
import 'package:seafarer_bio_data/features/onboarding/onboarding_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/edit_details.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/home_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/profile_completion.dart';
import 'package:seafarer_bio_data/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/view/subscription_page.dart';

class AppRoutes{
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const editProfile = '/edit-profile';
  static const profileCompletion = '/profile-completion';
  static const subscription = '/subscription';


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
        case editProfile:
        return MaterialPageRoute(builder: (context) => const EditDetails());

      case profileCompletion:
        return MaterialPageRoute(builder: (context) => const ProfileCompletion(),);
      case subscription:
        return MaterialPageRoute(
            builder: (context) => const SubscriptionPage());

      default:
        throw const FormatException("Route not found!, check routes again");
    }
  }
}