import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String username;
  final String email;
  final String phone;

  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isSystem;

  final String gender;
  final DateTime? dateOfBirth;
  final String placeOfBirth;

  final String profilePic;

  final String referralCode;
  final int? referredBy;

  final String address;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String? password;

  final String googleId;
  final String googleAccessToken;
  final String googleRefreshToken;
  final DateTime? googleTokenExpiry;

  final String role;
  final int status;
  final String workflowState;
  final int tokenVersion;

  final DateTime? lastLogin;
  final int? createdBy;
  final int? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isSystem,
    required this.gender,
    this.dateOfBirth,
    required this.placeOfBirth,
    required this.profilePic,
    required this.referralCode,
    this.referredBy,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.password,
    required this.country,
    required this.googleId,
    required this.googleAccessToken,
    required this.googleRefreshToken,
    this.googleTokenExpiry,
    required this.role,
    required this.status,
    required this.workflowState,
    required this.tokenVersion,
    this.lastLogin,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isSystem,
    String? gender,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? profilePic,
    String? referralCode,
    int? referredBy,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? country,
    String? password,
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
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
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
      password: password ?? this.password,
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

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    fullName,
    username,
    email,
    phone,
    isEmailVerified,
    isPhoneVerified,
    isSystem,
    gender,
    dateOfBirth,
    placeOfBirth,
    profilePic,

    referralCode,
    referredBy,
    address,
    city,
    province,
    postalCode,
    country,
    password,
    googleId,
    googleAccessToken,
    googleRefreshToken,
    googleTokenExpiry,
    role,
    status,
    workflowState,
    tokenVersion,
    lastLogin,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
}
