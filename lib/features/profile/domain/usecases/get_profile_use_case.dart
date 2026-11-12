import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Profile> execute(int userId) {
    return repository.getProfileByUserId(userId);
  }
}