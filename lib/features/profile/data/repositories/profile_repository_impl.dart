import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_dto.dart';
import '../../../../core/constants/api_constants.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio _dio;

  ProfileRepositoryImpl(this._dio);

  @override
  Future<Profile> getProfileByUserId(int userId) async {
    debugPrint("Cargando perfil para userId: $userId");

    if (userId == 0) {
      throw Exception("ID de usuario no valido");
    }

    try {
      final response = await _dio.get(
        "${ApiConstants.profiles}/by-user-id",
        queryParameters: {'userId': userId},
      );
      return ProfileDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Perfil no encontrado");
      }
      throw Exception("Error al cargar perfil");
    }
  }

  @override
  Future<Profile> updateProfile(int profileId, Profile profile) async {
    try {
      final response = await _dio.put(
        "${ApiConstants.profiles}/$profileId",
        data: ProfileDto.toUpdateJson(profile),
      );
      return ProfileDto.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al actualizar el perfil");
    }
  }
}
