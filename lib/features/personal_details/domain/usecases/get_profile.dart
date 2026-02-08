import 'package:seafarer_bio_data/core/usecases/usecase.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/profile_entity.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/repositories/profile_repository.dart';

class GetProfileUseCase
    extends StreamUseCase<Profile?, String> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Stream<Profile?> call(String userId) {
    return repository.getProfile(userId);
  }
}
