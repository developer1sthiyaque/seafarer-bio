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

class SubscriptionVerifying extends SubscriptionState {
  final String message;

  const SubscriptionVerifying([this.message = 'Verifying purchase with store...']);

  @override
  List<Object?> get props => [message];
}

class PlansLoaded extends SubscriptionState {
  final List<SubscriptionPackage> plans;

  const PlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class SubscriptionActive extends SubscriptionState {
  final SubscriptionPackage plan;
  final SubscriptionStatusDetails? details;
  final DateTime? expirationDate;

  const SubscriptionActive(
    this.plan, {
    this.details,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [plan, details, expirationDate];
}


class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
