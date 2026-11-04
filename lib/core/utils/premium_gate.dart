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
      final expiresAt = p.premiumExpiresAt;

      // Server webhook wrote expiration:
      if (expiresAt != null) {
        if (expiresAt.isBefore(DateTime.now())) {
          return false;
        }
        return p.isPremiumPaid;
      }
    }

    // 2. Optimistic bridge: only a fresh, verified RC state
    if (subscriptionState is SubscriptionActive) {
      final exp = subscriptionState.expirationDate; // add to the state
      if (exp != null) {
        return exp.isAfter(DateTime.now());
      }
      return true;
    }
    return false;
  }
}

