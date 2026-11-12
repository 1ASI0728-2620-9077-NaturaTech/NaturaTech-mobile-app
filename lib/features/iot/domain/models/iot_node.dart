import 'package:equatable/equatable.dart';

class IotNode extends Equatable {
  final int id;
  final String nodeCode;
  final String status;
  final int plantId;
  final int profileId;
  final String createdAt;

  const IotNode({
    required this.id,
    required this.nodeCode,
    required this.status,
    required this.plantId,
    this.profileId = 0,
    this.createdAt = '',
  });

  @override
  List<Object?> get props => [id, nodeCode, status, plantId];
}
