import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/user.dart';
import '../models/user_dto.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.signIn,
        data: {'email': email, 'password': password},
      );
      final user = UserDto.fromJson(response.data);

      final tempDio = Dio();
      final userResponse = await tempDio.get(
        "${ApiConstants.users}/${user.id}",
        options: Options(headers: {'Authorization': 'Bearer ${user.token}'}),
      );
      final roles = userResponse.data['roles'] as List? ?? [];
      final hasAdminRole = roles.any((r) => r.toString().contains('ADMIN'));
      final hasUserRole = roles.any((r) => r.toString().contains('USER'));

      if (hasAdminRole && !hasUserRole) {
        throw Exception(
            "Las cuentas de administrador solo funcionan en la aplicacion web. "
            "Por favor, inicia sesion con una cuenta de usuario.");
      }

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 401) {
        throw Exception("Usuario o contraseña incorrectos");
      }
      if (e.response?.statusCode == 400) {
        throw Exception("Datos de inicio de sesión inválidos");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Tiempo de espera agotado. Intenta de nuevo");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("Sin conexión a internet");
      }
      throw Exception("Error al iniciar sesión. Intenta de nuevo");
    }
  }

  @override
  Future<void> signUp(String name, String email, String password, String subscriptionPlan) async {
    try {
      await _dio.post(
        ApiConstants.signUp,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'subscriptionPlan': subscriptionPlan,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception("Datos inválidos o el usuario ya existe");
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Tiempo de espera agotado. Intenta de nuevo");
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception("Sin conexión a internet");
      }
      throw Exception("Error en el registro. Intenta de nuevo");
    }
  }
}
