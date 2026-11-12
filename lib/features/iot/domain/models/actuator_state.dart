import 'package:equatable/equatable.dart';

/// Estado deseado de los actuadores del nodo.
/// - servo (riego) y led (UV): "AUTO" | "ON" | "OFF"
/// - buzzer (alarma): "ON" | "OFF"
class ActuatorState extends Equatable {
  final bool linked;
  final String buzzerMode;
  final String servoMode;
  final String ledMode;

  const ActuatorState({
    this.linked = false,
    this.buzzerMode = 'OFF',
    this.servoMode = 'AUTO',
    this.ledMode = 'AUTO',
  });

  ActuatorState copyWith({String? buzzerMode, String? servoMode, String? ledMode}) {
    return ActuatorState(
      linked: linked,
      buzzerMode: buzzerMode ?? this.buzzerMode,
      servoMode: servoMode ?? this.servoMode,
      ledMode: ledMode ?? this.ledMode,
    );
  }

  @override
  List<Object?> get props => [linked, buzzerMode, servoMode, ledMode];
}
