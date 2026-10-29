import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/core/config/environment.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/i_subscription_repository.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  @override
  Future<void> initialize() async {
    final apiKey = Environment.instance.revenueCatApiKey;
    if (apiKey.isEmpty) {
      debugPrint('⚠️ RevenueCat API key is not set in environment file.');
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await Purchases.setLogLevel(LogLevel.debug);
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      // 1. Inspect all active entitlements
      print("Active entitlements: ${customerInfo.entitlements.active.keys.toList()}");
      final entitlement = customerInfo
          .entitlements.active[PaymentConstants.kProEntitlementId];

      final isPremium = entitlement?.isActive ?? false;

      print("Is Pro Active: $isPremium");
      final expiryDate = entitlement?.expirationDate != null
          ? DateTime.parse(entitlement!.expirationDate!)
          : null;

      return SubscriptionStatus(
        isPremium: isPremium,
        expiryDate: expiryDate,
      );
    } catch (e) {
      return const SubscriptionStatus(isPremium: false);
    }
  }

  @override
  Future<List<SubscriptionPlan>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(PaymentConstants.kOfferingId) ??
          offerings.current;

      if (offering != null && offering.availablePackages.isNotEmpty) {
        return offering.availablePackages.map((package) {
          final product = package.storeProduct;
          return SubscriptionPlan(
            id: package.identifier,
            title: product.title,
            description: product.description,
            priceString: product.priceString,
            price: product.price,
            currencyCode: product.currencyCode,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching offerings in repository: $e');
    }
    return [];
  }

  @override
  Future<SubscriptionStatus> purchasePlan(SubscriptionPlan plan) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(PaymentConstants.kOfferingId) ??
          offerings.current;
      Package? packageToPurchase;

      if (offering != null) {
        packageToPurchase = offering.availablePackages.firstWhere(
          (p) => p.identifier == plan.id,
        );
      }

      if (packageToPurchase != null) {
        final result = await Purchases.purchase(
          PurchaseParams.package(packageToPurchase),
        );
        final customerInfo = result.customerInfo;
        final entitlement = customerInfo
            .entitlements.active[PaymentConstants.kProEntitlementId];

        return SubscriptionStatus(
          isPremium: entitlement?.isActive ?? false,
          expiryDate: entitlement?.expirationDate != null
              ? DateTime.parse(entitlement!.expirationDate!)
              : null,
        );
      }
    } catch (e) {
      debugPrint('Error purchasing plan in repository: $e');
    }
    return await getSubscriptionStatus();
  }

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final entitlement = customerInfo
          .entitlements.active[PaymentConstants.kProEntitlementId];

      return SubscriptionStatus(
        isPremium: entitlement?.isActive ?? false,
        expiryDate: entitlement?.expirationDate != null
            ? DateTime.parse(entitlement!.expirationDate!)
            : null,
      );
    } catch (e) {
      return await getSubscriptionStatus();
    }
  }
}
