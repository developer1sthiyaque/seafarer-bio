import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/auth/presentation/pages/login_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';
import 'package:seafarer_bio_data/widgets/app_text_form_field.dart';

import '../../helpers/finders.dart';
import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_profiles.dart';

/// Test plan §2.1 — Auth Screens: Login.
void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockSubscriptionBloc subscriptionBloc;

  setUpAll(registerWidgetTestFallbacks);

  setUp(() async {
    await initTestPreferences({'userId': 'uid-123'});

    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    subscriptionBloc = MockSubscriptionBloc();

    when(() => authBloc.state).thenReturn(AuthInitial());
    when(() => profileBloc.state).thenReturn(ProfileInitial());
    when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());
  });

  Future<void> pumpLogin(WidgetTester tester) => pumpTestApp(
        tester,
        child: const LoginPage(),
        authBloc: authBloc,
        profileBloc: profileBloc,
        subscriptionBloc: subscriptionBloc,
        stubRoutes: true,
      );

  Finder emailField() => appTextField('Email');

  Finder passwordField() => appTextField('Password');

  group('§2.1 rendering', () {
    testWidgets('renders email and password fields and a submit button',
        (tester) async {
      await pumpLogin(tester);

      expect(find.text('Welcome Seafarer'), findsOneWidget);
      expect(emailField(), findsOneWidget);
      expect(passwordField(), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.text('Sign In'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers a link to create an account', (tester) async {
      await pumpLogin(tester);

      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });

    testWidgets('hides the password by default', (tester) async {
      await pumpLogin(tester);

      expect(
        tester.widget<AppTextFormField>(passwordField()).obscureText,
        isTrue,
      );
      expect(
        tester.widget<AppTextFormField>(emailField()).obscureText,
        isFalse,
      );
      expect(svgAsset('assets/icons/eye_off.svg'), findsOneWidget);
    });

    testWidgets('reveals the password when the bloc says it is unobscured',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        const AuthPasswordObscuredState(isPasswordObscured: false),
      );

      await pumpLogin(tester);

      expect(
        tester.widget<AppTextFormField>(passwordField()).obscureText,
        isFalse,
      );
      expect(svgAsset('assets/icons/eye.svg'), findsOneWidget);
    });
  });

  group('§2.1 validation', () {
    testWidgets('submitting an empty form shows errors and does not sign in',
        (tester) async {
      await pumpLogin(tester);

      await scrollAndTap(tester, find.text('Sign In'));

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });

    testWidgets('a malformed email blocks submission', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(emailField(), 'not-an-email');
      await tester.enterText(passwordField(), 'password123');
      await scrollAndTap(tester, find.text('Sign In'));

      expect(find.text('Enter a valid email address'), findsOneWidget);
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });

    testWidgets('a too-short password blocks submission', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(emailField(), 'seafarer@example.com');
      await tester.enterText(passwordField(), 'short');
      await scrollAndTap(tester, find.text('Sign In'));

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });
  });

  group('§2.1 submitting valid credentials', () {
    testWidgets('dispatches SignInEvent with the entered credentials',
        (tester) async {
      await pumpLogin(tester);

      await tester.enterText(emailField(), 'seafarer@example.com');
      await tester.enterText(passwordField(), 'password123');
      await scrollAndTap(tester, find.text('Sign In'));

      final event = verify(() => authBloc.add(captureAny<AuthEvent>()))
          .captured
          .single as SignInEvent;
      expect(event.email, 'seafarer@example.com');
      expect(event.password, 'password123');
    });

    testWidgets('shows a loading indicator while authenticating',
        (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([AuthLoading()]),
        initialState: AuthInitial(),
      );

      await pumpLogin(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });
  });

  group('§2.1 failed login', () {
    testWidgets('shows the error in a snackbar and stays on Login',
        (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([const AuthError('Wrong password')]),
        initialState: AuthInitial(),
      );

      await pumpLogin(tester);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Wrong password'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text(routeStubText(AppRoutes.home)), findsNothing);
    });
  });

  group('§2.1 successful login', () {
    testWidgets('loads the profile for the signed-in user', (tester) async {
      final user = MockUser();
      when(() => user.uid).thenReturn('uid-123');
      whenListen(
        authBloc,
        Stream.fromIterable([Authenticated(user)]),
        initialState: AuthInitial(),
      );

      await pumpLogin(tester);
      await tester.pump();

      final event = verify(() => profileBloc.add(captureAny<ProfileEvent>()))
          .captured
          .single as LoadProfile;
      expect(event.userId, 'uid-123');
    });

    testWidgets('a completed profile lands on Home', (tester) async {
      whenListen(
        profileBloc,
        Stream.fromIterable([ProfileLoaded(fullProfile())]),
        initialState: ProfileInitial(),
      );

      await pumpLogin(tester);
      await tester.pumpAndSettle();

      expect(find.text(routeStubText(AppRoutes.home)), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('an incomplete profile lands on profile completion',
        (tester) async {
      whenListen(
        profileBloc,
        Stream.fromIterable([ProfileLoaded(emptyProfile())]),
        initialState: ProfileInitial(),
      );

      await pumpLogin(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(routeStubText(AppRoutes.profileCompletion)),
        findsOneWidget,
      );
    });
  });

  group('§2.1 navigation away from Login', () {
    testWidgets('the sign-up link opens the signup route', (tester) async {
      await pumpLogin(tester);

      await scrollAndTap(tester, find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      expect(find.text(routeStubText(AppRoutes.signup)), findsOneWidget);
    });

    testWidgets(
      'the "Forgot password" link opens the reset screen '
      '[skipped: forgot password is not implemented]',
      (tester) async {
        // TDD — Login has no forgot-password affordance today. Expected:
        // a `TextButton('Forgot password?')` navigating to a
        // `AppRoutes.forgotPassword` screen that calls the
        // `AuthRepository.sendPasswordResetEmail` seam described in
        // `test/unit/auth/auth_repository_impl_test.dart`.
        fail('Login has no forgot-password link');
      },
      skip: true,
    );
  });

  group('§2.1 password visibility', () {
    testWidgets('tapping the eye icon asks the bloc to toggle obscuring',
        (tester) async {
      await pumpLogin(tester);

      await tester.tap(svgAssetTapTarget('assets/icons/eye_off.svg'));
      await tester.pump();

      verify(() => authBloc.add(any<AuthEvent>(
            that: isA<TogglePasswordVisibility>(),
          ))).called(1);
    });
  });
}
