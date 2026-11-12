import '../../domain/models/profile.dart';

class ProfileDto extends Profile {
  const ProfileDto({
    required super.id,
    required super.fullName,
    required super.subscriptionPlan,
    super.profilePictureBase64,
    required super.userId,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['personName']?.toString() ?? "Usuario Nuevo",
      subscriptionPlan: json['subscriptionPlan']?.toString() ?? "BASIC",
      profilePictureBase64: json['profilePictureBase64']?.toString() ?? '',
      userId: json['userId'] is int
          ? json['userId']
          : (json['userId'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> toUpdateJson(Profile profile) {
    return {
      'personName': profile.fullName,
      'subscriptionPlan': profile.subscriptionPlan,
      'profilePictureBase64': profile.profilePictureBase64,
    };
  }
}
