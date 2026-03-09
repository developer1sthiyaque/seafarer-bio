import '../repositories/i_subscription_repository.dart';
import '../entities/subscription_status.dart';

class GetOfferings {
  final ISubscriptionRepository repository;

  GetOfferings(this.repository);

  Future<List<SubscriptionPlan>> call() async {
    return await repository.getOfferings();
  }
}
