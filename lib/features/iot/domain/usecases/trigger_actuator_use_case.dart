import '../models/actuator_command.dart';
import '../repositories/iot_repository.dart';

class TriggerActuatorUseCase {
  final IotRepository repository;
  TriggerActuatorUseCase(this.repository);

  Future<List<ActuatorCommand>> getPendingCommands(String nodeCode) {
    return repository.getPendingCommands(nodeCode);
  }

  Future<void> completeCommand(String nodeCode, int commandId) {
    return repository.completeCommand(nodeCode, commandId);
  }
}
