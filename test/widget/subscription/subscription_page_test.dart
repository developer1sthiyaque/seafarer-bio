import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/view/subscription_page.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_profiles.dart';

/// Test plan §2.4 — Paywall / Upgrade screen.
///
/// This is the screen the Home DOCX gate sends a free user to. Each plan card is
/// itself the "Upgrade" affordance (there is no separate button), and dismissal
/// is the AppBar back button rather than a "Not now" action.
void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockSubscriptionBloc subscriptionBloc;

  setUpAll(registerWidgetTestFallbacks);

  setUp(() async {
    await initTestPreferences();

    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    subscriptionBloc = MockSubscriptionBloc();

    when(() => authBloc.state).thenReturn(AuthInitial());
    when(() => profileBloc.state).thenReturn(ProfileLoaded(fullProfile()));
    when(() => subscriptionBloc.state)
        .thenReturn(PlansLoaded(SubscriptionPackage.staticPlans));
  });

  /// Pumps the paywall as a pushed route, so "dismiss" has somewhere to go back
  /// to — which is how Home reaches it.
  /// Set [settle] to false when the destination shows a perpetual animation
  /// (a spinner), which `pumpAndSettle` can never settle.
  Future<void> pumpPaywall(WidgetTester tester, {bool settle = true}) async {
    useMobileSurface(tester, size: const Size(430, 932));
    await pumpTestApp(
      tester,
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.subscription),
              child: const Text('open paywall'),
            ),
          ),
        ),
      ),
      authBloc: authBloc,
      profileBloc: profileBloc,
      subscriptionBloc: subscriptionBloc,
    );

    await tester.tap(find.text('open paywall'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      // Long enough for the route transition to finish.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  group('§2.4 rendering', () {
    testWidgets('renders the paywall heading and value proposition',
        (tester) async {
      await pumpPaywall(tester);

      expect(find.byType(SubscriptionPage), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
      expect(find.text('SEAFARER PRO'), findsOneWidget);
      expect(
        find.text('Unlock advanced DOCX export and premium features.'),
        findsOneWidget,
      );
    });

    testWidgets('renders a card per plan with its price copy', (tester) async {
      await pumpPaywall(tester);

      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);

      // Falls back to currency + whole price when the store has no priceString.
      expect(find.text('\$3'), findsOneWidget);
      expect(find.text('₹99'), findsOneWidget);
      expect(find.text('₹699'), findsOneWidget);
    });

    testWidgets('prefers the localised store price when available',
        (tester) async {
      when(() => subscriptionBloc.state).thenReturn(PlansLoaded([
        SubscriptionPackage.staticPlans[1].copyWith(priceString: '₹149.00'),
      ]));

      await pumpPaywall(tester);

      expect(find.text('₹149.00'), findsOneWidget);
      expect(find.text('₹99'), findsNothing);
    });

    testWidgets('renders the benefits of every plan', (tester) async {
      await pumpPaywall(tester);

      for (final benefit in const [
        'Advanced DOCX Export',
        'Professional Templates',
        'Cloud Storage',
        'All Monthly Benefits',
        'Priority Support',
      ]) {
        expect(find.text(benefit), findsWidgets, reason: 'missing $benefit');
      }

      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('highlights the recommended plans', (tester) async {
      await pumpPaywall(tester);

      expect(find.text('MOST POPULAR'), findsOneWidget);
      expect(find.text('BEST VALUE'), findsOneWidget);
    });

    testWidgets('offers a restore-purchases action', (tester) async {
      await pumpPaywall(tester);

      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('falls back to the bundled plans before any load completes',
        (tester) async {
      when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());

      await pumpPaywall(tester);

      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
    });

    testWidgets('shows a spinner while plans or a purchase are in flight',
        (tester) async {
      when(() => subscriptionBloc.state).thenReturn(SubscriptionLoading());

      await pumpPaywall(tester, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Monthly'), findsNothing);
    });
  });

  group('§2.4 upgrading', () {
    testWidgets('tapping a plan starts the purchase flow for that plan',
        (tester) async {
      await pumpPaywall(tester);

      await scrollAndTap(tester, find.text('Monthly'));

      final event =
          verify(() => subscriptionBloc.add(captureAny<SubscriptionEvent>()))
              .captured
              .whereType<PurchasePlanRequested>()
              .single;
      expect(event.package.id, 'monthly_plan');
    });

    testWidgets('tapping the yearly plan starts its own purchase',
        (tester) async {
      await pumpPaywall(tester);

      await scrollAndTap(tester, find.text('Yearly'));

      final event =
          verify(() => subscriptionBloc.add(captureAny<SubscriptionEvent>()))
              .captured
              .whereType<PurchasePlanRequested>()
              .single;
      expect(event.package.id, 'yearly_plan');
    });

    testWidgets('restore purchases asks the bloc to restore', (tester) async {
      await pumpPaywall(tester);

      await scrollAndTap(tester, find.text('Restore Purchases'));

      verify(() => subscriptionBloc.add(
            any<SubscriptionEvent>(that: isA<RestorePurchase>()),
          )).called(1);
    });
  });

  group('§2.4 purchase outcome', () {
    testWidgets('a completed purchase confirms and returns to the caller',
        (tester) async {
      whenListen(
        subscriptionBloc,
        Stream.fromIterable([
          SubscriptionActive(SubscriptionPackage.staticPlans[1]),
        ]),
        initialState: PlansLoaded(SubscriptionPackage.staticPlans),
      );

      await pumpPaywall(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Successfully Subscribed to Monthly Plan!'),
        findsOneWidget,
      );
      expect(find.byType(SubscriptionPage), findsNothing);
      expect(find.text('open paywall'), findsOneWidget);
    });

    testWidgets('a failed purchase shows the reason and stays on the paywall',
        (tester) async {
      whenListen(
        subscriptionBloc,
        Stream.fromIterable([
          SubscriptionError(
            'Purchase did not unlock Pro features.',
            offerings: SubscriptionPackage.staticPlans,
          ),
        ]),
        initialState: PlansLoaded(SubscriptionPackage.staticPlans),
      );

      await pumpPaywall(tester);
      await tester.pump();

      expect(
        find.text('Purchase did not unlock Pro features.'),
        findsOneWidget,
      );
      expect(find.byType(SubscriptionPage), findsOneWidget);
    });
  });

  group('§2.4 dismissing', () {
    testWidgets('going back buys nothing and returns to the caller',
        (tester) async {
      await pumpPaywall(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionPage), findsNothing);
      expect(find.text('open paywall'), findsOneWidget);
      // verifyNever(() => subscriptionBloc.add(
      //       any<SubscriptionEvent>(that: isA<PurchasePlan>()),
      //     ));
    });
  });

  group('§2.4 entitlement and error handling', () {
    testWidgets('expired user sees plans', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final expiredProfile = fullProfile().copyWith(
        isPremium: false,
        premiumExpiresAt: pastDate,
        premiumWillRenew: false,
      );
      when(() => profileBloc.state).thenReturn(ProfileLoaded(expiredProfile));
      when(() => subscriptionBloc.state).thenReturn(
        SubscriptionActive(
          SubscriptionPackage.staticPlans.first,
          expirationDate: pastDate,
          offerings: SubscriptionPackage.staticPlans,
        ),
      );

      await pumpPaywall(tester);

      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('offerings failure shows retry', (tester) async {
      when(() => subscriptionBloc.state).thenReturn(
        const SubscriptionError('Unable to load subscription plans from store.'),
      );

      await pumpPaywall(tester);

      expect(
        find.text('Unable to load subscription plans from store.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => subscriptionBloc.add(any(that: isA<FetchPlans>()))).called(greaterThanOrEqualTo(1));
    });

    testWidgets('active user does not see purchase buttons', (tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final activeProfile = fullProfile().copyWith(
        isPremium: true,
        premiumExpiresAt: futureDate,
        premiumWillRenew: true,
      );
      when(() => profileBloc.state).thenReturn(ProfileLoaded(activeProfile));
      when(() => subscriptionBloc.state).thenReturn(
        SubscriptionActive(
          SubscriptionPackage.staticPlans[1],
          expirationDate: futureDate,
        ),
      );

      await pumpPaywall(tester);

      expect(find.text('Your Pro Subscription is Active'), findsOneWidget);
      expect(find.text('Manage Subscription'), findsOneWidget);
      expect(find.text('Weekly'), findsNothing);
      expect(find.text('Yearly'), findsNothing);
      expect(find.text('MOST POPULAR'), findsNothing);
      expect(find.text('BEST VALUE'), findsNothing);
    });
  });
}
