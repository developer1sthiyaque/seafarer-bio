import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_bloc.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_event.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_state.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    final sl = GetIt.instance;
    if (!sl.isRegistered<SplashBloc>()) {
      sl.registerFactory(() => SplashBloc());
    }
  });

  tearDown(() => GetIt.instance.reset());
  group('SplashBloc', () {
    late SplashBloc splashBloc;

    setUp(() {
      splashBloc = SplashBloc();
    });

    tearDown(() {
      splashBloc.close();
    });

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashNavigateToOnboarding] when onboarding is not completed',
      build: () {
        SharedPreferences.setMockInitialValues({'onboardingCompleted': false});
        return splashBloc;
      },
      act: (bloc) async {
        await PreferenceService.init();
        bloc.add(LoadSplash());
      },
      wait: const Duration(seconds: 3),
      expect: () => [
        SplashLoading(),
        SplashNavigateToOnboarding(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashNavigateToLogin] when onboarding is completed but not logged in',
      build: () {
        SharedPreferences.setMockInitialValues({
          'onboardingCompleted': true,
          'isLoggedIn': false,
        });
        return splashBloc;
      },
      act: (bloc) async {
        await PreferenceService.init();
        bloc.add(LoadSplash());
      },
      wait: const Duration(seconds: 3),
      expect: () => [
        SplashLoading(),
        SplashNavigateToLogin(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashNavigateToProfileCompletion] when logged in but profile not completed',
      build: () {
        SharedPreferences.setMockInitialValues({
          'onboardingCompleted': true,
          'isLoggedIn': true,
          'profileCompleted': false,
        });
        return splashBloc;
      },
      act: (bloc) async {
        await PreferenceService.init();
        bloc.add(LoadSplash());
      },
      wait: const Duration(seconds: 3),
      expect: () => [
        SplashLoading(),
        SplashNavigateToProfileCompletion(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashNavigateToDashboard] when logged in and profile completed',
      build: () {
        SharedPreferences.setMockInitialValues({
          'onboardingCompleted': true,
          'isLoggedIn': true,
          'profileCompleted': true,
        });
        return splashBloc;
      },
      act: (bloc) async {
        await PreferenceService.init();
        bloc.add(LoadSplash());
      },
      wait: const Duration(seconds: 3),
      expect: () => [
        SplashLoading(),
        SplashNavigateToDashboard(),
      ],
    );
  });
}
