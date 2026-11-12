import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/plant.dart';
import '../../domain/repositories/plant_repository.dart';
import '../models/plant_dto.dart';
import '../../../../core/constants/api_constants.dart';

class PlantRepositoryImpl implements PlantRepository {
  final Dio _dio;

  PlantRepositoryImpl(this._dio);

  @override
  Future<List<Plant>> getPlantsByProfile(int profileId) async {
    try {
      final response = await _dio.get("${ApiConstants.plants}/by-profile/$profileId");
      return (response.data as List).map((item) => PlantDto.fromJson(item)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception("Error al cargar las plantas");
    }
  }

  @override
  Future<Plant> getPlantById(int plantId) async {
    try {
      final response = await _dio.get("${ApiConstants.plants}/$plantId");
      return PlantDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al obtener la planta");
    }
  }

  @override
  Future<Plant> createPlant(Plant plant) async {
    try {
      final payload = PlantDto.toCreateJson(plant);
      debugPrint("Creando planta - payload: $payload");
      final response = await _dio.post(
        ApiConstants.plants,
        data: payload,
      );
      return PlantDto.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Error al crear planta - status: ${e.response?.statusCode}, body: ${e.response?.data}");
      throw Exception("Error al crear la planta: ${e.response?.data ?? e.message}");
    }
  }

  @override
  Future<Plant> updatePlant(Plant plant) async {
    try {
      final response = await _dio.put(
        "${ApiConstants.plants}/${plant.id}",
        data: PlantDto.toUpdateJson(plant),
      );
      return PlantDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al actualizar la planta");
    }
  }

  @override
  Future<void> deletePlant(int plantId) async {
    try {
      final response = await _dio.delete(
        "${ApiConstants.plants}/$plantId",
        options: Options(responseType: ResponseType.plain),
      );
      debugPrint("Delete plant response: ${response.statusCode}");
    } on DioException catch (e) {
      debugPrint("Delete plant error - status: ${e.response?.statusCode}, body: ${e.response?.data}");
      if (e.response?.statusCode == 500) {
        throw Exception("Elimina primero las tareas asociadas a esta planta");
      }
      if (e.response?.statusCode == 404) {
        return;
      }
      throw Exception("Error al eliminar la planta");
    }
  }
}
