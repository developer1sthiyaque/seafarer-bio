import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';
import 'package:seafarer_bio_data/core/services/revenuecat_service.dart';

import '../../helpers/mocks.dart';

/// Test plan §1.3 — Subscription Service.
///
/// `RevenueCatService.isProSubscriber` is the single place the app decides
/// whether DOCX export is unlocked, so it is covered exhaustively here.
void main() {
  late RevenueCatService service;
  late MockCustomerInfo customerInfo;
  late MockEntitlementInfos entitlements;

  setUp(() {
    service = RevenueCatService();
    customerInfo = MockCustomerInfo();
    entitlements = MockEntitlementInfos();
    when(() => customerInfo.entitlements).thenReturn(entitlements);
  });

  /// Builds an entitlement mock.
  MockEntitlementInfo entitlement({
    required bool isActive,
    String? expirationDate,
  }) {
    final info = MockEntitlementInfo();
    when(() => info.isActive).thenReturn(isActive);
    when(() => info.expirationDate).thenReturn(expirationDate);
    return info;
  }

  /// Puts [held] on the mocked customer, keyed by entitlement id.
  void givenEntitlements(Map<String, MockEntitlementInfo> held) {
    when(() => entitlements.all).thenReturn(held);
    final active = Map<String, MockEntitlementInfo>.fromEntries(
      held.entries.where((e) => e.value.isActive),
    );
    when(() => entitlements.active).thenReturn(active);
  }

  group('§1.3 isSubscribed', () {
    test('is true when the pro entitlement is active', () {
      final pro = entitlement(
        isActive: true,
        expirationDate: '2999-01-01T00:00:00Z',
      );
      givenEntitlements({PaymentConstants.kProEntitlementId: pro});

      expect(service.isProSubscriber(customerInfo), isTrue);
    });

    test('is false when there is no customer info at all', () {
      expect(service.isProSubscriber(null), isFalse);
    });

    test('is false when the customer holds no entitlements', () {
      givenEntitlements({});

      expect(service.isProSubscriber(customerInfo), isFalse);
    });

    test('is false when the customer holds a different entitlement', () {
      final other = entitlement(isActive: true);
      givenEntitlements({'some_other_entitlement': other});

      expect(service.isProSubscriber(customerInfo), isFalse);
    });
  });

  group('§1.3 subscription expiry', () {
    test('an expired entitlement is not treated as subscribed', () {
      final expired = entitlement(
        isActive: false,
        expirationDate: '2020-01-01T00:00:00Z',
      );
      givenEntitlements({PaymentConstants.kProEntitlementId: expired});

      expect(service.isProSubscriber(customerInfo), isFalse);
    });

    test('an entitlement present but inactive is not subscribed', () {
      final inactive = entitlement(isActive: false);
      givenEntitlements({PaymentConstants.kProEntitlementId: inactive});

      expect(service.isProSubscriber(customerInfo), isFalse);
    });

    test('the SDK isActive flag wins over the raw expiry date', () {
      final gracePeriod = entitlement(
        isActive: true,
        expirationDate: '2020-01-01T00:00:00Z',
      );
      givenEntitlements({PaymentConstants.kProEntitlementId: gracePeriod});

      expect(service.isProSubscriber(customerInfo), isTrue);
    });
  });

  group('§1.3 entitlement identifier', () {
    test('is the id configured in the RevenueCat dashboard', () {
      expect(PaymentConstants.kProEntitlementId, 'pro');
    });
  });
}
