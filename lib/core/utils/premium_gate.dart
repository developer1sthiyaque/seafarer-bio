import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

class PremiumGate {
  static bool isPremium({
    required SubscriptionState subscriptionState,
    required ProfileState profileState,
  }) {
    // 1. Server decision wins when the profile is loaded
    //    and the webhook has written premium fields.
    if (profileState is ProfileLoaded) {
      final p = profileState.profile;

      // Hard stop: server says expired
      final expiresAt = p.premiumExpiresAt; // add to the entity if missing
      if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
        return false;
      }
      if (p.isPremiumPaid) return true;
    }

    // 2. Optimistic bridge: only a fresh, verified RC state
    if (subscriptionState is SubscriptionActive) {
      final exp = subscriptionState.expirationDate; // add to the state
      return exp != null && exp.isAfter(DateTime.now());
    }
    return false;
  }
}

