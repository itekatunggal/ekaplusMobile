// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../../core/config/api_config.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> checkPhoneExists(String phone);
  Future<User> getUserInfo();
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

  // ⭐ NEW: Update profile picture
  Future<User> updateProfilePicture(String profilePicPath);

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

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

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

  User _parseUpdateResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['status'] != 'success') {
      throw ServerException(
        message: body['message'] ?? 'Gagal memperbarui data',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final updatedUser = UserModel.fromApiJson(body['data']);
    saveLoginUser(updatedUser);
    return updatedUser;
  }

  bool _isLocalFilePath(String path) {
    if (path.isEmpty) return false;

    // Cek apakah ada extension file image
    final hasImageExtension =
        path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.gif') ||
        path.toLowerCase().endsWith('.webp');

    if (!hasImageExtension) return false;

    // Cek apakah file exist di filesystem
    final file = File(path);
    return file.existsSync();
  }

  Future<User> _uploadFileMultipart(
    Uri uri,
    String token,
    String filePath,
  ) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw const UnknownException(message: 'File tidak ditemukan');
    }

    final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
    final mimeTypeParts = mimeType.split('/');

    Future<http.Response> sendMultipart(String currentToken) async {
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $currentToken';
      request.headers['Accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_pic',
          filePath,
          contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
        ),
      );

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    }

    final response = await HttpRequestHandler.send(
      () => sendMultipart(token),
      retryOnUnauthorized: () async {
        final refreshed = await _refreshTokenInternal();
        if (!refreshed) {
          await clearSession();
          throw const UnauthorizedException();
        }
        final newToken = await getToken();
        if (newToken == null || newToken.isEmpty) {
          throw const UnauthorizedException();
        }
        return sendMultipart(newToken);
      },
      defaultServerMessage: 'Gagal memperbarui foto profil',
      successCodes: const {200},
    );

    return _parseUpdateResponse(response);
  }

  Future<User> _updateProfilePicJson(
    Uri uri,
    String token,
    String profilePic,
  ) async {
    final response = await HttpRequestHandler.send(
      () => http.put(
        uri,
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({'profile_pic': profilePic}),
      ),
      retryOnUnauthorized: () async {
        final refreshed = await _refreshTokenInternal();
        if (!refreshed) {
          await clearSession();
          throw const UnauthorizedException();
        }
        final newToken = await getToken();
        if (newToken == null || newToken.isEmpty) {
          throw const UnauthorizedException();
        }
        return http.put(
          uri,
          headers: {...ApiConfig.headers, 'Authorization': 'Bearer $newToken'},
          body: jsonEncode({'profile_pic': profilePic}),
        );
      },
      defaultServerMessage: 'Gagal memperbarui foto profil',
    );

    return _parseUpdateResponse(response);
  }

  Future<bool> _refreshTokenInternal() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await HttpRequestHandler.send(
        () => http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/user/auth/refresh-token'),
          headers: ApiConfig.headers,
          body: jsonEncode({'refresh_token': refreshToken}),
        ),
        defaultServerMessage: 'Gagal memperbarui sesi login',
      );

      final body = jsonDecode(response.body);
      final data = body['data'];

      await saveToken(data['access_token']);
      await saveRefreshToken(data['refresh_token']);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> authedRequest(
    Future<http.Response> Function(String token) request,
  ) async {
    final token = await getToken();

    if (token == null) {
      throw const UnauthorizedException(message: 'Not authenticated');
    }

    return HttpRequestHandler.send(
      () => request(token),
      retryOnUnauthorized: () async {
        final refreshed = await _refreshTokenInternal();
        if (!refreshed) {
          await clearSession();
          throw const UnauthorizedException(message: 'Session expired');
        }

        final newToken = await getToken();
        if (newToken == null || newToken.isEmpty) {
          throw const UnauthorizedException(message: 'Session expired');
        }
        return request(newToken);
      },
      defaultServerMessage: 'Permintaan autentikasi gagal',
    );
  }

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  @override
  Future<bool> checkPhoneExists(String phone) async {
    final response = await HttpRequestHandler.send(
      () => http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/exist/$phone'),
        headers: ApiConfig.headers,
      ),
      defaultServerMessage: 'Gagal memeriksa nomor telepon',
    );

    final body = jsonDecode(response.body);

    return body["data"];
  }

  @override
  Future<String> registerOtp(String phone) async {
    final response = await HttpRequestHandler.send(
      () => http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/register'),
        headers: ApiConfig.headers,
        body: jsonEncode({'phone': phone}),
      ),
      defaultServerMessage: 'Mengirim OTP gagal',
    );

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

    final body = jsonDecode(response.body);
    return body['message'];
  }

  @override
  Future<bool> verifyOtp(String account, String otp, String method) async {
    if (otp.length != 6) return false;
    await HttpRequestHandler.send(
      () => http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/otp/verify'),
        headers: ApiConfig.headers,
        body: jsonEncode({'account': account, "code": otp, "method": method}),
      ),
      defaultServerMessage: 'Verifikasi OTP gagal',
    );

    return true;
  }

  @override
  Future<UserModel> login(String identifier, String password) async {
    final response = await HttpRequestHandler.send(
      () => http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({'user': identifier, 'password': password}),
      ),
      defaultServerMessage: 'Login gagal',
    );

    final body = jsonDecode(response.body);

    if (body['status'] != 'success' || body['data'] == null) {
      throw ServerException(message: body['message'] ?? 'Login gagal');
    }

    final data = body['data'];
    final token = data['access_token'];
    final refreshToken = data['refresh_token'];

    final userJson = data['user'];

    if (token == null || userJson == null) {
      throw const UnknownException(message: 'Invalid login response');
    }

    final user = UserModel.fromApiJson(userJson);

    await saveToken(token);
    await saveLoginUser(user);
    await saveRefreshToken(refreshToken);

    return user;
  }

  @override
  Future<UserModel> loginWithGoogle(String idToken) async {
    final response = await HttpRequestHandler.send(
      () => http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/google/mobile'),
        headers: ApiConfig.headers,
        body: jsonEncode({'id_token': idToken}),
      ),
      defaultServerMessage: 'Login Google gagal',
    );

    final body = jsonDecode(response.body);

    if (body['data'] == null) {
      throw const UnknownException(message: 'Response tidak valid');
    }

    final data = body['data'];
    final token = data['access_token'];
    final refreshToken = data['refresh_token'];
    final userJson = data['user'];

    if (token == null || userJson == null) {
      throw const UnknownException(message: 'Invalid login response');
    }

    final user = UserModel.fromApiJson(userJson);

    await saveToken(token);
    await saveRefreshToken(refreshToken);
    await saveLoginUser(user);

    return user;
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _refreshTokenKey, value: token);
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
    final response = await HttpRequestHandler.send(
      () => http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/register/complete'),
        headers: ApiConfig.headers,
        body: jsonEncode(user.toJson()),
      ),
      defaultServerMessage: 'Failed to save user data',
    );

    final body = jsonDecode(response.body);

    if (body['status'] != "success") {
      throw ServerException(
        message: body['message'] ?? 'Failed to save user data',
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
  Future<User> getUserInfo() async {
    final response = await authedRequest((token) {
      return http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/me'),
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );
    });

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Gagal memperbarui data user');
    }

    final updatedUser = UserModel.fromApiJson(body['data']);

    await saveLoginUser(updatedUser);
    return updatedUser;
  }

  // ⭐ NEW: Update Profile Picture
  @override
  Future<User> updateProfilePicture(String profilePicPath) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/user/me');

      // Cek: Apakah ini path file lokal atau UUID string?
      final isFilePath = _isLocalFilePath(profilePicPath);

      if (isFilePath) {
        // CASE 1: Upload file baru (multipart)
        return await _uploadFileMultipart(uri, token, profilePicPath);
      } else {
        // CASE 2: Update/delete UUID string (JSON)
        return await _updateProfilePicJson(uri, token, profilePicPath);
      }
    } catch (e) {
      throw Exception('Gagal memperbarui foto: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSession() async {
    await SessionManager.clearSession();
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
