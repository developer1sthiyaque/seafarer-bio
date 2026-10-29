import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';

class SubscriptionStatusDetails extends Equatable {
  final bool isActive;
  final String planName;
  final String? expirationDate;
  final bool willRenew;
  final String? managementUrl;
  final List<String> allPurchases;

  const SubscriptionStatusDetails({
    required this.isActive,
    required this.planName,
    this.expirationDate,
    this.willRenew = false,
    this.managementUrl,
    this.allPurchases = const [],
  });

  static const freeTier = SubscriptionStatusDetails(
    isActive: false,
    planName: 'Free Tier',
    allPurchases: [],
  );

  factory SubscriptionStatusDetails.fromCustomerInfo(CustomerInfo? customerInfo) {
    if (customerInfo == null) return freeTier;

    final activeEntitlements = customerInfo.entitlements.active;
    final proEntitlement =
        activeEntitlements[PaymentConstants.kProEntitlementId] ??
        activeEntitlements['seafarer_pro'] ??
        activeEntitlements['pro'];

    final isActive = proEntitlement?.isActive == true;

    String? formattedExpirationDate;
    if (proEntitlement?.expirationDate != null) {
      try {
        final parsed = DateTime.parse(proEntitlement!.expirationDate!);
        formattedExpirationDate =
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      } catch (_) {
        formattedExpirationDate = proEntitlement?.expirationDate;
      }
    }

    String planName = 'Free Tier';
    if (isActive) {
      final pid = proEntitlement?.productIdentifier ?? '';
      if (pid.contains('weekly')) {
        planName = 'Weekly Pro';
      } else if (pid.contains('monthly')) {
        planName = 'Monthly Pro';
      } else if (pid.contains('yearly')) {
        planName = 'Yearly Pro';
      } else if (pid.isNotEmpty) {
        planName = pid;
      } else {
        planName = 'Seafarer Pro';
      }
    }

    return SubscriptionStatusDetails(
      isActive: isActive,
      planName: planName,
      expirationDate: formattedExpirationDate,
      willRenew: proEntitlement?.willRenew ?? false,
      managementUrl: customerInfo.managementURL,
      allPurchases: customerInfo.allPurchasedProductIdentifiers,
    );
  }

  @override
  List<Object?> get props => [
        isActive,
        planName,
        expirationDate,
        willRenew,
        managementUrl,
        allPurchases,
      ];
}
