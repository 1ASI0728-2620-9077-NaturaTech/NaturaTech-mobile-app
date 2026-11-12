import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Profile> execute(int profileId, Profile profile) {
    return repository.updateProfile(profileId, profile);
  }
}
