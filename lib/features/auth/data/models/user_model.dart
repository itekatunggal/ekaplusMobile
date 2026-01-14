import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.username,
    required super.email,
    required super.phone,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.isSystem,
    required super.gender,
    required super.password,
    super.dateOfBirth,
    required super.placeOfBirth,
    required super.profilePic,

    required super.referralCode,
    super.referredBy,
    required super.address,
    required super.city,
    required super.province,
    required super.postalCode,
    required super.country,
    required super.googleId,
    required super.googleAccessToken,
    required super.googleRefreshToken,
    super.googleTokenExpiry,
    required super.role,
    required super.status,
    required super.workflowState,
    required super.tokenVersion,
    super.lastLogin,
    super.createdBy,
    super.updatedBy,
    required super.createdAt,
    required super.updatedAt,
  });

  static DateTime? _safeDate(dynamic v) {
    if (v == null) return null;

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    try {
      final dt = DateTime.parse(s);
      return dt.isUtc ? dt : dt.toUtc();
    } catch (_) {
      return null;
    }
  }

  static int _safeInt(dynamic v) {
    try {
      if (v == null) return 0;
      if (v is int) return v;
      return int.parse(v.toString());
    } catch (_) {
      return 0;
    }
  }

  static int? _safeNullableInt(dynamic v) {
    try {
      if (v == null) return null;
      if (v is int) return v;
      return int.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }

  factory UserModel.fromApiJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: _safeInt(json['id']),
        firstName: json['first_name'] ?? '',
        password: json['password'] ?? '',
        lastName: json['last_name'] ?? '',
        fullName: json['full_name'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',

        isEmailVerified: _safeBool(json['is_email_verified']),
        isPhoneVerified: _safeBool(json['is_phone_verified']),
        isSystem: _safeBool(json['is_system']),
        gender: json['gender'] ?? '',
        dateOfBirth: _safeDate(json['date_of_birth']),
        placeOfBirth: json['place_of_birth'] ?? '',
        profilePic: json['profile_pic'] ?? '',

        referralCode: json['referral_code'] ?? '',
        referredBy: _safeNullableInt(json['referred_by']),
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        province: json['province'] ?? '',
        postalCode: json['postal_code'] ?? '',
        country: json['country'] ?? '',
        googleId: json['google_id'] ?? '',
        googleAccessToken: json['google_access_token'] ?? '',
        googleRefreshToken: json['google_refresh_token'] ?? '',
        googleTokenExpiry: _safeDate(json['google_token_expiry']),
        role: json['role'] ?? '',
        status: _safeInt(json['status']),
        workflowState: json['workflow_state'] ?? '',
        tokenVersion: _safeInt(json['token_version']),
        lastLogin: _safeDate(json['last_login']),
        createdBy: _safeNullableInt(json['created_by']),
        updatedBy: _safeNullableInt(json['updated_by']),
        createdAt: _safeDate(json['created_at']) ?? DateTime.now(),
        updatedAt: _safeDate(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('UserModel.fromApiJson: $e');
    }
  }

  factory UserModel.fromLocalJson(Map<String, dynamic> json) {
    try {
      return UserModel.fromApiJson(json);
    } catch (e) {
      throw Exception('UserModel.fromLocalJson: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'password': password,
      'last_name': lastName,
      'full_name': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'is_system': isSystem,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toUtc().toIso8601String(),
      'place_of_birth': placeOfBirth,
      'profile_pic': profilePic,

      'referral_code': referralCode,
      'referred_by': referredBy,
      'address': address,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'country': country,
      'google_id': googleId,
      'google_access_token': googleAccessToken,
      'google_refresh_token': googleRefreshToken,
      'google_token_expiry': googleTokenExpiry?.toIso8601String(),
      'role': role,
      'status': status,
      'workflow_state': workflowState,
      'token_version': tokenVersion,
      'last_login': lastLogin?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      // 'created_at': createdAt.toIso8601String(),
      // 'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? username,
    String? password,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isSystem,
    String? gender,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? profilePic,
    String? picture,
    String? referralCode,
    int? referredBy,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    String? googleId,
    String? googleAccessToken,
    String? googleRefreshToken,
    DateTime? googleTokenExpiry,
    String? role,
    int? status,
    String? workflowState,
    int? tokenVersion,
    DateTime? lastLogin,
    int? createdBy,
    int? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isSystem: isSystem ?? this.isSystem,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      profilePic: profilePic ?? this.profilePic,

      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      googleId: googleId ?? this.googleId,
      googleAccessToken: googleAccessToken ?? this.googleAccessToken,
      googleRefreshToken: googleRefreshToken ?? this.googleRefreshToken,
      googleTokenExpiry: googleTokenExpiry ?? this.googleTokenExpiry,
      role: role ?? this.role,
      status: status ?? this.status,
      workflowState: workflowState ?? this.workflowState,
      tokenVersion: tokenVersion ?? this.tokenVersion,
      lastLogin: lastLogin ?? this.lastLogin,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
