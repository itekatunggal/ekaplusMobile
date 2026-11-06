import 'dart:convert';

class SocialRegistrationValidator {
  static const _reservedUsernames = <String>{
    'admin',
    'administrator',
    'root',
    'system',
    'support',
    'api',
    'www',
    'mail',
    'help',
    'official',
    'user',
    'guest',
    'null',
    'undefined',
    'ekaplus',
    'ekatunggal',
  };

  const SocialRegistrationValidator._();

  static String? username(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) return 'Username harus diisi';
    if (username.length < 3 || username.length > 30) {
      return 'Username harus terdiri dari 3–30 karakter';
    }
    if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(username)) {
      return 'Gunakan huruf, angka, titik, atau underscore tanpa spasi';
    }
    if (_reservedUsernames.contains(username.toLowerCase())) {
      return 'Username tersebut tidak dapat digunakan';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password harus diisi';
    if (password.length < 6) return 'Password minimal 6 karakter';
    if (utf8.encode(password).length > 72) {
      return 'Password maksimal 72 byte UTF-8';
    }
    return null;
  }

  static String? confirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (value != password) return 'Konfirmasi password tidak sama';
    return null;
  }
}
