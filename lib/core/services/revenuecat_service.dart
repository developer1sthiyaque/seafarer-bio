import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/core/config/environment.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';

class RevenueCatService {
  bool _isConfigured = false;
  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  Stream<CustomerInfo> get customerInfoStream =>
      _customerInfoController.stream;

  bool get isConfigured => _isConfigured;

  Future<void> init() async {
    if (_isConfigured) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final apiKey = Environment.instance.revenueCatApiKey;

      if (apiKey.isEmpty) {
        debugPrint('⚠️  RevenueCat API key is not set in environment file.');
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        final configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);
        _isConfigured = true;

        Purchases.addCustomerInfoUpdateListener((customerInfo) {
          if (!_customerInfoController.isClosed) {
            _customerInfoController.add(customerInfo);
          }
        });
      } else {
        debugPrint('RevenueCat is not supported on this platform');
      }
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
    }
  }

  Future<LogInResult?> logIn(String uid) async {
    if (!_isConfigured || uid.isEmpty) return null;
    try {
      final result = await Purchases.logIn(uid);
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(result.customerInfo);
      }
      return result;
    } catch (e) {
      debugPrint('Error logging in to RevenueCat for user $uid: $e');
      return null;
    }
  }

  Future<CustomerInfo?> logOut() async {
    if (!_isConfigured) return null;
    try {
      final customerInfo = await Purchases.logOut();
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(customerInfo);
      }
      return customerInfo;
    } catch (e) {
      debugPrint('Error logging out of RevenueCat: $e');
      return null;
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

  Future<CustomerInfo?> purchasePackage(Package package) async {
    final purchaseResult = await Purchases.purchase(
      PurchaseParams.package(package),
    );
    if (!_customerInfoController.isClosed) {
      _customerInfoController.add(purchaseResult.customerInfo);
    }
    return purchaseResult.customerInfo;
  }

  Future<CustomerInfo?> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    if (!_customerInfoController.isClosed) {
      _customerInfoController.add(customerInfo);
    }
    return customerInfo;
  }

  bool isProSubscriber(CustomerInfo? customerInfo) {
    if (customerInfo == null) return false;
    final activeEntitlement =
        customerInfo.entitlements.active[PaymentConstants.kProEntitlementId];
    return activeEntitlement?.isActive == true;
  }

  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final selectedOffering =
          offerings.getOffering(PaymentConstants.kOfferingId);

      if (selectedOffering != null) {
        return selectedOffering.availablePackages;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return [];
    }
  }

  void dispose() {
    _customerInfoController.close();
  }
}
