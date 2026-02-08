import 'package:seafarer_bio_data/core/usecases/usecase.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase extends UseCase<void, Profile> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<void> call(Profile profile) {
    return repository.updateProfile(profile);
  }
}
