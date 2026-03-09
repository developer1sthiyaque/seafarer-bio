import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/constants/app_theme.dart';
import 'package:seafarer_bio_data/core/di/injection_container.dart';
import 'package:seafarer_bio_data/core/services/firebase_services.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseServices().initializeFirebase();
  await PreferenceService.init();
  await setupLocator();
  await sl<RevenueCatService>().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(
          create: (_) => sl<SplashBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (_) => sl<SubscriptionBloc>()..add(FetchPlans()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bio data app',
        theme:AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generatedRoutes,
      ),
    );
  }
}


