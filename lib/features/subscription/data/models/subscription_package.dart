import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionPackage {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String? priceString;
  final int durationInDays;
  final List<String> benefits;
  final Package? rcPackage;

  SubscriptionPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    this.priceString,
    required this.durationInDays,
    required this.benefits,
    this.rcPackage,
  });
  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      durationInDays: json['durationInDays'] as int,
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }

  SubscriptionPackage copyWith({
    double? price,
    String? currency,
    String? priceString,
    Package? rcPackage,
  }) {
    return SubscriptionPackage(
      id: id,
      name: name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      priceString: priceString ?? this.priceString,
      durationInDays: durationInDays,
      benefits: benefits,
      rcPackage: rcPackage ?? this.rcPackage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'durationInDays': durationInDays,
      'benefits': benefits,
    };
  }

  static List<SubscriptionPackage> staticPlans = [
    SubscriptionPackage(
      id: 'weekly_plan',
      name: 'Weekly',
      price: 29.0,
      currency: '₹',
      durationInDays: 7,
      benefits: [
        'Advanced DOCX Export',
        'Basic Templates',
      ],
    ),
    SubscriptionPackage(
      id: 'monthly_plan',
      name: 'Monthly',
      price: 99.0,
      currency: '₹',
      durationInDays: 30,
      benefits: [
        'Advanced DOCX Export',
        'Professional Templates',
        'Cloud Storage',
      ],
    ),
    SubscriptionPackage(
      id: 'yearly_plan',
      name: 'Yearly',
      price: 699.0,
      currency: '₹',
      durationInDays: 365,
      benefits: [
        'All Monthly Benefits',
        'Priority Support',
      ],
    ),
  ];
}
