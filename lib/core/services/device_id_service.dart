import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceIdService {
  static const _storageKey = 'installation_device_id';

  final FlutterSecureStorage _secureStorage;

  const DeviceIdService(this._secureStorage);

  Future<String> getDeviceId() async {
    final existing = await _secureStorage.read(key: _storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final generated = base64UrlEncode(bytes).replaceAll('=', '');
    await _secureStorage.write(key: _storageKey, value: generated);
    return generated;
  }
}
