import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

import '../../helpers/mocks.dart';

/// Test plan §1.3 — Subscription Service: plan loading and purchase states.
void main() {
  late MockRevenueCatService revenueCat;

  setUpAll(() {
    registerFallbackValue(MockPackage());
  });

  setUp(() {
    revenueCat = MockRevenueCatService();
    when(() => revenueCat.customerInfoStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => revenueCat.getCustomerInfo()).thenAnswer((_) async => null);
    when(() => revenueCat.isProSubscriber(any())).thenReturn(false);
  });

  SubscriptionBloc buildBloc() =>
      SubscriptionBloc(revenueCatService: revenueCat);

  MockPackage rcPackage({
    required PackageType type,
    required double price,
    required String priceString,
    String currencyCode = 'INR',
  }) {
    final product = MockStoreProduct();
    when(() => product.price).thenReturn(price);
    when(() => product.priceString).thenReturn(priceString);
    when(() => product.currencyCode).thenReturn(currencyCode);

    final package = MockPackage();
    when(() => package.packageType).thenReturn(type);
    when(() => package.storeProduct).thenReturn(product);
    return package;
  }

  group('§1.3 fetching plans', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'falls back to the bundled static plans when the store has no offerings',
      setUp: () {
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(FetchPlans()),
      expect: () => [
        SubscriptionLoading(),
        PlansLoaded(SubscriptionPackage.staticPlans),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'falls back to the static plans when the store call fails',
      setUp: () {
        when(() => revenueCat.getOfferings())
            .thenThrow(Exception('store unavailable'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(FetchPlans()),
      expect: () => [
        SubscriptionLoading(),
        PlansLoaded(SubscriptionPackage.staticPlans),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'merges live store pricing into the matching static plan',
      setUp: () {
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => [
              rcPackage(
                type: PackageType.monthly,
                price: 149.0,
                priceString: '₹149.00',
              ),
            ]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(FetchPlans()),
      verify: (bloc) {
        final plans = (bloc.state as PlansLoaded).plans;
        expect(plans, hasLength(3));

        final monthly = plans.firstWhere((p) => p.id == 'monthly_plan');
        expect(monthly.price, 149.0);
        expect(monthly.priceString, '₹149.00');
        expect(monthly.currency, 'INR');
        expect(monthly.rcPackage, isNotNull);
        expect(monthly.benefits, contains('Advanced DOCX Export'));

        final weekly = plans.firstWhere((p) => p.id == 'weekly_plan');
        expect(weekly.rcPackage, isNull);
        expect(weekly.price, 3.99);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'maps weekly, monthly and annual store packages to their plans',
      setUp: () {
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => [
              rcPackage(
                type: PackageType.weekly,
                price: 4.99,
                priceString: '₹4.99',
              ),
              rcPackage(
                type: PackageType.monthly,
                price: 149.0,
                priceString: '₹149.00',
              ),
              rcPackage(
                type: PackageType.annual,
                price: 999.0,
                priceString: '₹999.00',
              ),
            ]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(FetchPlans()),
      verify: (bloc) {
        final plans = (bloc.state as PlansLoaded).plans;
        expect(
          plans.map((p) => p.priceString),
          ['₹4.99', '₹149.00', '₹999.00'],
        );
        expect(plans.every((p) => p.rcPackage != null), isTrue);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits SubscriptionActive immediately when customer is already Pro',
      setUp: () {
        final customer = MockCustomerInfo();
        when(() => revenueCat.getCustomerInfo())
            .thenAnswer((_) async => customer);
        when(() => revenueCat.isProSubscriber(customer)).thenReturn(true);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(FetchPlans()),
      expect: () => [
        SubscriptionLoading(),
        SubscriptionActive(SubscriptionPackage.staticPlans.first),
      ],
    );
  });

  group('§1.3 upgrade purchase flow', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'a plan with no store package reports an error and reloads the plans',
      setUp: () {
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) =>
          bloc.add(PurchasePlan(SubscriptionPackage.staticPlans.first)),
      expect: () => [
        SubscriptionLoading(),
        const SubscriptionError('RevenueCat package not found for this plan.'),
        SubscriptionLoading(),
        PlansLoaded(SubscriptionPackage.staticPlans),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'a successful purchase moves the app into SubscriptionActive',
      setUp: () {
        final customer = MockCustomerInfo();
        when(() => revenueCat.purchasePackage(any()))
            .thenAnswer((_) async => customer);
        when(() => revenueCat.isProSubscriber(customer)).thenReturn(true);
      },
      build: buildBloc,
      act: (bloc) {
        final planWithPkg = SubscriptionPackage.staticPlans.first.copyWith(
          rcPackage: MockPackage(),
        );
        bloc.add(PurchasePlan(planWithPkg));
      },
      expect: () => [
        SubscriptionLoading(),
        isA<SubscriptionActive>(),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'a purchase that does not unlock pro reports an error and reloads plans',
      setUp: () {
        final customer = MockCustomerInfo();
        when(() => revenueCat.purchasePackage(any()))
            .thenAnswer((_) async => customer);
        when(() => revenueCat.isProSubscriber(customer)).thenReturn(false);
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) {
        final planWithPkg = SubscriptionPackage.staticPlans.first.copyWith(
          rcPackage: MockPackage(),
        );
        bloc.add(PurchasePlan(planWithPkg));
      },
      expect: () => [
        SubscriptionLoading(),
        const SubscriptionError('Purchase did not unlock Pro features.'),
        SubscriptionLoading(),
        PlansLoaded(SubscriptionPackage.staticPlans),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'user cancellation dismisses silently without error SnackBar',
      setUp: () {
        when(() => revenueCat.purchasePackage(any())).thenThrow(
          PlatformException(
            code: '${PurchasesErrorCode.purchaseCancelledError.index}',
            message: 'User cancelled',
          ),
        );
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) {
        final planWithPkg = SubscriptionPackage.staticPlans.first.copyWith(
          rcPackage: MockPackage(),
        );
        bloc.add(PurchasePlan(planWithPkg));
      },
      expect: () => [
        SubscriptionLoading(),
        PlansLoaded(SubscriptionPackage.staticPlans),
      ],
    );
  });

  group('§1.3 restore purchases', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'restoring an active subscription moves the app into SubscriptionActive',
      setUp: () {
        final customer = MockCustomerInfo();
        when(() => revenueCat.restorePurchases())
            .thenAnswer((_) async => customer);
        when(() => revenueCat.isProSubscriber(customer)).thenReturn(true);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(RestorePurchase()),
      expect: () => [
        SubscriptionLoading(),
        SubscriptionActive(SubscriptionPackage.staticPlans.last),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'restoring with nothing to restore reports an error and reloads plans',
      setUp: () {
        final customer = MockCustomerInfo();
        when(() => revenueCat.restorePurchases())
            .thenAnswer((_) async => customer);
        when(() => revenueCat.isProSubscriber(customer)).thenReturn(false);
        when(() => revenueCat.getOfferings()).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(RestorePurchase()),
      expect: () => [
        SubscriptionLoading(),
        const SubscriptionError('No active subscriptions found to restore.'),
        SubscriptionLoading(),
        PlansLoaded(SubscriptionPackage.staticPlans),
      ],
    );
  });

  group('§1.3 state reset on logout', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'ResetSubscriptionState emits SubscriptionInitial',
      build: buildBloc,
      seed: () => SubscriptionActive(SubscriptionPackage.staticPlans.first),
      act: (bloc) => bloc.add(ResetSubscriptionState()),
      expect: () => [
        SubscriptionInitial(),
      ],
    );
  });
}
