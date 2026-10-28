import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/auth/presentation/pages/signup_page.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/widgets/app_button.dart';

import '../../helpers/finders.dart';
import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';

/// Test plan §2.1 — Auth Screens: Signup mirrors Login for new accounts.
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
    when(() => profileBloc.state).thenReturn(ProfileInitial());
    when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());
  });

  Future<void> pumpSignUp(WidgetTester tester) => pumpTestApp(
        tester,
        child: const SignUpPage(),
        authBloc: authBloc,
        profileBloc: profileBloc,
        subscriptionBloc: subscriptionBloc,
        stubRoutes: true,
      );

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(appTextField('First name'), 'Isthiyaque');
    await tester.enterText(appTextField('Last name'), 'Kambathagothi');
    await tester.enterText(appTextField('Email'), 'new@example.com');
    await tester.enterText(appTextField('Password'), 'password123');
    await tester.enterText(appTextField('Confirm Password'), 'password123');
  }

  group('§2.1 rendering', () {
    testWidgets('renders every account field and a submit button',
        (tester) async {
      await pumpSignUp(tester);

      expect(find.text('Create Account'), findsOneWidget);
      expect(appTextField('First name'), findsOneWidget);
      expect(appTextField('Last name'), findsOneWidget);
      expect(appTextField('Email'), findsOneWidget);
      expect(appTextField('Password'), findsOneWidget);
      expect(appTextField('Confirm Password'), findsOneWidget);

      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.text('Sign Up'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers a link back to login', (tester) async {
      await pumpSignUp(tester);

      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('§2.1 validation', () {
    testWidgets('submitting an empty form shows errors and does not sign up',
        (tester) async {
      await pumpSignUp(tester);

      await scrollAndTap(tester, find.text('Sign Up'));

      // Both name fields share the same message.
      expect(find.text('Name is required'), findsNWidgets(2));
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsNWidgets(2));
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });

    testWidgets('a mismatched confirmation blocks submission', (tester) async {
      await pumpSignUp(tester);

      await tester.enterText(appTextField('First name'), 'Isthiyaque');
      await tester.enterText(appTextField('Last name'), 'Kambathagothi');
      await tester.enterText(appTextField('Email'), 'new@example.com');
      await tester.enterText(appTextField('Password'), 'password123');
      await tester.enterText(appTextField('Confirm Password'), 'different123');

      await scrollAndTap(tester, find.text('Sign Up'));

      expect(find.text('Password does not match'), findsOneWidget);
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });

    testWidgets('a malformed email blocks submission', (tester) async {
      await pumpSignUp(tester);

      await fillValidForm(tester);
      await tester.enterText(appTextField('Email'), 'not-an-email');

      await scrollAndTap(tester, find.text('Sign Up'));

      expect(find.text('Enter a valid email address'), findsOneWidget);
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });
  });

  group('§2.1 creating an account', () {
    testWidgets('dispatches SignUpEvent with the entered details',
        (tester) async {
      await pumpSignUp(tester);
      await fillValidForm(tester);

      await scrollAndTap(tester, find.text('Sign Up'));

      final event = verify(() => authBloc.add(captureAny<AuthEvent>()))
          .captured
          .single as SignUpEvent;
      expect(event.firstname, 'Isthiyaque');
      expect(event.lastname, 'Kambathagothi');
      expect(event.email, 'new@example.com');
      expect(event.password, 'password123');
    });

    testWidgets('trims surrounding whitespace on the name fields',
        (tester) async {
      await pumpSignUp(tester);
      await tester.enterText(appTextField('First name'), '  Isthiyaque  ');
      await tester.enterText(appTextField('Last name'), '  Kambathagothi ');
      await tester.enterText(appTextField('Email'), 'new@example.com');
      await tester.enterText(appTextField('Password'), 'password123');
      await tester.enterText(appTextField('Confirm Password'), 'password123');

      await scrollAndTap(tester, find.text('Sign Up'));

      final event = verify(() => authBloc.add(captureAny<AuthEvent>()))
          .captured
          .single as SignUpEvent;
      expect(event.firstname, 'Isthiyaque');
      expect(event.lastname, 'Kambathagothi');
    });

    testWidgets('an email with stray whitespace is rejected by validation',
        (tester) async {
      // Documents an inconsistency rather than endorsing it: submission trims
      // the email (`emailController.text.trim()`), but `AppValidators.email`
      // runs against the raw value, so a trailing space fails validation before
      // the trim can help. Trimming inside the validator (or an
      // input formatter) would make the two agree.
      await pumpSignUp(tester);
      await fillValidForm(tester);
      await tester.enterText(appTextField('Email'), ' new@example.com ');

      await scrollAndTap(tester, find.text('Sign Up'));

      expect(find.text('Enter a valid email address'), findsOneWidget);
      verifyNever(() => authBloc.add(any<AuthEvent>()));
    });

    testWidgets('shows a loading indicator while the account is created',
        (tester) async {
      when(() => authBloc.state).thenReturn(AuthLoading());

      await pumpSignUp(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing);
    });
  });

  group('§2.1 failed signup', () {
    testWidgets('shows the error in a snackbar and stays on Signup',
        (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([const AuthError('Email already in use')]),
        initialState: AuthInitial(),
      );

      await pumpSignUp(tester);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email already in use'), findsOneWidget);
      expect(find.byType(SignUpPage), findsOneWidget);
    });
  });

  group('§2.1 successful signup', () {
    testWidgets('loads the new profile and continues to profile completion',
        (tester) async {
      final user = MockUser();
      when(() => user.uid).thenReturn('uid-new');
      whenListen(
        authBloc,
        Stream.fromIterable([SignUpSuccess(user)]),
        initialState: AuthInitial(),
      );

      await pumpSignUp(tester);
      await tester.pumpAndSettle();

      final event = verify(() => profileBloc.add(captureAny<ProfileEvent>()))
          .captured
          .single as LoadProfile;
      expect(event.userId, 'uid-new');

      expect(
        find.text(routeStubText(AppRoutes.profileCompletion)),
        findsOneWidget,
      );
    });
  });

  group('§2.1 navigation away from Signup', () {
    testWidgets('the login link opens the login route', (tester) async {
      await pumpSignUp(tester);

      await scrollAndTap(tester, find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text(routeStubText(AppRoutes.login)), findsOneWidget);
    });
  });

  group('§2.1 password visibility', () {
    testWidgets('tapping the eye icon asks the bloc to toggle obscuring',
        (tester) async {
      await pumpSignUp(tester);

      await scrollAndTap(
        tester,
        svgAssetTapTarget('assets/icons/eye_off.svg').first,
      );

      verify(() => authBloc.add(any<AuthEvent>(
            that: isA<TogglePasswordVisibility>(),
          ))).called(1);
    });
  });
}
