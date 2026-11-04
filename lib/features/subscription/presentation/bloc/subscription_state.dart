import 'package:equatable/equatable.dart';
import '../../data/models/subscription_package.dart';
import '../../data/models/subscription_status_details.dart';

abstract class SubscriptionState extends Equatable {
  final List<SubscriptionPackage> offerings;

  const SubscriptionState({this.offerings = const []});

  @override
  List<Object?> get props => [offerings];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial({super.offerings});
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading({super.offerings});
}

class SubscriptionVerifying extends SubscriptionState {
  final String message;

  const SubscriptionVerifying([
    this.message = 'Verifying purchase with store...',
    List<SubscriptionPackage> offerings = const [],
  ]) : super(offerings: offerings);

  @override
  List<Object?> get props => [message, offerings];
}

class PlansLoaded extends SubscriptionState {
  final List<SubscriptionPackage> plans;

  const PlansLoaded(this.plans) : super(offerings: plans);

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
    super.offerings,
  });

  @override
  List<Object?> get props => [plan, details, expirationDate, offerings];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(
    this.message, {
    super.offerings,
  });

  @override
  List<Object?> get props => [message, offerings];
}
