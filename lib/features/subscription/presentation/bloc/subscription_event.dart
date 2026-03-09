import 'package:equatable/equatable.dart';
import '../../data/models/subscription_package.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class FetchPlans extends SubscriptionEvent {}

class PurchasePlan extends SubscriptionEvent {
  final SubscriptionPackage package;

  const PurchasePlan(this.package);

  @override
  List<Object?> get props => [package];
}

class RestorePurchase extends SubscriptionEvent {}
