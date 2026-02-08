import 'package:seafarer_bio_data/features/personal_details/data/datasources/personal_info_local_data_source.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';



class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Profile?> getProfile(String userId) {
    return remoteDataSource.getProfile(userId);
  }

  @override
  Future<void> saveProfile(Profile profile) {
    return remoteDataSource.saveProfile(profile);
  }

  @override
  Future<void> updateProfile(Profile profile) {
    return remoteDataSource.updateProfile(profile);
  }

  @override
  Future<void> createProfile(Profile profile) {
    return remoteDataSource.createProfile(profile);
  }
}
