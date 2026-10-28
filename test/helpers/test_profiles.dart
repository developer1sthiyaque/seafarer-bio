import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';

/// Pure-Dart mirrors of the JSON fixtures in `test/fixtures/`.
///
/// Widget and integration tests use these builders (no `dart:io`, so they also
/// run on a device); `test/unit/models/profile_entity_test.dart` asserts that
/// they stay in sync with the JSON files.

/// A 2x2 PNG, base64 encoded — same bytes as `profile_full.json`.
const String kTestPhotoBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGOQSzkBRAwQCgAhfgUpmyH9hgAAAABJRU5ErkJggg==';

const PersonalDetails kFullPersonalDetails = PersonalDetails(
  postAppliedFor: 'Fourth Engineer',
  firstname: 'Isthiyaque',
  lastname: 'Kambathagothi',
  fatherName: 'Abdul Rauf Kambathagothi',
  dob: '17/7/1987',
  nationality: 'Indian',
  profilePic: kTestPhotoBase64,
);

const Document kPassportDocument = Document(
  name: 'Passport',
  number: 'P1234567',
  issueDate: '12/3/2018',
  place: 'Bangalore',
  validity: '11/3/2028',
);

const Course kMedicalCourse = Course(
  title: 'Medical',
  number: 'MED-99871',
  issueDate: '5/1/2020',
  place: 'Mumbai',
  validity: '4/1/2025',
);

const SeaExperience kOceanPioneerExperience = SeaExperience(
  vesselName: 'MV Ocean Pioneer',
  companyName: 'Blue Horizon Shipping',
  vesselType: 'Bulk Carrier',
  grt: '48500',
  bhp: '12000',
  rank: 'Third Engineer',
  from: '1.4.2021',
  to: '1.12.2021',
  period: '8',
);

/// Matches `fixtures/profile_full.json`: photo present, one Passport, one
/// Medical course, no sea-experience rows.
Profile fullProfile({bool isPremiumPaid = false}) => Profile(
      userId: 'user_full_001',
      personalDetails: kFullPersonalDetails,
      documents: const [kPassportDocument],
      courses: const [kMedicalCourse],
      seaExperiences: const [],
      isProfileCompleted: true,
      isPremiumPaid: isPremiumPaid,
    );

/// Matches `fixtures/profile_no_photo.json`.
Profile noPhotoProfile() => Profile(
      userId: 'user_no_photo_002',
      personalDetails: const PersonalDetails(
        postAppliedFor: 'Fourth Engineer',
        firstname: 'Isthiyaque',
        lastname: 'Kambathagothi',
        fatherName: 'Abdul Rauf Kambathagothi',
        dob: '17/7/1987',
        nationality: 'Indian',
        profilePic: '',
      ),
      documents: const [kPassportDocument],
      courses: const [kMedicalCourse],
      seaExperiences: const [],
      isProfileCompleted: true,
    );

/// Matches `fixtures/profile_empty.json`: every optional section empty.
Profile emptyProfile() => Profile(
      userId: 'user_empty_003',
      personalDetails: const PersonalDetails(
        postAppliedFor: '',
        firstname: 'New',
        lastname: 'Seafarer',
        fatherName: '',
        dob: '',
        nationality: '',
        profilePic: '',
      ),
      isProfileCompleted: false,
    );

/// Matches `fixtures/profile_sea_experience.json`: fully populated tables.
Profile seaExperienceProfile() => Profile(
      userId: 'user_sea_004',
      personalDetails: const PersonalDetails(
        postAppliedFor: 'Second Engineer',
        firstname: 'Isthiyaque',
        lastname: 'Kambathagothi',
        fatherName: 'Abdul Rauf Kambathagothi',
        dob: '17/7/1987',
        nationality: 'Indian',
        profilePic: '',
      ),
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
      courses: const [
        kMedicalCourse,
        Course(
          title: 'STCW',
          number: 'STCW-4412',
          issueDate: '9/9/2019',
          place: 'Chennai',
          validity: '8/9/2024',
        ),
      ],
      seaExperiences: const [
        kOceanPioneerExperience,
        SeaExperience(
          vesselName: 'MT Coral Star',
          companyName: 'Anchor Marine Pvt Ltd',
          vesselType: 'Oil Tanker',
          grt: '62000',
          bhp: '15500',
          rank: 'Second Engineer',
          from: '15.2.2022',
          to: '15.11.2022',
          period: '9',
        ),
      ],
      isProfileCompleted: true,
      isPremiumPaid: true,
    );

/// A profile whose free-text fields are long enough to overflow a naive layout.
Profile longTextProfile() => Profile(
      userId: 'user_long_005',
      personalDetails: const PersonalDetails(
        postAppliedFor:
            'Senior Second Engineer Officer In Charge Of An Engineering Watch',
        firstname: 'Isthiyaque',
        lastname: 'Kambathagothi',
        fatherName: 'Abdul Rauf Kambathagothi',
        dob: '17/7/1987',
        nationality: 'Indian',
        profilePic: '',
      ),
      documents: const [kPassportDocument],
      courses: const [kMedicalCourse],
      seaExperiences: const [
        SeaExperience(
          vesselName:
              'MV Extraordinarily Long Vessel Name For Overflow Regression Testing Purposes',
          companyName:
              'International Consolidated Maritime Transport And Logistics Corporation Limited',
          vesselType: 'Very Large Crude Carrier (VLCC) Double Hull',
          grt: '318000',
          bhp: '38500',
          rank: 'Second Engineer',
          from: '1.1.2020',
          to: '1.1.2021',
          period: '12',
        ),
      ],
      isProfileCompleted: true,
    );
