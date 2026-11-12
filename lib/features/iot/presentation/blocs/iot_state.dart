import 'package:equatable/equatable.dart';
import '../../domain/models/sensor_reading.dart';

abstract class IotState extends Equatable {
  @override
  List<Object?> get props => [];
}

class IotInitial extends IotState {}
class IotLoading extends IotState {}
class IotLoaded extends IotState {
  final SensorReading reading;
  IotLoaded(this.reading);
  @override
  List<Object?> get props => [reading];
}
class IotActionSuccess extends IotState {
  final String message; // Ej: "Luz UV encendida"
  IotActionSuccess(this.message);
}
class IotError extends IotState {
  final String message;
  IotError(this.message);
}