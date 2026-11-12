import 'package:dio/dio.dart';
import '../../domain/models/sensor_reading.dart';
import '../../domain/models/actuator_command.dart';
import '../../domain/models/iot_node.dart';
import '../../domain/models/actuator_state.dart';
import '../../domain/repositories/iot_repository.dart';
import '../models/sensor_reading_dto.dart';
import '../models/actuator_command_dto.dart';
import '../models/iot_node_dto.dart';
import '../models/actuator_state_dto.dart';
import '../../../../core/constants/api_constants.dart';

class IotRepositoryImpl implements IotRepository {
  final Dio _dio;

  IotRepositoryImpl(this._dio);

  // ---------------------------------------------------------------------------
  // Telemetría
  // ---------------------------------------------------------------------------
  @override
  Future<SensorReading> getLatestReading(int plantId) async {
    try {
      final response = await _dio
          .get("${ApiConstants.baseUrl}/iot/plants/$plantId/readings/latest");
      return SensorReadingDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al obtener telemetria");
    }
  }

  // ---------------------------------------------------------------------------
  // Gestión de nodos
  // ---------------------------------------------------------------------------
  @override
  Future<IotNode?> getNodeForPlant(int profileId, int plantId) async {
    try {
      final response =
          await _dio.get("${ApiConstants.iotNodes}/by-profile/$profileId");
      final nodes = (response.data as List)
          .map((json) => IotNodeDto.fromJson(json))
          .toList();
      for (final node in nodes) {
        if (node.plantId == plantId) return node;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; // el perfil no tiene nodos
      throw Exception("Error al consultar el dispositivo");
    }
  }

  @override
  Future<IotNode> linkNode(String nodeCode, int plantId, int profileId) async {
    try {
      // 1) Intentar vincular un nodo ya registrado.
      final response = await _dio.patch(
        "${ApiConstants.iotNodes}/$nodeCode/link-plant",
        data: {'plantId': plantId},
      );
      return IotNodeDto.fromJson(response.data);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404) {
        // 2) El nodo no existe todavía -> crearlo (lo crea y lo vincula).
        try {
          final response = await _dio.post(ApiConstants.iotNodes, data: {
            'nodeCode': nodeCode,
            'plantId': plantId,
            'profileId': profileId,
          });
          return IotNodeDto.fromJson(response.data);
        } catch (_) {
          throw Exception("No se pudo registrar el dispositivo '$nodeCode'.");
        }
      }
      if (code == 409) {
        throw Exception("Ese dispositivo ya está vinculado a otra planta.");
      }
      throw Exception("No se pudo vincular el dispositivo.");
    }
  }

  @override
  Future<void> unlinkNode(String nodeCode) async {
    try {
      await _dio.post("${ApiConstants.iotNodes}/$nodeCode/unlink");
    } catch (e) {
      throw Exception("No se pudo desvincular el dispositivo.");
    }
  }

  // ---------------------------------------------------------------------------
  // Actuadores
  // ---------------------------------------------------------------------------
  @override
  Future<ActuatorState> getActuatorState(String nodeCode) async {
    try {
      final response =
          await _dio.get("${ApiConstants.iotNodes}/$nodeCode/sync/status");
      return ActuatorStateDto.fromSyncStatus(response.data);
    } catch (e) {
      throw Exception("Error al obtener el estado de los actuadores");
    }
  }

  @override
  Future<void> setActuatorState(String nodeCode, ActuatorState state) async {
    try {
      await _dio.put(
        "${ApiConstants.iotNodes}/$nodeCode/actuators/desired",
        data: {
          'buzzerMode': state.buzzerMode,
          'servoMode': state.servoMode,
          'ledMode': state.ledMode,
        },
      );
    } catch (e) {
      throw Exception("No se pudo cambiar el actuador");
    }
  }

  // ---------------------------------------------------------------------------
  // Heredados (compatibilidad)
  // ---------------------------------------------------------------------------
  @override
  Future<IotNode> createNode(String nodeCode, int plantId, int profileId) async {
    try {
      final response = await _dio.post(ApiConstants.iotNodes, data: {
        'nodeCode': nodeCode,
        'plantId': plantId,
        'profileId': profileId,
      });
      return IotNodeDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al registrar nodo IoT");
    }
  }

  @override
  Future<List<ActuatorCommand>> getPendingCommands(String nodeCode) async {
    try {
      final response = await _dio
          .get("${ApiConstants.iotEdge}/nodes/$nodeCode/actuator-commands/pending");
      return (response.data as List)
          .map((json) => ActuatorCommandDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception("Error al obtener comandos pendientes");
    }
  }

  @override
  Future<void> completeCommand(String nodeCode, int commandId) async {
    try {
      await _dio.put(
          "${ApiConstants.iotEdge}/nodes/$nodeCode/actuator-commands/$commandId/complete");
    } catch (e) {
      throw Exception("Error al completar comando");
    }
  }
}
