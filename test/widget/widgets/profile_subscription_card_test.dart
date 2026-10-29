import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/profile_subscription_card.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_status_details.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_profiles.dart';

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
    when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    SubscriptionStatusDetails? initialDetails,
  }) async {
    useMobileSurface(tester, size: const Size(390, 844));
    await pumpTestApp(
      tester,
      child: Scaffold(
        body: SingleChildScrollView(
          child: ProfileSubscriptionCard(
            profile: fullProfile(),
            initialDetails: initialDetails,
          ),
        ),
      ),
      authBloc: authBloc,
      profileBloc: profileBloc,
      subscriptionBloc: subscriptionBloc,
      stubRoutes: true,
    );
    await tester.pump();
  }

  group('ProfileSubscriptionCard', () {
    testWidgets('renders user details card with user name', (tester) async {
      await pumpCard(tester);

      expect(find.text('Isthiyaque Kambathagothi'), findsOneWidget);
      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('renders Free Tier badge and Upgrade button when inactive',
        (tester) async {
      await pumpCard(
        tester,
        initialDetails: SubscriptionStatusDetails.freeTier,
      );

      expect(find.text('Free Tier'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
    });

    testWidgets('tapping Upgrade navigates to subscription route',
        (tester) async {
      await pumpCard(
        tester,
        initialDetails: SubscriptionStatusDetails.freeTier,
      );

      final upgradeButton = find.text('Upgrade to Pro');
      expect(upgradeButton, findsOneWidget);

      await tester.tap(upgradeButton);
      await tester.pumpAndSettle();

      expect(find.text(routeStubText(AppRoutes.subscription)), findsOneWidget);
    });

    testWidgets(
        'renders Pro Active badge, plan name, renewal date, and Manage button when active',
        (tester) async {
      final proDetails = SubscriptionStatusDetails(
        isActive: true,
        planName: 'Seafarer Pro Monthly',
        expirationDate: 'Nov 29, 2026',
        willRenew: true,
        managementUrl: 'https://play.google.com/store/account/subscriptions',
        allPurchases: ['seafarer_pro_monthly'],
      );

      await pumpCard(tester, initialDetails: proDetails);

      expect(find.text('Pro Active'), findsOneWidget);
      expect(find.text('Seafarer Pro Monthly'), findsOneWidget);
      expect(find.text('Renews on: Nov 29, 2026'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Purchase History'), findsOneWidget);
      expect(find.text('seafarer_pro_monthly'), findsOneWidget);
    });
  });
}
