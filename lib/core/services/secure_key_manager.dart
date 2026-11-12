import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyManager {
  static const _keyName = 'chatbot_api_key_v2';
  String? _cachedKey;

  static const _encodedKey =
      'si se quiere utilizar el chatbot, se debe colocar una clave codificada en base64 acá';

  FlutterSecureStorage get _storage {
    AndroidOptions androidOptions() =>
        const AndroidOptions(encryptedSharedPreferences: true);
    return FlutterSecureStorage(aOptions: androidOptions());
  }

  Future<String> getApiKey() async {
    if (_cachedKey != null) return _cachedKey!;

    try {
      final stored = await _storage.read(key: _keyName).timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );

      if (stored != null && stored.isNotEmpty) {
        _cachedKey = stored;
        return _cachedKey!;
      }
    } catch (e) {
      debugPrint('SecureStorage read failed: $e');
    }

    final decoded = utf8.decode(base64Decode(_encodedKey));
    _cachedKey = decoded;

    try {
      await _storage.write(key: _keyName, value: decoded).timeout(
            const Duration(seconds: 3),
            onTimeout: () {},
          );
    } catch (e) {
      debugPrint('SecureStorage write failed: $e');
    }

    return _cachedKey!;
  }
}
