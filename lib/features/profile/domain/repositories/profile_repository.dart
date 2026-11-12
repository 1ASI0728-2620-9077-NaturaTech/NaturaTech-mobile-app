import '../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfileByUserId(int userId);
  Future<Profile> updateProfile(int profileId, Profile profile);
}
