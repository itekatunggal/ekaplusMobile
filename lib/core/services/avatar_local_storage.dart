// lib/core/services/avatar_local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class AvatarLocalStorage {
  static const String _avatarPathKey = 'local_avatar_path';
  static const String _avatarBgColorKey = 'local_avatar_bg_color';
  static const String _originalProfilePicKey = 'original_profile_pic';

  /// Save avatar path and background color to local storage
  static Future<void> saveLocalAvatar({
    required String avatarPath,
    required String bgColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPathKey, avatarPath);
    await prefs.setString(_avatarBgColorKey, bgColor);
  }

  /// Get local avatar path
  static Future<String?> getLocalAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarPathKey);
  }

  /// Get local avatar background color
  static Future<String?> getLocalAvatarBgColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarBgColorKey);
  }

  /// Clear local avatar data
  static Future<void> clearLocalAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarPathKey);
    await prefs.remove(_avatarBgColorKey);
  }

  /// Check if local avatar exists
  static Future<bool> hasLocalAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_avatarPathKey);
    return path != null && path.isNotEmpty;
  }

  /// Save original profile pic before using local avatar
  static Future<void> saveOriginalProfilePic(String profilePic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_originalProfilePicKey, profilePic);
  }

  /// Get original profile pic
  static Future<String?> getOriginalProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_originalProfilePicKey);
  }

  /// Clear original profile pic
  static Future<void> clearOriginalProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_originalProfilePicKey);
  }
}
