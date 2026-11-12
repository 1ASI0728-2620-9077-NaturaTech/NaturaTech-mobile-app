import 'package:equatable/equatable.dart';

class ActuatorCommand extends Equatable {
  final int id;
  final int nodeId;
  final String actuatorType;
  final String action;
  final String status;
  final String? issuedAt;

  const ActuatorCommand({
    required this.id,
    required this.nodeId,
    required this.actuatorType,
    required this.action,
    required this.status,
    this.issuedAt,
  });

  @override
  List<Object?> get props => [id, nodeId, actuatorType, action, status];
}
