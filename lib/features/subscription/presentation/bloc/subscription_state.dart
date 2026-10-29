import 'package:equatable/equatable.dart';
import '../../data/models/subscription_package.dart';
import '../../data/models/subscription_status_details.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class PlansLoaded extends SubscriptionState {
  final List<SubscriptionPackage> plans;

  const PlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class SubscriptionActive extends SubscriptionState {
  final SubscriptionPackage plan;
  final SubscriptionStatusDetails? details;

  const SubscriptionActive(this.plan, {this.details});

  @override
  List<Object?> get props => [plan, details];
}


class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
