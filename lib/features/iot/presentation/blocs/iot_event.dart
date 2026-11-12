import 'package:equatable/equatable.dart';

abstract class IotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchLatestTelemetry extends IotEvent {
  final int nodeId;
  FetchLatestTelemetry(this.nodeId);
}

class ToggleActuator extends IotEvent {
  final int nodeId;
  final String type; // UV_LIGHT o WATER_SPRAYER
  final String action; // ACTIVATE o DEACTIVATE
  
  ToggleActuator({required this.nodeId, required this.type, required this.action});
}