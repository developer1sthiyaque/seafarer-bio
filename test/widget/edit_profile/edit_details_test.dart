import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/edit_details.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/course_wrapper_widget.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/widgets/document_wrapper_widget.dart';
import 'package:seafarer_bio_data/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:seafarer_bio_data/widgets/app_date_picker.dart';
import 'package:seafarer_bio_data/widgets/not_found_widget.dart';

import '../../helpers/finders.dart';
import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_profiles.dart';

/// Test plan §2.3 — Edit Profile screen.
///
/// Notes on how this screen differs from the plan: it has **no `Form`**, so the
/// per-field validators supplied to the document/course widgets never run, the
/// Save button is always enabled, and a successful save shows a SnackBar rather
/// than popping back to Home. Those gaps are captured as skipped TDD tests.
/// Wide enough to dodge the known `SeaExperienceWidget` overflow (~463px).
const Size kWideSurface = Size(600, 932);

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
    when(() => subscriptionBloc.state).thenReturn(SubscriptionInitial());
    when(() => profileBloc.state).thenReturn(ProfileLoaded(fullProfile()));
  });

  /// A large-phone surface: the sea-experience empty state (`NotFoundWidget`)
  /// overflows shorter viewports — see
  /// `test/widget/widgets/not_found_widget_test.dart`.
  Future<void> pumpEdit(
    WidgetTester tester, {
    Size surface = const Size(430, 932),
  }) async {
    useMobileSurface(tester, size: surface);
    await pumpTestApp(
      tester,
      child: const EditDetails(),
      authBloc: authBloc,
      profileBloc: profileBloc,
      subscriptionBloc: subscriptionBloc,
      stubRoutes: true,
    );
  }

  Finder addIconFor(String section) {
    const order = {'Documents': 0, 'Courses': 1, 'Sea Experience': 2};
    return svgAssetTapTarget('assets/icons/add-icon.svg').at(order[section]!);
  }

  group('§2.3 pre-filling', () {
    testWidgets('pre-fills every personal detail', (tester) async {
      await pumpEdit(tester);

      expect(appTextFieldValue(tester, 'Post Applied For'), 'Fourth Engineer');
      expect(appTextFieldValue(tester, 'First name'), 'Isthiyaque');
      expect(appTextFieldValue(tester, 'Last name'), 'Kambathagothi');
      expect(
        appTextFieldValue(tester, "Father's Name"),
        'Abdul Rauf Kambathagothi',
      );
      expect(appTextFieldValue(tester, 'Date of Birth'), '17/7/1987');
      expect(appTextFieldValue(tester, 'Nationality'), 'Indian');
    });

    testWidgets('pre-fills the document rows', (tester) async {
      await pumpEdit(tester);

      expect(find.byType(DocumentWrapperWidget), findsOneWidget);
      expect(find.text('Passport'), findsOneWidget);
      expect(appTextFieldValue(tester, 'Passport Number'), 'P1234567');
      expect(appTextFieldValue(tester, 'Passport Issued Place'), 'Bangalore');
      expect(appDatePickerValue(tester, 'Passport Issued Date'), '12/3/2018');
      expect(appDatePickerValue(tester, 'Passport Validity'), '11/3/2028');
    });

    testWidgets('pre-fills the course rows', (tester) async {
      await pumpEdit(tester);

      expect(find.byType(CourseWrapperWidget), findsOneWidget);
      expect(find.text('Medical'), findsOneWidget);
      expect(appTextFieldValue(tester, 'Medical Number'), 'MED-99871');
      expect(appTextFieldValue(tester, 'Medical Issued Place'), 'Mumbai');
      expect(appDatePickerValue(tester, 'Medical Issued Date'), '5/1/2020');
      expect(appDatePickerValue(tester, 'Medical Validity'), '4/1/2025');
    });

    testWidgets('pre-fills the sea experience rows', (tester) async {
      when(() => profileBloc.state)
          .thenReturn(ProfileLoaded(seaExperienceProfile()));

      // `SeaExperienceWidget` overflows on phone widths — see
      // `test/widget/widgets/layout_overflow_test.dart`. A wider surface keeps
      // this test focused on the data rather than that known defect.
      await pumpEdit(tester, surface: kWideSurface);

      expect(find.byType(SeaExperienceWidget), findsNWidgets(2));
      expect(find.text('MV Ocean Pioneer'), findsOneWidget);
      expect(find.text('MT Coral Star'), findsOneWidget);
      expect(find.text('Bulk Carrier'), findsOneWidget);
      expect(find.text('Third Engineer'), findsOneWidget);
    });

    testWidgets('shows an empty state when there is no sea experience',
        (tester) async {
      await pumpEdit(tester);

      expect(find.byType(NotFoundWidget), findsOneWidget);
      expect(find.byType(SeaExperienceWidget), findsNothing);
    });

    testWidgets('shows the photo placeholder when there is no photo',
        (tester) async {
      when(() => profileBloc.state).thenReturn(ProfileLoaded(noPhotoProfile()));

      await pumpEdit(tester);

      expect(find.text('No Photo'), findsOneWidget);
    });

    testWidgets('shows the stored photo when there is one', (tester) async {
      await pumpEdit(tester);

      expect(find.text('No Photo'), findsNothing);
      expect(find.byType(Image), findsWidgets);
    });
  });

  group('§2.3 adding rows', () {
    testWidgets('adding a document appends a new editable row', (tester) async {
      await pumpEdit(tester);

      await scrollAndTap(tester, addIconFor('Documents'));
      await tester.pumpAndSettle();

      expect(find.text('Add New Documents Type'), findsOneWidget);
      await tester.enterText(appTextField('Documents Name'), 'CDC');
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentWrapperWidget), findsNWidgets(2));
      expect(appTextField('CDC Number'), findsOneWidget);
      expect(appTextFieldValue(tester, 'CDC Number'), isEmpty);
    });

    testWidgets('adding a course appends a new editable row', (tester) async {
      await pumpEdit(tester);

      await scrollAndTap(tester, addIconFor('Courses'));
      await tester.pumpAndSettle();

      expect(find.text('Add New Courses Type'), findsOneWidget);
      await tester.enterText(appTextField('Courses Name'), 'STCW');
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();

      expect(find.byType(CourseWrapperWidget), findsNWidgets(2));
      expect(appTextField('STCW Number'), findsOneWidget);
    });

    testWidgets('adding a sea experience appends a new card', (tester) async {
      // Wider surface: see the note on the known `SeaExperienceWidget` overflow.
      await pumpEdit(tester, surface: kWideSurface);

      await scrollAndTap(tester, addIconFor('Sea Experience'));
      await tester.pumpAndSettle();

      expect(find.text('Add Sea Experience'), findsOneWidget);
      await tester.enterText(appTextField('Ship Name'), 'MV Ocean Pioneer');
      await tester.enterText(
        appTextField('Company Name'),
        'Blue Horizon Shipping',
      );
      await tester.enterText(appTextField('Type'), 'Bulk Carrier');
      await tester.enterText(appTextField('Rank'), 'Third Engineer');
      await tester.enterText(appTextField('GRT'), '48500');
      await tester.enterText(appTextField('BHP'), '12000');

      await scrollAndTap(tester, find.text('Add Experience'));
      await tester.pumpAndSettle();

      expect(find.byType(SeaExperienceWidget), findsOneWidget);
      expect(find.text('MV Ocean Pioneer'), findsOneWidget);
      expect(find.byType(NotFoundWidget), findsNothing);
    });
  });

  group('§2.3 removing rows', () {
    testWidgets('removing a document deletes the row', (tester) async {
      await pumpEdit(tester);
      expect(find.byType(DocumentWrapperWidget), findsOneWidget);

      await scrollAndTap(
        tester,
        find.descendant(
          of: find.byType(DocumentWrapperWidget),
          matching: find.byIcon(Icons.cancel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DocumentWrapperWidget), findsNothing);
      expect(appTextField('Passport Number'), findsNothing);
    });

    testWidgets('removing a course deletes the row', (tester) async {
      await pumpEdit(tester);
      expect(find.byType(CourseWrapperWidget), findsOneWidget);

      await scrollAndTap(
        tester,
        find.descendant(
          of: find.byType(CourseWrapperWidget),
          matching: find.byIcon(Icons.cancel),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CourseWrapperWidget), findsNothing);
    });

    testWidgets('removing a sea experience deletes the card', (tester) async {
      when(() => profileBloc.state)
          .thenReturn(ProfileLoaded(seaExperienceProfile()));

      // `SeaExperienceWidget` overflows on phone widths — see
      // `test/widget/widgets/layout_overflow_test.dart`. A wider surface keeps
      // this test focused on the data rather than that known defect.
      await pumpEdit(tester, surface: kWideSurface);
      expect(find.byType(SeaExperienceWidget), findsNWidgets(2));

      await scrollAndTap(tester, find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.byType(SeaExperienceWidget), findsOneWidget);
      expect(find.text('MV Ocean Pioneer'), findsNothing);
      expect(find.text('MT Coral Star'), findsOneWidget);
    });
  });

  group('§2.3 saving', () {
    testWidgets('dispatches the edited profile', (tester) async {
      await pumpEdit(tester);

      await tester.enterText(appTextField('First name'), 'Isthiyaq');
      await tester.enterText(appTextField('Post Applied For'), 'Chief Engineer');

      await scrollAndTap(tester, find.text('Save Changes'));

      final event = verify(() => profileBloc.add(captureAny<ProfileEvent>()))
          .captured
          .single as UpdateFullProfileEvent;

      expect(event.personalDetails!.firstname, 'Isthiyaq');
      expect(event.personalDetails!.postAppliedFor, 'Chief Engineer');
      expect(event.personalDetails!.lastname, 'Kambathagothi');
      expect(event.personalDetails!.dob, '17/7/1987');
      expect(event.documents, hasLength(1));
      expect(event.documents!.single.name, 'Passport');
      expect(event.documents!.single.number, 'P1234567');
      expect(event.courses, hasLength(1));
      expect(event.courses!.single.title, 'Medical');
      expect(event.seaExperiences, isEmpty);
    });

    testWidgets('dispatches newly added rows', (tester) async {
      await pumpEdit(tester);

      await scrollAndTap(tester, addIconFor('Documents'));
      await tester.pumpAndSettle();
      await tester.enterText(appTextField('Documents Name'), 'CDC');
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();
      await tester.enterText(appTextField('CDC Number'), 'MUM123456');
      await tester.enterText(appTextField('CDC Issued Place'), 'Mumbai');
      tester.widget<AppDatePicker>(appDatePicker('CDC Validity')).controller.text = '01/01/2030';
      tester.widget<AppDatePicker>(appDatePicker('CDC Issued Date')).controller.text = '01/01/2020';

      await scrollAndTap(tester, find.text('Save Changes'));

      final event = verify(() => profileBloc.add(captureAny<ProfileEvent>()))
          .captured
          .last as UpdateFullProfileEvent;

      expect(event.documents, hasLength(2));
      expect(event.documents!.last.name, 'CDC');
      expect(event.documents!.last.number, 'MUM123456');
    });

    testWidgets('dispatches removals', (tester) async {
      await pumpEdit(tester);

      await scrollAndTap(
        tester,
        find.descendant(
          of: find.byType(DocumentWrapperWidget),
          matching: find.byIcon(Icons.cancel),
        ),
      );
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Save Changes'));

      final event = verify(() => profileBloc.add(captureAny<ProfileEvent>()))
          .captured
          .last as UpdateFullProfileEvent;

      expect(event.documents, isEmpty);
    });

    testWidgets('confirms a successful save to the user', (tester) async {
      whenListen(
        profileBloc,
        Stream.fromIterable([ProfileLoaded(fullProfile())]),
        initialState: ProfileLoaded(fullProfile()),
      );

      await pumpEdit(tester);
      await tester.pump();

      expect(find.text('Profile Updated Successfully'), findsOneWidget);
    });

    testWidgets('a failed save shows the error and keeps the user on screen',
        (tester) async {
      whenListen(
        profileBloc,
        Stream.fromIterable([ProfileError('Exception: network error')]),
        initialState: ProfileLoaded(fullProfile()),
      );

      await pumpEdit(tester);
      await tester.pumpAndSettle();

      expect(find.text('Exception: network error'), findsOneWidget);
      expect(find.byType(EditDetails), findsOneWidget);
    });

    testWidgets('shows a spinner while the save is in flight', (tester) async {
      whenListen(
        profileBloc,
        Stream.fromIterable([ProfileLoading()]),
        initialState: ProfileLoaded(fullProfile()),
      );

      await pumpEdit(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'returns to Home after a successful save '
      '[skipped: the screen does not pop]',
      (tester) async {
        // TDD — `EditDetails` shows a SnackBar on success; the
        // `Navigator.of(context).pop()` in its `BlocListener` is commented out,
        // so the user has to press back manually. Expected: pop (or
        // `pushNamedAndRemoveUntil(AppRoutes.home)`) once the save succeeds.
        fail('Edit Profile does not navigate back after saving');
      },
      skip: true,
    );
  });

  group('§2.3 validation', () {
    testWidgets(
      'field-level validation errors render inline '
      '[skipped: the screen has no Form]',
      (tester) async {
        // TDD — `DocumentWrapperWidget` / `CourseWrapperWidget` pass
        // `AppValidators.required` to their fields, but `EditDetails` never
        // wraps them in a `Form`, so nothing ever calls `validate()` and a row
        // can be saved completely blank. Expected: a `Form` with a
        // `GlobalKey<FormState>` (as `LoginPage` and `SignUpPage` already do)
        // validated before dispatching `UpdateFullProfileEvent`.
        fail('Edit Profile has no Form, so validators never run');
      },
      skip: true,
    );

    testWidgets(
      'Save is disabled while the form is invalid '
      '[skipped: Save is always enabled]',
      (tester) async {
        // TDD — `AppButton` takes a non-null `VoidCallback onTap` and has no
        // disabled state. Expected: `AppButton({VoidCallback? onTap})` rendering
        // a muted style when null, driven by the form's validity.
        fail('Save Changes is always enabled');
      },
      skip: true,
    );

    testWidgets('blank required fields block submission due to form validation',
        (tester) async {
      await pumpEdit(tester);

      await tester.enterText(appTextField('Passport Number'), '');
      await tester.enterText(appTextField('First name'), '');

      await scrollAndTap(tester, find.text('Save Changes'));

      verifyNever(() => profileBloc.add(any()));
    });
  });
}
