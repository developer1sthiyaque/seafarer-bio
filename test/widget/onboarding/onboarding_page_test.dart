import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/core/utils/shared_preferences.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/onboarding/onboarding_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';

void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockSubscriptionBloc subscriptionBloc;

  setUpAll(registerWidgetTestFallbacks);

  setUp(() async {
    await initTestPreferences({'onboardingCompleted': false});

    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    subscriptionBloc = MockSubscriptionBloc();

    when(() => authBloc.state).thenReturn(AuthInitial());
    when(() => profileBloc.state).thenReturn(ProfileInitial());
    when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());
  });

  Future<void> pumpOnboarding(WidgetTester tester) => pumpTestApp(
        tester,
        child: const OnboardingPage(),
        authBloc: authBloc,
        profileBloc: profileBloc,
        subscriptionBloc: subscriptionBloc,
        stubRoutes: true,
      );

  group('OnboardingPage rendering & navigation', () {
    testWidgets('renders first slide with brand, title, description, and Next button',
        (tester) async {
      await pumpOnboarding(tester);

      expect(find.text('SEAFARER'), findsOneWidget);
      expect(find.text('MARITIME DOSSIER'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('STAGE 1 OF 4'), findsOneWidget);
      expect(find.text('Professional Profile'), findsOneWidget);
      expect(
        find.text(
          'Keep your personal information and essential travel documents organized in one secure place.',
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.text('Next'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('stepping through slides advances to Get Started and navigates to Login',
        (tester) async {
      await pumpOnboarding(tester);

      // Slide 1 -> Slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('STAGE 2 OF 4'), findsOneWidget);
      expect(find.text('Certification Tracker'), findsOneWidget);

      // Slide 2 -> Slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('STAGE 3 OF 4'), findsOneWidget);
      expect(find.text('Service History'), findsOneWidget);

      // Slide 3 -> Slide 4
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('STAGE 4 OF 4'), findsOneWidget);
      expect(find.text('Export & Share'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(PreferenceService.isOnboardingCompleted, isTrue);
      expect(find.text(routeStubText(AppRoutes.login)), findsOneWidget);
    });

    testWidgets('tapping Skip sets onboarding completed and navigates to Login',
        (tester) async {
      await pumpOnboarding(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(PreferenceService.isOnboardingCompleted, isTrue);
      expect(find.text(routeStubText(AppRoutes.login)), findsOneWidget);
    });
  });
}
