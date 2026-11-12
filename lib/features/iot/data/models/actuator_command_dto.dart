import '../../domain/models/actuator_command.dart';

class ActuatorCommandDto {
  static ActuatorCommand fromJson(Map<String, dynamic> json) {
    return ActuatorCommand(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt() ?? 0,
      nodeId: json['nodeId'] is int
          ? json['nodeId']
          : (json['nodeId'] as num?)?.toInt() ?? 0,
      actuatorType: json['actuatorType']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      issuedAt: json['issuedAt']?.toString(),
    );
  }
}
