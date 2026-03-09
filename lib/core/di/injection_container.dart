import 'package:seafarer_bio_data/core/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import 'package:seafarer_bio_data/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:seafarer_bio_data/features/auth/domain/repositories/auth_repository.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_in.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_out.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_up.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/data/datasources/personal_info_local_data_source.dart';
import 'package:seafarer_bio_data/features/personal_details/data/repositories/profile_repository_impl.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/usecases/get_profile.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/usecases/save_profile.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/usecases/update_profile.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/splash/bloc/splash_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';


final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<RevenueCatService>(() => RevenueCatService());


  // Auth Feature
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(
    sl<AuthRepository>(),
    sl<ProfileRepository>(),
  ));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerFactory(() => SplashBloc());
  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        authRepository: sl(),
      ));

  // Personal Details Feature
  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => SaveProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerFactory(() => ProfileBloc(
        getProfile: sl(),
        saveProfile: sl(),
        updateProfile: sl(),
      ));

  // Subscription Feature
  sl.registerFactory(() => SubscriptionBloc(revenueCatService: sl()));
}
