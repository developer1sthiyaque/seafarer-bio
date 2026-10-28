import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';

/// Test plan §1.3 / §2.4 — the plan model behind the paywall copy.
void main() {
  group('§1.3 SubscriptionPackage serialization', () {
    test('fromJson reads every persisted field', () {
      final package = SubscriptionPackage.fromJson(const {
        'id': 'monthly_plan',
        'name': 'Monthly',
        'price': 99,
        'currency': '₹',
        'durationInDays': 30,
        'benefits': ['Advanced DOCX Export', 'Cloud Storage'],
      });

      expect(package.id, 'monthly_plan');
      expect(package.name, 'Monthly');
      expect(package.price, 99.0);
      expect(package.currency, '₹');
      expect(package.durationInDays, 30);
      expect(package.benefits, ['Advanced DOCX Export', 'Cloud Storage']);
      expect(package.rcPackage, isNull);
    });

    test('fromJson tolerates a missing benefits list', () {
      final package = SubscriptionPackage.fromJson(const {
        'id': 'weekly_plan',
        'name': 'Weekly',
        'price': 3.99,
        'currency': '\$',
        'durationInDays': 7,
      });

      expect(package.benefits, isEmpty);
    });

    test('toMap round-trips through fromJson', () {
      final original = SubscriptionPackage.staticPlans.first;

      final restored = SubscriptionPackage.fromJson(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.price, original.price);
      expect(restored.currency, original.currency);
      expect(restored.durationInDays, original.durationInDays);
      expect(restored.benefits, original.benefits);
    });
  });

  group('§1.3 SubscriptionPackage.copyWith', () {
    test('overrides pricing while keeping identity and benefits', () {
      final original = SubscriptionPackage.staticPlans[1];

      final updated = original.copyWith(
        price: 149.0,
        currency: 'INR',
        priceString: '₹149.00',
      );

      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.durationInDays, original.durationInDays);
      expect(updated.benefits, original.benefits);
      expect(updated.price, 149.0);
      expect(updated.currency, 'INR');
      expect(updated.priceString, '₹149.00');
    });

    test('leaves untouched fields alone', () {
      final original = SubscriptionPackage.staticPlans.last;

      final updated = original.copyWith(priceString: '₹999.00');

      expect(updated.price, original.price);
      expect(updated.currency, original.currency);
    });
  });

  group('§2.4 bundled plan catalogue', () {
    test('offers exactly the weekly, monthly and yearly plans', () {
      expect(
        SubscriptionPackage.staticPlans.map((p) => p.id),
        ['weekly_plan', 'monthly_plan', 'yearly_plan'],
      );
    });

    test('every plan carries price copy and at least one benefit', () {
      for (final plan in SubscriptionPackage.staticPlans) {
        expect(plan.name, isNotEmpty, reason: '${plan.id} needs a title');
        expect(plan.price, greaterThan(0), reason: '${plan.id} needs a price');
        expect(plan.currency, isNotEmpty);
        expect(plan.durationInDays, greaterThan(0));
        expect(plan.benefits, isNotEmpty);
      }
    });

    test('DOCX export is advertised as the paid benefit', () {
      // This is the benefit the Home DOC gate points the user at.
      expect(
        SubscriptionPackage.staticPlans
            .any((p) => p.benefits.any((b) => b.contains('DOCX'))),
        isTrue,
      );
    });
  });
}
