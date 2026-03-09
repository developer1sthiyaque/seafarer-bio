import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _apiKey = 'test_nVaERCNFqZmdhCQxxlVmZllXyqS';
  static const String entitlementId = 'bioapp Pro';

  Future<void> init() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      late PurchasesConfiguration configuration;
      if (Platform.isAndroid || Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKey);
        await Purchases.configure(configuration);
      } else {
        debugPrint('RevenueCat is not supported on this platform');
      }
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }

  bool isProSubscriber(CustomerInfo? customerInfo) {
    if (customerInfo == null) return false;
    final entitlement = customerInfo.entitlements.all[entitlementId];
    return entitlement?.isActive == true;
  }

  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return [];
    }
  }
}
