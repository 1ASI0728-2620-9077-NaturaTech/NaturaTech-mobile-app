import 'package:equatable/equatable.dart';

/// Última lectura cruda de los sensores del nodo (coincide con el backend:
/// humidityPercent, airTemperature, gasPercent, lightPercent).
/// Cualquier valor puede ser null si ese sensor no reportó dato.
class SensorReading extends Equatable {
  final int id;
  final int nodeId;
  final double? humidityPercent;
  final double? airTemperature;
  final double? gasPercent;
  final double? lightPercent;
  final DateTime timestamp;

  const SensorReading({
    required this.id,
    required this.nodeId,
    this.humidityPercent,
    this.airTemperature,
    this.gasPercent,
    this.lightPercent,
    required this.timestamp,
  });

  @override
  List<Object?> get props =>
      [id, nodeId, humidityPercent, airTemperature, gasPercent, lightPercent, timestamp];
}
