import '../repositories/i_subscription_repository.dart';
import '../entities/subscription_status.dart';

class PurchasePlan {
  final ISubscriptionRepository repository;

  PurchasePlan(this.repository);

  Future<SubscriptionStatus> call(SubscriptionPlan plan) async {
    return await repository.purchasePlan(plan);
  }
}
