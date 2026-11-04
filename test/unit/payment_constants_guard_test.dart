import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/core/config/environment.dart';
import 'package:seafarer_bio_data/core/constants/payment_constants.dart';

void main() {
  group('PaymentConstants Environment Guard', () {
    test('dev environment has premium entitlement and seafarer_pro offering', () {
      expect(Environment.instance.isDev, isTrue);
      expect(PaymentConstants.kProEntitlementId, equals('premium'));
      expect(PaymentConstants.kOfferingId, equals('seafarer_pro'));
    });

    test('prod environment has pro entitlement and seafarer offering', () async {
      final prodValues = await Isolate.run(() async {
        await Environment.instance.initialize(Env.prod);
        return {
          'entitlement': PaymentConstants.kProEntitlementId,
          'offering': PaymentConstants.kOfferingId,
        };
      });

      expect(prodValues['entitlement'], equals('pro'));
      expect(prodValues['offering'], equals('seafarer'));
    });
  });
}

