import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/core/constants/app_routes.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/edit_details.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/home_page.dart';
import 'package:seafarer_bio_data/features/subscription/data/models/subscription_package.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';

import '../../helpers/finders.dart';
import '../../helpers/mocks.dart';
import '../../helpers/platform_mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_profiles.dart';

/// Test plan §2.2 — Home / Bio Data screen.
///
/// Notes on how this screen differs from the plan, so failures are easy to
/// trace: the DOCX paywall is a **SnackBar with an "Upgrade" action**, not a
/// dialog/bottom sheet, and logout has **no confirmation dialog** (the plan
/// marks that as "if applicable").
void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockSubscriptionBloc subscriptionBloc;
  late Directory tempDir;
  late PlatformCallLog pathProviderLog;

  const pdfIcon = 'assets/icons/pdf_icon.svg';
  const docIcon = 'assets/icons/file_doc.svg';
  const editIcon = 'assets/icons/edit.svg';

  setUpAll(registerWidgetTestFallbacks);

  setUp(() async {
    await initTestPreferences();

    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    subscriptionBloc = MockSubscriptionBloc();

    when(() => authBloc.state).thenReturn(AuthInitial());
    when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());
    when(() => profileBloc.state).thenReturn(ProfileLoaded(fullProfile()));

    tempDir = Directory.systemTemp.createTempSync('home_page_test');
    // The export flow is deliberately made to fail at the *save* step: the
    // document is still generated, but nothing is written to disk and the OS
    // viewer is never invoked. `FileSaveService` swallows the failure, so this
    // stays a clean assertion on "the export was attempted".
    pathProviderLog = mockPathProvider(
      tempDir,
      failWith: PlatformException(code: 'unavailable'),
    );
    mockOpenFilex();
  });

  tearDown(() {
    clearPlatformMocks();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    bool stubRoutes = true,
  }) async {
    await pumpTestApp(
      tester,
      child: const HomePage(),
      authBloc: authBloc,
      profileBloc: profileBloc,
      subscriptionBloc: subscriptionBloc,
      stubRoutes: stubRoutes,
    );
  }

  void givenSubscribed() {
    when(() => subscriptionBloc.state)
        .thenReturn(SubscriptionActive(SubscriptionPackage.staticPlans.last));
  }

  Finder tableAt(int index) => find.byType(Table).at(index);

  Finder inTable(int index, String text) => find.descendant(
        of: tableAt(index),
        matching: find.text(text),
      );

  int rowCount(WidgetTester tester, int index) =>
      tester.widget<Table>(tableAt(index)).children.length;

  group('§2.2 app bar', () {
    testWidgets('renders the title and all four action icons', (tester) async {
      await pumpHome(tester);

      expect(find.text('My Bio Data'), findsOneWidget);
      expect(svgAsset(pdfIcon), findsOneWidget);
      expect(svgAsset(docIcon), findsOneWidget);
      expect(svgAsset(editIcon), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('a free user sees no premium-management icon', (tester) async {
      await pumpHome(tester);

      expect(find.byIcon(Icons.workspace_premium), findsNothing);
    });

    testWidgets('a subscriber also sees the premium-management icon',
        (tester) async {
      givenSubscribed();

      await pumpHome(tester);

      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('the DOC icon is greyed out for a free user', (tester) async {
      await pumpHome(tester);

      expect(
        tester.widget<SvgPicture>(svgAsset(docIcon)).colorFilter,
        const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      );
    });

    testWidgets('the DOC icon is not greyed out for a subscriber',
        (tester) async {
      givenSubscribed();

      await pumpHome(tester);

      expect(
        tester.widget<SvgPicture>(svgAsset(docIcon)).colorFilter,
        isNot(const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
      );
    });
  });

  group('§2.2 profile header', () {
    testWidgets('renders every header label with its value', (tester) async {
      await pumpHome(tester);

      const expected = <String, String>{
        'Post Applied For': 'Fourth Engineer',
        'First Name': 'Isthiyaque',
        'Last Name': 'Kambathagothi',
        "Father's Name": 'Abdul Rauf Kambathagothi',
        'Date of Birth': '17/7/1987',
        'Nationality': 'Indian',
      };

      expected.forEach((label, value) {
        expect(find.text(label), findsOneWidget, reason: 'missing $label');
        expect(find.text(value), findsOneWidget, reason: 'missing $value');
      });
    });

    testWidgets('shows the "No Photo" placeholder when there is no photo',
        (tester) async {
      when(() => profileBloc.state).thenReturn(ProfileLoaded(noPhotoProfile()));

      await pumpHome(tester);

      expect(find.text('No Photo'), findsOneWidget);
    });

    testWidgets('shows the photo when one is stored', (tester) async {
      await pumpHome(tester);

      expect(find.text('No Photo'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).image != null,
          description: 'photo Container with a DecorationImage',
        ),
        findsOneWidget,
      );
    });
  });

  group('§2.2 Documents table', () {
    testWidgets('renders the documented column headers', (tester) async {
      await pumpHome(tester);

      for (final header in const [
        'Document',
        'Number',
        'Date of issue',
        'Place of issue',
        'Validity',
      ]) {
        expect(inTable(0, header), findsOneWidget, reason: 'missing $header');
      }
    });

    testWidgets('renders a row per document', (tester) async {
      await pumpHome(tester);

      expect(rowCount(tester, 0), 2); // header + one Passport row
      expect(inTable(0, 'Passport'), findsOneWidget);
      expect(inTable(0, 'P1234567'), findsOneWidget);
      expect(inTable(0, '12/3/2018'), findsOneWidget);
      expect(inTable(0, 'Bangalore'), findsOneWidget);
      expect(inTable(0, '11/3/2028'), findsOneWidget);
    });

    testWidgets('renders headers only when there are no documents',
        (tester) async {
      when(() => profileBloc.state).thenReturn(ProfileLoaded(emptyProfile()));

      await pumpHome(tester);

      expect(rowCount(tester, 0), 1);
      expect(inTable(0, 'Document'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('§2.2 Courses table', () {
    testWidgets('renders the documented column headers', (tester) async {
      await pumpHome(tester);

      for (final header in const [
        'Course',
        'Number',
        'Date of issue',
        'Place of issue',
        'Validity',
      ]) {
        expect(inTable(1, header), findsOneWidget, reason: 'missing $header');
      }
    });

    testWidgets('renders a row per course', (tester) async {
      await pumpHome(tester);

      expect(rowCount(tester, 1), 2);
      expect(inTable(1, 'Medical'), findsOneWidget);
      expect(inTable(1, 'MED-99871'), findsOneWidget);
      expect(inTable(1, '5/1/2020'), findsOneWidget);
      expect(inTable(1, 'Mumbai'), findsOneWidget);
      expect(inTable(1, '4/1/2025'), findsOneWidget);
    });

    testWidgets('renders headers only when there are no courses',
        (tester) async {
      when(() => profileBloc.state).thenReturn(ProfileLoaded(emptyProfile()));

      await pumpHome(tester);

      expect(rowCount(tester, 1), 1);
      expect(inTable(1, 'Course'), findsOneWidget);
    });
  });

  group('§2.2 Sea Experience table', () {
    testWidgets('renders the documented column headers', (tester) async {
      await pumpHome(tester);

      for (final header in const [
        'Name of vessel',
        'Company name',
        'Type of vessel',
        'G.R.T',
        'B.H.P',
        'Rank',
        'From',
        'To',
        'Period',
      ]) {
        expect(inTable(2, header), findsOneWidget, reason: 'missing $header');
      }
    });

    testWidgets('renders a row per sea experience entry', (tester) async {
      when(() => profileBloc.state)
          .thenReturn(ProfileLoaded(seaExperienceProfile()));

      await pumpHome(tester);

      expect(rowCount(tester, 2), 3); // header + two voyages
      expect(inTable(2, 'MV Ocean Pioneer'), findsOneWidget);
      expect(inTable(2, 'Blue Horizon Shipping'), findsOneWidget);
      expect(inTable(2, 'Bulk Carrier'), findsOneWidget);
      expect(inTable(2, '48500'), findsOneWidget);
      expect(inTable(2, '12000'), findsOneWidget);
      expect(inTable(2, 'MT Coral Star'), findsOneWidget);
    });

    testWidgets('renders headers only when there is no sea experience',
        (tester) async {
      await pumpHome(tester);

      // The screenshot profile has no voyages yet.
      expect(rowCount(tester, 2), 1);
      expect(inTable(2, 'Name of vessel'), findsOneWidget);
    });
  });

  group('§2.2 empty profile', () {
    testWidgets('renders without crashing when every table is empty',
        (tester) async {
      when(() => profileBloc.state).thenReturn(ProfileLoaded(emptyProfile()));

      await pumpHome(tester);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Table), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'shows an empty-state placeholder for each empty table '
      '[skipped: placeholder is not implemented]',
      (tester) async {
        // TDD — the tables currently render a bare header row when empty. The
        // app already has `NotFoundWidget(title:, desc:)` (used by Edit Profile
        // for sea experience); Home should render it under each empty table.
        fail('Home renders no empty-state placeholder');
      },
      skip: true,
    );
  });

  group('§2.2 loading and error states', () {
    testWidgets('shows a spinner while the profile loads', (tester) async {
      when(() => profileBloc.state).thenReturn(ProfileLoading());

      await pumpHome(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Table), findsNothing);
    });

    testWidgets('shows the message when the profile fails to load',
        (tester) async {
      when(() => profileBloc.state)
          .thenReturn(ProfileError('Could not reach the server'));

      await pumpHome(tester);

      expect(find.text('Could not reach the server'), findsOneWidget);
    });

    testWidgets('loads the profile once the user is authenticated',
        (tester) async {
      final user = MockUser();
      when(() => user.uid).thenReturn('uid-123');
      whenListen(
        authBloc,
        Stream.fromIterable([Authenticated(user)]),
        initialState: AuthInitial(),
      );

      await pumpHome(tester);
      await tester.pump();

      final event = verify(() => profileBloc.add(captureAny<ProfileEvent>()))
          .captured
          .single as LoadProfile;
      expect(event.userId, 'uid-123');
    });
  });

  group('§2.2 long content', () {
    testWidgets('every table is horizontally scrollable', (tester) async {
      await pumpHome(tester);

      final scrollables = tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .where((s) => s.scrollDirection == Axis.horizontal);

      expect(scrollables.length, 3);
    });

    testWidgets('long vessel and company names do not overflow the screen',
        (tester) async {
      useMobileSurface(tester);
      when(() => profileBloc.state)
          .thenReturn(ProfileLoaded(longTextProfile()));

      await pumpHome(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(Table), findsNWidgets(3));
    });

    testWidgets('a wide sea experience table can be scrolled sideways',
        (tester) async {
      useMobileSurface(tester);
      when(() => profileBloc.state)
          .thenReturn(ProfileLoaded(seaExperienceProfile()));

      await pumpHome(tester);

      // The right-most column is off-screen until the table is dragged.
      await tester.drag(inTable(2, 'Name of vessel'), const Offset(-300, 0));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(inTable(2, 'Period'), findsOneWidget);
    });
  });

  group('§2.2 PDF icon (free for everyone)', () {
    testWidgets('is present and tappable for a free user', (tester) async {
      await pumpHome(tester);

      expect(svgAsset(pdfIcon), findsOneWidget);
      final target = tester.widget<InkWell>(svgAssetTapTarget(pdfIcon));
      expect(target.onTap, isNotNull);
    });

    testWidgets('is present and tappable for a subscriber', (tester) async {
      givenSubscribed();

      await pumpHome(tester);

      final target = tester.widget<InkWell>(svgAssetTapTarget(pdfIcon));
      expect(target.onTap, isNotNull);
    });

    testWidgets(
      'tapping it generates, saves and opens the PDF '
      '[skipped: runs as an integration test]',
      (tester) async {
        // `HomePage` calls the static `ProfilePdfBuilder.generateAndSave`,
        // which writes the file and hands it to `OpenFilex`. On a desktop test
        // host `OpenFilex` shells out via `Process.start` instead of using the
        // mockable method channel, so exercising the tap here would launch a
        // real viewer application. It is covered on-device in
        // `integration_test/free_user_export_test.dart` instead.
        //
        // To make this assertable in a widget test, `HomePage` would need the
        // exporter injected (e.g. a `ProfileExporter` from `sl<>()`), or
        // `generateAndSave` split into generate + save as
        // `buildPdfBytes` already is.
        fail('PDF tap cannot be exercised on a desktop test host');
      },
      skip: true,
    );
  });

  group('§2.2 DOC icon when NOT subscribed', () {
    testWidgets('shows the upgrade prompt instead of downloading',
        (tester) async {
      await pumpHome(tester);

      await tester.tap(svgAssetTapTarget(docIcon));
      await tester.pump();

      expect(
        find.text('DOCX Export is a Pro feature. Please subscribe to unlock.'),
        findsOneWidget,
      );
      expect(find.text('Upgrade'), findsOneWidget);
    });

    testWidgets('starts no download', (tester) async {
      await pumpHome(tester);

      await tester.tap(svgAssetTapTarget(docIcon));
      await tester.pumpAndSettle();

      expect(pathProviderLog.calls, isEmpty);
    });

    testWidgets('tapping Upgrade opens the subscription screen',
        (tester) async {
      await pumpHome(tester);

      await tester.tap(svgAssetTapTarget(docIcon));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upgrade'));
      await tester.pumpAndSettle();

      expect(find.text(routeStubText(AppRoutes.subscription)), findsOneWidget);
    });

    testWidgets('dismissing the prompt does not attempt a download',
        (tester) async {
      await pumpHome(tester);

      await tester.tap(svgAssetTapTarget(docIcon));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);

      // Swipe the prompt away instead of taking the upgrade.
      await tester.drag(find.byType(SnackBar), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
      expect(pathProviderLog.calls, isEmpty);
      expect(find.text(routeStubText(AppRoutes.subscription)), findsNothing);
    });
  });

  group('§2.2 DOC icon when subscribed', () {
    testWidgets('exports directly with no upgrade prompt', (tester) async {
      givenSubscribed();

      await pumpHome(tester);

      await tester.tap(svgAssetTapTarget(docIcon));
      await tester.pump();

      expect(find.text('Generating DOCX...'), findsOneWidget);
      expect(
        find.text('DOCX Export is a Pro feature. Please subscribe to unlock.'),
        findsNothing,
      );

      await tester.pumpAndSettle();

      // The document was built and the save was attempted.
      expect(
        pathProviderLog.contains('getApplicationDocumentsDirectory'),
        isTrue,
      );
    });

    testWidgets(
        'profile isPremiumPaid flag does not bypass paywall without active subscription (PAY-SEC-001/002)',
        (tester) async {
      // PAY-SEC-001 / PAY-SEC-002: RevenueCat is the single source of truth.
      // Firestore profile flag is ignored if RevenueCat subscription is inactive.
      when(() => profileBloc.state)
          .thenReturn(ProfileLoaded(fullProfile(isPremiumPaid: true)));

      await pumpHome(tester);

      await tester.tap(svgAssetTapTarget(docIcon));
      await tester.pump();

      expect(
        find.text('DOCX Export is a Pro feature. Please subscribe to unlock.'),
        findsOneWidget,
      );
      expect(find.text('Upgrade'), findsOneWidget);
    });
  });

  group('§2.2 Edit icon', () {
    testWidgets('opens Edit Profile pre-filled with the current data',
        (tester) async {
      // Edit Profile's `NotFoundWidget` empty state is sized at 15% of screen
      // height and needs ~131 logical pixels, so it overflows on the default
      // 800x600 test window (and on shorter phones — see
      // `test/widget/widgets/not_found_widget_test.dart`). A large-phone
      // surface keeps this test focused on the pre-fill behaviour.
      useMobileSurface(tester, size: const Size(430, 932));

      await pumpHome(tester, stubRoutes: false);

      await tester.tap(svgAssetTapTarget(editIcon));
      await tester.pumpAndSettle();

      expect(find.byType(EditDetails), findsOneWidget);
      expect(appTextFieldValue(tester, 'First name'), 'Isthiyaque');
      expect(appTextFieldValue(tester, 'Last name'), 'Kambathagothi');
      expect(appTextFieldValue(tester, 'Post Applied For'), 'Fourth Engineer');
      expect(appTextFieldValue(tester, 'Date of Birth'), '17/7/1987');
      expect(appTextFieldValue(tester, 'Nationality'), 'Indian');
    });
  });

  group('§2.2 Logout icon', () {
    testWidgets('asks the auth bloc to sign out', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      verify(() => authBloc.add(any<AuthEvent>(that: isA<SignOutEvent>())))
          .called(1);
    });

    testWidgets('returns to Login once the session is cleared', (tester) async {
      whenListen(
        authBloc,
        Stream.fromIterable([Unauthenticated()]),
        initialState: AuthInitial(),
      );

      await pumpHome(tester);
      await tester.pumpAndSettle();

      expect(find.text(routeStubText(AppRoutes.login)), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets(
      'asks for confirmation before logging out '
      '[skipped: no confirmation dialog exists]',
      (tester) async {
        // TDD — tapping logout signs out immediately. The plan lists the
        // confirmation dialog as "if applicable"; if it is wanted, expect an
        // AlertDialog with Cancel/Logout actions and no `SignOutEvent` until
        // Logout is confirmed.
        fail('Logout has no confirmation step');
      },
      skip: true,
    );
  });
}
