import '../models/sensor_reading.dart';
import '../models/actuator_command.dart';
import '../models/iot_node.dart';
import '../models/actuator_state.dart';

abstract class IotRepository {
  // --- Telemetría ---
  /// Última lectura de los sensores de la planta (lanza excepción si no hay datos).
  Future<SensorReading> getLatestReading(int plantId);

  // --- Gestión de nodos ---
  /// Devuelve el nodo vinculado a la planta (o null si no hay ninguno).
  Future<IotNode?> getNodeForPlant(int profileId, int plantId);

  /// Vincula un nodo (por nodeCode) a la planta. Si el nodo no existe, lo crea.
  Future<IotNode> linkNode(String nodeCode, int plantId, int profileId);

  /// Desvincula el nodo de su planta.
  Future<void> unlinkNode(String nodeCode);

  // --- Actuadores ---
  /// Lee los modos deseados de los actuadores del nodo.
  Future<ActuatorState> getActuatorState(String nodeCode);

  /// Fija los modos deseados de los actuadores del nodo.
  Future<void> setActuatorState(String nodeCode, ActuatorState state);

  // --- Métodos heredados (se conservan por compatibilidad; el dispositivo/edge
  //     los usa, no la app directamente) ---
  Future<IotNode> createNode(String nodeCode, int plantId, int profileId);
  Future<List<ActuatorCommand>> getPendingCommands(String nodeCode);
  Future<void> completeCommand(String nodeCode, int commandId);
}
