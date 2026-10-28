import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seafarer_bio_data/features/auth/domain/usecases/sign_up.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';

import '../../helpers/mocks.dart';

/// Test plan §1.2 — Auth Service: sign-up also seeds the user's blank bio data,
/// which is what Home reads on first launch.
void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late MockUser user;
  late SignUpUseCase useCase;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    user = MockUser();
    useCase = SignUpUseCase(authRepository, profileRepository);

    when(() => user.uid).thenReturn('uid-new');
    when(() => profileRepository.createProfile(any()))
        .thenAnswer((_) async {});
  });

  test('creates an empty profile keyed to the new user id', () async {
    when(() => authRepository.signUpWithEmailAndPassword(
          any(),
          any(),
          any(),
          any(),
        )).thenAnswer((_) async => user);

    final result = await useCase(
      'Isthiyaque',
      'Kambathagothi',
      'new@example.com',
      'password123',
    );

    expect(result, user);

    final created = verify(
      () => profileRepository.createProfile(captureAny()),
    ).captured.single as Profile;

    expect(created.userId, 'uid-new');
    expect(created.personalDetails.firstname, 'Isthiyaque');
    expect(created.personalDetails.lastname, 'Kambathagothi');
    expect(created.personalDetails.postAppliedFor, isEmpty);
    expect(created.personalDetails.dob, isEmpty);
    expect(created.personalDetails.nationality, isEmpty);
    expect(created.personalDetails.profilePic, isEmpty);
    expect(created.documents, isEmpty);
    expect(created.courses, isEmpty);
    expect(created.seaExperiences, isEmpty);
    expect(created.isProfileCompleted, isFalse);
  });

  test('throws and creates no profile when Firebase returns no user', () async {
    when(() => authRepository.signUpWithEmailAndPassword(
          any(),
          any(),
          any(),
          any(),
        )).thenAnswer((_) async => null);

    expect(
      () => useCase('A', 'B', 'a@b.co', 'password123'),
      throwsA(isA<Exception>()),
    );

    verifyNever(() => profileRepository.createProfile(any()));
  });

  test('propagates an auth conflict without creating a profile', () async {
    when(() => authRepository.signUpWithEmailAndPassword(
          any(),
          any(),
          any(),
          any(),
        )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

    expect(
      () => useCase('A', 'B', 'taken@example.com', 'password123'),
      throwsA(isA<FirebaseAuthException>()),
    );

    verifyNever(() => profileRepository.createProfile(any()));
  });
}
