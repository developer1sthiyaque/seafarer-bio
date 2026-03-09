import 'package:equatable/equatable.dart';

class SubscriptionStatus extends Equatable {
  final bool isPremium;
  final DateTime? expiryDate;

  const SubscriptionStatus({
    required this.isPremium,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [isPremium, expiryDate];
}

class SubscriptionPlan extends Equatable {
  final String id;
  final String title;
  final String description;
  final String priceString;
  final double price;
  final String currencyCode;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.currencyCode,
  });

  @override
  List<Object?> get props =>
      [id, title, description, priceString, price, currencyCode];
}
