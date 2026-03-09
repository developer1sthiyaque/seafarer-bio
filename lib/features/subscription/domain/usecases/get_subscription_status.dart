import '../repositories/i_subscription_repository.dart';
import '../entities/subscription_status.dart';

class GetSubscriptionStatus {
  final ISubscriptionRepository repository;

  GetSubscriptionStatus(this.repository);

  Future<SubscriptionStatus> call() async {
    return await repository.getSubscriptionStatus();
  }
}
