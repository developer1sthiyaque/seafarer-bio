import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seafarer_bio_data/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  SignUpUseCase(this.authRepository,this.profileRepository);

  Future<User?> call(String firstname,String lastname,String email, String password) async{
    final user = await authRepository.signUpWithEmailAndPassword(
      firstname,
      lastname,
      email,
      password,
    );

    if (user == null) {
      throw Exception('User signup failed');
    }

    // 2️⃣ Create initial empty profile
    final profile = Profile(
      userId: user.uid,
      personalDetails: PersonalDetails(
        postAppliedFor: '',
        firstname: firstname, // 👈 we already have name
        lastname: lastname, // 👈 we already have name
        fatherName: '',
        dob: '',
        nationality: '',
        profilePic: '',
      ),
      documents: const [],
      courses: const [],
      seaExperiences: const [],
    );

    await profileRepository.createProfile(profile);

    return user;
  }
}
