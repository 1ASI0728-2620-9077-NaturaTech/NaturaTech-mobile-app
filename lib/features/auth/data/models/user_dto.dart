import '../../domain/models/user.dart';

class UserDto extends User {
  const UserDto({
    required super.id,
    required super.email,
    String? token,
  }) : super(token: token ?? "");

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt() ?? 0,
      email: json['email']?.toString() ?? "",
      token: json['token']?.toString() ?? "",
    );
  }
}
