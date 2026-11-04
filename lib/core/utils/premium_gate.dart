import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

class PremiumGate {
  static bool isPremium({
    required SubscriptionState subscriptionState,
    required ProfileState profileState,
  }) {
    final hasActiveSub = subscriptionState is SubscriptionActive;
    final hasPaidProfile =
        profileState is ProfileLoaded && profileState.profile.isPremiumPaid;
    return hasActiveSub || hasPaidProfile;
  }
}

