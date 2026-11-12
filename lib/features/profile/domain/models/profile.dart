import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String fullName;
  final String subscriptionPlan;
  final String profilePictureBase64;
  final int userId;

  const Profile({
    required this.id,
    required this.fullName,
    required this.subscriptionPlan,
    this.profilePictureBase64 = '',
    required this.userId,
  });

  @override
  List<Object?> get props => [id, fullName, subscriptionPlan, userId];
}
