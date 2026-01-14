// lib/core/services/storage_service.dart
// ignore_for_file: empty_catches

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // File names
  static const String _usersFileName = 'users_data.json';
  static const String _otpFileName = 'otp_sessions.json';

  // ============================================
  // 1. Get Local File Path
  // ============================================
  Future<File> _getLocalFile(String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('File operations not supported on web');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // Create file with empty array if not exists
    if (!await file.exists()) {
      if (fileName == _usersFileName) {
        await file.writeAsString(
          jsonEncode({
            'users': [],
            'last_updated': DateTime.now().toIso8601String(),
          }),
        );
      } else if (fileName == _otpFileName) {
        await file.writeAsString(
          jsonEncode({
            'otp_sessions': [],
            'last_updated': DateTime.now().toIso8601String(),
          }),
        );
      }
    }

    return file;
  }

  // ============================================
  // 2. Load Users (with auto-sync from assets if empty)
  // ============================================
  Future<List<Map<String, dynamic>>> loadUsers() async {
    try {
      final file = await _getLocalFile(_usersFileName);
      final contents = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(contents);

      final List<dynamic> usersList = jsonData['users'] ?? [];

      // 🔥 AUTO SYNC FROM ASSETS if local storage is empty
      if (usersList.isEmpty) {
        await syncUsersFromAssets();

        final newContents = await file.readAsString();
        final newJsonData = jsonDecode(newContents);
        final newUsersList = newJsonData['users'] ?? [];

        return newUsersList.cast<Map<String, dynamic>>();
      }

      return usersList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // 3. Save User (Register) + Auto Copy to Assets
  // ============================================
  Future<void> saveUser(Map<String, dynamic> newUser) async {
    try {
      // Load existing users
      final users = await loadUsers();

      // Check if user already exists (by phone)
      final existingIndex = users.indexWhere(
        (user) => user['phone'] == newUser['phone'],
      );

      if (existingIndex != -1) {
        users[existingIndex] = newUser;
      } else {
        users.add(newUser);
      }

      await _saveUsersToFile(users);
      await _autoSaveToAssets(users);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // Helper: Save users to local file
  // ============================================
  Future<void> _saveUsersToFile(List<Map<String, dynamic>> users) async {
    final file = await _getLocalFile(_usersFileName);
    final jsonData = {
      'users': users,
      'last_updated': DateTime.now().toIso8601String(),
      'total_users': users.length,
    };

    // Write with pretty print
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(jsonData);
    await file.writeAsString(prettyJson);
  }

  // ============================================
  // AUTO SAVE TO ASSETS (Development Mode)
  // Merge dengan existing data, tidak overwrite
  // ============================================
  Future<void> _autoSaveToAssets(List<Map<String, dynamic>> newUsers) async {
    if (kIsWeb) {
      return;
    }

    try {
      // Path ke assets/data/users.json (project root)
      final projectPath = Directory.current.path;
      final assetsFile = File('$projectPath/assets/data/users.json');

      // Buat folder jika belum ada
      final assetsDir = Directory('$projectPath/assets/data');
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      // Load existing data dari assets (jika ada)
      List<Map<String, dynamic>> existingUsers = [];
      if (await assetsFile.exists()) {
        try {
          final existingContent = await assetsFile.readAsString();
          final existingJson = jsonDecode(existingContent);
          if (existingJson is Map && existingJson.containsKey('users')) {
            final List<dynamic> usersList = existingJson['users'];
            existingUsers = usersList.cast<Map<String, dynamic>>();
          }
        } catch (e) {}
      }

      // Merge: Update existing or add new
      for (var newUser in newUsers) {
        final existingIndex = existingUsers.indexWhere(
          (u) => u['phone'] == newUser['phone'],
        );

        if (existingIndex != -1) {
          // Update existing
          existingUsers[existingIndex] = newUser;
        } else {
          // Add new
          existingUsers.add(newUser);
        }
      }

      // Save to assets dengan pretty print
      final assetsData = {
        'users': existingUsers,
        'last_updated': DateTime.now().toIso8601String(),
        'total_users': existingUsers.length,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(assetsData);
      await assetsFile.writeAsString(prettyJson);
    } catch (e) {
      // Don't throw - this is optional for development
    }
  }

  // ============================================
  // 4. Get User by Phone
  // ============================================
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final users = await loadUsers();
      return users.firstWhere(
        (user) => user['phone'] == phone,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 5. Get User by Username
  // ============================================
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final users = await loadUsers();
      return users.firstWhere(
        (user) => user['username'] == username,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 6. Get User by Email
  // ============================================
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final users = await loadUsers();
      return users.firstWhere(
        (user) => user['email'] == email,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 7. Delete User
  // ============================================
  Future<void> deleteUser(String phone) async {
    try {
      final users = await loadUsers();
      users.removeWhere((user) => user['phone'] == phone);
      await _saveUsersToFile(users);
      await _autoSaveToAssets(users);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 8. Update User
  // ============================================
  Future<void> updateUser(String phone, Map<String, dynamic> updates) async {
    try {
      final users = await loadUsers();
      final index = users.indexWhere((user) => user['phone'] == phone);

      if (index != -1) {
        users[index] = {...users[index], ...updates};
        users[index]['updated_at'] = DateTime.now().toIso8601String();
        await _saveUsersToFile(users);
        await _autoSaveToAssets(users);
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 9. Clear All Users (for testing)
  // ============================================
  Future<void> clearAllUsers() async {
    try {
      await _saveUsersToFile([]);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 10. Get File Path (for debugging)
  // ============================================
  Future<String> getUsersFilePath() async {
    final file = await _getLocalFile(_usersFileName);
    return file.path;
  }

  // ============================================
  // 11. Export Users as JSON String
  // ============================================
  Future<String> exportUsersAsJson() async {
    try {
      final users = await loadUsers();
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert({
        'users': users,
        'exported_at': DateTime.now().toIso8601String(),
        'total_users': users.length,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 12. Get Assets File Path
  // ============================================
  String getAssetsFilePath() {
    final projectPath = Directory.current.path;
    return '$projectPath/assets/data/users.json';
  }

  // ============================================
  // OTP Methods
  // ============================================

  Future<List<Map<String, dynamic>>> loadOtpSessions() async {
    try {
      final file = await _getLocalFile(_otpFileName);
      final contents = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(contents);

      final List<dynamic> otpList = jsonData['otp_sessions'] ?? [];
      return otpList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveOtpSession(Map<String, dynamic> otpSession) async {
    try {
      final sessions = await loadOtpSessions();
      sessions.removeWhere((s) => s['phone'] == otpSession['phone']);
      sessions.add(otpSession);

      final file = await _getLocalFile(_otpFileName);
      final jsonData = {
        'otp_sessions': sessions,
        'last_updated': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveAllUsers(List<Map<String, dynamic>> users) async {
    try {
      await _saveUsersToFile(users);
      await _autoSaveToAssets(users);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 13. Sync Users From Assets (for first launch)
  // ============================================
  Future<void> syncUsersFromAssets() async {
    if (kIsWeb) {
      return;
    }

    try {
      final projectPath = Directory.current.path;
      final assetsFile = File('$projectPath/assets/data/users.json');

      if (!await assetsFile.exists()) {
        return;
      }

      // Read from assets
      final assetsContent = await assetsFile.readAsString();
      final assetsJson = jsonDecode(assetsContent);

      if (assetsJson is Map && assetsJson.containsKey('users')) {
        final List<dynamic> usersList = assetsJson['users'];
        final users = usersList.cast<Map<String, dynamic>>();

        await _saveUsersToFile(users);
      }
    } catch (e) {}
  }
}
