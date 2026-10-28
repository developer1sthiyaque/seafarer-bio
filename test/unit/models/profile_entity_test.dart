import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';

import '../../helpers/firestore_fakes.dart';
import '../../helpers/fixture_reader.dart';
import '../../helpers/test_profiles.dart';

/// Test plan §1.1 — Models.
///
/// This app persists to Firestore, so the serialization boundary is
/// `fromFirestore` / `toFirestore` rather than `fromJson` / `toJson`, and all
/// date fields are stored as raw display strings (`17/7/1987`) rather than
/// `DateTime`. Tests below are written against that actual contract.
void main() {
  group('§1.1 Profile.fromFirestore / toFirestore round-trip', () {
    test('preserves every field of a fully populated profile', () {
      final data = fixtureMap('profile_sea_experience.json');
      final userId = data.remove('userId') as String;

      final profile = profileFromFirestoreMap(data, userId: userId);

      // `userId` comes from the snapshot id, not the document body, so the
      // serialized form is compared against the body alone.
      // PAY-SEC-001/002: isPremium is stripped from client toFirestore()
      expect(profile.toFirestore(), equals(data..remove('isPremium')));
      expect(profile.userId, userId);
    });

    test('preserves nested documents, courses and seaExperience lists', () {
      final data = fixtureMap('profile_sea_experience.json');
      final profile = profileFromFirestoreMap(data, userId: 'user_sea_004');

      expect(profile.documents, hasLength(2));
      expect(profile.courses, hasLength(2));
      expect(profile.seaExperiences, hasLength(2));

      expect(profile.documents.first.name, 'Passport');
      expect(profile.documents.first.number, 'P1234567');
      expect(profile.documents.first.issueDate, '12/3/2018');
      expect(profile.documents.first.place, 'Bangalore');
      expect(profile.documents.first.validity, '11/3/2028');

      expect(profile.courses.first.title, 'Medical');
      expect(profile.courses.first.number, 'MED-99871');
      expect(profile.courses.first.place, 'Mumbai');

      final experience = profile.seaExperiences.first;
      expect(experience.vesselName, 'MV Ocean Pioneer');
      expect(experience.companyName, 'Blue Horizon Shipping');
      expect(experience.vesselType, 'Bulk Carrier');
      expect(experience.grt, '48500');
      expect(experience.bhp, '12000');
      expect(experience.rank, 'Third Engineer');
      expect(experience.from, '1.4.2021');
      expect(experience.to, '1.12.2021');
      expect(experience.period, '8');
    });

    test('survives a second round-trip unchanged (idempotent)', () {
      final data = fixtureMap('profile_full.json')..remove('userId');

      final once = profileFromFirestoreMap(data, userId: 'u');
      final twice = profileFromFirestoreMap(once.toFirestore(), userId: 'u');

      expect(twice.toFirestore(), equals(once.toFirestore()));
    });

    test('the Dart test builders stay in sync with the JSON fixtures', () {
      final fromFixture = profileFromFirestoreMap(
        fixtureMap('profile_full.json')..remove('userId'),
        userId: 'user_full_001',
      );

      expect(fromFixture.toFirestore(), equals(fullProfile().toFirestore()));
      expect(fromFixture.userId, fullProfile().userId);
    });
  });

  group('§1.1 optional and empty values deserialize safely', () {
    test('a profile with no documents, courses or sea experience', () {
      final data = fixtureMap('profile_empty.json')..remove('userId');
      final profile = profileFromFirestoreMap(data, userId: 'user_empty_003');

      expect(profile.documents, isEmpty);
      expect(profile.courses, isEmpty);
      expect(profile.seaExperiences, isEmpty);
      expect(profile.isProfileCompleted, isFalse);
      expect(profile.isPremiumPaid, isFalse);
      // PAY-SEC-001/002: isPremium is stripped from client toFirestore()
      expect(profile.toFirestore(), equals(data..remove('isPremium')));
    });

    test('a profile with no photo keeps profilePic empty rather than null', () {
      final data = fixtureMap('profile_no_photo.json')..remove('userId');
      final profile = profileFromFirestoreMap(data, userId: 'x');

      expect(profile.personalDetails.profilePic, isEmpty);
    });

    test('an entirely absent document body falls back to empty defaults', () {
      final profile = profileFromFirestoreMap(const {}, userId: 'brand_new');

      expect(profile.userId, 'brand_new');
      expect(profile.personalDetails.firstname, isEmpty);
      expect(profile.personalDetails.profilePic, isEmpty);
      expect(profile.documents, isEmpty);
      expect(profile.courses, isEmpty);
      expect(profile.seaExperiences, isEmpty);
      expect(profile.isProfileCompleted, isFalse);
      expect(profile.isPremiumPaid, isFalse);
    });

    test('missing individual keys fall back per field', () {
      final profile = profileFromFirestoreMap(
        const {
          'personalDetails': {'firstname': 'Solo'},
          'documents': [
            {'name': 'Passport'},
          ],
        },
        userId: 'partial',
      );

      expect(profile.personalDetails.firstname, 'Solo');
      expect(profile.personalDetails.lastname, isEmpty);
      expect(profile.documents.single.name, 'Passport');
      expect(profile.documents.single.number, isEmpty);
      expect(profile.documents.single.validity, isEmpty);
    });

    test('null snapshot data does not throw', () {
      expect(
        () => Profile.fromFirestore(
          FakeProfileSnapshot(id: 'none', data: null),
          null,
        ),
        returnsNormally,
      );
    });
  });

  group('§1.1 date fields are stored losslessly, whatever the format', () {
    // Dates are persisted as the exact display string the picker produced, so
    // no locale-dependent parsing happens on the model boundary. These cases
    // lock in that no reformatting or truncation creeps in later.
    const formats = <String>[
      '17/7/1987', // screenshot format: single-digit day/month
      '07/07/1987', // zero padded
      '1987-07-17', // ISO
      '17.7.1987', // the format the sea-experience picker writes
      '1/1/2100', // far future validity
      '', // never set
    ];

    for (final value in formats) {
      test('dob "$value" survives a round-trip verbatim', () {
        final profile = profileFromFirestoreMap(
          {
            'personalDetails': {'dob': value},
          },
          userId: 'd',
        );

        expect(profile.personalDetails.dob, value);
        expect(
          (profile.toFirestore()['personalDetails']
              as Map<String, dynamic>)['dob'],
          value,
        );
      });
    }

    test('document issue and validity dates survive a round-trip verbatim', () {
      final profile = profileFromFirestoreMap(
        const {
          'documents': [
            {
              'name': 'Passport',
              'issued-date': '17/7/1987',
              'validity': '1.1.2030',
            },
          ],
        },
        userId: 'd',
      );

      expect(profile.documents.single.issueDate, '17/7/1987');
      expect(profile.documents.single.validity, '1.1.2030');
    });
  });

  group('§1.1 equality', () {
    test('two identically populated profiles are equal', () {
      expect(fullProfile(), equals(fullProfile()));
    });

    test('profiles differing in personal details are not equal', () {
      final other = fullProfile().copyWith(
        personalDetails: kFullPersonalDetails.copyWithFirstname('Someone'),
      );

      expect(other, isNot(equals(fullProfile())));
    });

    test('profiles differing in their document list are not equal', () {
      final other = fullProfile().copyWith(documents: const []);

      expect(other, isNot(equals(fullProfile())));
    });

    test('profiles differing only in isPremiumPaid are not equal', () {
      // Premium state drives the DOCX gate on Home, so it must take part in
      // equality — otherwise a BlocBuilder will not rebuild when it flips.
      expect(
        fullProfile(isPremiumPaid: true),
        isNot(equals(fullProfile(isPremiumPaid: false))),
      );
    });

    test('profiles differing only in isProfileCompleted are not equal', () {
      expect(
        fullProfile().copyWith(isCompleted: true),
        isNot(equals(fullProfile().copyWith(isCompleted: false))),
      );
    });

    test('identical documents are equal, differing ones are not', () {
      expect(kPassportDocument, equals(kPassportDocument));

      expect(
        const Document(
          name: 'Passport',
          number: 'P1234567',
          issueDate: '12/3/2018',
          place: 'Bangalore',
          validity: '11/3/2028',
        ),
        equals(kPassportDocument),
      );

      expect(
        const Document(
          name: 'Passport',
          number: 'P7654321',
          issueDate: '12/3/2018',
          place: 'Bangalore',
          validity: '11/3/2028',
        ),
        isNot(equals(kPassportDocument)),
      );
    });

    test('documents differing only in issue date are not equal', () {
      expect(
        const Document(
          name: 'Passport',
          number: 'P1234567',
          issueDate: '1/1/2001',
          place: 'Bangalore',
          validity: '11/3/2028',
        ),
        isNot(equals(kPassportDocument)),
      );
    });

    test('documents differing only in place of issue are not equal', () {
      expect(
        const Document(
          name: 'Passport',
          number: 'P1234567',
          issueDate: '12/3/2018',
          place: 'Chennai',
          validity: '11/3/2028',
        ),
        isNot(equals(kPassportDocument)),
      );
    });

    test('courses compare on every field', () {
      expect(kMedicalCourse, equals(kMedicalCourse));
      expect(
        kMedicalCourse.copyWith(number: 'OTHER'),
        isNot(equals(kMedicalCourse)),
      );
      expect(
        const Course(
          title: 'Medical',
          number: 'MED-99871',
          issueDate: '5/1/2020',
          place: 'Chennai',
          validity: '4/1/2025',
        ),
        isNot(equals(kMedicalCourse)),
      );
    });

    test('sea experience entries compare on every field', () {
      expect(kOceanPioneerExperience, equals(kOceanPioneerExperience));
      expect(
        kOceanPioneerExperience.copyWith(grt: '1'),
        isNot(equals(kOceanPioneerExperience)),
      );
      expect(
        kOceanPioneerExperience.copyWith(period: '99'),
        isNot(equals(kOceanPioneerExperience)),
      );
    });
  });

  group('§1.1 copyWith', () {
    test('Profile.copyWith replaces only what is passed', () {
      final original = fullProfile();
      final updated = original.copyWith(documents: const []);

      expect(updated.documents, isEmpty);
      expect(updated.userId, original.userId);
      expect(updated.personalDetails, original.personalDetails);
      expect(updated.courses, original.courses);
      expect(updated.seaExperiences, original.seaExperiences);
      expect(updated.isProfileCompleted, original.isProfileCompleted);
      expect(updated.isPremiumPaid, original.isPremiumPaid);
    });

    test('Profile.copyWith with no arguments returns an equivalent profile', () {
      final original = fullProfile(isPremiumPaid: true);
      final copy = original.copyWith();

      expect(copy.toFirestore(), equals(original.toFirestore()));
      expect(copy.userId, original.userId);
    });

    test('Profile.copyWith can flip the premium and completion flags', () {
      final updated = fullProfile().copyWith(isPremium: true, isCompleted: true);

      expect(updated.isPremiumPaid, isTrue);
      expect(updated.isProfileCompleted, isTrue);
    });

    test('SeaExperience.copyWith replaces only what is passed', () {
      final updated = kOceanPioneerExperience.copyWith(rank: 'Chief Engineer');

      expect(updated.rank, 'Chief Engineer');
      expect(updated.vesselName, kOceanPioneerExperience.vesselName);
      expect(updated.companyName, kOceanPioneerExperience.companyName);
      expect(updated.vesselType, kOceanPioneerExperience.vesselType);
      expect(updated.grt, kOceanPioneerExperience.grt);
      expect(updated.bhp, kOceanPioneerExperience.bhp);
      expect(updated.from, kOceanPioneerExperience.from);
      expect(updated.to, kOceanPioneerExperience.to);
      expect(updated.period, kOceanPioneerExperience.period);
    });

    test('Course.copyWith replaces only what is passed', () {
      final updated = kMedicalCourse.copyWith(number: 'MED-00001');

      expect(updated.number, 'MED-00001');
      expect(updated.title, kMedicalCourse.title);
      expect(updated.issueDate, kMedicalCourse.issueDate);
      expect(updated.validity, kMedicalCourse.validity);
      // `place` must keep the original place of issue.
      expect(updated.place, kMedicalCourse.place);
    });

    test('Course.copyWith can replace the place of issue', () {
      final updated = kMedicalCourse.copyWith(issuePlace: 'Kochi');

      expect(updated.place, 'Kochi');
      expect(updated.issueDate, kMedicalCourse.issueDate);
    });
  });
}

extension on PersonalDetails {
  PersonalDetails copyWithFirstname(String value) => PersonalDetails(
        postAppliedFor: postAppliedFor,
        firstname: value,
        lastname: lastname,
        fatherName: fatherName,
        dob: dob,
        nationality: nationality,
        profilePic: profilePic,
      );
}
