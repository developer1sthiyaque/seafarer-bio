import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/i_subscription_repository.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  static const String _entitlementId = 'pro'; // Default entitlement ID

  @override
  Future<void> initialize() async {
    // Note: These are placeholder keys. The user should replace them with actual RevenueCat API keys.
    String apiKey = Platform.isAndroid
        ? 'goog_placeholder_android_key'
        : 'appl_placeholder_ios_key';

    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[_entitlementId];

      bool isPremium = entitlement?.isActive ?? false;
      DateTime? expiryDate = entitlement?.expirationDate != null
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
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages.map((package) {
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
      // Handle error
    }
    return [];
  }

  @override
  Future<SubscriptionStatus> purchasePlan(SubscriptionPlan plan) async {
    try {
      // We need the original Package object to perform the purchase.
      // Since our domain entity only has limited info, we fetch offerings again to find the matching package.
      Offerings offerings = await Purchases.getOfferings();
      Package? packageToPurchase;

      if (offerings.current != null) {
        packageToPurchase = offerings.current!.availablePackages.firstWhere(
          (p) => p.identifier == plan.id,
        );
      }

      if (packageToPurchase != null) {
        final result = await Purchases.purchasePackage(packageToPurchase);
        final customerInfo = result.customerInfo;
        EntitlementInfo? entitlement =
            customerInfo.entitlements.all[_entitlementId];

        return SubscriptionStatus(
          isPremium: entitlement?.isActive ?? false,
          expiryDate: entitlement?.expirationDate != null
              ? DateTime.parse(entitlement!.expirationDate!)
              : null,
        );
      }
    } catch (e) {
      // Handle error or user cancellation
    }
    return await getSubscriptionStatus();
  }

  @override
  Future<SubscriptionStatus> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[_entitlementId];

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
