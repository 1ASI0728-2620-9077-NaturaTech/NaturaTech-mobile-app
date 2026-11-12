import 'package:equatable/equatable.dart';
import '../../domain/models/profile.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final int userId;
  LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateProfileEvent extends ProfileEvent {
  final int profileId;
  final Profile profile;
  UpdateProfileEvent(this.profileId, this.profile);

  @override
  List<Object?> get props => [profileId, profile];
}
