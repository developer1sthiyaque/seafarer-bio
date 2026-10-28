import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';
import 'package:seafarer_bio_data/features/auth/domain/repositories/auth_repository.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_in.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_out.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_up.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/usecases/get_profile.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/usecases/save_profile.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/usecases/update_profile.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

// --- Auth boundary -----------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

// --- Profile boundary --------------------------------------------------------

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockSaveProfileUseCase extends Mock implements SaveProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

// --- Subscription boundary ---------------------------------------------------

class MockRevenueCatService extends Mock implements RevenueCatService {}

class MockCustomerInfo extends Mock implements CustomerInfo {}

class MockEntitlementInfos extends Mock implements EntitlementInfos {}

class MockEntitlementInfo extends Mock implements EntitlementInfo {}

class MockPackage extends Mock implements Package {}

class MockStoreProduct extends Mock implements StoreProduct {}

// --- Blocs (for widget/integration tests) ------------------------------------

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockSubscriptionBloc
    extends MockBloc<SubscriptionEvent, SubscriptionState>
    implements SubscriptionBloc {}

/// Registers fallbacks for every argument type used with `any()`.
///
/// Safe to call more than once.
void registerTestFallbackValues() {
  // Auth events
  registerFallbackValue(const SignInEvent(email: '', password: ''));
  registerFallbackValue(
    const SignUpEvent(firstname: '', lastname: '', email: '', password: ''),
  );
  registerFallbackValue(SignOutEvent());
  registerFallbackValue(const AuthStatusChanged(null));
  registerFallbackValue(TogglePasswordVisibility());

  // Profile events
  registerFallbackValue(LoadProfile(''));
  registerFallbackValue(UpdateFullProfileEvent());
  registerFallbackValue(UpdatePersonalDetailsEvent(_fallbackPersonalDetails));
  registerFallbackValue(UpdateDocumentsEvent(const []));
  registerFallbackValue(UpdateCoursesEvent(const []));
  registerFallbackValue(UpdateSeaExperienceEvent(const []));
  registerFallbackValue(SaveProfileEvent(_fallbackProfile));

  // Subscription events
  registerFallbackValue(FetchPlans());
  registerFallbackValue(RestorePurchase());
  registerFallbackValue(PurchasePlan(SubscriptionPackage.staticPlans.first));

  // Entities
  registerFallbackValue(_fallbackProfile);
}

const PersonalDetails _fallbackPersonalDetails = PersonalDetails(
  postAppliedFor: '',
  firstname: '',
  lastname: '',
  fatherName: '',
  dob: '',
  nationality: '',
  profilePic: '',
);

const Profile _fallbackProfile = Profile(
  userId: '',
  personalDetails: _fallbackPersonalDetails,
);
