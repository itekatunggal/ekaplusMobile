import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> checkPhoneExists(String phone);
  Future<bool> checkPassword(String password);
  Future<User> changePassword(String oldPassword, String newPassword);
  Future<String> generateOtp(String phone, String method);
  Future<String> registerOtp(String phone);
  Future<bool> verifyOtp(String phone, String otp, String method);
  Future<void> saveLoginUser(UserModel user);
  Future<User> changeEmail(String newEmail, String otp);
  Future<User> changePhone(String newPhone, String otp);

  Future<UserModel> login(String identifier, String password);
  Future<UserModel> loginWithGoogle(String idToken);

  Future<void> saveToken(String token);
  Future<String?> getToken();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();

  Future<UserModel?> getUserByPhone(String phone);
  Future<UserModel?> getUserByUsername(String username);
  Future<UserModel?> getUserByEmail(String email);

  Future<void> updateUser(int userId, Map<String, dynamic> changes);

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthRemoteDataSource {
  static const _assetPath = 'assets/data/users.json';
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'current_user';

  final FlutterSecureStorage secureStorage;
  final Box box;

  AuthLocalDataSourceImpl(this.secureStorage, this.box);

  Future<List<Map<String, dynamic>>> _loadUsersFromAssets() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      final list = decoded is Map ? decoded['users'] ?? [] : decoded;
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }

  String normalizePhone(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    return cleaned;
  }

  @override
  Future<bool> checkPhoneExists(String phone) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/user/exist/$phone'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode != 200) {
      throw 'Gagal memeriksa nomor telepon';
    }

    final body = jsonDecode(response.body);

    return body["data"];
  }

  @override
  Future<String> registerOtp(String phone) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/register'),
      headers: ApiConfig.headers,
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode != 200) {
      throw 'Mengirim OTP gagal';
    }

    final body = jsonDecode(response.body);

    return body["message"];
  }

  @override
  Future<String> generateOtp(String account, String method) async {
    final response = await authedRequest((token) {
      return http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/otp'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({'account': account, 'method': method}),
      );
    });

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw body['message'] ?? 'Mengirim OTP gagal';
    }

    final body = jsonDecode(response.body);
    return body['message'];
  }

  @override
  Future<bool> verifyOtp(String account, String otp, String method) async {
    try {
      if (otp.length != 6) return false;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/otp/verify'),
        headers: ApiConfig.headers,
        body: jsonEncode({'account': account, "code": otp, "method": method}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw body["message"] ?? 'Verifikasi OTP gagal';
      }

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<UserModel> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({'user': identifier, 'password': password}),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw '${errorBody["message"] ?? response.body}';
      }

      final body = jsonDecode(response.body);

      if (body['status'] != 'success' || body['data'] == null) {
        throw body['message'] ?? 'Login failed';
      }

      final data = body['data'];
      final token = data['access_token'];
      final refreshToken = data['refresh_token'];

      final userJson = data['user'];

      if (token == null || userJson == null) {
        throw 'Invalid login response';
      }

      final user = UserModel.fromApiJson(userJson);

      await saveToken(token);
      await saveLoginUser(user);
      await saveRefreshToken(refreshToken);

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<UserModel> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/google/mobile'),
        headers: ApiConfig.headers,
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Login Google gagal (${response.statusCode})');
      }

      final body = jsonDecode(response.body);

      if (body == null || body['data'] == null) {
        throw Exception('Response tidak valid');
      }

      final data = body['data'];
      final token = data['access_token'];
      final refreshToken = data['refresh_token'];
      final userJson = data['user'];

      if (token == null || userJson == null) {
        throw Exception('Invalid login response');
      }

      final user = UserModel.fromApiJson(userJson);

      await saveToken(token);
      await saveRefreshToken(refreshToken);

      await saveLoginUser(user);

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<bool> _refreshTokenInternal() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/auth/refresh-token'),
      headers: ApiConfig.headers,
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) return false;

    final body = jsonDecode(response.body);
    final data = body['data'];

    await saveToken(data['access_token']);
    await saveRefreshToken(data['refresh_token']); // ROTATE

    return true;
  }

  Future<http.Response> authedRequest(
    Future<http.Response> Function(String token) request,
  ) async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    var response = await request(token);

    if (response.statusCode != 401) {
      return response;
    }

    // 🔁 coba refresh
    final refreshed = await _refreshTokenInternal();
    if (!refreshed) {
      await clearSession();
      throw Exception('Session expired');
    }

    final newToken = await getToken();
    return request(newToken!);
  }

  @override
  Future<String?> getToken() async {
    return secureStorage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: 'refresh_token');
  }

  @override
  Future<void> saveLoginUser(UserModel user) async {
    await SessionManager.saveUser(user.toJson());
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/register/complete'),
        headers: ApiConfig.headers,
        body: jsonEncode(user.toJson()),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode != 200 || body['status'] != "success") {
        throw Exception(body['message'] ?? 'Failed to save user data');
      }
    } catch (e) {
      throw Exception(
        e is Exception ? e.toString() : 'Failed to save user data',
      );
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final json = box.get(_userKey);
    if (json == null) return null;
    return UserModel.fromApiJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    final cached = await getCachedUser();
    if (cached != null && cached.phone == phone) {
      return cached;
    }

    final users = await _loadUsersFromAssets();
    final data = users.where((u) => u['phone'] == phone);
    if (data.isEmpty) return null;
    return UserModel.fromApiJson(data.first);
  }

  @override
  Future<UserModel?> getUserByUsername(String username) async {
    final cached = await getCachedUser();
    if (cached != null && cached.username == username) {
      return cached;
    }

    final users = await _loadUsersFromAssets();
    final data = users.where((u) => u['username'] == username);
    if (data.isEmpty) return null;
    return UserModel.fromApiJson(data.first);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final cached = await getCachedUser();
    if (cached != null && cached.email == email) {
      return cached;
    }

    final users = await _loadUsersFromAssets();
    final data = users.where((u) => u['email'] == email);
    if (data.isEmpty) return null;
    return UserModel.fromApiJson(data.first);
  }

  @override
  Future<void> updateUser(int userId, Map<String, dynamic> changes) async {
    final response = await authedRequest((token) {
      return http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/me'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(changes),
      );
    });

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Gagal memperbarui data user');
    }
  }

  @override
  Future<void> clearSession() async {
    await secureStorage.delete(key: _tokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await box.delete(_userKey);
  }

  @override
  Future<bool> checkPassword(String password) async {
    final response = await authedRequest((token) {
      return http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/me/check-password'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({'password': password}),
      );
    });

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal cek password');
    }

    return body['data'] ?? false;
  }

  @override
  Future<User> changePassword(String oldPassword, String newPassword) async {
    final response = await authedRequest((token) {
      return http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/me/change-password'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );
    });

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Gagal memperbarui password');
    }

    final updatedUser = UserModel.fromApiJson(body['data']);
    await saveLoginUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<User> changeEmail(String newEmail, String otp) async {
    final response = await authedRequest((token) {
      return http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/me/change-email'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({'new_email': newEmail, 'otp': otp}),
      );
    });

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Gagal memperbarui email');
    }

    final updatedUser = UserModel.fromApiJson(body['data']);
    await saveLoginUser(updatedUser);

    return updatedUser;
  }

  @override
  Future<User> changePhone(String newPhone, String otp) async {
    final response = await authedRequest((token) {
      return http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/me/change-phone'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({'new_phone': newPhone, 'otp': otp}),
      );
    });

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Gagal memperbarui nomor telepon');
    }

    final updatedUser = UserModel.fromApiJson(body['data']);
    await saveLoginUser(updatedUser);

    return updatedUser;
  }
}
