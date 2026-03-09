import 'package:equatable/equatable.dart';
import '../../data/models/subscription_package.dart';

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

  const SubscriptionActive(this.plan);

  @override
  List<Object?> get props => [plan];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
