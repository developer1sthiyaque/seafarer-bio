import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_bloc.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_event.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/bloc/personal_info_state.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_profiles.dart';

/// Supports test plan §2.3 and §3.4 — the bloc behind Home and Edit Profile.
///
/// `ProfileState` does not implement `Equatable`, so states are matched by type
/// and their payload is asserted in `verify`.
void main() {
  late MockGetProfileUseCase getProfile;
  late MockSaveProfileUseCase saveProfile;
  late MockUpdateProfileUseCase updateProfile;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    getProfile = MockGetProfileUseCase();
    saveProfile = MockSaveProfileUseCase();
    updateProfile = MockUpdateProfileUseCase();

    when(() => updateProfile(any())).thenAnswer((_) async {});
    when(() => saveProfile(any())).thenAnswer((_) async {});
  });

  ProfileBloc buildBloc() => ProfileBloc(
        getProfile: getProfile,
        saveProfile: saveProfile,
        updateProfile: updateProfile,
      );

  group('LoadProfile', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] for an existing profile',
      setUp: () {
        when(() => getProfile('user_full_001'))
            .thenAnswer((_) => Stream.value(fullProfile()));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadProfile('user_full_001')),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
      verify: (bloc) {
        expect((bloc.state as ProfileLoaded).profile, fullProfile());
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'stays loading when the profile document does not exist yet',
      setUp: () {
        when(() => getProfile(any()))
            .thenAnswer((_) => Stream<Profile?>.value(null));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadProfile('brand-new-user')),
      expect: () => [isA<ProfileLoading>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileError when the profile stream fails',
      setUp: () {
        when(() => getProfile(any()))
            .thenAnswer((_) => Stream<Profile?>.error(Exception('permission')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadProfile('user_full_001')),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
      verify: (bloc) {
        expect((bloc.state as ProfileError).message, contains('permission'));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'follows live updates to the same profile',
      setUp: () {
        when(() => getProfile(any())).thenAnswer(
          (_) => Stream<Profile?>.fromIterable([
            fullProfile(),
            fullProfile().copyWith(documents: const []),
          ]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(LoadProfile('user_full_001')),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
        isA<ProfileLoaded>(),
      ],
      verify: (bloc) {
        expect((bloc.state as ProfileLoaded).profile.documents, isEmpty);
      },
    );
  });

  group('UpdateFullProfileEvent (Edit Profile save)', () {
    blocTest<ProfileBloc, ProfileState>(
      'merges the edits and emits the updated ProfileLoaded',
      build: buildBloc,
      seed: () => ProfileLoaded(fullProfile()),
      act: (bloc) => bloc.add(UpdateFullProfileEvent(
        personalDetails: const PersonalDetails(
          postAppliedFor: 'Second Engineer',
          firstname: 'Isthiyaq',
          lastname: 'Kambathagothi',
          fatherName: 'Abdul Rauf Kambathagothi',
          dob: '17/7/1987',
          nationality: 'Indian',
          profilePic: '',
        ),
        seaExperiences: const [kOceanPioneerExperience],
      )),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
      verify: (bloc) {
        final saved = verify(() => updateProfile(captureAny()))
            .captured
            .single as Profile;

        expect(saved.userId, 'user_full_001');
        expect(saved.personalDetails.firstname, 'Isthiyaq');
        expect(saved.personalDetails.postAppliedFor, 'Second Engineer');
        expect(saved.seaExperiences, [kOceanPioneerExperience]);
        // Sections not passed in the event are carried over untouched.
        expect(saved.documents, [kPassportDocument]);
        expect(saved.courses, [kMedicalCourse]);

        expect((bloc.state as ProfileLoaded).profile, saved);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'appends new document and sea experience rows',
      build: buildBloc,
      seed: () => ProfileLoaded(fullProfile()),
      act: (bloc) => bloc.add(UpdateFullProfileEvent(
        documents: const [
          kPassportDocument,
          Document(
            name: 'CDC',
            number: 'MUM123456',
            issueDate: '1/2/2019',
            place: 'Mumbai',
            validity: '31/1/2029',
          ),
        ],
        seaExperiences: const [kOceanPioneerExperience],
      )),
      verify: (bloc) {
        final profile = (bloc.state as ProfileLoaded).profile;
        expect(profile.documents, hasLength(2));
        expect(profile.documents.last.name, 'CDC');
        expect(profile.seaExperiences, hasLength(1));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'can clear every table',
      build: buildBloc,
      seed: () => ProfileLoaded(seaExperienceProfile()),
      act: (bloc) => bloc.add(UpdateFullProfileEvent(
        documents: const [],
        courses: const [],
        seaExperiences: const [],
      )),
      verify: (bloc) {
        final profile = (bloc.state as ProfileLoaded).profile;
        expect(profile.documents, isEmpty);
        expect(profile.courses, isEmpty);
        expect(profile.seaExperiences, isEmpty);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileError and keeps the user on screen when the save fails',
      setUp: () {
        when(() => updateProfile(any())).thenThrow(Exception('network error'));
      },
      build: buildBloc,
      seed: () => ProfileLoaded(fullProfile()),
      act: (bloc) => bloc.add(UpdateFullProfileEvent(
        documents: const [],
      )),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
      verify: (bloc) {
        expect((bloc.state as ProfileError).message, contains('network error'));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'is ignored when no profile is loaded',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateFullProfileEvent(documents: const [])),
      expect: () => <ProfileState>[],
      verify: (_) => verifyNever(() => updateProfile(any())),
    );
  });

  group('SaveProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'delegates to the save use case without changing state',
      build: buildBloc,
      act: (bloc) => bloc.add(SaveProfileEvent(fullProfile())),
      expect: () => <ProfileState>[],
      verify: (_) => verify(() => saveProfile(fullProfile())).called(1),
    );
  });

  group('profile completion wizard steps', () {
    blocTest<ProfileBloc, ProfileState>(
      'personal details step emits PersonalDetailsUpdateSuccess',
      build: buildBloc,
      seed: () => ProfileLoaded(emptyProfile()),
      act: (bloc) => bloc.add(UpdatePersonalDetailsEvent(kFullPersonalDetails)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<PersonalDetailsUpdateSuccess>(),
      ],
      verify: (bloc) {
        final profile =
            (bloc.state as PersonalDetailsUpdateSuccess).profile;
        expect(profile.personalDetails, kFullPersonalDetails);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'documents step only runs after the personal details step',
      build: buildBloc,
      seed: () => ProfileLoaded(emptyProfile()),
      act: (bloc) => bloc.add(UpdateDocumentsEvent(const [kPassportDocument])),
      expect: () => <ProfileState>[],
      verify: (_) => verifyNever(() => updateProfile(any())),
    );

    blocTest<ProfileBloc, ProfileState>(
      'documents step emits DocumentsUpdateSuccess',
      build: buildBloc,
      seed: () => PersonalDetailsUpdateSuccess(emptyProfile()),
      act: (bloc) => bloc.add(UpdateDocumentsEvent(const [kPassportDocument])),
      expect: () => [isA<ProfileLoading>(), isA<DocumentsUpdateSuccess>()],
      verify: (bloc) {
        expect(
          (bloc.state as DocumentsUpdateSuccess).profile.documents,
          [kPassportDocument],
        );
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'courses step emits CertificateUpdateSuccess and marks the profile complete',
      build: buildBloc,
      seed: () => DocumentsUpdateSuccess(emptyProfile()),
      act: (bloc) => bloc.add(UpdateCoursesEvent(const [kMedicalCourse])),
      expect: () => [isA<ProfileLoading>(), isA<CertificateUpdateSuccess>()],
      verify: (_) {
        final saved =
            verify(() => updateProfile(captureAny())).captured.single as Profile;
        expect(saved.courses, [kMedicalCourse]);
        expect(saved.isProfileCompleted, isTrue);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'a failing wizard step emits ProfileError',
      setUp: () {
        when(() => updateProfile(any())).thenThrow(Exception('offline'));
      },
      build: buildBloc,
      seed: () => ProfileLoaded(emptyProfile()),
      act: (bloc) => bloc.add(UpdatePersonalDetailsEvent(kFullPersonalDetails)),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    test(
      'sea experience step emits CertificateUpdateSuccess',
      () {
        // TDD — `_onUpdateSeaExperience` is declared `void` and does not await
        // `_updateProfile`, so its `emit` runs after the event handler has
        // already completed, which Bloc rejects at runtime. The event is also
        // dead code: no screen dispatches `UpdateSeaExperienceEvent` (Edit
        // Profile uses `UpdateFullProfileEvent`).
        //
        // Expected fix: make the handler `Future<void>` and `await
        // _updateProfile(...)`, matching `_onUpdateDocuments`.
        fail('_onUpdateSeaExperience emits after its handler completes');
      },
      skip: 'Handler does not await its update — see comment',
    );
  });

  group('close', () {
    test('cancels its subscription without throwing', () async {
      when(() => getProfile(any()))
          .thenAnswer((_) => StreamController<Profile?>().stream);

      final bloc = buildBloc();
      bloc.add(LoadProfile('user_full_001'));

      await expectLater(bloc.close(), completes);
    });
  });
}
