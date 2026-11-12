import 'package:dio/dio.dart';
import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_dto.dart';
import '../../../../core/constants/api_constants.dart';

class TaskRepositoryImpl implements TaskRepository {
  final Dio _dio;
  TaskRepositoryImpl(this._dio);

  @override
  Future<List<Task>> getTasksByPlant(int plantId) async {
    try {
      final response =
          await _dio.get(ApiConstants.tasks, queryParameters: {'plantId': plantId});
      return (response.data as List).map((json) => TaskDto.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception("Error al obtener tareas");
    }
  }

  @override
  Future<List<Task>> getPendingTasks(int plantId) async {
    try {
      final response = await _dio
          .get("${ApiConstants.tasks}/pending", queryParameters: {'plantId': plantId});
      return (response.data as List).map((json) => TaskDto.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception("Error al obtener tareas pendientes");
    }
  }

  @override
  Future<List<Task>> getTaskHistory(int plantId) async {
    try {
      final response = await _dio
          .get("${ApiConstants.tasks}/history", queryParameters: {'plantId': plantId});
      return (response.data as List).map((json) => TaskDto.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception("Error al obtener historial de tareas");
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post(
        ApiConstants.tasks,
        data: TaskDto.toCreateJson(task),
      );
      return TaskDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al crear tarea");
    }
  }

  @override
  Future<Task> completeTask(int taskId, {int? humidity, String? notes}) async {
    try {
      final data = <String, dynamic>{};
      if (humidity != null) data['humidity'] = humidity;
      if (notes != null) data['notes'] = notes;

      final response = await _dio.patch(
        "${ApiConstants.tasks}/$taskId/complete",
        data: data,
      );
      return TaskDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al completar tarea");
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      await _dio.delete(
        "${ApiConstants.tasks}/$taskId",
        options: Options(responseType: ResponseType.plain),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return;
      throw Exception("Error al eliminar tarea");
    }
  }
}
