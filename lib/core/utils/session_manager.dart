import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'current_user';
  static const _activeBcidKey = 'active_branch_customer_id';

  static final _secure = FlutterSecureStorage();

  static Future<bool>? _refreshingFuture;

  static Future<bool> isLoggedIn() async {
    final token = await _secure.read(key: _tokenKey);
    final box = Hive.box('auth_user_box');
    return token != null && box.get(_userKey) != null;
  }

  static Future<String?> getToken() {
    return _secure.read(key: _tokenKey);
  }

  static Future<String?> getRefreshToken() {
    return _secure.read(key: _refreshTokenKey);
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final box = Hive.box('auth_user_box');
    final data = box.get(_userKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static Future<void> saveToken(String token) {
    return _secure.write(key: _tokenKey, value: token);
  }

  static Future<void> saveRefreshToken(String token) {
    return _secure.write(key: _refreshTokenKey, value: token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final box = Hive.box('auth_user_box');
    await box.put(_userKey, user);
  }

  static Future<void> clearSession() async {
    await _secure.delete(key: _tokenKey);
    await _secure.delete(key: _refreshTokenKey);
    final box = Hive.box('auth_user_box');
    await box.delete(_userKey);
    await box.delete(_activeBcidKey);
  }

  static Future<void> saveActiveBranchCustomerId(int bcid) async {
    final box = Hive.box('auth_user_box');
    await box.put(_activeBcidKey, bcid);
  }

  static Future<int?> getActiveBranchCustomerId() async {
    final box = Hive.box('auth_user_box');
    final raw = box.get(_activeBcidKey);
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString());
  }

  static Future<void> clearActiveBranchCustomerId() async {
    final box = Hive.box('auth_user_box');
    await box.delete(_activeBcidKey);
  }

  static Future<bool> refreshToken() {
    if (_refreshingFuture != null) {
      return _refreshingFuture!;
    }

    _refreshingFuture = _doRefreshToken();
    return _refreshingFuture!;
  }

  static Future<bool> _doRefreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await clearSession();
        return false;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/user/auth/refresh-token');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode != 200) {
        await clearSession();
        return false;
      }

      final decoded = jsonDecode(response.body);
      final data = decoded['data'];

      final newAccessToken = data?['access_token'];
      final newRefreshToken = data?['refresh_token'];

      if (newAccessToken == null) {
        await clearSession();
        return false;
      }

      await saveToken(newAccessToken);

      if (newRefreshToken != null) {
        await saveRefreshToken(newRefreshToken);
      }

      return true;
    } catch (_) {
      await clearSession();
      return false;
    } finally {
      _refreshingFuture = null;
    }
  }
}
