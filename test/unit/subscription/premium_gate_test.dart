import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/core/utils/premium_gate.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

void main() {
  group('PremiumGate Tests', () {
    test(
        'returns false when isPremium=false, premiumExpiresAt in the past, premiumWillRenew=false, and SubscriptionActive is stale',
        () {
      final pastDate = DateTime.now().subtract(const Duration(days: 7));

      final profile = Profile(
        userId: 'test_user_123',
        personalDetails: const PersonalDetails(
          postAppliedFor: 'Captain',
          firstname: 'John',
          lastname: 'Doe',
          fatherName: 'Richard Doe',
          dob: '1990-01-01',
          nationality: 'Indian',
          profilePic: '',
        ),
        isPremiumPaid: false,
        premiumExpiresAt: pastDate,
        premiumWillRenew: false,
      );

      final profileState = ProfileLoaded(profile);

      final subscriptionState = SubscriptionActive(
        SubscriptionPackage.staticPlans.first,
        expirationDate: pastDate,
      );

      final result = PremiumGate.isPremium(
        subscriptionState: subscriptionState,
        profileState: profileState,
      );

      expect(result, isFalse);
    });

    test(
        'returns true when profile isPremiumPaid is true and premiumExpiresAt is in the future',
        () {
      final futureDate = DateTime.now().add(const Duration(days: 7));

      final profile = Profile(
        userId: 'test_user_123',
        personalDetails: const PersonalDetails(
          postAppliedFor: 'Captain',
          firstname: 'John',
          lastname: 'Doe',
          fatherName: 'Richard Doe',
          dob: '1990-01-01',
          nationality: 'Indian',
          profilePic: '',
        ),
        isPremiumPaid: true,
        premiumExpiresAt: futureDate,
        premiumWillRenew: true,
      );

      final profileState = ProfileLoaded(profile);
      final subscriptionState = SubscriptionInitial();

      final result = PremiumGate.isPremium(
        subscriptionState: subscriptionState,
        profileState: profileState,
      );

      expect(result, isTrue);
    });

    test(
        'returns true when fresh SubscriptionActive has expirationDate in the future even if profile is not loaded',
        () {
      final futureDate = DateTime.now().add(const Duration(days: 7));

      final profileState = ProfileInitial();
      final subscriptionState = SubscriptionActive(
        SubscriptionPackage.staticPlans.first,
        expirationDate: futureDate,
      );

      final result = PremiumGate.isPremium(
        subscriptionState: subscriptionState,
        profileState: profileState,
      );

      expect(result, isTrue);
    });
  });
}

