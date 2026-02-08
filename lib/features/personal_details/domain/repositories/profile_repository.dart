import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Stream<Profile?> getProfile(String userId);

  Future<void> saveProfile(Profile profile);

  Future<void> updateProfile(Profile profile);

  Future<void> createProfile(Profile profile);
}
