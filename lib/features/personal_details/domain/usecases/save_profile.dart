import 'package:seafarer_bio_data/core/usecases/usecase.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';

import '../entities/profile_entity.dart';

class SaveProfileUseCase
    extends UseCase<void, Profile> {
  final ProfileRepository repository;

  SaveProfileUseCase(this.repository);

  @override
  Future<void> call(Profile profile) {
    return repository.saveProfile(profile);
  }
}
