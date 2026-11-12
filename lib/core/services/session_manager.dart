import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  String? _token;
  int? _userId;
  String? _email;

  FlutterSecureStorage get _storage {
    AndroidOptions androidOptions() =>
        const AndroidOptions(encryptedSharedPreferences: true);
    return FlutterSecureStorage(aOptions: androidOptions());
  }

  Future<void> saveSession({
    required String token,
    required int userId,
    required String email,
  }) async {
    _token = token;
    _userId = userId;
    _email = email;
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'userId', value: userId.toString());
    await _storage.write(key: 'email', value: email);
    debugPrint("Sesion guardada - userId: $userId");
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    try {
      _token = await _storage.read(key: 'token').timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
    } catch (e) {
      debugPrint('getToken error: $e');
    }
    return _token;
  }

  Future<int?> getUserId() async {
    if (_userId != null) return _userId;
    try {
      final stored = await _storage.read(key: 'userId').timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
      if (stored != null) _userId = int.tryParse(stored);
    } catch (e) {
      debugPrint('getUserId error: $e');
    }
    return _userId;
  }

  Future<String?> getEmail() async {
    if (_email != null) return _email;
    try {
      _email = await _storage.read(key: 'email').timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
    } catch (e) {
      debugPrint('getEmail error: $e');
    }
    return _email;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = null;
    try {
      await _storage.deleteAll().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('logout storage error: $e');
    }
    debugPrint("Sesion cerrada");
  }

  bool get isLoggedIn => _token != null;
}
