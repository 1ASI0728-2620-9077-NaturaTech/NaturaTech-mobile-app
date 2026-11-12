import '../../domain/models/actuator_state.dart';

class ActuatorStateDto {
  /// Parsea la respuesta de GET /nodes/{nodeCode}/sync/status:
  /// { "linked": true, "desiredState": { "buzzerMode": "OFF", "servoMode": "AUTO", "ledMode": "AUTO" } }
  static ActuatorState fromSyncStatus(Map<String, dynamic> json) {
    final desired = (json['desiredState'] as Map<String, dynamic>?) ?? const {};
    return ActuatorState(
      linked: json['linked'] == true,
      buzzerMode: (desired['buzzerMode']?.toString() ?? 'OFF').toUpperCase(),
      servoMode: (desired['servoMode']?.toString() ?? 'AUTO').toUpperCase(),
      ledMode: (desired['ledMode']?.toString() ?? 'AUTO').toUpperCase(),
    );
  }
}
