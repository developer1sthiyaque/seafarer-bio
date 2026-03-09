import '../entities/subscription_status.dart';

abstract class ISubscriptionRepository {
  Future<void> initialize();
  Future<SubscriptionStatus> getSubscriptionStatus();
  Future<List<SubscriptionPlan>> getOfferings();
  Future<SubscriptionStatus> purchasePlan(SubscriptionPlan plan);
  Future<SubscriptionStatus> restorePurchases();
}
